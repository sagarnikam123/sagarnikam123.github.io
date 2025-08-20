---
title: "Git - simple workflows"
description: "snippet for daily activity"
date: 2023-01-31 12:02:00 +0530
categories: [version control]
tags: [git, guide, snippet]
---

While working with code, repository and collaboration through git, encounters simple workflow or process.

- **pull specific branch**
  ```shell
  # clone the remote master/main
  git clone <remote url>

  # checkout to a branch
  git checkout <remote_branch_name>

  # pull the code
  git pull origin "<local_branch_name>"
  ```

- **create new branch from specific one on local**
  ```shell
  # go to the branch from which you want to create the new branch
  git checkout <existing-branch>

  # create a new branch
  git branch <new-branch>

  # Switch to the new branch
  git checkout <new-branch>

  # Make changes & commit to the new branch as needed
  git commit -m "<Commit message>"

  # push the new branch to a remote repository
  git push -u origin <new-branch>
  ```

- **git pull specific tag**
  ```shell
  # list tags
  git tag -l

  # pull specific tag
  git checkout tags/<tag_name>
  ```

- **git pull latest features into forked branch**
  ```shell
  # check remote upstream
  git remote -v

  # get latest features
  git fetch upstream

  # merge into current branch
  git branch && git merge upstream/master

  # remove conflicts - if found any
  git rm .github/workflows/pr-filter.yml .github/workflows/scripts/pr-filter.js
  rm '.github/workflows/pr-filter.yml'
  rm '.github/workflows/scripts/pr-filter.js'

  git commit -m "feat: merge upstream/master to sync with jekyll-theme-chirpy latest features"
  git push origin master
  ```
