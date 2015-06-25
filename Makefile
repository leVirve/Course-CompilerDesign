all:
	byacc -vd grammar.y
	flex token.l
	gcc lex.yy.c y.tab.c asm_lib.c -lfl -std=gnu11 -o andes_compiler

exec:
	nds32le-elf-gcc andes.s -static -Wa,-g -o andes.adx
	nds32le-elf-gdb andes.adx -tui
yacc:
	byacc -vd grammar.y
	flex token.l

test1:
	./andes_compiler < test1.c
	cat andes.s
	diff andes.s test1_ans.s

test2:
	./andes_compiler< test2.c
	cat andes.s
	diff andes.s test2_ans.s

