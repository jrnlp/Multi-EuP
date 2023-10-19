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

# Read user input for -M value with a default value of 100
read -p "Enter the k for topK [default: 100]: " k
k=${k:-100}  # If k is empty, set it to the default value of 100

# Read user input for specific languages (if any)
read -p "Enter specific languages for evaluation in uppercase separated by commas (e.g., EN,DE): " eval_languages

# Convert the input string to an array of languages
IFS=',' read -ra eval_languages_array <<< "$eval_languages"

# If no specific languages are entered, use all languages from the list
if [ -z "$eval_languages" ]; then
    eval_languages=("EN" "DE" "FR" "ES" "PL" "IT" "PT" "NL" "RO" "EL" "HU" "HR" "SV" "BG" "FI" "CS" "SK" "DA" "SL" "MT" "LT" "LV" "ET" "GA")
else
    eval_languages=("${eval_languages_array[@]}")
fi

# Path to the Python scripts
index_python_script="pyserini.index.lucene"
search_python_script="pyserini.search.lucene"
eval_python_script="pyserini.eval.trec_eval"

# Get the total number of languages
total_languages=${#eval_languages[@]}

# Initialize a counter for processed languages
processed_count=0

# Loop through each language for indexing, retrieval, and evaluation
for language in "${eval_languages[@]}"; do
    processed_count=$((processed_count + 1))

    echo "Language: $language (Processed $processed_count languages out of $total_languages)"

    # Lowercase the language argument
    lowercase_language=$(echo "$language" | tr '[:upper:]' '[:lower:]')

    # Indexing
    echo "Indexing language: $language (Processed $processed_count languages out of $total_languages)"
    if python -m $index_python_script -collection JsonCollection -input "mlep-bm25-$variant/mlep-bm25-$language/" -index "indexes/mlep-$variant/mlep-bm25-$language" -generator DefaultLuceneDocumentGenerator -threads 1 -storePositions -storeDocvectors -storeRaw -language "$lowercase_language"; then
        echo "Language $language indexing done (Processed $processed_count languages out of $total_languages)"
    else
        echo "Failed to run pyserini indexing for language $language (Processed $processed_count languages out of $total_languages)"
    fi
    echo "=============================="

    # Retrieval
    echo "Retrieval language: $language (Processed $processed_count languages out of $total_languages)"
    if python -m $search_python_script --index "indexes/mlep-$variant/mlep-bm25-$language" --topics "mlep-bm25-$variant/mlep-bm25-$language/queries.tsv" --output "output/mlep-$variant/mlep-bm25-$language/mlep-bm25-$language.txt" --language "$lowercase_language" --bm25; then
        echo "Language $language retrieval done (Processed $processed_count languages out of $total_languages)"
    else
        echo "Failed to run pyserini search for language $language (Processed $processed_count languages out of $total_languages)"
    fi
    echo "=============================="

    # Evaluation
    echo "Evaluate BM25 on language: $language (Processed $processed_count languages out of $total_languages)"
    # Clear the previous content in the ranking_metric file
    > "output/mlep-$variant/mlep-bm25-$language/ranking_metric_$language.txt"
    # Run pyserini evaluation command and save output to a file
    if python -m $eval_python_script -c -M "$k" "mlep-bm25-$variant/mlep-bm25-$language/qrels.txt" "output/mlep-$variant/mlep-bm25-$language/mlep-bm25-$language.txt" >> "output/mlep-$variant/mlep-bm25-$language/ranking_metric_$language.txt" 2>&1; then
        echo "Language $language evaluation done (Processed $processed_count languages out of $total_languages)"
    else
        echo "Failed to run pyserini evaluation for language $language (Processed $processed_count languages out of $total_languages)"
    fi
    echo "=============================="

done

echo "DONE!"
