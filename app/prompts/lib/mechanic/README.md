There are two git submodules here:

- ./system/7-mechanic-docs, which points directly to the mechanic-docs repo
  - gitbook repos are suitable for direct inclusion into our system prompts
- ./mechanic-tasks, which points directly to the mechanic-tasks repo
  - this repo is _not_ suitable for direct inclusion into our system prompts, which is why it isn't in ./system
  - run ./update-demonstration-task-symlinks to wire stuff into place
