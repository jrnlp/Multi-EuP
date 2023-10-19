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

# Read user input for -M value with a default value of 100
read -p "Enter the k for topK [default: 100]: " k
k=${k:-100}  # If k is empty, set it to the default value of 100

# Read user input for specific languages (if any)
read -p "Enter specific languages in uppercase separated by commas (e.g., EN,DE): " selected_languages

# Convert the input string to an array of languages
IFS=',' read -ra languages_array <<< "$selected_languages"

# If no specific languages are entered, use all languages from the list
if [ -z "$selected_languages" ]; then
    languages=("EN" "DE" "FR" "ES" "PL" "IT" "PT" "NL" "RO" "EL" "HU" "HR" "SV" "BG" "FI" "CS" "SK" "DA" "SL" "MT" "LT" "LV" "ET" "GA")
else
    languages=("${languages_array[@]}")
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

# Path to the Python script
python_script="pyserini.eval.trec_eval"

# Loop through each language
for language in "${languages[@]}"; do

    echo "Evaluate on language: $language"

    # Lowercase the language argument
    lowercase_language=$(echo "$language" | tr '[:upper:]' '[:lower:]')

    # Clear the previous content in the ranking_metric file
#    > "output/mlep-meta-bm25-splited/$task_folder/whitespace/$task_folder_test_ranking_metric_$language.txt"

    if [[ "$model" == "bm25" ]]; then
        # Run BM25 evaluation and save the printout
        if python -m $python_script -c -M "$k" "mlep-meta-bm25-splited-clean/mlep-bm25-$language/qrels.test.txt" "output/mlep-meta-bm25-splited/$task_folder/clean/mlep-bm25-$language-test.txt" >> "output/mlep-meta-bm25-splited/$task_folder/clean/test_ranking_metric_$language.txt" 2>&1; then
            echo "BM25 evaluation for language $language done"
        else
            echo "Failed to run BM25 evaluation for language $language"
        fi
    elif [[ "$model" == "mdpr" ]]; then
        # Run MDPR evaluation and save the printout
        if python -m $python_script -c -M "$k" "mlep-meta-bm25-splited/$task_folder/mlep-bm25-$language/qrels.test.txt" "output/mlep-meta-mdpr-splited/$task_folder/mlep-mdpr-$language-test.txt" > "output/mlep-meta-mdpr-splited/$task_folder/$task_folder/test_ranking_metric_$language.txt" 2>&1; then
            echo "MDPR evaluation for language $language done"
        else
            echo "Failed to run MDPR evaluation for language $language"
        fi
    else
        echo "Invalid model choice. Please enter 'bm25' or 'mdpr'."
        exit 1
    fi

    echo "=============================="
done
