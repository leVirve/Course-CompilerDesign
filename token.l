%{
    int lines = 1;
    void clear();
    void print();
    void prints();
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
"//"+[^\n]*             prints("comment");
"/*"                    BEGIN COMMENT;
<COMMENT>\n             { prints("comment"); lines++; }
<COMMENT>"*/"           { prints("comment"); BEGIN INITIAL; } 
<COMMENT>.              ;
\n                      lines++;
"#include".*            { clear(); print("include header file"); }
for\(                   { clear(); print_sub("for-loop"); }
return                  print("");
{symbol}                print("");
{operators}             print("operator   : ");
{number}|{realnumber}   print("number     : ");
{datatype}              print("data type  : ");
{identifier}            print("variable ID: ");
{character}             { prints("'"); prints("character  : %c", yytext[1]); unput('\''); }
{identifier}\(          { print_sub("function ID: "); unput('('); }
{identifier}=           { print_sub("variable ID: "); unput('='); }
.                       ;
%%

void clear() { yytext[0] = '\0'; }
void prints(char *p, char* args[]) { printf("#%-2d ", lines); printf(p, args); putchar('\n'); }
void print(char *format)           { printf("#%-2d %s%s\n", lines, format, yytext); }
void print_sub(char *format)       { printf("#%-2d %s%.*s\n", lines, format, yyleng - 1, yytext); }

int main()
{
    yylex();
    return 0;
}
