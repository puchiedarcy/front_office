#!/bin/bash
echo -n "" > $3

declare -a objects
declare -A object_segments
declare -A segments

while IFS= read -r line; do
    if [[ ${line} =~ ([a-z_]+)\.o: ]]; then
        _OBJ_NAME="${BASH_REMATCH[1]}"
        objects+=("$_OBJ_NAME")
        continue
    fi

    if [[ ${line} =~ ^[[:space:]]+([A-Z]+)[[:space:]]+Offs=.*Size=([0-9A-F]+).* ]]; then
        object_segments["${BASH_REMATCH[1]}"]+="${BASH_REMATCH[2]}:$_OBJ_NAME;"
        continue
    fi

    if [[ ${line} =~ ^([A-Z]+)[[:space:]]+[0-9A-F]+[[:space:]]+[0-9A-F]+[[:space:]]+([0-9A-F]+).* ]]; then
        segments["${BASH_REMATCH[1]}"]="${BASH_REMATCH[2]}"
        continue
    fi

    if [[ ${line} == "Exports list by name:" ]]; then
        break
    fi
done < <(tail -n +3 "$1")

declare -A max_segment_sizes

while IFS= read -r line; do
    if [[ ${line} =~ ^[[:space:]]+([A-Z]+):.*size=\$([0-9A-F]+).* ]]; then
        max_segment_sizes["${BASH_REMATCH[1]}"]="${BASH_REMATCH[2]}"
    fi
done < "$2"

_COUNTER=0
_NUM_SEGMENTS=${#max_segment_sizes[@]}
(( _NUM_SEGMENTS-- ))
echo "{" >> $3
for i in "${!max_segment_sizes[@]}"
do
    echo "\"$i\": {" >> $3
        echo "\"size\": \"${max_segment_sizes[$i]}\"," >> $3
        echo "\"used\": \"${segments[$i]:2:4}\"," >> $3
        echo "\"used_by_objects\": {" >> $3
            IFS=';' read -ra pairs <<< "${object_segments[$i]}"
            _PAIR_COUNTER=0
            _NUM_PAIRS=${#pairs[@]}
            (( _NUM_PAIRS-- ))
            for j in "${pairs[@]}"; do
                echo "\"${j:7}\": \"${j:2:4}\"" >> $3
                if [[ $_PAIR_COUNTER < $_NUM_PAIRS ]]; then
                    echo "," >> $3
                    (( _PAIR_COUNTER++ ))
                fi
            done
        echo "}" >> $3
    echo "}" >> $3
    if [[ $_COUNTER < $_NUM_SEGMENTS ]]; then
        echo "," >> $3
        (( _COUNTER++ ))
    fi
done
echo "}" >> $3

tr -d "\n" < $3 > /tmp/map.json
mv /tmp/map.json $3
echo "" >> $3
