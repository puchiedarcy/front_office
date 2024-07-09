all:
	ca65 frontOffice.s -o frontOffice.o
	ld65 -o frontOffice.nes -t nes frontOffice.o

clean:
	rm frontOffice.o
	rm frontOffice.nes
