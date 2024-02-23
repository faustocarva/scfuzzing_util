#!/bin/bash

# Function to process JSON files
process_json() {
    local file="$1"
    local swc_id="$2"
    local swc_dir="$3"
    # Check if the file exists and is readable
    if [ -r "$file" ]; then
	#bytecode_path="./bytecode/$(dirname $file | xargs basename)/$(jq -r '.["node name"]' $file)"
	dapp_name=$(dirname $file | xargs basename)
	contract_name=$(jq -r '.["node name"]' $file | cut -f 1 -d '.')
	bytecode_file=$(echo $file | sed 's/SWCbytecode/bytecode/')
	found_swc=$(jq --arg swc_id "$swc_id" '.SWCs | any(.category | contains($swc_id))' $file)
	if $found_swc; then
	    echo "Processing...$bytecode_file"
	    #echo $contract_name
	    #echo $bytecode_file
	    jq -r --arg contract "$contract_name" '.contracts | with_entries(select(.key |  split(":") |  .[] == $contract))[].abi' $bytecode_file > $swc_dir/"$dapp_name"__"$contract_name".abi
	    jq -r --arg contract "$contract_name" '.contracts | with_entries(select(.key |  split(":") |  .[] == $contract))[].bin' $bytecode_file > $swc_dir/"$dapp_name"__"$contract_name".bin
	    tr -d '\n' < $swc_dir/"$dapp_name"__"$contract_name".bin  > $swc_dir/"$dapp_name"__"$contract_name".bin.2
	    mv $swc_dir/"$dapp_name"__"$contract_name".bin.2 $swc_dir/"$dapp_name"__"$contract_name".bin
	fi
        #jq --arg bytecode_path "$bytecode_path" '. + { "path_to_bytecode": $bytecode_path }' "$file" 
    else
        echo "Error: Unable to read file $file"
    fi
}

# Function to process all JSON files in a directory
process_directory() {
    local directory="$1"
    local swc_id="$2"
    local swc_dir="$3"
    # Check if the directory exists
    if [ ! -d "$directory" ]; then
        echo "Error: Directory '$directory' not found."
        exit 1
    fi

    while IFS= read -r -d '' file; do
	process_json "$file" "$swc_id" "$swc_dir"
    done < <(find "$directory" -type f -name '*.json' -print0)
}

# Main script
if [ $# -ne 2 ]; then
    echo "Usage: $0 <directory> <swc-id>"
    exit 1
fi

directory="$1"
swc="$2"
swc_dir=$(pwd)/swc_"$2"

# Get the absolute path of the directory
directory="$(realpath "$directory")"

rm -fR $swc_dir
mkdir $swc_dir

# Process the directory
process_directory "$directory" "$swc" "$swc_dir"
