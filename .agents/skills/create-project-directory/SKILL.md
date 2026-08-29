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

**do not advance if `projects/{{project_name}}` does not exists or if it is not
an initialized `git submodule`.**