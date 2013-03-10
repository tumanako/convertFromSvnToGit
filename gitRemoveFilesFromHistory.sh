#!/bin/bash
# Copyright: Public Domain (PD)

# immediately exit in case of an error
set -o errexit

# author: David Underhill, hoijui

# Script to permanently delete files/folders from your git repository.
# To use it, cd to your repository's root and then run the script
# with a list of paths you want to delete, e.g.:
# > gitRemoveFilesFromHistory.sh path1 path2

DO_EXTENSION_FILTERING=1
DO_CLEANUP=0

if [ $# -eq 0 ]; then
	extensions=".*\.jar\|.*\.bin\|.*\.LIB\|.*\.exe\|.*\.so\|.*\.sch\|.*\.s\|.*\.dylib\|.*\.ods\|.*\.odg\|.*\.pdf\|.*\.pcb\|.*\.cbp\|.*\.wxs\|.*\.OBJ"
else
	extensions=$@
fi

# Make sure we are at the root of git repository
if [ ! -d .git ]; then
	echo "Error: must run this script from the root of a git repository" 1>&2
	exit 1
fi

# Remove all paths passed as arguments from the history of the repository
if [ "${DO_EXTENSION_FILTERING}" = "1" ]; then
	#git filter-branch --prune-empty --index-filter "git rm -qrf --cached --ignore-unmatch $(find . -type f -regex='${extensions}')" HEAD
	#git filter-branch --prune-empty --tree-filter "remFiles=\"$(find . -type f -regex=${extensions}\") && git rm -qrf --cached --ignore-unmatch $remFiles" HEAD
	echo "removing files matching: '${extensions}' ..."
	git filter-branch --force --prune-empty --tree-filter "find . -type f -regex \"${extensions}\" | xargs rm -f 2>&1 > /dev/null" HEAD
else
	files=$@
	git filter-branch --force --prune-empty --index-filter "git rm -qrf --cached --ignore-unmatch $files" HEAD
fi

# Remove the temporary history git-filter-branch otherwise leaves behind
# for a long time
if [ "${DO_CLEANUP}" = "1" ]; then
	rm -rf .git/refs/original/
	git reflog expire --all
	git gc --aggressive --prune
fi
