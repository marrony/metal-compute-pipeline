
main: main.m
	clang -Wall main.m -o main -framework Metal -framework Foundation

all: main
