%{
#  include <stdio.h>
#  include <stdlib.h>
#  include "fb3-2.h"

temp_parse scratch;

%}

%union {
	number_tok number;
	int a;
}

%token <number> NUMBER
%token EOL

%%

boot:	/*nothing*/
	| boot EOL
;



%%

yyerror(char *s)
{
  fprintf(stderr, "error: %s\n", s);
}
