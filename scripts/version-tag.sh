#!/bin/bash

echo "Latest tag:"
git tag --sort=creatordate | tail -n 1

echo "";

dry_run=0
if [[ "$1" == "--dry-run" ]]; then
  dry_run=1
fi

current_branch=$(git symbolic-ref --short HEAD)
if [[ "$current_branch" != "main" ]]; then
  echo "Error: You must be on the 'main' branch to update the version."

  if [[ "$dry_run" -ne 1 ]]; then
    exit 1
  fi
fi

read -p "Enter the new version number (e.g., 1.0.1): " new_version

if [[ -z "$new_version" ]]; then
  echo "Error: Version number cannot be empty."
  exit 1
fi

echo "Updating pubspec.yaml with version $new_version..."
sed -i "s|^version: .*|version: $new_version|" pubspec.yaml


if [[ "$dry_run" -ne 0 ]]; then
  echo "git add pubspec.yaml"
  echo "git commit -m \"Bump version to $new_version\""
  echo "git tag \"$new_version\""
  echo "git push origin main"
  echo "git push origin $new_version"
else
  git add pubspec.yaml
  # TODO: we want to sign this commit with GPG
  git commit -S -m "Bump version to $new_version"
  git -s tag "$new_version"
  git push origin main
  git push origin "$new_version"
fi

echo "Version bumped to $new_version, changes pushed and tagged!"
