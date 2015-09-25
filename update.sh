#!/usr/bin/bash

DIRNAME=`dirname $0`
JENKINS=$1

if [ -z "$JENKINS" ]; then
    echo "usage: $0 JENKINS_URL"
    exit 1
fi

pushd $DIRNAME

wget "$JENKINS/job/anaconda-x86_64/lastSuccessfulBuild/artifact/tests/coverage-report.log" -O coverage-report.log 2>/dev/null
if [ "$?" -ne "0" ]; then
    echo "Download failed, exitting ..."
    exit 2
fi

wget "$JENKINS/job/anaconda-x86_64/lastSuccessfulBuild/artifact/.coverage" -O .coverage 2>/dev/null
if [ "$?" -ne "0" ]; then
    echo "Download failed, exitting ..."
    exit 2
fi


DATE=`date --rfc-3339=date`
DIFF=`git diff`
# changes detected
if [ -n "$DIFF" ]; then
    git commit -a -m "Updated coverage results from $DATE"
    git tag "anaconda-$DATE"
    git push --tags origin master
fi

popd
