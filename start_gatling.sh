#!/bin/bash
# Start the required infra to run gatling tests
cd $(dirname $0)
HERE=`readlink -e .`
set -e


function setup_ansible() {
  . venv/bin/activate
  # prevent ssh auth checking fingerprints
  export ANSIBLE_HOST_KEY_CHECKING=False
}

function start_gatling() {
  pushd ansible
  ansible-playbook -vv -i inventory.py ./start_gatling.yml -v
  popd
}

# ------------------------------
# main
setup_ansible
start_gatling
