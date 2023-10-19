#!/bin/bash

# Read user input for model
read -p "Enter 'bm25' for BM25 model or 'mdpr' for MDPR model: " model

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

# Read user input for IR task
read -p "Enter 'onevsone' for one-vs-one or 'onevsmany' for one-vs-many IR task: " ir_task

# Check user input and set variables accordingly
if [[ "$ir_task" == "onevsone" ]]; then
    task_folder="onevsone"
elif [[ "$ir_task" == "onevsmany" ]]; then
    task_folder="onevsmany"
else
    echo "Invalid IR task choice. Please enter 'onevsone' or 'onevsmany'."
    exit 1
fi

# List of languages
languages=("EN" "DE" "FR" "ES" "PL" "IT" "PT" "NL" "RO" "EL" "HU" "HR" "SV" "BG" "FI" "CS" "SK" "DA" "SL" "MT" "LT" "LV" "ET" "GA")

# Read user input for specific languages (if any)
read -p "Enter specific languages in uppercase separated by commas (e.g., EN,DE): " selected_languages

# Convert the input string to an array of languages
IFS=',' read -ra languages_array <<< "$selected_languages"

# If no specific languages are entered, use all languages from the list
if [ -z "$selected_languages" ]; then
    selected_languages=("${languages[@]}")
fi

# Loop through each language
for language in "${selected_languages[@]}"; do
    echo "Retrieval language: $language"

    # Lowercase the language argument
    lowercase_language=$(echo "$language" | tr '[:upper:]' '[:lower:]')

    if [[ "$model" == "bm25" ]]; then
        # Construct the Python command for the BM25 script
        python_command="python -m pyserini.search.lucene --index /lt/scratch/jinruiy/MLEP-data/pyserini-data/indexs/$ir_task --topics mlep-meta-bm25-splited-clean/mlep-bm25-$language/queries.test.tsv --output /lt/scratch/jinruiy/MLEP-data/pyserini-data/output/mlep-meta-bm25-splited/$task_folder/clean/mlep-bm25-$language-test.txt --bm25"
    elif [[ "$model" == "mdpr" ]]; then
        # Construct the Python command for the MDPR script
        python_command="CUDA_VISIBLE_DEVICES=6 python -m pyserini.search.faiss --threads 16 --encoder-class auto --encoder castorini/mdpr-tied-pft-msmarco --topics mlep-meta-bm25-splited/$task_folder/mlep-bm25-$language/queries.test.tsv --index mlep-mdpr-dindex/mlep-meta-mdpr-$variant --output output/mlep-meta-mdpr-splited/$task_folder/mlep-mdpr-$language-test.txt --hits 100"
    else
        echo "Invalid model choice. Please enter 'bm25' or 'mdpr'."
        exit 1
    fi

    # Run the Python command and handle errors
    if eval "$python_command"; then
        echo "Language $language retrieval done"
    else
        echo "Failed to run Python command for language $language"
    fi

    echo "=============================="
done
