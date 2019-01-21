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

EXACTNESS #(i|I)|#(e|E)

PREFIX2  {RADIX2}{EXACTNESS}{0,1}|{EXACTNESS}{0,1}{RADIX2}
PREFIX8  {RADIX8}{EXACTNESS}{0,1}|{EXACTNESS}{0,1}{RADIX8}
PREFIX10 {EXACTNESS}{0,1}|{EXACTNESS}{0,1}
PREFIX16 {RADIX16}{EXACTNESS}{0,1}|{EXACTNESS}{0,1}{RADIX16}

/* identifier token */
LETTER [a-zA-Z]
INITIAL {LETTER}|[!$%&*/:<=>?~_^]
SUBSEQUENT {INITIAL}|{DIGIT}|"."|"+"|"-"|"@"
IDENTIFIER {INITIAL}{SUBSEQUENT}*|"+"|"-"|"..."

/* string token */
STRINGCHARATER (\\\")|(\\\\)

%x STRING_MODE

%%
{PREFIX2}			{printf("PREFIX2");}
{IDENTIFIER}		{ printf("identifier"); }
\"					{ printf("string mode, "); BEGIN STRING_MODE;}
[ \t]*				/* ignore whitespace */
.					{ printf("Unknown token"); }

<STRING_MODE>[^"\\]*								{ printf("any string char, "); }
<STRING_MODE>\\\"|\\\\|\\a|\\b|\\f|\\n|\\r|\\t|\\v	{ printf("escape, "); }
<STRING_MODE>\\x{HEX_SCALAR};						{ printf("Hex Scalar, "); }
<STRING_MODE>\\[ \t]*[\n\r]+[ \t]*					/* Absorb whitespace */
<STRING_MODE>\"					{	printf("END STRING_MODE"); 
									BEGIN INITIAL;}
<STRING_MODE>.					{ printf("wut?"); }
%%
