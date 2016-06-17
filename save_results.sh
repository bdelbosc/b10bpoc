#!/bin/bash
cd $(dirname $0)
set -e

. venv/bin/activate

function save_results() {
  pushd ansible
  ansible-playbook -vv -i inventory.py ./playbooks/save_results.yml
  popd
}

# ------------------------------
# main
save_results
