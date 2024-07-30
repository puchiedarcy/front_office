all:
	ca65 -g -o front_office.o -t nes front_office.s
	ld65 -C front_office.cfg -Ln front_office.labels -o front_office.nes front_office.o
	./label_maker.sh front_office.labels

clean:
	rm -f front_office.labels
	rm -f front_office.nes*
	rm -f front_office.o
