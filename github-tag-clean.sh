#!/bin/bash
# Vars for the Arguments
DATE=""
REPO=""
DRY_RUN=false
LOCAL_ONLY=false

# Traps CTRL-C and exits out of the script.
trap ctrl_c INT
function ctrl_c() {
    echo "The execution of the script was aborted due to user entering Ctrl-c"
    exit -1
}

# Basic usage prompt.
function usage() {
    echo "github-tag-clean.sh -d/--date YYYY-MM-DD -r/--repo <repo_uri> {-D/--dry-run} {-l/--local-only}"
}

function validate() {
    NOW=$(date +%Y-%m-%d)
    URL_REGEX="(https|git):\/\/github.com\/[a-zA-Z0-9]+\/[a-zA-Z0-9]+(\/|.git)?"
    
    # Validate the date is present and not in the future.
    if [ -z $DATE ]; then
        echo "Date is required."
        elif [[ $DATE > $NOW ]]; then
        echo "Date cannot be in the future"
        exit -1
    fi
    
    # Validates the repo arguments presence and that it fits the expected 
    # github url formats.
    if [ -z $REPO ]; then
        echo "Repository must be specified."
        elif [[ ! $REPO =~ $URL_REGEX ]]; then
        echo "Repository is invalid."
        exit -1
    fi
}

function remove_tags() { 
    PROJECT_NAME=$(basename $REPO)
    PROJECT_NAME=${PROJECT_NAME%.*} # Adjust in case the .git path is used.
    git clone --quiet $REPO         # Quiet clone to reduce the chatter.
    cd $PROJECT_NAME
    
    # Determine Latest Tag
    LATEST_TAG=$(git describe --tags --abbrev=0)
    
    # Pulls all tags for the currently clone repo/branch.
    TAGS_QUERY=$(git for-each-ref --sort=taggerdate --format='%(tag)___%(taggerdate:raw)' refs/tags \
        | grep -v '^___' \
    | awk 'BEGIN {FS="___"} {t=strftime("%Y-%m-%d",$2); printf("%s %s\n", t, $1)}')
    
    declare -a TAGS
    declare -a TAGS_TO_REMOVE
    TAGS=($TAGS_QUERY)
    
    # For each tag in the array, we check that it is older than the provided
    # date, and that it is _not_ the latest tag. If it meets that criteria,
    # we add it to the TAGS_TO_REMOVE array for further work.
    for ((index=0; index < ${#TAGS[*]}; index=index+2));
    do
        TAG_DATE=$(date -d "${TAGS[$index]}" +%s)
        if [[ $TAG_DATE < $DATE ]] && [ "$LATEST_TAG" != "${TAGS[($index+1)]}" ]; then
            if [ "$LATEST_TAG" != "${TAGS[($index+1)]}" ]; then
                TAGS_TO_REMOVE+=("${TAGS[($index+1)]}")
            fi
        fi
    done
    
    # For this section, if we are running in dry mode, we will output the tags
    # only (to stdout for easier redirection if needed).
    if $DRY_RUN == true; then
        echo "The following tags would be deleted:"
    fi

    # This will loop through the TAGS_TO_REMOVE array and if we aren't doing a
    # dry run, we will do the removal.
    for tag in ${TAGS_TO_REMOVE[@]}; do
        if $DRY_RUN == false; then
            git tag -d "$tag"

            # If we're running locally we can skip pushing to the remote.
            if $LOCAL_ONLY == false; then
                git push --delete origin "$tag"
            fi
        else
            echo "$tag"
        fi
    done
    
    # This is just so we don't fill a drive with a bunch of these repos
    # unnecessarily.
    cd ..
    rm -rf $PROJECT_NAME
}

# Store the options and flags in variables for readability.
short_args=d:r:Dlh
long_args=date:,repo:,dry-run,local-only,help
SCRIPT_ARGS=$(getopt -o $short_args --long $long_args -- "$@")
eval set -- "$SCRIPT_ARGS"

while :; do
    case "${1}" in
        -d|--date       ) DATE=$2;                  shift 2 ;;
        -r|--repo       ) REPO=$2;                  shift 2 ;;
        -D|--dry-run    ) DRY_RUN=true;             shift   ;;
        -l|--local-only ) LOCAL_ONLY=true;          shift   ;;
        -h|--help       ) usage;                    exit    ;;
        --              ) shift;                    break   ;;
        *               ) usage;                    exit    ;;
    esac
done

validate
remove_tags