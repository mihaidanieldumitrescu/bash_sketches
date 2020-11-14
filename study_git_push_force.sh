#!/usr/bin/env bash

GIT_INIT_FOLDER=/tmp/test_force_with_lease.git
master_branch_name=master
derivate_branch_name=derivate_branch

function reset {
  echo "reset"
  echo

  rm -rf $GIT_INIT_FOLDER && echo "removed directory $GIT_INIT_FOLDER"
  rm -rf /tmp/$master_branch_name && echo "removed directory /tmp/$master_branch_name"
  rm -rf /tmp/$derivate_branch_name && echo "removed directory /tmp/$derivate_branch_name"
}

function create_local_remote {
  echo "create_local_remote"
  echo

  mkdir $GIT_INIT_FOLDER
  cd $GIT_INIT_FOLDER

  git init --bare
}

function clone_repos {
  echo "clone_repos"
  echo

  cd /tmp

  git clone $GIT_INIT_FOLDER $master_branch_name

  commit_test_file common_test_file $master_branch_name
  push $master_branch_name

  cd /tmp
  git clone $GIT_INIT_FOLDER $derivate_branch_name
}

function simulate_commits {
  echo "simulate_commits"
  echo

  create_separate_branch

  # forward derivate branch with one commit and update remote
  commit_test_file only_on_derivate_branch $derivate_branch_name
  push $derivate_branch_name

  # forward master with one commit and update remote
  commit_test_file "newer_commit_master_remote" $master_branch_name
  push $master_branch_name

  # amend commit
  amend_last_commit "Amended commit" $derivate_branch_name
}

function create_separate_branch {
  echo "create_separate_branch"
  echo

  cd /tmp/$derivate_branch_name
  git checkout -b $derivate_branch_name
  git push --set-upstream origin derivate_branch
  push $derivate_branch_name
}

function amend_last_commit {
  echo "amend_last_commit"
  echo

  commit_msg=$1
  branch_name=$2

  cd /tmp/$branch_name
  git commit --amend -m "$1"

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

  cd /tmp/$branch_name
  git push --force-with-lease --dry-run
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

reset
echo
create_local_remote
echo
clone_repos
echo
simulate_commits
echo

echo "Initialization done"

push_dry_run $derivate_branch_name
push_forced_with_lease_dry_run $derivate_branch_name
