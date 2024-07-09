all:
	ca65 -o frontOffice.o -t nes frontOffice.s
	ld65 -o frontOffice.nes -t nes frontOffice.o

clean:
	rm frontOffice.o
	rm frontOffice.nes
