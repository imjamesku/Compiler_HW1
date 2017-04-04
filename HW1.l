%{
#include <stdio.h>
int num_lines;
%}
%x comment
%%
"/*"	{
	BEGIN(comment);
	}
<comment>"*/"	{
	BEGIN(INITIAL);
	}
\n	{
		num_lines++;
	}
void|int|double|bool|char|null|for|while|do|if|else|switch|return|break|continue|const|true|false|struct|case|default	{
		printf("#key:%s\n", yytext);
	}
%%
int main(int argc, char* argv[]){
	--argc;
	++argv;
	printf("arc = %d\n", argc);
	printf("arcv[0] = %s\n", argv[0]);
	if(argc > 0)
		yyin = fopen(argv[0], "r");
	else
		yyin = stdin;
	yylex();
	printf("#num_lines = %d\n", num_lines);
	return 0;
}

