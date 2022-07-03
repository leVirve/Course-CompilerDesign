all: tokenizer test

tokenizer: token.l
	flex token.l
	cc lex.yy.c -o $@.o -lfl

test:
	tokenizer.o < basic.c > output.rpt
	diff output.rpt basic.rpt

clean:
	rm tokenizer.o lex.yy.c output.rpt
