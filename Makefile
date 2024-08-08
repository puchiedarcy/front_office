all: build

build: libs test_inner

clean:
	rm -rf bin/

libs: $(wildcard lib/*/*.s test/test.s)
	mkdir -p bin
	$(foreach file, $^, \
		ca65 -g -o bin/$(notdir $(basename $(file))).o $(file); \
		ar65 r bin/$(notdir $(basename $(file))).lib bin/$(notdir $(basename $(file))).o; \
	)

test: libs test_inner

test_inner: $(wildcard test/tests/*.s)
	mkdir -p bin/test
	$(foreach file, $^, \
		ca65 -g -t sim6502 -o bin/test/$(notdir $(basename $(file))).o $(file); \
		ld65 -t sim6502 -o bin/test/$(notdir $(basename $(file))).prg bin/test/$(notdir $(basename $(file))).o bin/$(notdir $(basename $(file))).lib sim6502.lib bin/test.lib bin/parameters.lib; \
		sim65 -c -v bin/test/$(notdir $(basename $(file))).prg; \
	)

release: build
	ca65 -g -o bin/front_office.o -t nes front_office.s
	ld65 -C front_office.cfg -Ln bin/front_office.labels -o bin/front_office.nes bin/*.o
	./label_maker.sh bin/front_office.labels
