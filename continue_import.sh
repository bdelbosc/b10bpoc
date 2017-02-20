#!/bin/bash
cd $(dirname $0)
set -e

. venv/bin/activate

function continue_import() {
  pushd ansible
  ansible-playbook --tags continue -vv -i inventory.py ./playbooks/import.yml -v
  popd
}

# ------------------------------
# main
continue_import
