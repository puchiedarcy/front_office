#!/bin/bash
echo -n "" > frontOffice.nes.ram.nl
echo -n "" > frontOffice.nes.0.nl
echo -n "" > frontOffice.nes.1.nl

write_to_namelist() {
    echo "\$$1#$2#" >> $3
}

while IFS= read -r line; do
    _ADDRESS="${line:5:4}"
    _LABEL="${line:11}"

    case $_ADDRESS in
        0*)
            write_to_namelist $_ADDRESS $_LABEL frontOffice.nes.ram.nl
        ;;
        [89AB]*)
            write_to_namelist $_ADDRESS $_LABEL frontOffice.nes.0.nl
        ;;
        [CDEF]*)
            write_to_namelist $_ADDRESS $_LABEL frontOffice.nes.1.nl
        ;;
    esac
done < "$1"
