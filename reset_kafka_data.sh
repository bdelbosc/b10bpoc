#!/bin/bash
cd $(dirname $0)
set -e

. venv/bin/activate

function reset_kafka() {
  pushd ansible
  ansible-playbook -vv -i inventory.py ./playbooks/reset_kafka.yml
  popd
}

# ------------------------------
# main
reset_kafka
