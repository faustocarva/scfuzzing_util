#!/bin/bash

# Usage: ./extract_fields.sh <contract_name> <solc_output_file>

contract_name="$1"
solc_output_file="$2"

#jq -r --arg contract "$contract_name" '.contracts["\(.contract_name)"] | .bin, .abi' "$solc_output_file"
jq -r --arg contract "$contract_name" '.contracts | with_entries(select(.key | endswith($contract)))[].abi' "$solc_output_file" > "$contract_name".abi
jq -r --arg contract "$contract_name" '.contracts | with_entries(select(.key | endswith($contract)))[].bin' "$solc_output_file" > "$contract_name".bin
tr -d '\n' < "$contract_name".bin  > "$contract_name".bin.2
mv "$contract_name".bin.2 "$contract_name".bin
