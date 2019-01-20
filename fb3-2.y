%{
#  include <stdio.h>
#  include <stdlib.h>
#  include "fb3-2.h"
%}


%token EOL
%token IDENTIFIER

%%

boot:	/*nothing*/
	| boot EOL
;



%%

yyerror(char *s)
{
  fprintf(stderr, "error: %s\n", s);
}
