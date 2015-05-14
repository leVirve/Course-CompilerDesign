
all:
	byacc -d grammar.y
	flex token.l
	gcc lex.yy.c y.tab.c -lfl -o all.o
	./all.o < grammar.c

test:
	byacc -d test.y
	flex token.l
	gcc lex.yy.c y.tab.c -lfl -o test.o
	./test.o < 1.c


