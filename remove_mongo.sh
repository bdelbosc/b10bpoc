#!/bin/bash
cd $(dirname $0)
set -e

. venv/bin/activate

function remove_mongo() {
  pushd ansible
  ansible-playbook -vv -i inventory.py ./playbooks/remove_mongo.yml
  popd
}

# ------------------------------
# main
remove_mongo
