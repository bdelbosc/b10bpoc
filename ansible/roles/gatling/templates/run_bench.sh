#!/bin/bash -e
# Run the Nuxeo gatling bench and generates simulation reports
cd $(dirname $0)
HERE=`readlink -e .`

export PATH=/opt/maven3/bin:$PATH
TARGET=http://localhost:8080/nuxeo
NUXEO_GIT=https://github.com/nuxeo/nuxeo.git
SCRIPT_ROOT="./bench-scripts"
SCRIPT_DIR="nuxeo-distribution/nuxeo-distribution-cap-gatling-tests"
SCRIPT_PATH="$SCRIPT_ROOT/$SCRIPT_DIR"
SCRIPT_BRANCH=master
REDIS_DB=7
REPORT_PATH="./reports"
GAT_REPORT_VERSION=1.0-SNAPSHOT
GAT_REPORT_JAR=~/.m2/repository/org/nuxeo/tools/gatling-report/$GAT_REPORT_VERSION/gatling-report-$GAT_REPORT_VERSION-capsule-fat.jar
GRAPHITE_DASH=http://monitor1/dashboard/#nuxeo-bench
MUSTACHE_TEMPLATE=./data.mustache
CONCURRENT_USERS=`echo $(({{counts.nuxeo}}*44))`
# fail on any command error
set -e

function find_bench_scripts_branch() {
  local build_dir="$HERE/bin/.build/nuxeo"
  # if the distrib as been build from a branch use the same branch
  if [ -d $build_dir ]; then
    pushd $build_dir
    SCRIPT_BRANCH=`git symbolic-ref -q --short HEAD || git describe --tags --exact-match`
    popd
  fi
}


function clone_bench_scripts() {
  echo "Cloning bench script using $SCRIPT_BRANCH"
  mkdir $SCRIPT_ROOT
  pushd $SCRIPT_ROOT
  # shallow clone
  git init
  git remote add origin $NUXEO_GIT
  git pull --depth 1 origin $SCRIPT_BRANCH
  popd
}

function update_bench_scripts() {
  echo "Updating bench script using $SCRIPT_BRANCH"
  pushd $SCRIPT_ROOT
  set +e
  git pull --depth 20 origin $SCRIPT_BRANCH
  if [ $? -ne 0 ]; then
    popd
    set -e
    echo "Fail to update bench script, try to clone"
    rm -rf $SCRIPT_ROOT
    clone_bench_scripts
  else
    set -e
    popd
  fi
}

function clone_or_update_bench_scripts() {
  find_bench_scripts_branch
  if [ -d $SCRIPT_ROOT ]; then
    update_bench_scripts
  else
    clone_bench_scripts
  fi
}

function load_data_into_redis() {
  echo "Load bench data into Redis"
  pushd $SCRIPT_PATH
  echo flushdb | redis-cli -n $REDIS_DB
  # redis-cli don t like unbuffered input
  unset PYTHONUNBUFFERED
  python ./scripts/inject-arbres.py -d > /dev/null
  python ./scripts/inject-arbres.py -d | redis-cli -n $REDIS_DB --pipe
  export PYTHONUNBUFFERED=1
  popd
}

function gatling() {
  mvn -nsu test gatling:execute -Pbench -Durl=$TARGET -Dgatling.simulationClass=$@
}


