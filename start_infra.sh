#!/bin/bash
# Start the required infra to run a bench
cd $(dirname $0)
HERE=`readlink -e .`
distrib="lastbuild"
keypair="Jenkins"
set -e
set -x

function help {
    echo "Usage: $0 -m -d<distribution>"
    echo "  -d distribution : nuxeo distribution (default: lastbuild) (see bin/get-nuxeo-distribution.py for details)"
    echo "  -k keypair      : use this keypair instead of jenkins"
    exit 0
}

while getopts ":P:md:k:n:h" opt; do
    case $opt in
        h)
            help
            ;;
        d)
            distrib=$OPTARG
            ;;
        k)
            keypair=$OPTARG
            ;;
        :)
            echo "Option -$OPTARG requires an argument" >&2
            exit 1
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
    esac
done

function prepare_deploy_directory() {
  # Prepare distribution
  if [ -d $HERE/deploy ]; then
    rm -rf $HERE/deploy
  fi
  mkdir $HERE/deploy
}

function get_nuxeo_distribution() {
  sudo apt-get update
  sudo apt-get -q -y install python-lxml python-requests
  ./bin/get-nuxeo-distribution.py -v $distrib -o $HERE/deploy/nuxeo-distribution.zip
  cp /opt/build/hudson/instance.clid $HERE/deploy/
  echo "nuxeo-platform-importer" > $HERE/deploy/mp-list
  cp /opt/build/hudson/instance.clid $HERE/deploy/
}

function setup_ansible() {
  if [ ! -d venv ]; then
    virtualenv venv
  fi
  . venv/bin/activate
  pip install -r ansible/requirements.txt
  echo "---" > ansible/group_vars/all/custom.yml
  echo "keypair: $keypair" >> ansible/group_vars/all/custom.yml
}

function start_nodes() {
  pushd ansible
  ansible-playbook -i inventory.py start_nodes.yml -v
  popd
}

function setup_nodes() {
  pushd ansible
  ansible-playbook -i inventory.py setup.yml -v
  popd
}

# main -----------------------------------------
#
prepare_deploy_directory
# build_nuxeo
setup_ansible
start_nodes
setup_nodes
