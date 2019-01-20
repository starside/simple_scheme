/* just like Unix wc */
%{
%}

DIGIT [0-9]
LETTER [a-zA-Z]
INITIAL {LETTER}|[!$%&*/:<=>?~_^]
SUBSEQUENT {INITIAL}|{DIGIT}|"."|"+"|"-"
IDENTIFIER {INITIAL}{SUBSEQUENT}*|"+"|"-"|"..."

%%
{IDENTIFIER}	{ printf("identifier"); }
{INITIAL}	{ printf("Initial"); }
{DIGIT}	{ printf("Digit"); }
{SUBSEQUENT}    { printf("subsequent"); }
%%
