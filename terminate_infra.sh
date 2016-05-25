#!/bin/bash
cd $(dirname $0)
set -e

. venv/bin/activate

function terminate_nodes() {
  pushd ansible
  ansible-playbook -i inventory.py terminate_nodes.yml -v
  popd
}

# ------------------------------
# main

teminate_nodes

