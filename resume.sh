#!/bin/bash
cd $(dirname $0)
set -e

. venv/bin/activate

function resume() {
  pushd ansible
  export ANSIBLE_HOST_KEY_CHECKING=False
  ansible-playbook -i inventory.py ./playbooks/resume.yml -v
  ansible-playbook -i inventory.py ./playbooks/wake_up.yml -v
  popd
}

# ------------------------------
# main
resume