function run_simulations() {
  echo "Run simulations"
  pushd $SCRIPT_PATH || exit 2
  mvn -nsu clean
  # init the users/group on all instance so we don't need to share a directory db
  curl -XPOST http://monitor1:8080s/  -d '{"what": "Gatling setup", "tags":"phases gatling"}'
{% for host in groups['nuxeo'] %}
  mvn -nsu test gatling:execute -Pbench -Durl=http://{{hostvars[host].private_ip}}:8080/nuxeo -Dgatling.simulationClass=org.nuxeo.cap.bench.Sim00Setup
{% endfor %}
  # init user ws and give some chance to graphite to init all metrics before mass import
  gatling "org.nuxeo.cap.bench.Sim25WarmUsersJsf"
  curl -XPOST http://monitor1:8080s/  -d '{"what": "Gatling import", "tags":"phases gatling"}'
  gatling "org.nuxeo.cap.bench.Sim10MassImport" -DnbNodes=100000
  #gatling "org.nuxeo.cap.bench.Sim10MassImport" -DnbNodes=1000000 -Dusers=$CONCURRENT_USERS
  curl -XPOST http://monitor1:8080s/  -d '{"what": "Gatling create folders", "tags":"phases gatling"}'
  gatling "org.nuxeo.cap.bench.Sim10CreateFolders"
  curl -XPOST http://monitor1:8080s/  -d '{"what": "Gatling create documents", "tags":"phases gatling"}'
  gatling "org.nuxeo.cap.bench.Sim20CreateDocuments" -Dusers=$CONCURRENT_USERS
  curl -XPOST http://monitor1:8080s/  -d '{"what": "Gatling create documents async", "tags":"phases gatling"}'
  gatling "org.nuxeo.cap.bench.Sim25WaitForAsync"
  curl -XPOST http://monitor1:8080s/  -d '{"what": "Gatling update documents", "tags":"phases gatling"}'
  gatling "org.nuxeo.cap.bench.Sim30UpdateDocuments" -Dusers=$CONCURRENT_USERS -Dduration=180
  #gatling "org.nuxeo.cap.bench.Sim30UpdateDocuments" -Dusers=$CONCURRENT_USERS -Dduration=400
  curl -XPOST http://monitor1:8080s/  -d '{"what": "Gatling update documents async", "tags":"phases gatling"}'
  gatling "org.nuxeo.cap.bench.Sim35WaitForAsync"
  curl -XPOST http://monitor1:8080s/  -d '{"what": "Gatling navigation", "tags":"phases gatling"}'
  gatling "org.nuxeo.cap.bench.Sim30Navigation" -Dusers=$CONCURRENT_USERS -Dduration=180
  curl -XPOST http://monitor1:8080s/  -d '{"what": "Gatling search", "tags":"phases gatling"}'
  gatling "org.nuxeo.cap.bench.Sim30Search" -Dusers=$CONCURRENT_USERS -Dduration=180
  curl -XPOST http://monitor1:8080s/  -d '{"what": "Gatling navigation jsf", "tags":"phases gatling"}'
  gatling "org.nuxeo.cap.bench.Sim30NavigationJsf" -Dduration=180
  curl -XPOST http://monitor1:8080s/  -d '{"what": "Gatling bench", "tags":"phases gatling"}'
  gatling "org.nuxeo.cap.bench.Sim50Bench" -Dnav.users=80 -Dnavjsf=5 -Dupd.user=15 -Dnavjsf.pause_ms=1000 -Dduration=180
  curl -XPOST http://monitor1:8080s/  -d '{"what": "Gatling CRUD", "tags":"phases gatling"}'
  gatling "org.nuxeo.cap.bench.Sim50CRUD" -Dusers=$CONCURRENT_USERS -Dduration=120
  curl -XPOST http://monitor1:8080s/  -d '{"what": "Gatling CRUD async", "tags":"phases gatling"}'
  gatling "org.nuxeo.cap.bench.Sim55WaitForAsync"
  # gatling "org.nuxeo.cap.bench.Sim80ReindexAll"
  # gatling "org.nuxeo.cap.bench.Sim30Navigation" -Dusers=100 -Dduration=120 -Dramp=50
  curl -XPOST http://monitor1:8080s/  -d '{"what": "Gatling terminated", "tags":"phases gatling"}'
  popd
}

function download_gatling_report_tool() {
  if [ ! -f $GAT_REPORT_JAR ]; then
    mvn -DgroupId=org.nuxeo.tools -DartifactId=gatling-report -Dversion=$GAT_REPORT_VERSION -Dclassifier=capsule-fat -DrepoUrl=http://maven.nuxeo.org/nexus/content/groups/public-snapshot dependency:get
  fi
}

