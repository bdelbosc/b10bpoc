#!/bin/bash
cd $(dirname $0)
set -e

. venv/bin/activate

function reset_mongo() {
  pushd ansible
  ansible-playbook -vv -i inventory.py ./playbooks/reset_mongo.yml
  popd
}

# ------------------------------
# main
reset_mongo
