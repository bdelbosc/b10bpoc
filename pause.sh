#!/bin/bash
cd $(dirname $0)
set -e

. venv/bin/activate

function pause() {
  pushd ansible
  ansible-playbook -i inventory.py ./playbooks/pause.yml -v
  popd
}

# ------------------------------
# main
pause

