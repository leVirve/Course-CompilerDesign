%{
    #include <stdio.h>
    int yydebug = 1;
    extern int yyerror(char*);
    extern int yylex(void);
%}

%union {
    int intVal;
    char* strVal;
}

%token TYPE IDENTIFIER FUNCTION_IDENTIFIER NUMBER CHAR
%token RETURN

%left '+' '-'
%left '*' '/'

%start program

%%

program: functions {printf("functions -> program\n");};

functions
        : functions function { printf("functions function -> functions\n"); }
        | function { printf("function -> functions\n"); }
        ;

function
        : function_declaration '{' statement_list '}' { printf("function_declaration { statement_list } -> function\n"); }
        | function_declaration ';' { printf("function_declaration ';' -> function\n"); }
        ;

function_declaration
        : TYPE FUNCTION_IDENTIFIER '(' parameter_list ')' {printf("TYPE FUNCTION_IDENTIFIER '(' parameter_list ')' -> function_declaration\n");}
        ;

parameter_list
        : parameter_list ',' parameter { printf("parameter_list ',' parameter -> parameter_list\n"); }
        | parameter { printf("parameter -> parameter_list\n"); }
        ;

parameter
        : { printf("null -> parameter\n"); }
        | TYPE IDENTIFIER { printf("TYPE IDENTIFIER -> parameter\n"); }
        | TERM {printf("term -> parameter\n");}
        ;

statement_list
        : statement ';' { printf("statement ';' -> statement_list\n"); }
        | statement_list statement ';' { printf("statement_list statement ';' -> statement_list\n"); }

statement
        : IDENTIFIER '=' expression { printf("IDENTIFIER '=' expression -> statement\n"); }
        | TYPE IDENTIFIER '=' expression { printf("TYPE IDENTIFIER '=' expression -> statement\n"); }
        | TYPE IDENTIFIER { printf("TYPE IDENTIFIER -> statement\n"); }
        | RETURN expression {printf("RETURN expression -> statement\n");}
        ;

expression
        : expression '+' expression {printf("expression '+' expression -> expression\n");}
        | expression '-' expression {printf("expression '-' expression -> expression\n");}
        | expression '*' expression {printf("expression '*' expression -> expression\n");}
        | expression '/' expression {printf("expression '/' expression -> expression\n");}
        | '(' expression ')' {printf("'(' expression ')' -> expression\n");}
        | FUNCTION_IDENTIFIER '(' parameter_list ')' {printf("FUNCTION_IDENTIFIER '(' parameter_list ')' -> expression\n");}
        | TERM {printf("term -> expression\n");}
        ;

TERM: NUMBER {printf("NUMBER -> term\n");} | CHAR {printf("CHAR -> term\n");} | IDENTIFIER {printf("IDENTIFIER -> term\n");} ;

%%

int yyerror(char* s)
{
    fprintf(stderr, "%s\n", s);
}

int main()
{
    yyparse();
    return 0;
}
