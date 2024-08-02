#!/bin/bash
echo -n "" > bin/front_office.nes.ram.nl
echo -n "" > bin/front_office.nes.0.nl
echo -n "" > bin/front_office.nes.1.nl

write_to_namelist() {
    echo "\$$1#$2#" >> $3
}

while IFS= read -r line; do
    _ADDRESS="${line:5:4}"
    _LABEL="${line:11}"

    case $_ADDRESS in
        0*)
            write_to_namelist $_ADDRESS $_LABEL bin/front_office.nes.ram.nl
        ;;
        [89AB]*)
            write_to_namelist $_ADDRESS $_LABEL bin/front_office.nes.0.nl
        ;;
        [CDEF]*)
            write_to_namelist $_ADDRESS $_LABEL bin/front_office.nes.1.nl
        ;;
    esac
done < "$1"
