all:
	ca65 -g -o frontOffice.o -t nes frontOffice.s
	ld65 -C frontOffice.cfg -Ln frontOffice.labels -o frontOffice.nes frontOffice.o
	./labelMaker.sh frontOffice.labels

clean:
	rm frontOffice.labels
	rm frontOffice.nes*
	rm frontOffice.o
