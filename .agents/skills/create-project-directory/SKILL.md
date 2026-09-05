---
name: create-project-directory
description: |
    create project directory to keep reverse engineering artifacts. use when
    need to save an artifact and the project directory does not exist or if it
    is not an initialized git submodule.
---

# create project directory

## input

to create project directory to keep reverse engineering artifacts, user should
define `{{project_name}}`.

## flow

### create project directory

**this project should only contain the tools for reverse engineering. every
project artifacts and report should be added to the project repository itself.**

if user has not added a `git submodule` at `projects/{{project_name}}`, ask user
for the submodule URL and add the submodule.

## verification

after processing this skill flow:

- confirm that `projects/{{project_name}}` exists.
- confirm that `projects/{{project_name}}` is a directory.
- confirm that `projects/{{project_name}}` is a `git submodule`.
- confirm that `projects/{{project_name}}` is an initialized `git submodule`.
- confirm that `projects/{{project_name}}` is the only directory created by
  this skill.