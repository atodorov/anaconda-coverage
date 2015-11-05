#!/usr/bin/bash

DIRNAME=`dirname $0`
JENKINS=$1

if [ -z "$JENKINS" ]; then
    echo "usage: $0 JENKINS_URL"
    exit 1
fi

pushd $DIRNAME

for f in ".coverage" \
        "tests/coverage-report.log" \
        "tests/cppcheck/runcppcheck.log" \
        "tests/glade/run_glade_tests.log" \
        "tests/kickstart_tests/scripts/run_kickstart_tests.log" \
        "tests/nosetests.log" \
        "tests/nosetests_root.log" \
        "tests/pylint/runpylint.py.log" \
        "tests/storage/run_storage_tests.py.log" \
        "tests/test-suite.log"; do

    tgt=`basename $f`
    wget "$JENKINS/job/anaconda-x86_64/lastSuccessfulBuild/artifact/$f" -O "$tgt" 2>/dev/null
    if [ "$?" -ne "0" ]; then
        echo "Downloading $f failed, exitting ..."
        exit 2
    fi
done

DATE=`date --rfc-3339=date`
DIFF=`git diff`
# changes detected
if [ -n "$DIFF" ]; then
    git commit -a -m "Updated coverage results from $DATE"
    git tag "anaconda-$DATE"
    git push --tags origin master
fi

popd
