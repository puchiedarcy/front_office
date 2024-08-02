all: test build

test:
	cl65 -o test_double_dabble.prg -t sim6502 test_double_dabble.s
	sim65 -c test_double_dabble.prg

build:
	cl65 -C front_office.cfg -g -Ln front_office.labels -o front_office.nes -t nes front_office.s
	./label_maker.sh front_office.labels

clean:
	rm -f front_office.labels
	rm -f front_office.nes*
	rm -f front_office.o
	rm -f test_*.o
	rm -f test_*.prg
