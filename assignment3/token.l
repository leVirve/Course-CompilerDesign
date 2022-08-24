%{
  #include <stdio.h>
  #include "andes_compiler.h"
  #include "asm_lib.h"
  FILE* f_asm;
  int line = 0;
  YYSTYPE yylval;
%}

datatype        int|double|char
identifier      [a-zA-Z_][a-zA-Z0-9_]*
number          0|[1-9][0-9]*
realnumber      (0|[1-9][0-9]*)\.[0-9]*
operators       [+\-*/=<>]
symbols         [(){},;]
%x COMMENT
%%

"//"[^\n]*              printf("#%-2d comment\n", line);
"/*"                    BEGIN COMMENT;
<COMMENT>\n             {printf("#%-2d comment\n", line++);};
<COMMENT>"*/"           {printf("#%-2d comment\n", line);BEGIN INITIAL;}
<COMMENT>.              ;

\n                      line++;
{symbols}               {printf("#%-2d %s\n", line, yytext);return yytext[0];}
{operators}             {printf("#%-2d operator   : %s\n", line, yytext);return yytext[0];}
'./'                    {printf("#%-2d '\n#%-2d character  : %c\n#%-2d '\n", line, line, yytext[1], line);return CHAR;}
"return"                {printf("#%-2d return\n", line);return RETURN;}

{number}                {
    test_install_sym(yytext, INTEGER);
    printf("An integer: %s\n", yytext);
    yylval.intv = atoi(yytext);
    return NUMBER;
}

{realnumber}            {
    test_install_sym(yytext, FLOAT);
    printf("A float: %s\n", yytext);
    yylval.intv = atof(yytext);
    return REALNUMBER;
}
{datatype}              {printf("#%-2d type   : %s\n", line, yytext);return TYPE;}

{identifier}            {
    printf("#%-2d variable ID: %s\n", line, yytext);
    if(!check_id_exist(yytext)) {
        test_install_sym(yytext, IDENTIFIER);
        DEBUG("intall %s\n", yytext);
    }
    yylval.id = strdup(yytext);
    return IDENTIFIER;
}

.                       ;
%%