function build_report() {
  report_root="${1%-*}"
  if [ -d $report_root ]; then
    report_root = "${report_root}-bis"
  fi
  mkdir $report_root || true
  mv $1 $report_root/detail
  java -jar $GAT_REPORT_JAR -o $report_root/overview -g $GRAPHITE_DASH $report_root/detail/simulation.log
  find $report_root -name simulation.log -exec gzip {} \;
}

function build_reports() {
  echo "Building reports"
  download_gatling_report_tool
  for report in `find $SCRIPT_PATH/target/gatling/results -name simulation.log`; do
    build_report `dirname $report`
  done
}

function move_reports() {
  echo "Moving reports"
  mv $SCRIPT_PATH/target/gatling/results/* $REPORT_PATH
}

function build_stat() {
  # create a yml file with all the stats
  set -x
  java -jar $GAT_REPORT_JAR -f -o $REPORT_PATH -n data.yml -t $MUSTACHE_TEMPLATE \
    -m import,create,createasync,nav,navjsf,search,update,updateasync,bench,crud,crudasync \
    $REPORT_PATH/sim10massimport/detail/simulation.log.gz \
    $REPORT_PATH/sim20createdocuments/detail/simulation.log.gz \
    $REPORT_PATH/sim25waitforasync/detail/simulation.log.gz \
    $REPORT_PATH/sim30navigation/detail/simulation.log.gz \
    $REPORT_PATH/sim30navigationjsf/detail/simulation.log.gz \
    $REPORT_PATH/sim30search/detail/simulation.log.gz \
    $REPORT_PATH/sim30updatedocuments/detail/simulation.log.gz \
    $REPORT_PATH/sim35waitforasync/detail/simulation.log.gz \
    $REPORT_PATH/sim50bench/detail/simulation.log.gz \
    $REPORT_PATH/sim50crud/detail/simulation.log.gz \
    $REPORT_PATH/sim55waitforasync/detail/simulation.log.gz
  echo "nuxeonodes: {{counts.nuxeo}}" >> $REPORT_PATH/data.yml
  echo "dbnodes: {{counts.mongodb}}" >> $REPORT_PATH/data.yml
  echo "esnodes: {{counts.elastic}}" >> $REPORT_PATH/data.yml
  echo "nuxeotype: \"{{types.nuxeo}}\"" >> $REPORT_PATH/data.yml
  echo "dbtype: \"{{types.mongodb}}\"" >> $REPORT_PATH/data.yml
  echo "estype: \"{{types.elastic}}\"" >> $REPORT_PATH/data.yml
  echo "distribution: \"{{nuxeo_distribution}}\"" >> $REPORT_PATH/data.yml
  echo "bench_suite: \"{{bench}}\"" >> $REPORT_PATH/data.yml
  echo "classifier: \"{{ hostvars[groups['nuxeo'][0]]['bench_tag'] }}\"" >> $REPORT_PATH/data.yml
  echo "default_category: \"misc\"" >> $REPORT_PATH/data.yml
  echo "" >> $REPORT_PATH/data.yml
  echo "build_number: $BUILD_NUMBER" >> $REPORT_PATH/data.yml
  echo "build_url: \"$BUILD_URL\"" >> $REPORT_PATH/data.yml
  echo "job_name: \"$JOB_NAME\"" >> $REPORT_PATH/data.yml
  echo "dbprofile: \"$dbprofile\"" >> $REPORT_PATH/data.yml
  echo "" >> $REPORT_PATH/data.yml
  set +x
}

function clean() {
  rm -rf $REPORT_PATH || true
  mkdir $REPORT_PATH
}

# -------------------------------------------------------
# main
#
clean
clone_or_update_bench_scripts
load_data_into_redis
run_simulations
set +e
build_reports
move_reports
build_stat
