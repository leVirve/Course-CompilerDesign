%{
    #include "y.tab.h"
    int lines = 1;
    void clear();
    void print();
    void prints();
    void print_sub();
%}
datatype        int|double|char
identifier      [a-zA-Z_][a-zA-Z0-9_]*
operators       [+\-*/=<>]
symbol          [(){}',;\"]
number          0|[1-9][0-9]*
realnumber      (0|[1-9][0-9]*)\.[0-9]*
%x COMMENT

%%
"//"[^\n]*              prints("comment");
"/*"                    BEGIN COMMENT;
<COMMENT>\n             { prints("comment"); lines++; }
<COMMENT>"*/"           { prints("comment"); BEGIN INITIAL; }
<COMMENT>.              ;
\n                      lines++;
return                  { print(""); return RETURN; }
{symbol}                { print(""); return yytext[0]; }
{operators}             { print("operator   : "); return yytext[0]; }
{number}|{realnumber}   { print("number     : "); return NUMBER; }
{datatype}              { print("data type  : "); return TYPE; }
{identifier}            { print("variable ID: "); return IDENTIFIER; }
'./'                    { prints("'"); prints("character  : %c", yytext[1]); return CHAR; }
{identifier}/\(         { print("function ID: "); return FUNCTION_IDENTIFIER; }
{identifier}/=          { print("variable ID: "); return IDENTIFIER; }
.                       ;
%%

void clear() { yytext[0] = '\0'; }
void print(char *format)           { printf("#%-2d %s%s\n", lines, format, yytext); }
void prints(char *p, char* args[]) { printf("#%-2d ", lines); printf(p, args); putchar('\n'); }

