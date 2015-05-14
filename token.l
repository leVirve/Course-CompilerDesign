%{
    #include "y.tab.h"
%}

datatype        int|double|char
identifier      [a-zA-Z_][a-zA-Z0-9_]*
number          0|[1-9][0-9]*
realnumber      (0|[1-9][0-9]*)\.[0-9]*
operators       [+\-*/=<>]
symbols         [(){},]
%x COMMENT
%%

"//"[^\n]*              ;
"/*"                    BEGIN COMMENT;
<COMMENT>\n             ;
<COMMENT>"*/"           BEGIN INITIAL;
<COMMENT>.              ;

\n                      ;
{symbols}               return yytext[0];
{operators}             return yytext[0];
'.'                     return CHAR;
"return"                return RETURN;
{number}|{realnumber}   return NUMBER;
{datatype}              return TYPE;
{identifier}            return IDENTIFIER;
{identifier}/\(         return FUNCTION_IDENTIFIER;
{identifier}/=          return IDENTIFIER;
.                       ;
%%

