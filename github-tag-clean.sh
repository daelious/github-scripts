#!/bin/bash
DATE=""
REPO=""
DRY_RUN=false
LOCAL_ONLY=false

trap ctrl_c INT
function ctrl_c() {
  echo "The execution of the script was aborted due to user entering Ctrl-c"
  exit -1
}

function usage() {
  echo "github-tag-clean.sh -d/--date YYYY-MM-DD -r/--repo <repo_uri> {-D/--dry-run} {-l/--local-only}"
}

function validate() { 
  NOW=$(date +%Y-%m-%d)
  URL_REGEX="(https|git):\/\/github.com\/[a-zA-Z0-9]+\/[a-zA-Z0-9]+(\/|.git)?"
  if [ -z $DATE ]; then
    echo "Date is required."
  elif [[ $DATE > $NOW ]]; then
    echo "Date cannot be in the future"
    exit -1    
  fi

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
  git clone --quiet $REPO
  cd $PROJECT_NAME

  # Determine Latest Tag
  LATEST_TAG=$(git describe --tags --abbrev=0)

  TAGS_QUERY=$(git for-each-ref --sort=taggerdate --format='%(tag)___%(taggerdate:raw)' refs/tags \
  | grep -v '^___' \
  | awk 'BEGIN {FS="___"} {t=strftime("%Y-%m-%d",$2); printf("%s %s\n", t, $1)}')
 
  declare -a TAGS
  declare -a TAGS_TO_REMOVE
  TAGS=($TAGS_QUERY)

 
  # Cleanup
  cd ..
  rm -rf $PROJECT_NAME 
}

short_args=d:r:Dlh
long_args=date:,repo:,dry-run,local-only,help
SCRIPT_ARGS=$(getopt -o $short_args --long $long_args -- "$@")
eval set -- "$SCRIPT_ARGS"

while :; do
  case "${1}" in
    -d|--date       ) DATE=$2;   shift 2 ;;
    -r|--repo       ) REPO=$2;                  shift 2 ;;
    -D|--dry-run    ) DRY_RUN=true              shift   ;;
    -l|--local-only ) LOCAL_ONLY=true           shift   ;;
    -h|--help       ) usage                     exit    ;;
    --              ) shift;                    break   ;;
    *               ) usage                     exit    ;;
  esac  
done