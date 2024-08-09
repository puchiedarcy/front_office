#!/bin/bash
echo -n "" > bin/front_office.chart

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
        object_segments["$_OBJ_NAME"]+="${BASH_REMATCH[1]}:${BASH_REMATCH[2]};"
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

for i in "${objects[@]}"
do
    echo $i
    echo "${object_segments[$i]}"
done

for i in "${!segments[@]}"
do
    echo $i
    echo "${segments[$i]}"
done
