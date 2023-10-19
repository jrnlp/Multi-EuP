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

# Read user input for specific languages (if any)
read -p "Enter specific languages in uppercase separated by space (e.g., EN DE): " eval_languages

# Convert the input string to an array of languages
IFS=' ' read -ra eval_languages_array <<< "$eval_languages"

# If no specific languages are entered, use all languages from the list
if [ -z "$eval_languages" ]; then
    eval_languages=("EN" "DE" "FR" "ES" "PL" "IT" "PT" "NL" "RO" "EL" "HU" "HR" "SV" "BG" "FI" "CS" "SK" "DA" "SL" "MT" "LT" "LV" "ET" "GA")
else
    eval_languages=("${eval_languages_array[@]}")
fi

# Path to the Python script
python_script="scripts/mlep-bm25/gather_ranking_metric.py"
# Initialize languages_arg as an empty string
languages_arg=""

for lang in "${languages[@]}"; do
    languages_arg+="--languages $lang "
done

# Remove the trailing space
languages_arg="${languages_arg%" "}"


# Adjust the input directory based on the IR task type
if [[ "$ir_task" == "onevsone" ]]; then
    input_dir="output/mlep-meta-$model-splited/onevsone/"
else
    input_dir="output/mlep-meta-$model-splited/onevsmany/"
fi

# Run the Python script with the specified input and output directories
python $python_script --input_dir "$input_dir" --output_dir "output/mlep-meta-$model-splited/$ir_task/" $languages_arg

echo "DONE!"
