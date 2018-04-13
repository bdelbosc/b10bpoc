#!/bin/bash
# Start the required infra to run a bench
cd $(dirname $0)
HERE=`readlink -e .`
distrib_url="http://community.nuxeo.com/static/snapshots/nuxeo-server-tomcat-10.2-SNAPSHOT.zip"
clid=/opt/build/hudson/instance.clid
profile=b10m
set -e

function help {
    echo "Usage: $0 -i<profile> -c<instance.clid> -d<distribution>"
    echo "  -d distribution : nuxeo distribution (default: lastbuild) (see bin/get-nuxeo-distribution.py for details)"
    echo "  -i profile: b10m, b100m, b1b"
    echo "  -u nuxeo zip url, conflict with -d option"
    echo "  -c instance.clid : path to a nuxeo instance clid"
    exit 0
}

while getopts "d:c:u:i:h" opt; do
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
        i)
            profile=$OPTARG
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
  echo "nuxeo-jsf-ui" > $HERE/deploy/mp-list
  echo "nuxeo-platform-importer-1.9.1-SNAPSHOT" >> $HERE/deploy/mp-list
  echo "nuxeo-dam" >> $HERE/deploy/mp-list
  cp -r ./custom/bundles $HERE/deploy/ || /bin/true
  cp -r ./custom/lib $HERE/deploy/ || /bin/true
  cp -r ./custom/mp-add $HERE/deploy/ || /bin/true
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
  export ANSIBLE_PIPELINING=True
  export ANSIBLE_RETRIES=2
  export ANSIBLE_TIMEOUT=60
}

function run_ansible() {
  pushd ansible
  # --limit nuxeo
  #  --tags "hh"
  set -x
  ansible-playbook -vv  -i environments/$profile --extra-vars "nuxeo_distribution=$distrib_url" site.yml
  popd
}

# main -----------------------------------------
#
prepare_deploy_directory
get_nuxeo_distribution
setup_ansible
run_ansible
