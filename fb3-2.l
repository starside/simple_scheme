/* just like Unix wc */
%{
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

EXACTNESS (#(i|I)|#(e|E)){0,1}

PREFIX2  {RADIX2}{EXACTNESS}|{EXACTNESS}{RADIX2}
PREFIX8  {RADIX8}{EXACTNESS}|{EXACTNESS}{RADIX8}
PREFIX10 {EXACTNESS}|{EXACTNESS}
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

%x STRING_MODE

%%
{NUM}/{DELIMETER}				{ printf("number, ");}
{IDENTIFIER}/{DELIMETER}		{ printf("identifier"); }
{BOOLEAN}/{DELIMETER}			{ printf(" bool "); }
{CHARACTER}/{DELIMETER}			{ printf(" CHARACTER "); }
{STRING}						{ printf(" string "); }
{DELIMETER}						{printf(" delim ");}
#\(|,@|#'|#`|#,|#,@				{printf(" compound_lexeme ");}
[()\[\]'`,.]					{ printf(" simple_lexeme "); }
[ \t]+							/* ignore space */
.								{ printf("Unknown token"); }

<STRING_MODE>[^"\\]*								{ printf("any string char, "); }
<STRING_MODE>\\\"|\\\\|\\a|\\b|\\f|\\n|\\r|\\t|\\v	{ printf("escape, "); }
<STRING_MODE>\\x{HEX_SCALAR};						{ printf("Hex Scalar, "); }
<STRING_MODE>\\[ \t]*[\n\r]+[ \t]*					/* Absorb whitespace */
<STRING_MODE>\"					{	printf("END STRING_MODE"); 
									BEGIN INITIAL;}
<STRING_MODE>.					{ printf("wut?"); }
%%
