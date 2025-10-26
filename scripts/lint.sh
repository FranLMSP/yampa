#!/bin/bash

export BASE=origin/main
# - committed changes vs BASE
# - staged (--cached)
# - unstaged (work tree vs index)
# - untracked files
FILES=$(
  {
    git diff --name-only "$BASE"...HEAD || true
    git diff --name-only --cached || true
    git diff --name-only || true
    git ls-files -m || true
    git ls-files --others --exclude-standard || true
  } | grep -E '\.dart$$' | sort -u
)

if [ -z "$FILES" ]; then
  echo "No changed Dart files to lint."
  exit 0
fi

flutter analyze $FILES
