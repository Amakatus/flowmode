#!/bin/bash

websites_array=()
function querry_websites() {
    while IFS= read -r line; do
        websites_array+=("$line") 
    done < sites.txt
}

echo ${websites_array[1]}
