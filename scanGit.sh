#!/bin/bash

# needs to setup cov-build:
. .profile

TOKEN=$(cat .cov_git_token)

cd coverity/git

# cleanup old state
git clean -dfx
git reset --hard
git fetch --all
git checkout origin/pu
name=$(git describe)
git merge --no-edit github/coverity
descrip="gitster/pu + stefanbeller/coverity"

# The script will be used in the next run:
cp scanGit.sh ../scanGit.sh

# prevents FLEX_ARRAY warnings from coverity:
echo "CFLAGS+=-DFLEX_ARRAY=65536" >config.mak
echo "CPPFLAGS+=-DFLEX_ARRAY=65536" >config.mak

cov-build --dir cov-int make
tar czvf git-${name}.tgz cov-int

curl --form project=git \
  --form token=$TOKEN \
  --form email=stefanbeller@googlemail.com \
  --form file=@git-${name}.tgz \
  --form version="${name}" \
  --form description="${descrip}" \
  https://scan.coverity.com/builds?project=git

echo $?

