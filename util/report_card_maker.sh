#!/bin/bash
echo -n "" > $2

declare -a tests
declare -A error_codes
declare -A cycles

for _RESULT in "$1/test_"*".results"; do
    while IFS= read -r line; do
        if [[ $line =~ ^.*_(.*)+\.prg.* ]]; then
            _TEST=${BASH_REMATCH[1]}
            tests+=("$_TEST")
            cycles["$_TEST"]=$_CYCLES
        fi

        if [[ $line =~ ^PVExit.*([0-9]+).* ]]; then
            error_codes["$_TEST"]=${BASH_REMATCH[1]}
        fi

        if [[ $line =~ ^([0-9]+)\ cycles ]]; then
            _CYCLES=${BASH_REMATCH[1]}
        fi
    done < $_RESULT
done

_COUNTER=0
_NUM_TESTS=${#tests[@]}
(( _NUM_TESTS-- ))
echo "{" >> $2
for i in "${!tests[@]}"
do
    _TEST=${tests[$i]}
    echo "\"$_TEST\": {" >> $2
        echo "\"error_code\": \"${error_codes[$_TEST]}\"," >> $2
        echo "\"cycles\": \"${cycles[$_TEST]}\"" >> $2
    echo "}" >> $2
    if [[ $_COUNTER < $_NUM_TESTS ]]; then
        echo "," >> $2
        (( _COUNTER++ ))
    fi
done
echo "}" >> $2

tr -d "\n" < $2 > /tmp/report_card.json
mv /tmp/report_card.json $2
echo "" >> $2
