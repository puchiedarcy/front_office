all:
	ca65 -g -o frontOffice.o -t nes frontOffice.s
	ld65 -C frontOffice.cfg -Ln frontOffice.labels -o frontOffice.nes frontOffice.o
	./labelMaker.sh frontOffice.labels

clean:
	rm -f frontOffice.labels
	rm -f frontOffice.nes*
	rm -f frontOffice.o
