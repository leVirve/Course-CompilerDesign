%{
    int lines = 1;
    void clear();
    void print();
    void print_sub();
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
"#include".*            { clear(); print("include header file\n", lines); }
for\(                   { clear(); print_sub("for-loop"); }
return                  print("");
{symbol}                print("");
{operators}             print("operator   : ");
{number}|{realnumber}   print("number     : ");
{datatype}              print("data type  : ");
{identifier}            print("variable ID: ");
{character}             { printf("#%-2d '\n#%-2d character  : %c\n", lines, lines, yytext[1]); unput('\''); }
{identifier}\(          { print_sub("function ID: "); unput('('); }
{identifier}=           { print_sub("variable ID: "); unput('='); }
.                       ;
%%

void clear() { yytext[0] = '\0'; }
void print(char *format) { printf("#%-2d %s%s\n", lines, format, yytext); }
void print_sub(char *format) { printf("#%-2d %s%.*s\n", lines, format, yyleng - 1, yytext); }

int main()
{
    yylex();
    return 0;
}
