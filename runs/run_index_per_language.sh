#!/bin/bash

# Read user input for flag
read -p "Enter 'full' for full version or 'toy' for toy version: " version_flag

# Check user input and set variables accordingly
if [[ "$version_flag" == "full" ]]; then
    variant="full"
elif [[ "$version_flag" == "toy" ]]; then
    variant="toy"
else
    echo "Invalid input. Using 'toy' version by default."
    variant="toy"
fi

# List of languages
languages=("EN" "DE" "FR" "ES" "PL" "IT" "PT" "NL" "RO" "EL" "HU" "HR" "SV" "BG" "FI" "CS" "SK" "DA" "SL" "MT" "LT" "LV" "ET" "GA")

# Path to the Python script
python_script="pyserini.index.lucene"

# Loop through each language
for language in "${languages[@]}"; do

    echo "Indexing language: $language"

    # Lowercase the language argument
    lowercase_language=$(echo "$language" | tr '[:upper:]' '[:lower:]')

    # Run pyserini indexing command and handle errors
    if python -m $python_script -collection JsonCollection -input "mlep-bm25-$variant/mlep-bm25-$language/" -index "indexes/mlep-$variant/mlep-bm25-$language" -generator DefaultLuceneDocumentGenerator -threads 1 -storePositions -storeDocvectors -storeRaw; then
        echo "Language $language indexing done"
    else
        echo "Failed to run pyserini indexing for language $language"
    fi

    echo "=============================="
done
