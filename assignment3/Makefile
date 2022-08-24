all:
	andes_compiler

andes_compiler: token.l grammar.y
	flex -o $@.yy.c token.l
	bison -d grammar.y -y -o $@.c
	cc $@.yy.c $@.c asm_lib.c -lfl -o $@.o

exec:
	nds32le-elf-gcc andes.s -static -Wa,-g -o andes.adx
	nds32le-elf-gdb andes.adx -tui

yacc:
	byacc -vd grammar.y
	flex token.l

test1:
	./andes_compiler.o < test1.c
	cat andes.s
	diff andes.s test1_ans.s

test2:
	./andes_compiler.o < test2.c
	cat andes.s
	diff andes.s test2_ans.s

clean:
	rm andes_compiler.*
	rm andes.s
	# rm *.gch
	# rm andes.adx
	# rm andes_compiler
