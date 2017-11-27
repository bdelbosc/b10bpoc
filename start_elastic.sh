#!/bin/bash
# Start the required infra to setup elasticsearch and start indexing
cd $(dirname $0)
HERE=`readlink -e .`
profile=b10m
set -e

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

function setup_ansible() {
  . venv/bin/activate
  # prevent ssh auth checking fingerprints
  export ANSIBLE_HOST_KEY_CHECKING=False
}

function run_elastic() {
  pushd ansible
  ansible-playbook -vv -i environments/$profile ./start_elastic.yml -v
  popd
}

# ------------------------------
# main
setup_ansible
run_elastic

