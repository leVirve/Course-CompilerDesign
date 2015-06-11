all:
	byacc -vd grammar.y
	flex token.l
	gcc lex.yy.c y.tab.c asm_lib.c -lfl -std=gnu11

exec:
	nds32le-elf-gcc test.s -static -Wa,-g -o andes.adx
	nds32le-elf-gdb andes.adx -tui
yacc:
	byacc -vd grammar.y
	flex token.l

test1:
	./a.out < test1.c
	cat test.s
	diff test.s test1_ans.s

test2:
	./a.out < test2.c
	cat test.s

