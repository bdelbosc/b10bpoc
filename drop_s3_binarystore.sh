#!/bin/bash
cd $(dirname $0)
set -e

. venv/bin/activate

function drop_s3() {
  pushd ansible
  ansible-playbook -vv -i inventory.py ./playbooks/drop_s3.yml
  popd
}

# ------------------------------
# main
drop_s3
