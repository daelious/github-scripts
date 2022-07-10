#!/bin/bash
DATE=""
REPO=""
DRY_RUN=false
LOCAL_ONLY=false

function usage() {
  echo "github-tag-clean.sh -d/--date YYYY-MM-DD -r/--repo <repo_uri> {-D/--dry-run} {-l/--local-only}"
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