#!/bin/bash
# Stop the bench infra
cd $(dirname $0)
set -e

. venv/bin/activate

function stop_nodes() {
  pushd ansible
  ansible-playbook -i inventory.py stop_nodes.yml -v
  popd
}

# ------------------------------
# main

stop_nodes

