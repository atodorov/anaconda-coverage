#!/usr/bin/bash

DIRNAME=`dirname $0`
JENKINS=$1

if [ -z "$JENKINS" ]; then
    echo "usage: $0 JENKINS_URL"
    exit 1
fi

pushd $DIRNAME

for f in ".coverage" \
        "result/coverage-report.log" \
        "result/runcppcheck.log" \
        "result/gettext_tests.log" \
        "result/run_glade_tests.py.log" \
        "result/run_install_test.log" \
        "result/nosetests.log" \
        "result/nosetests_root.log" \
        "result/runpylint.py.log" \
        "result/run_storage_tests.py.log" \
        "result/test-suite.log"; do

    tgt=`basename $f`
    wget "$JENKINS/job/anaconda-x86_64/lastSuccessfulBuild/artifact/$f" -O "$tgt" 2>/dev/null
    if [ "$?" -ne "0" ]; then
        echo "Downloading $f failed ..." | systemd-cat -t $DIRNAME -p err
        git checkout "$tgt"
    fi
done

DATE=`date --rfc-3339=date`
DIFF=`git diff`
# changes detected
if [ -n "$DIFF" ]; then
    git commit -a -m "Updated test results from $DATE"
    git tag "anaconda-$DATE"
    git push --tags origin master
    echo "git push" | systemd-cat -t $DIRNAME -p info
fi

popd
