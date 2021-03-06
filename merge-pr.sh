#!/bin/bash
#
#    Copyright © 2016 Zetok Zalbavar
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Script for merging pull requests. Works only when there are no merge
# conflicts. Assumes that working dir is a qTox git repo.
#
# Requires SSH key that github accepts and GPG set to sign merge commits.

# usage:
#   ./$script $pr_number $optional_message
#
#
# $pr_number – number of the PR as shown on GH
# $optional_message – message that is going to be put in merge commit,
#       before the appended shortlog.
#

PR=$1

# make sure to add newlines to the message, otherwise merge message
# will not look well
if [[ ! -z $2 ]]
then
    OPT_MSG="
$2
"
fi


# FIXME: ↓
#[[ ${PR} =~ "^[:digit:]+$" ]] || echo "Not a PR number!" && exit 1

# list remotes, and if there's no tux3 one, add it
if  ! git remote | grep original > /dev/null
then
    git remote add original git@github.com:tux3/qTox.git
fi

# print the message only if the merge was successful
after_merge_msg() {
    echo ""
    echo "PR #$PR was merged into «merge$PR» branch."
    echo "To compare with master:"
    echo "git diff master..merge$PR"
    echo ""
    echo "To push that to master on github:"
    echo "git checkout master && git merge --ff merge$PR && git push original master"
    echo ""
    echo "After pushing to master, delete branches:"
    echo ""
    echo "git branch -d {merge,}$PR"
}


git fetch original && \
git checkout master && \
git rebase original/master master && \
git fetch original pull/$PR/head:$PR && \
git checkout master -b merge$PR && \
git merge --no-ff -S $PR -m "Merge pull request #$PR
$OPT_MSG
$(git shortlog master..$PR)" && \
after_merge_msg
