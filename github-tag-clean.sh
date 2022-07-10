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