typedef struct {
  char *name;
  unsigned int value;
} KWORD;

#define FALSE   0
#define TRUE    1

typedef struct {
   char         *lexptr;
   unsigned int token;
   union {
      int   ival;
      float fval;
      char  *sval;
   } attr;
} symbol_type;

symbol_type symbol_t[100];
extern int symbol_t_index;

