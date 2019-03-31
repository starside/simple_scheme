/* just like Unix wc */
%option yylineno
%option stack

%{
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include "fb3-2.h"
#include "fb3-2.tab.h"

extern temp_parse scratch;

int complex_state = 0;
number_tok complex_num;
real_tok real_num;

enum sign_tok real_get_sign(char c) {
    assert(c == '+' || c == '-');
    switch(c) {
        case '+':
            return plus;
        case '-':
            return minus;
    };
    return sign_err;
}

void ClearRealNum() {
    memset(&real_num, 0, sizeof(real_num));
}

void print_realnum() {
    char sign;
    switch(real_num.sign) {
        case plus:
            sign = '+';
            break;
        case minus:
            sign = '-';
            break;
        default:
            sign = 'E';
    };
    switch(real_num.inf){
        case inf:
            printf("DEBUG: Real number is %cinf\n", sign);
            break;
        case nan:
            printf("DEBUG: Real number is %cnan\n", sign);
            break;
        default:
            printf("DEBUG: Real number is %c %u / %u", sign, 
            real_num.ureal.numerator, real_num.ureal.denominator);
    };
}

#define COMPLEX_COMPONENT_BEGIN() {\
    yy_push_state(COMPLEX_MODE);\
    BEGIN REAL2_MODE;\
}

#define PUSH_STATE(s) yy_push_state(s)

#define POP_STATE() yy_pop_state();

#define SET_RADIX(r) yylval.number.prefix.radix=r

#define NOP() unput(yytext[0])

#define ENTER_NUMBER(rad, ex) {             \
    memset(&yylval, 0, sizeof(yylval));     \
    memset(&scratch, 0, sizeof(scratch));   \
    scratch.real.sign = plus;               \
    yylval.number.prefix.radix=rad;         \
    yylval.number.prefix.exactness=ex;      \
    switch(rad) {                           \
        case r2:                            \
            PUSH_STATE(COMPLEX_MODE_COMP1); \
            break;                          \
        default:                            \
            BEGIN REAL_MODE;                \
        };                                  \
    }

enum sign_tok get_sign(char s) {
    switch(s){
        case '+':
            return plus;
        case '-':
            return minus;
    }
    return plus;
} 

void err() {
    printf("Error");
}



%}

/* Numbers */
DIGIT [0-9]
DIGIT2 0|1
DIGIT8 [0-7]
DIGIT10 {DIGIT}
DIGIT16 [0-9a-fA-F]
HEX_SCALAR {DIGIT16}+

RADIX2 #(b|B)
RADIX8 #(o|O)
RADIX10 /*empty*/
RADIX16 #(x|X)

UINTEGER2 {DIGIT2}+
UINTEGER8 {DIGIT8}+
UINTEGER10 {DIGIT10}+
UINTEGER16 {DIGIT16}+

EX_I #(i|I)
EX_E #(e|E)
EXACTNESS1 {EX_I}|{EX_E}
EXACTNESS {EXACTNESS1}{0,1}

PREFIX2  {RADIX2}{EXACTNESS}|{EXACTNESS}{RADIX2}
PREFIX8  {RADIX8}{EXACTNESS}|{EXACTNESS}{RADIX8}
PREFIX10 {EXACTNESS}
PREFIX16 {RADIX16}{EXACTNESS}|{EXACTNESS}{RADIX16}

SIGN [+-]{0,1}
EXPONENTMARKER [esfdlESFDL]
EXPONENT ({EXPONENTMARKER}{SIGN}{DIGIT10}+){0,1}
MANTISSAWIDTH (\|{DIGIT10}+){0,1}
SUFFIX {EXPONENT}

DECIMAL10 {UINTEGER10}{SUFFIX}|\.{DIGIT10}+{SUFFIX}|{DIGIT10}+\.{DIGIT10}*{SUFFIX}

