#!/bin/bash
cd $(dirname $0)
set -e

. venv/bin/activate

function nuxeo_start() {
  pushd ansible
  ansible-playbook -i inventory.py ./playbooks/nuxeo_start.yml -vv
  popd
}

function run_import() {
  pushd ansible
  ansible-playbook -vv -i inventory.py ./playbooks/import.yml -v
  popd
}

# ------------------------------
# main
#nuxeo_start
run_import
