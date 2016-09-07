#!/bin/bash
# Start the required infra to setup elasticsearch and start indexing
cd $(dirname $0)
HERE=`readlink -e .`
set -e


function setup_ansible() {
  . venv/bin/activate
  # prevent ssh auth checking fingerprints
  export ANSIBLE_HOST_KEY_CHECKING=False
}

function run_elastic() {
  pushd ansible
  ansible-playbook -vv -i inventory.py ./start_elastic.yml -v
  popd
}

# ------------------------------
# main
setup_ansible
run_elastic

