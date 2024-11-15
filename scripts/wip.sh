#!/bin/bash

# Usage:  create WIP commit
#         push to current branch
#         reconcile the cluster with flux
#         remove previous WIP commit

echo -n "Checking variables..."

if [ ! -d "$ROOT_DIR" ]; then
    echo ""
    echo "$ROOT_DIR does not exist. Make sure your env is loaded!"
    exit 1
fi

cd $ROOT_DIR

echo " Finished."

# Source: https://github.com/ohmyzsh/ohmyzsh/blob/1546e1226a7b739776bda43f264b221739ba0397/lib/git.zsh#L68-L81
function git_current_branch {
  local ref
  ref=$(command git symbolic-ref --quiet HEAD 2> /dev/null)
  local ret=$?
  if [[ $ret != 0 ]]; then
    [[ $ret == 128 ]] && return  # no git repo.
    ref=$(command git rev-parse --short HEAD 2> /dev/null) || return
  fi
  echo "${ref#refs/heads/}"
}

function gwip {
  git add -A
  git rm $(git ls-files --deleted) 2> /dev/null
  git commit --no-gpg-sign -m "--wip-- [skipci]"
}

function gunwip {
  git log -n 1 | grep -q -c "\-\-wip\-\-" && git reset HEAD~1
}

function gpcf {
  git push --force-with-lease origin "$(git_current_branch)"
}

echo "Encrypting secrets"
echo ""
task sops:encrypt-all
echo ""
gwip
gpcf
echo "Reconciling flux"
echo ""
task flux:reconcile cluster=arc1
echo ""
echo "Git Log:"
gunwip
echo ""
echo "Waiting..."
echo ""
sleep 5
echo "Flux Status:"
flux get all -A
echo ""
