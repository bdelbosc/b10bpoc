#!/bin/bash
# Start the required infra to run a bench
cd $(dirname $0)
HERE=`readlink -e .`
distrib_url="http://community.nuxeo.com/static/snapshots/nuxeo-distribution-tomcat-8.4-SNAPSHOT-nuxeo-cap.zip"
clid=/opt/build/hudson/instance.clid
set -e

function help {
    echo "Usage: $0 -c<instance.clid> -d<distribution>"
    echo "  -d distribution : nuxeo distribution (default: lastbuild) (see bin/get-nuxeo-distribution.py for details)"
    echo "  -u nuxeo zip url, conflict with -d option"
    echo "  -c instance.clid : path to a nuxeo instance clid"
    exit 0
}

while getopts "d:c:u:h" opt; do
    case $opt in
        h)
            help
            ;;
        d)
            distrib=$OPTARG
            ;;
        u)
            distrib_url=$OPTARG
            ;;
        c)
            clid=$OPTARG
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
  cp $clid $HERE/deploy/ || /bin/true
  echo "nuxeo-platform-importer" > $HERE/deploy/mp-list
  cp -r ./custom/bundles $HERE/deploy/ || /bin/true
  cp -r ./custom/bundles.indexing $HERE/deploy/ || /bin/true
  cp -r ./custom/templates $HERE/deploy/ || /bin/true
}

function get_nuxeo_distribution() {
  if [ ! -z $distrib ]; then
    #sudo apt-get update
    #sudo apt-get -q -y install python-lxml python-requests
    pip install lxml requests
    ./bin/get-nuxeo-distribution.py -v $distrib -o $HERE/deploy/nuxeo-distribution.zip
  fi
}

function setup_ansible() {
  if [ ! -d venv ]; then
    virtualenv venv
  fi
  . venv/bin/activate
  pip install -q -r ansible/requirements.txt
  # prevent ssh auth checking fingerprints
  export ANSIBLE_HOST_KEY_CHECKING=False
}

function run_ansible() {
  pushd ansible
  # --limit nuxeo
  #  --tags "hh"
  ansible-playbook -vv  -i inventory.py --extra-vars "nuxeo_distribution=$distrib_url" site.yml
  popd
}

# main -----------------------------------------
#
prepare_deploy_directory
get_nuxeo_distribution
setup_ansible
run_ansible
