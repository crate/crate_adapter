#!/bin/bash
#
# Licensed to CRATE Technology GmbH ("Crate") under one or more contributor
# license agreements.  See the NOTICE file distributed with this work for
# additional information regarding copyright ownership.  Crate licenses
# this file to you under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.  You may
# obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
# License for the specific language governing permissions and limitations
# under the License.
#
# However, if you have executed another commercial license agreement
# with Crate these terms will supersede the license and you may use the
# software solely pursuant to the terms of the relevant commercial agreement.

function p_ok() {
  echo -e "\033[32m$1\033[0m";
}

function p_err() {
  echo -e "\033[31;1m$1\033[0m";
}

function exit_on_error() {
   p_err "$1"
   exit 1
}

WORKING_DIR=`readlink -f $(dirname $0)/..`


# check if Go is installed
which go > /dev/null
if [ $? -gt 1 ]
then
   exit_on_error "$0 requires Go to be installed."
fi

# check if everything is committed
CLEAN=`git status -s`
if [ ! -z "$CLEAN" ]
then
   exit_on_error "Working directory not clean. Please commit all changes before tagging"
fi

p_ok "Fetching origin ..."
git fetch origin > /dev/null

# get current branch
BRANCH=`git branch | grep "^*" | cut -d " " -f 2`
p_ok "Current branch is $BRANCH"

# check if master == origin/master
LOCAL_COMMIT=`git show --format="%H" $BRANCH`
ORIGIN_COMMIT=`git show --format="%H" origin/$BRANCH`

if [ "$LOCAL_COMMIT" != "$ORIGIN_COMMIT" ]
then
   exit_on_error "Local $BRANCH is not up to date"
fi

# build project locally
go build $WORKING_DIR

# check if tag to create has already been created
VERSION=`crate_adapter -version`
rm crate_adapter
EXISTS=`git tag | grep $VERSION`
if [ "$VERSION" == "$EXISTS" ]
then
   exit_on_error "Revision $VERSION already tagged"
fi

# check if VERSION is in head of CHANGES.txt
REV_NOTE=`grep "[0-9/]\{10\} $VERSION" CHANGES.rst`
if [ -z "$REV_NOTE" ]
then
    exit_on_error "No notes for revision $VERSION found in CHANGES.rst"
fi

p_ok "Creating tag $VERSION ..."
git tag -a "$VERSION" -m "Release tag for revision $VERSION"
git push --tags

p_ok "Done"