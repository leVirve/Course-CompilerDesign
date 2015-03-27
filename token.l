%{
    int lines = 1;
%}
datatype        int|double|char
identifier      [a-zA-Z_][a-zA-Z0-9_]*
operators       [+\-*/=<>]|"++"|"--"|"<="|">="
symbol          [(){}',;]
number          0|[1-9][0-9]*
realnumber      (0|[1-9][0-9]*)\.[0-9]*
character       '.'
%x COMMENT

%%
"/*"                    BEGIN COMMENT;
<COMMENT>\n             printf("#%-2d comment\n", lines++);
<COMMENT>.              ;
<COMMENT>"*/"           { printf("#%-2d comment\n", lines); BEGIN INITIAL; } 
"//"+[^\n]*             printf("#%-2d comment\n", lines);
\n                      ++lines;
return                  printf("#%-2d return\n", lines);
"#include".*            printf("#%-2d include header file\n", lines);
for\(                   printf("#%-2d for-loop   : %.*s\n", lines, yyleng - 1, yytext);
{symbol}                printf("#%-2d %s\n", lines, yytext);
{operators}             printf("#%-2d operator   : %s\n", lines, yytext);
{number}|{realnumber}   printf("#%-2d number     : %s\n", lines, yytext);
{datatype}              printf("#%-2d data type  : %s\n", lines, yytext);
{character}             { printf("#%-2d '\n#%-2d character  : %c\n", lines, lines, yytext[1]); unput('\''); }
{identifier}\(          { printf("#%-2d function ID: %.*s\n", lines, yyleng - 1, yytext); unput('('); }
{identifier}=           { printf("#%-2d variable ID: %.*s\n", lines, yyleng - 1, yytext); unput('='); }
{identifier}            printf("#%-2d variable ID: %s\n", lines, yytext);
.                       ;
%%

int main()
{
    yylex();
    return 0;
}
