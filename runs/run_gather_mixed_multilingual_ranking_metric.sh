#!/bin/bash

# Read user input for flag
read -p "Enter 'full' for the full version or 'toy' for the toy version: " version_flag

# Check user input and set variables accordingly
if [[ "$version_flag" == "full" ]]; then
    variant="full"
elif [[ "$version_flag" == "toy" ]]; then
    variant="toy"
else
    echo "Invalid input. Using 'toy' version by default."
    variant="toy"
fi

# Pass the input to the Python script as a space-separated string
python_script="scripts/mlep-bm25/gather_mixed_multilingual_ranking_metric.py"
languages_arg=""

# Read user input for specific languages (if any)
read -p "Enter specific languages in uppercase separated by space (e.g., EN DE): " eval_languages

# Use the default language list if no specific languages are entered
if [ -z "$eval_languages" ]; then
    eval_languages=("EN" "DE" "FR" "ES" "PL" "IT" "PT" "NL" "RO" "EL" "HU" "HR" "SV" "BG" "FI" "CS" "SK" "DA" "SL" "MT" "LT" "LV" "ET" "GA")
else
    languages_arg="--languages \"$eval_languages\""
fi

echo "Running Python script gather ranking metric for languages: $eval_languages"
python $python_script --input_dir "output/mlep-meta-bm25-$variant/" --output_dir "output/mlep-meta-bm25-$variant/" $languages_arg

echo "DONE!"
