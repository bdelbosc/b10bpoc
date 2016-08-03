#!/bin/bash
# Start the required infra to setup elasticsearch and start indexing
cd $(dirname $0)
HERE=`readlink -e .`
set -e

. venv/bin/activate

function run_elastic() {
  pushd ansible
  ansible-playbook -vv -i inventory.py ./start_elastic.yml -v
  popd
}

# ------------------------------
# main
run_elastic

