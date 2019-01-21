/* just like Unix wc */
%{
%}

/* identifier token */
DIGIT [0-9]
DIGIT16 [0-9a-fA-F]
HEX_SCALAR {DIGIT16}+

LETTER [a-zA-Z]
INITIAL {LETTER}|[!$%&*/:<=>?~_^]
SUBSEQUENT {INITIAL}|{DIGIT}|"."|"+"|"-"|"@"
IDENTIFIER {INITIAL}{SUBSEQUENT}*|"+"|"-"|"..."

/* string token */
STRINGCHARATER (\\\")|(\\\\)

%x STRING_MODE

%%
{IDENTIFIER}		{ printf("identifier"); }
\"					{ printf("string mode"); BEGIN STRING_MODE;}
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
