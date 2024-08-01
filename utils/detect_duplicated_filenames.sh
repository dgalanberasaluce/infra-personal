#!/bin/zsh

# Detect duplicated filenames (by name) in different folders
# MacOs compatible. Commented out linux compatible coommand

# Temporary files to store intermediate results
temp_file_all=$(mktemp)
temp_file_dirs=$(mktemp)

# Find all files and their directories
find . -type f -exec sh -c 'basename "$1" && dirname "$1"' sh {} \; > "$temp_file_all"

# (Linux/bash) Find all files and their directories 
# find . -type f -printf '%f %h\n' > "$temp_file_all"

# Extract file names and their directories, sort them and find duplicates
awk 'NR % 2 == 1 { file_name = $0 } NR % 2 == 0 { print file_name, $0 }' "$temp_file_all" | sort -k1,1 | awk 'BEGIN { prev_file_name = ""; prev_dir = "" } { if ($1 == prev_file_name && $2 != prev_dir) { print $2 } prev_file_name = $1; prev_dir = $2 }' >> "$temp_file_dirs"

# (Linux/bash) Extract file names and their directories, sort them and find duplicates
#awk '{print $1}' "$temp_file_all" | sort | uniq -d | while read -r file_name; do
#    grep "^$file_name " "$temp_file_all" | awk '{print $2}' >> "$temp_file_dirs"
#done


# Sort and find duplicate directories
sort "$temp_file_dirs" | uniq -d

# Clean up temporary files
rm "$temp_file_all" "$temp_file_dirs"
