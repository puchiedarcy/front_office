all: libs test build

libs:
	cl65 -c double_dabble.s
	ar65 r double_dabble.lib double_dabble.o

test: libs
	cl65 -o test_double_dabble.prg -t sim6502 test_double_dabble.s double_dabble.lib
	sim65 -c test_double_dabble.prg

build: libs 
	cl65 -C front_office.cfg -g -Ln front_office.labels -o front_office.nes -t nes front_office.s double_dabble.lib
	./label_maker.sh front_office.labels

clean:
	rm -f front_office.labels
	rm -f front_office.nes*
	rm -f *.lib
	rm -f *.o
	rm -f *.prg
