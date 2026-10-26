CC = gcc

all: lab03_O0

lab03_O0: lab03.c
	$(CC) -O0 -fno-stack-protector -no-pie -g -o lab03_O0 lab03.c

clean:
	rm -f lab03_O0

.PHONY: all clean