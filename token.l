%{
    int lines = 0;
    char comment_block = 0;
%}
identifier  int|double|char
word  [a-zA-Z][a-zA-Z0-9_]*
operators [+\-*/=]
space [ \t\n]
number 0|[1-9][0-9]*
realnumber (0|[1-9][0-9]*)\.[0-9]*
%Start COMMENT DECLARE FUNC

%%
"/*"                    { BEGIN(COMMENT); comment_block = 1; }
<COMMENT>[^*\n]*        ;
<COMMENT>"*"+[^*/\n]*   ;
<COMMENT>\n             printf("#%d comment\n", ++lines);
<COMMENT>"*/"           { 
        if(comment_block) {
            printf("#%d comment\n", lines + 1);
            comment_block = 0;
        } 
        BEGIN INITIAL;
    }
"//"+[^\n]*             printf("#%d comment\n", lines + 1);

\n                      ++lines;

<INITIAL>{identifier}            {
        printf("#%d data type  : %s\n", lines + 1, yytext);
        BEGIN(DECLARE);
}
<DECLARE>{word}[^(]     {
        printf("#%d function ID: %s\n", lines + 1, yytext);
        BEGIN(FUNC);
}
<FUNC>{identifier}      printf("#%d data type  : %s\n", lines + 1, yytext);
<FUNC>{word}            {
        printf("#%d variable ID: %s\n", lines + 1, yytext);
        BEGIN(DECLARE);
}
<DECLARE>")"            BEGIN INITIAL;
[(){},;]                printf("#%d %s\n", lines + 1, yytext);
{operators}             printf("#%d operator   : %s\n", lines + 1, yytext);
{number}|{realnumber}   printf("#%d number     : %s\n", lines + 1, yytext);
{space}                 ;
%%

int main()
{
    yylex();
    printf("There are %d lines\n", lines);
    return 0;
}
