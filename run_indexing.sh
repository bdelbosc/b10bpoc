#!/bin/bash
cd $(dirname $0)
set -e

. venv/bin/activate

function run_indexing() {
  pushd ansible
  ansible-playbook -vv -i inventory.py ./playbooks/index.yml -v
  popd
}

# ------------------------------
# main
run_indexing
