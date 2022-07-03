all: scanner

scanner: token.l grammar.y
	flex -o $@.yy.c token.l
	bison -d grammar.y -y -o $@.c
	cc $@.yy.c $@.c -lfl -o $@.o

test:
	scanner.o < testfile.c > output.rpt

clean:
	rm scanner.* output.rpt
