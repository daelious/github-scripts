#!/bin/bash

REPOS=("" "https://github.com/facebook/react" "https://github.com/facebook/react.git" "git://github.com/facebook/react.git" "git://github.com/facebook")
DATES=("" "07/07/2022" "2022-05-01" "2023-07-09")


for repo in "${REPOS[@]}"
do
    for date in "${DATES[@]}"
    do
        echo "====================================="
        echo "  Testing ${repo} - ${date}"
        echo "====================================="
        ./github-tag-clean.sh --repo=$repo --date=$date --local-only --dry-run > $repo_$date.test.txt
        echo "====================================="
    done
done