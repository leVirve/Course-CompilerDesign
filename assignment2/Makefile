
all:
	bison -d grammar.y -y
	flex token.l
	gcc lex.yy.c y.tab.c -lfl -o all.o
	./all.o < testfile.c

build:
	mkdir build
	cp token.l build/101062337_hw2.l
	cp grammar.y build/101062337_hw2.y
	scp build/* 101062337@140.114.88.219:~/Assignment2

clean:
	rm -rf build
	rm all.o
	rm y.tab.h
	rm y.tab.c
	rm lex.yy.c
