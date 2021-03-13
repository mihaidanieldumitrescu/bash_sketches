#!/usr/bin/env bash

GIT_INIT_FOLDER=/tmp/test_force_with_lease.git
master_branch_name=master
derivate_branch_name=derivate_branch

# TODO commit name should include branchname
# simulate conflict by adding a dummy file and deleting random lines

function reset {
  echo "reset"
  echo

  rm -rf $GIT_INIT_FOLDER && echo "removed directory $GIT_INIT_FOLDER"
  rm -rf /tmp/$master_branch_name && echo "removed directory /tmp/$master_branch_name"
  rm -rf /tmp/$derivate_branch_name && echo "removed directory /tmp/$derivate_branch_name"
  echo
}

# git init --bare
function create_local_remote {
  echo "create_local_remote"
  echo

  mkdir $GIT_INIT_FOLDER
  cd $GIT_INIT_FOLDER

  git init --bare 1> /dev/null
  echo
}

# make two separate working spaces
function clone_repos {
  echo "clone_repos"
  echo

  cd /tmp

  git clone $GIT_INIT_FOLDER $master_branch_name 2> /dev/null

  commit_test_file common_test_file $master_branch_name 2> /dev/null
  push $master_branch_name  2> /dev/null

  cd /tmp
  git clone $GIT_INIT_FOLDER $derivate_branch_name 2> /dev/null

}

# create a derivate branch
function create_separate_branch {
  echo "create_separate_branch"
  echo

  cd /tmp/$derivate_branch_name
  git checkout -b $derivate_branch_name  1> /dev/null
  git push --set-upstream origin derivate_branch  1> /dev/null
  push $derivate_branch_name 1> /dev/null

  echo
}


function amend_last_commit {
  echo "amend_last_commit"
  echo

  commit_msg=$1
  branch_name=$2

  cd /tmp/$branch_name
  git commit --amend -m "$1"

  echo
}

function commit_test_file {
  echo "commit_test_file"
  echo

  test_file_name=$1
  branch_name=$2

  cd /tmp/$branch_name

  touch $test_file_name
  git add $test_file_name

  git commit -m "Added '$test_file_name'"
}

function push_forced_with_lease_dry_run {
  echo "push_forced_with_lease_dry_run"
  echo

  branch_name=$1

  cd /tmp/master
  git log

  cd /tmp/$branch_name
  git remote show origin

  git push --force-with-lease # --dry-run

  cd /tmp/master
  git pull
  git log

}

function push_dry_run {
  echo "push_dry_run"
  echo

  branch_name=$1

  cd /tmp/$branch_name

  git push --dry-run
}

function push {
  branch_name=$1

  echo "git push origin $branch_name"
  echo

  cd /tmp/$branch_name
  git push
}

function create_separate_branch_with_one_commit {
  echo "simulate_commits"
  echo

  create_separate_branch

  # forward derivate branch with one commit and update remote
  commit_test_file only_on_derivate_branch $derivate_branch_name
  push $derivate_branch_name
}

function create_commit_on_master_and_push {
  # forward master with one commit and update remote
  commit_test_file "newer_commit_master_remote" $master_branch_name
  push $master_branch_name

  # amend commit
  amend_last_commit "Amended commit" $derivate_branch_name
}

function create_commit_on_derivate_and_rebase {
  # forward master with one commit and update remote
  commit_test_file "newer_commit_master_remote" $master_branch_name
  push $master_branch_name

  # amend commit
  amend_last_commit "Amended commit" $derivate_branch_name
}

reset

# GIT init bare
create_local_remote

# git clone twice, one for master, one for derivate, with destination in /tmp
clone_repos


create_separate_branch_with_one_commit
create_commit_on_master_and_push # master is now newer than derived/master

push_dry_run $derivate_branch_name
push_forced_with_lease_dry_run $derivate_branch_name
