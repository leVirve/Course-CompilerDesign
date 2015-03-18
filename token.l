%{
    int lines = 1;
    char comment_block = 0;
%}
datatype        int|double|char
identifier      [a-zA-Z_][a-zA-Z0-9_]*
operators [+\-*/=]
space [ \t\n]
number 0|[1-9][0-9]*
realnumber (0|[1-9][0-9]*)\.[0-9]*
char '.'
%Start COMMENT DECLARE FUNC ASSIGN

%%
"/*"                    { BEGIN(COMMENT); comment_block = 1; }
<COMMENT>[^*\n]*        ;
<COMMENT>"*"+[^*/\n]*   ;
<COMMENT>\n             printf("#%-2d comment\n", lines++);
<COMMENT>"*/"           { 
        if(comment_block) {
            printf("#%-2d comment\n", lines);
            comment_block = 0;
        } 
        BEGIN INITIAL;
    }
{char}                  {
        yytext[yyleng - 1] = '\0';
        printf("#%-2d '\n", lines);
        printf("#%-2d character  : %s\n", lines, (yytext + 1));
        unput('\'');
}
"//"+[^\n]*             printf("#%-2d comment\n", lines);
\n                      ++lines;
"return"                printf("#%-2d return\n", lines);

{datatype}              {
        printf("#%-2d data type  : %s\n", lines, yytext);
}
{identifier}\( {
        yytext[yyleng - 1] = '\0';
        printf("#%-2d function ID: %s\n", lines, yytext);
        unput('(');
}
{identifier}=  {
        yytext[yyleng - 1] = '\0';
        printf("#%-2d variable ID: %s\n", lines, yytext);
        unput('=');
}
{identifier}            printf("#%-2d variable ID: %s\n", lines, yytext);

[(){}',;]              printf("#%-2d %s\n", lines, yytext);
{operators}             printf("#%-2d operator   : %s\n", lines, yytext);
{number}|{realnumber}   printf("#%-2d number     : %s\n", lines, yytext);
{space}                 ;
%%

int main()
{
    yylex();
    return 0;
}
