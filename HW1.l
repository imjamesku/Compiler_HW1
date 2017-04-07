%{
#include <stdio.h>
#define MAX_STR_CONST 2048
int num_lines, char_counter;
char string_buf[MAX_STR_CONST];
char *string_buf_ptr;
%}
%x comment
%x string
%x char_condition
%%
"/*"	{
		BEGIN(comment);
	}
<comment>"*/"	{
		BEGIN(INITIAL);
	}
\"	{/*starting quote*/
		string_buf_ptr = string_buf;
		BEGIN(string);
	}
<string>{
	\"	{/*closing quote*/
			BEGIN(INITIAL);
			string_buf_ptr = '\0';
			printf("#string:%s\n", string_buf);
		}
	\n	{/*error - unterminated string constant*/

	}
	\\[0-7]{1,3}	{
		/*octal escape sequence*/
		int result;
		(void) sscanf(yytext + 1, "%o", &result);
		if(result > 0xff){
			/*error, out of bound*/
		}
		*string_buf_ptr++ = result;
	}
	\\[0-9]+	{
		/*generate error - bad sequence
		something like \48 (larger than 8) or \077777*/
	}
	\\n	{	*string_buf_ptr++ = '\\';
			*string_buf_ptr++ = 'n';
			
	}
	\\t	{	*string_buf_ptr++ = '\\';
			*string_buf_ptr++ = 't';
			
	}
	\\r	*string_buf_ptr++ = '\r';
	\\b	*string_buf_ptr++ = '\b';
	\\f	*string_buf_ptr++ = '\f';
	\\(.|\n)	*string_buf_ptr++ = yytext[1];
	[^\\\n\"]+	{
		char* yptr = yytext;
		while(*yptr){
			*string_buf_ptr++ = *yptr++;
		}
	}
}

\'	{
	BEGIN(char_condition);
	char_counter = 0;
}
<char_condition>{
	/*If char_counter>=1 error, there should be only 1 char in the quote.*/
	\'	{
		BEGIN(INITIAL);
	}
	[ -~]	{
		printf("#char:%c\n", yytext[0]);
		char_counter++;
	}
	\\n	{
		printf("#char:\\n\n");
		char_counter++;
	}
	\\t	{
		printf("#char:\\t\n");
		char_counter++;
	}
	/*\\r	printf("#char:%c\n", '\r');
	\\b	printf("#char:%c\n", '\b');
	\\f	printf("#char:%c\n", '\f');*/
}

\n	{
/*new line*/
	num_lines++;
	printf("-------line %d-------\n", num_lines);
}
" "	{
/*space*/
}
\t	{
/*tabs*/
}
void|int|double|bool|char|null|for|while|do|if|else|switch|return|break|continue|const|true|false|struct|case|default	{
	printf("#key:%s\n", yytext);
}
":"|";"|","|"."|"("|")"|"["|"]"|"{"|"}"	{
	printf("#punc:%s\n", yytext);
}
"+"|"-"|"*"|"/"|"%"|"++"|"--"|"<"|"<="|">"|">"|">="|"=="|"!="|"="|"&&"|"||"|"!"|"*"|"&"	{
	printf("#op:%s\n", yytext);
}
[0-9]+	{
/*Intergers*/
	printf("#int:%s\n", yytext);
}
[0-9]+\.[0-9]+	{
/*doubles*/
	printf("#double:%s\n", yytext);
}
[0-9]+(\.[0-9]+)?[eE][+-]?[0-9]+	{
/*scientific notation*/
	printf("#sci:%s\n", yytext);
}
[a-zA-Z_][a-zA-Z0-9_]*	{
/*identifiers*/
	printf("#id:%s\n", yytext);
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

