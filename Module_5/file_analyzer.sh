#!/bin/bash

# Creating Log file for errors
ERROR_LOG="errors.log"

# Implentation of help function using Here Document
show_help() {
    cat << EOF
Usage: $0 [OPTIONS]

Options:
  -d <directory>   Search for files in the specified directory recursively.
  -k <keyword>     Keyword to search for in files.
  -f <file>        Search for the keyword in the specified file.
  --help           Display this help menu.

Example:
  $0 -d /path/to/dir -k keyword
  $0 -f filename.txt -k keyword
EOF
}

# Function to recursively search for a keyword in files within a directory
search_recursive() {
    local dir="$1"
    local keyword="$2"
    
    for file in "$dir"/*; do
        if [[ -d "$file" ]]; then
            search_recursive "$file" "$keyword" 
        elif [[ -f "$file" ]]; then
            if grep -q "$keyword" "$file" 2>/dev/null; then
                echo "Found in: $file"
            fi
        fi
    done
}

# search function for a keyword in a specific file

search_in_file() {
    local file="$1"
    local keyword="$2"
    grep "$keyword" "$file" <<< "" 2>/dev/null && echo "Found in: $file" || echo "Not found in: $file"
}

# Functions to Validate inputs using Regular Expressions

validate_input() {
    local file="$1"
    local keyword="$2"
    
    if [[ ! -e "$file" ]]; then
        echo "Error: File '$file' does not exist." | tee -a "$ERROR_LOG"
        exit 1
    fi
    
    if [[ -z "$keyword" || ! "$keyword" =~ ^[a-zA-Z0-9]+$ ]]; then
        echo "Error: Invalid keyword. Only alphanumeric characters allowed." | tee -a "$ERROR_LOG"
        exit 1
    fi
}

# arguments using getopts

while getopts "d:k:f:-:" opt; do
    case "$opt" in
        d) directory="$OPTARG" ;;
        k) keyword="$OPTARG" ;;
        f) file="$OPTARG" ;;
        -) case "$OPTARG" in
               help) show_help; exit 0 ;;
               *) echo "Invalid option: --$OPTARG" | tee -a "$ERROR_LOG"; exit 1 ;;
           esac ;;
        ?) show_help; exit 1 ;;
    esac
done

# Ensure necessary arguments are provided
if [[ -z "$keyword" ]]; then
    echo "Error: Keyword is required." | tee -a "$ERROR_LOG"
    show_help
    exit 1
fi

# Process based on the provided arguments
if [[ -n "$directory" ]]; then
    if [[ -d "$directory" ]]; then
        search_recursive "$directory" "$keyword"
    else
        echo "Error: Directory '$directory' does not exist." | tee -a "$ERROR_LOG"
        exit 1
    fi
elif [[ -n "$file" ]]; then
    validate_input "$file" "$keyword"
    search_in_file "$file" "$keyword"
else
    echo "Error: Either a file (-f) or directory (-d) must be specified." | tee -a "$ERROR_LOG"
    show_help
    exit 1
fi


echo "Script executed successfully. Exit status: $?"