UREAL2 {UINTEGER2}|{UINTEGER2}\/{UINTEGER2}
UREAL8 {UINTEGER8}|{UINTEGER8}\/{UINTEGER8}
UREAL10 {UINTEGER10}|{UINTEGER10}\/{UINTEGER10}|{DECIMAL10}{MANTISSAWIDTH}
UREAL16 {UINTEGER16}|{UINTEGER16}\/{UINTEGER16}

NANINF "nan\.0"|"inf\.0"

REAL2 {SIGN}{UREAL2}|[+-]{NANINF}
REAL8 {SIGN}{UREAL8}|[+-]{NANINF}
REAL10 {SIGN}{UREAL10}|[+-]{NANINF}
REAL16 {SIGN}{UREAL16}|[+-]{NANINF}

COMPLEX2 {REAL2}|{REAL2}@{REAL2}|{REAL2}[+-]{UREAL2}i|{REAL2}[+-]{NANINF}i|{REAL2}[+-]i|[+-]{UREAL2}i|[+-]{NANINF}i|[+-]i
COMPLEX8 {REAL8}|{REAL8}@{REAL8}|{REAL8}[+-]{UREAL8}i|{REAL8}[+-]{NANINF}i|{REAL8}[+-]i|[+-]{UREAL8}i|[+-]{NANINF}i|[+-]i
COMPLEX10 {REAL10}|{REAL10}@{REAL10}|{REAL10}[+-]{UREAL10}i|{REAL10}[+-]{NANINF}i|{REAL10}[+-]i|[+-]{UREAL10}i|[+-]{NANINF}i|[+-]i
COMPLEX16 {REAL16}|{REAL16}@{REAL16}|{REAL16}[+-]{UREAL16}i|{REAL16}[+-]{NANINF}i|{REAL16}[+-]i|[+-]{UREAL16}i|[+-]{NANINF}i|[+-]i

NUM2 {PREFIX2}{COMPLEX2}
NUM8 {PREFIX8}{COMPLEX8}
NUM10 {PREFIX10}{COMPLEX10}
NUM16 {PREFIX16}{COMPLEX16}

NUM {NUM2}|{NUM8}|{NUM10}|{NUM16}

