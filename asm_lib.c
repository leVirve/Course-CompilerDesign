#include "asm_lib.h"
#ifndef _LIB_DEBUG
# define DEBUG(format, args...) printf("[Line:%d] " format, __LINE__, ##args)
#else
# define DEBUG(args...)
#endif

int cur_counter = 0;
int cur_scope   = 1;
int symbol_t_index = 0;

void init_symbol_table()
{
  memset(table, 0,sizeof(struct symbol_entry) * MAX_TABLE_SIZE);
}

char* install_symbol(char *s)
{
  if (cur_counter >= MAX_TABLE_SIZE)
    perror("Symbol Table Full");
  else {
    DEBUG("(scope:%d) intall %s @%d\n", cur_scope, s, cur_counter);
    table[cur_counter].scope = cur_scope;
    table[cur_counter].name = strdup(s);
    cur_counter++;
  }
  return s;
}

int look_up_symbol(char* s)
{
  DEBUG("cur = %d\n", cur_counter);
  if (cur_counter == 0) return -1;
  for (int i = cur_counter - 1; i >= 0; i--) {
    DEBUG("look up %s %s %d\n", s, table[i].name, i);
    if (!strcmp(s, table[i].name)) return i;
  }
  return -1;
}

int look_up_symbol_kw(char* s)
{
  if (symbol_t_index == 0) return -1;
  for (int i = symbol_t_index - 1; i >= 0; i--) {
    DEBUG("look up %s %s\n", s, symbol_t[i].lexptr);
    if (!strcmp(s, symbol_t[i].lexptr)) return i;
  }
}

void pop_up_symbol(int scope)
{
  int i;
  if (cur_counter == 0) return;
  for (i = cur_counter - 1; i >= 0; i--) {
    if (table[i].scope != scope) break;
  }
  if (i < 0) cur_counter = 0;
  cur_counter = i + 1;
}

void set_scope_and_offset_of_param(char *s)
{
  int total_args;
  int index = look_up_symbol(s);
  DEBUG("...%d\n", index);
  if (index < 0) perror("Error in function header");
  else {
    table[index].type = T_FUNCTION;
    total_args = cur_counter - index - 1;
    table[index].total_args = total_args;
    DEBUG(">>>>>>>>>>>>>>>> total args: %d\n", total_args);
    for (int j = total_args, i = cur_counter - 1; i > index; i--, j--) {
      table[i].scope = cur_scope;
      table[i].offset = j + 2;
      table[i].mode = ARGUMENT_MODE;
      fprintf(f_asm, "  swi   $r%d, [$fp + (-%d)]\n", j - 1, table[i].offset * 4 + 8);
    }
  }
}

void set_local_vars(char *functor)
{
  DEBUG("func == %s\n", functor);
  int total_locals;
  int index = look_up_symbol(functor);
  int index1 = index + table[index].total_args;
  total_locals = cur_counter - index1 - 1;
  if (total_locals < 0) perror("Error in number of local variables");
  table[index].total_locals = total_locals;
  for (int j = total_locals, i = cur_counter - 1; j > 0; i--, j--) {
    table[i].scope = cur_scope;
    table[i].offset = j;
    table[i].mode = LOCAL_MODE;
  }
}

void set_global_vars(char *s)
{
  int index = look_up_symbol(s);
  table[index].mode = GLOBAL_MODE;
  table[index].scope = 1;
}

void code_gen_func_header(char *function) {
  fprintf(f_asm, "  .align  2\n");
  fprintf(f_asm, "  .global %s\n", function);
  fprintf(f_asm, "  .type   %s, @function\n", function);
  fprintf(f_asm, "%s:\n", function);
  fprintf(f_asm, "  push.s  { $fp $lp }\n");
  fprintf(f_asm, "  addi    $fp, $sp, 8\n");
  fprintf(f_asm, "  addi    $sp, $sp, -16\n");
}

void code_gen_global_vars()
{
  for (int i = 0; i < cur_counter; i++) {
    if (table[i].mode == GLOBAL_MODE) {
      fprintf(f_asm, "_%s  label	word\n", table[i].name);
      fprintf(f_asm, " db  2 dup (?)\n");
    }
  }
}

void code_gen_at_end_of_function_body(char *function)
{
  fprintf(f_asm, "  addi    $sp, $fp, -8\n");
  fprintf(f_asm, "  pop.s   { $fp $lp }\n");
  fprintf(f_asm, "  ret\n");
  fprintf(f_asm, "  .size   %s, .-%s\n", function, function);
}


char* strdup_s (char *s) {
  char *d = (char*) malloc (strlen (s) + 1);
  if (d == NULL) return NULL;
  strcpy(d,s);
  return d;
}


int check_id_exist(char* text)
{
  for (int i = 0; i < symbol_t_index && symbol_t[i].lexptr != NULL; i++) {
    if (strcmp(text, symbol_t[i].lexptr) == 0) return TRUE;
  }
  return FALSE;
}

int yywrap()
{
  printf("Total Lines: %d\n\n", line);
  printf("YYTEXT\t\tVALUE\n");
  printf("---------------------\n");
  for(int i = 0; i < symbol_t_index; i++) {
    printf("%s\t\t", symbol_t[i].lexptr);
    switch(symbol_t[i].token) {
       case IDENTIFIER:
          printf("%s \n", symbol_t[i].attr.sval);
          break;
       case INTEGER:
          printf("%d \n", symbol_t[i].attr.ival);
          break;
       case FLOAT:
          printf("%f \n", symbol_t[i].attr.fval);
          break;
       default:
          printf("%s \n", symbol_t[i].attr.sval);
          break;
    }
  }
  return TRUE;
}

int test_install_sym(char* text, unsigned int type)
{
  symbol_t[symbol_t_index].lexptr = (char*) malloc(sizeof(char*)); // sizeof(char*)???????
  strcpy(symbol_t[symbol_t_index].lexptr, text);
  DEBUG("text(lexptr): %s\n", symbol_t[symbol_t_index].lexptr);
  symbol_t[symbol_t_index].token = type;
  switch(type) {
    case IDENTIFIER:
       symbol_t[symbol_t_index].attr.sval = (char*) malloc(sizeof(char*));
       strcpy(symbol_t[symbol_t_index].attr.sval, text);
       break;
    case INTEGER:
       symbol_t[symbol_t_index].attr.ival = atoi(text);
       break;
    case FLOAT:
       symbol_t[symbol_t_index].attr.fval = atof(text);
       break;
    default:
       symbol_t[symbol_t_index].attr.sval = (char*) malloc(sizeof(char*));
       strcpy(symbol_t[symbol_t_index].attr.sval, text);
       break;
 }
  symbol_t_index++;
  return TRUE;
}
