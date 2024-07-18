all:
	ca65 -o frontOffice.o -t nes frontOffice.s
	ld65 -C frontOffice.cfg -o frontOffice.nes frontOffice.o

clean:
	rm frontOffice.o
	rm frontOffice.nes
