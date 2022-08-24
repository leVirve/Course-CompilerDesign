#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "andes_compiler.h"
#include "const.h"

#define MAX_TABLE_SIZE 5000

#define T_FUNCTION      1
#define ARGUMENT_MODE   2
#define LOCAL_MODE      4
#define GLOBAL_MODE     8

#ifndef _DEBUG
# define DEBUG(format, args...) printf("[Line:%d] " format, __LINE__, ##args)
#else
# define DEBUG(args...)
#endif

typedef struct symbol_entry *PTR_SYMB;
struct symbol_entry {
   char *name;
   int scope;
   int offset;
   int id;
   int variant;
   int type;
   int total_args;
   int total_locals;
   int mode;
} table[MAX_TABLE_SIZE];

extern int cur_scope;
extern int cur_counter;
extern int line;
extern FILE *f_asm;

char* strdup_s(char*);

int test_install_sym(char* text, unsigned int type);
int check_id_exist(char* text);
void init_symbol_table();
void code_gen_global_vars();
void code_gen_with_header(char*);

char* install_symbol();
void set_local_vars(char*);
int look_up_symbol(char*);
int look_up_symbol_kw(char*);
void set_scope_and_offset_of_param(char*);
void code_gen_func_header(char*);
void code_gen_at_end_of_function_body(char*);
void pop_up_symbol(int);

