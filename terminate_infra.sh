#!/bin/bash
cd $(dirname $0)
set -e

. venv/bin/activate

function terminate() {
  pushd ansible
  ansible-playbook -i inventory.py ./playbooks/terminate.yml -v
  popd
}

# ------------------------------
# main
terminate

