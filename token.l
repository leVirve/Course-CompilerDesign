%{
    int lines = 1;
    char comment_block = 0;
%}
identifier  int|double|char
word  [a-zA-Z][a-zA-Z0-9_]*
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
<COMMENT>\n             printf("#%d comment\n", ++lines);
<COMMENT>"*/"           { 
        if(comment_block) {
            printf("#%d comment\n", lines);
            comment_block = 0;
        } 
        BEGIN INITIAL;
    }
"//"+[^\n]*             printf("#%d comment\n", lines);

\n                      ++lines;

<INITIAL>{identifier}   {
        printf("#%d data type  : %s\n", lines, yytext);
        BEGIN(DECLARE);
}
<DECLARE>{word}\(       {
        yytext[yyleng - 1] = '\0';
        printf("#%d function ID: %s\n", lines, yytext);
        unput('(');
        BEGIN(FUNC);
}
<DECLARE>")"            BEGIN INITIAL;
<DECLARE>{word}=        {
        yytext[yyleng - 1] = '\0';
        printf("#%d variable ID: %s\n", lines, yytext);
        unput('=');
        BEGIN(FUNC);
}
<DECLARE>";"            BEGIN INITIAL;
<FUNC>{identifier}      printf("#%d data type  : %s\n", lines, yytext);
<FUNC>{word}            printf("#%d variable ID: %s\n", lines, yytext);


[(){},;]                printf("#%d %s\n", lines, yytext);
{operators}             printf("#%d operator   : %s\n", lines, yytext);
{number}|{realnumber}   printf("#%d number     : %s\n", lines, yytext);
{char}                  printf("#%d char       : %s\n", lines, yytext);
{space}                 ;
return                  printf("#%d return\n", lines);
%%

int main()
{
    yylex();
    printf("There are %d lines\n", lines - 1);
    return 0;
}
