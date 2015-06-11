%{
  #include <stdio.h>
  #include "asm_lib.h"
  #include <math.h>
  #include <string.h>
  #include <stdlib.h>
  #include <malloc.h>
  extern int line;
  extern FILE *f_asm;
  int    errcnt=0;
  int    errline=0;
  int yylex();

  int pre_num = 0;
  char pre_func[30];
%}

%start program
%union {
    int     intv ;
    char    charv;
    char    *id;
}

%token TYPE, IDENTIFIER, NUMBER, CHAR, INTEGER, FLOAT
%token RETURN

%type <id> function_declaration, statement, expression, declaration
%type <id> IDENTIFIER, TERM
%type <intv> NUMBER

%left '+' '-'
%left '*' '/'

%%

program: functions {printf("functions -> program\n");};

functions
        : functions function { printf("functions function -> functions\n"); }
        | function { printf("function -> functions\n"); }
        ;

function
        : function_declaration {
                cur_scope++;
                set_scope_and_offset_of_param($1);
                code_gen_func_header($1);
            }
        '{' declarations {
                set_local_vars($1);
            }
        statement_list {
                pop_up_symbol(cur_scope);
                cur_scope--;
                code_gen_at_end_of_function_body($1);
            }
        '}' { printf("function_declaration { statement_list } -> function\n"); }
        | function_declaration ';' { printf("function_declaration ';' -> function\n"); }
        ;

function_declaration
        : TYPE IDENTIFIER '(' parameter_list ')' {
                $$=install_symbol($2);
                sprintf(pre_func, "%s", $$);
                printf("TYPE IDENTIFIER '(' parameter_list ')' -> function_declaration\n");
            }
        ;

parameter_list
        : parameter_list ',' parameter { printf("parameter_list ',' parameter -> parameter_list\n"); }
        | parameter {
                //fprintf(f_asm, "  swi   $r0, [$fp + (-%d)]\n", table[index].offset * 4 + 8);
                printf("parameter -> parameter_list\n");
            }
        ;

parameter
        : { printf("null -> parameter\n"); }
        | TYPE IDENTIFIER {
                printf("TYPE IDENTIFIER -> parameter\n");
            }
        | TERM {printf("term -> parameter\n");}
        ;

declarations
        : declaration ';' {printf("declaration -> declarations\n"); }
        | declarations declaration ';' {printf("declarations declaration -> declarations\n");}
        ;

declaration
        : TYPE IDENTIFIER '=' expression {
                $$=install_symbol($2);
                set_local_vars(pre_func);
                int index = look_up_symbol($2);
                int val_idx = look_up_symbol_kw($2) + 1;
                switch(table[index].mode) {
                case ARGUMENT_MODE:
                    break;
                case LOCAL_MODE:
                    fprintf(f_asm, "  movi  $r0, %d\n", symbol_t[val_idx].attr.ival);
                    fprintf(f_asm, "  swi   $r0, [$fp + (-%d)]\n", table[index].offset * 4 + 8);
                    break;
                default: break;
                }
                $$=$2;
                printf("TYPE IDENTIFIER '=' expression -> statement\n");
            }
        | declaration ',' IDENTIFIER '=' expression {
                $$=install_symbol($3);
                set_local_vars(pre_func);
                int index = look_up_symbol($3);
                int val_idx = look_up_symbol_kw($3) + 1;
                fprintf(f_asm, "  movi  $r0, %d\n", symbol_t[val_idx].attr.ival);
                fprintf(f_asm, "  swi   $r0, [$fp + (-%d)]\n", table[index].offset * 4 + 8);
            }
        | TYPE IDENTIFIER {
                $$=install_symbol($2);
                printf("TYPE IDENTIFIER -> statement\n");
            }


statement_list
        : statement ';' { printf("statement ';' -> statement_list\n"); }
        | statement_list statement ';' { printf("statement_list statement ';' -> statement_list\n"); }

statement
        : IDENTIFIER '=' expression {
                DEBUG("id==========%s\n", $1);
                int index = look_up_symbol($1);
                fprintf(f_asm, "  swi   $r0, [$fp + (-%d)]\n", table[index].offset * 4 + 8);
                printf("IDENTIFIER '=' expression -> statement\n");
            }
        | RETURN expression {
                fprintf(f_asm, "  movi  $r0, %d\n", 0);
                printf("RETURN expression -> statement\n");
            }
        ;

expression
        : IDENTIFIER '(' parameter_list ')' {printf("IDENTIFIER '(' parameter_list ')' -> expression\n");}
        | expression '/' expression {
                // ggggg 
                fprintf(f_asm, "  movi  $r0, %d\n", 5);
                printf("expression '/' expression -> expression\n");
            }
        | '(' expression ')' {printf("'(' expression ')' -> expression\n");}
        | expression '*' NUMBER {
                fprintf(f_asm, "  movi  $r0, %d\n", $3);
                fprintf(f_asm, "  mul   $r0, $r1, $r0\n");
            }
        | IDENTIFIER '+' NUMBER {
                int index = look_up_symbol($1);
                fprintf(f_asm, "  lwi   $r0, [$fp + (-%d)]\n", table[index].offset * 4 + 8);
                fprintf(f_asm, "  addi  $r1, $r0, %d\n", $3);
            }
        | expression '-' TERM {
                if ($3 == NULL) {
                    fprintf(f_asm, "  addi  $r0, $r0, -%d\n", pre_num);
                } else {
                    int index = look_up_symbol($1);
                    fprintf(f_asm, "  lwi   $r0, [$fp + (-%d)]\n", table[index].offset * 4 + 8);
                    fprintf(f_asm, "  sub   $r0, $r1, $0\n");
                }
            }
        | TERM {printf("term -> expression\n");}
        ;

TERM
    : NUMBER {
        $$=NULL;
        pre_num = $1;
        DEBUG("..........................%d\n", $1);
        printf("NUMBER -> term\n");
      }
    | CHAR {printf("CHAR -> term\n");}
    | IDENTIFIER {
            $$=$1;
            printf("IDENTIFIER -> term\n");
        }
    ;

%%

int yyerror(char* s)
{
    fprintf(stderr, "%s\n", s);
}

int main(int argc, char** argv)
{
  int i;
  --argc; ++argv;
  FILE* yyin;
  if (argc > 0) yyin = fopen(argv[0], "r");
  else yyin = stdin;

  if ((f_asm = fopen("test.s", "w")) == NULL) {
    fprintf(stderr, "Cant open the file %s for write\n", "test.s");
    exit(1);
  }

  fprintf(f_asm, "  .text\n");

  init_symbol_table();

  // code_gen_with_header(argv[0]);

  if (i = yyparse()) fprintf(stderr, "Bad parse, return code %d\n", i);
  else fprintf(stdout, "\nParsing Successfully\n");

  // code_gen_global_vars();

  fprintf(f_asm, "  .ident  \"GCC: (GNU) 4.9.0\"\n");
}

