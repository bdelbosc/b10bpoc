#!/bin/bash
cd $(dirname $0)
HERE=`readlink -e .`
profile=b10m
set -e

. venv/bin/activate


function help {
    echo "Usage: $0 -i<profile>"
    echo "  -i profile: b10m, b100m, b1b"
    exit 0
}

while getopts "i:h" opt; do
    case $opt in
        h)
            help
            ;;
        i)
            profile=$OPTARG
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
    esac
done


function nuxeo_start() {
  pushd ansible
  ansible-playbook -i environments/$profile ./playbooks/nuxeo_start.yml -vv
  popd
}

function run_import() {
  pushd ansible
  ansible-playbook -vv  -i environments/$profile ./playbooks/import.yml -v
  #ansible-playbook --tags "continue" -vv -i inventory.py ./playbooks/import.yml -v
  popd
}

# ------------------------------
# main
nuxeo_start
run_import