DELIMETER [\[\] \t\n\r()";#]

/* identifier token */
LETTER [a-zA-Z]
INITIAL {LETTER}|[!$%&*/:<=>?~_^]
SUBSEQUENT {INITIAL}|{DIGIT}|"."|"+"|"-"|"@"
IDENTIFIER {INITIAL}{SUBSEQUENT}*|"+"|"-"|"..."

/* string token */
STRINGCHARATER [^"\\]|\\\"|\\\\|\\a|\\b|\\f|\\n|\\r|\\t|\\v|\\x{HEX_SCALAR};|\\[ \t]*[\n\r]+[ \t]*
STRING \"{STRINGCHARATER}*\"

BOOLEAN #t|#T|#f|#F

CHARACTERNAME nul|alarm|backspace|tab|linefeed|newline|vtab|page|return|esc|space|delete
CHARACTER #\\{CHARACTERNAME}|#\\x{HEX_SCALAR}|#\\.

RADIX10_START [0-9+-]

%x STRING_MODE
%x REAL_MODE
%x REAL2_MODE_SIGN
%x REAL2_MODE
%x COMPLEX2_MODE
%x COMPLEX_MODE
%x REAL2_MODE_UREAL_DEN
%x REAL2_MODE_DEN_B
%x REAL2_MODE_DEN
%x REAL2_MODE_NUM
%x COMPLEX_MODE_COMP1
%x COMPLEX_MODE_COMP1_I
%x COMPLEX_MODE_COMP2

%%
    /* Check for numbers */

    /* Is is RADIX2 */
{RADIX2}{EX_I}          {ENTER_NUMBER(r2, i);}
{EX_I}{RADIX2}          {ENTER_NUMBER(r2, i);}
{RADIX2}{EX_E}          {ENTER_NUMBER(r2, e);}
{EX_E}{RADIX2}          {ENTER_NUMBER(r2, e);}
{RADIX2}/[01+-]         {ENTER_NUMBER(r2, d);}

    /* Is radix 8 */
{RADIX8}{EX_I}          {ENTER_NUMBER(r8, i);}
{EX_I}{RADIX8}          {ENTER_NUMBER(r8, i);}
{RADIX8}{EX_E}          {ENTER_NUMBER(r8, e);}
{EX_E}{RADIX8}          {ENTER_NUMBER(r8, e);}
{RADIX8}/[0-7+-]        {ENTER_NUMBER(r8, d);}

    /* Is Radix 10 */
{EX_I}{RADIX10_START}   {ENTER_NUMBER(r10, i);}
{EX_E}{RADIX10_START}   {ENTER_NUMBER(r10, e);}
{RADIX10_START}         {ENTER_NUMBER(r10, d);}

    /* Is RADIX 16 */
{RADIX16}{EX_I}         {ENTER_NUMBER(r16, i);}
{EX_I}{RADIX16}         {ENTER_NUMBER(r16, i);}
{RADIX16}{EX_E}         {ENTER_NUMBER(r16, e);}
{EX_E}{RADIX16}         {ENTER_NUMBER(r16, e);}
{RADIX16}/[0-9a-fA-F+-] {ENTER_NUMBER(r16, d);}

    /* Pick that ripe, low-hanging fruit */
<COMPLEX_MODE>[+-]?/[01]                        { 
                                                    switch(complex_state) {
                                                        case 0:
                                                            memset(&complex_num, 0, sizeof(complex_num));
                                                            break;
                                                        case 1:
                                                            break;                                        
                                                        default:
                                                            err();
                                                    };
                                                    if(yyleng > 0) unput(yytext[0]);   
                                                    printf(" complex_state=%d ", complex_state);
                                                    COMPLEX_COMPONENT_BEGIN(); 
                                                }
<COMPLEX_MODE>[+-]i                             { complex_state++; printf(",+-i,"); }
<COMPLEX_MODE>i                                 { printf(",i,"); }
<COMPLEX_MODE>{DELIMETER}                       { printf("Done complex"); }
<COMPLEX_MODE>.                                 { printf("Error: Unknown token"); }

    /* Complex component 1 entry point */
<COMPLEX_MODE_COMP1>[+-]i   {
        // Zero out complex number
        memset(&complex_num, 0, sizeof(complex_num));
        complex_num.re_im[1].ureal.numerator = 1;
        complex_num.re_im[1].sign = real_get_sign(yytext[0]);
        POP_STATE();
    }
<COMPLEX_MODE_COMP1>.    {
        NOP();
        // Zero out complex number
        memset(&complex_num, 0, sizeof(complex_num));
        PUSH_STATE(COMPLEX_MODE_COMP1_I);
        PUSH_STATE(REAL2_MODE);
    }

<COMPLEX_MODE_COMP1_I>i {
    print_realnum();
    printf("DEBUG:COMPLEX_MODE_COMP1_I Number is imaginary\n");
    POP_STATE();
}
<COMPLEX_MODE_COMP1_I>{DELIMETER} {
    print_realnum();
    printf("DEBUG:COMPLEX_MODE_COMP1_I Number is real\n");
    POP_STATE();
}
<COMPLEX_MODE_COMP1_I>[+-] {
    NOP();
    printf("DEBUG:COMPLEX_MODE_COMP1_I There is another component to read!\n");
    POP_STATE(); // Exit COMPLEX_MODE_COMP1
    PUSH_STATE(COMPLEX_MODE_COMP2);
    PUSH_STATE(REAL2_MODE);
}
<COMPLEX_MODE_COMP1_I>. {
    printf("Error of some sort!");
    POP_STATE();
}

<COMPLEX_MODE_COMP2>i{DELIMETER} {
    printf("DEBUG: Detected complex number\n");
    POP_STATE();
}

<COMPLEX_MODE_COMP2>. {
    printf("DEBUG: Invalid complex number");
    POP_STATE();
}


    /* Real2 mode entry point */
<REAL2_MODE>.                                   {   
                                                    // Zero out real_num and set the base to 2
                                                    ClearRealNum(); 
                                                    real_num.base = r2;

                                                    // Do not consume byte in the entry point
                                                    NOP(); 
                                                    BEGIN REAL2_MODE_SIGN; 
                                                }
    /* Pick out sign from real number, as well as nan and inf */
<REAL2_MODE_SIGN>[01]                           {
                                                    // No sign interpreted as +
                                                    unput(yytext[0]);
                                                    unput('+');
                                                }
    /* REAL2_MODE_SIGN State */
<REAL2_MODE_SIGN>[+-]/[01]                      {
                                                    real_num.sign = real_get_sign(yytext[0]);
                                                    // Read in numerator
                                                    BEGIN REAL2_MODE_NUM; 
                                                }
<REAL2_MODE_SIGN>[+-]nan\.0                     {
                                                    real_num.sign = real_get_sign(yytext[0]);
                                                    real_num.inf = nan;
                                                    // Done reading real number
                                                    POP_STATE();
                                                }
<REAL2_MODE_SIGN>[+-]inf\.0                     {
                                                    real_num.sign = real_get_sign(yytext[0]);
                                                    real_num.inf = inf;
                                                    // Done reading real number
                                                    POP_STATE();
                                                }                                                
<REAL2_MODE_SIGN>.                              {
                                                    printf("err %d", (int)yytext[0]);
                                                }

    /* REAL2_MOD_NUM state.  Read in numerator */
<REAL2_MODE_NUM>[01]+/\/                { 
                                           real_num.ureal.numerator = strtoull(yytext, NULL, 2);
                                           // Expect Denominator to follow
                                           BEGIN REAL2_MODE_DEN;
                                        }
<REAL2_MODE_NUM>[01]+                   {
                                            real_num.ureal.numerator = strtoull(yytext, NULL, 2);
                                            // Denominator implicit 1.  Done
                                            real_num.ureal.denominator = 1;
                                            POP_STATE();
                                        }
<REAL2_MODE_NUM>.                       {printf("Unknown numerator");}
    /* REAL2_mode_DEN State to consume residual / */
<REAL2_MODE_DEN>\/                      {
                                            // Consume the /
                                            BEGIN REAL2_MODE_DEN_B;
                                        }
    /* REAL2_MODE_DEN Read in denominator */
<REAL2_MODE_DEN>.                       {printf(" Error in REAL2_MODE_DEN");}

<REAL2_MODE_DEN_B>[01]+                 {
                                            // Read denominator.  Done 
                                            real_num.ureal.denominator = strtoull(yytext, NULL, 2);
                                            POP_STATE();
                                        }
<REAL2_MODE_DEN_B>.                             {printf("Error"); } 

<REAL_MODE>.*                                   {printf("in num mode");}


{IDENTIFIER}/{DELIMETER}        { printf("identifier"); }
{BOOLEAN}/{DELIMETER}           { printf(" bool "); }
{CHARACTER}/{DELIMETER}         { printf(" CHARACTER "); }
{STRING}                        { printf(" string "); }
{DELIMETER}                     { printf(" delim "); }
#\(|,@|#'|#`|#,|#,@             {printf(" compound_lexeme ");}
[()\[\]'`,.]                    { printf(" simple_lexeme "); }
[ \t]+                          /* ignore space */
.                               { printf("Unknown token"); }

<STRING_MODE>[^"\\]*                                { printf("any string char, "); }
<STRING_MODE>\\\"|\\\\|\\a|\\b|\\f|\\n|\\r|\\t|\\v  { printf("escape, "); }
<STRING_MODE>\\x{HEX_SCALAR};                       { printf("Hex Scalar, "); }
<STRING_MODE>\\[ \t]*[\n\r]+[ \t]*                  /* Absorb whitespace */
<STRING_MODE>\"                 {   printf("END STRING_MODE"); 
                                    BEGIN INITIAL;}
<STRING_MODE>.                  { printf("wut?"); }
%%
