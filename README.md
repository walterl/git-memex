# `git-memex` - Your git-based memory extension

`git-memex` is a simple, file-based, git backed personal knowledge base.

## Target workflow

### Initializing directory for git-memex
1. Run `gmx-init`. This should run `git init` and do any other setup that is
   necessary.

### Adding a file

1. Run something like `gmx-add`
  * Opens temporary file for new entry.
2. Write file content in Markdown
  1. Support turning a URL into a link in the format `[<page title>](<url>)`
  2. Support pasting of Markdown representing rich text in clipboard.
3. Save file and exit
4. Create filename from file's title
5. Save temporary file as calculated filename in git repo.
6. Automatically commit the new file.

### Searching for a file

First pass: Use `grep`, `git grep`, `ag`, or anything else the user wants.

Second pass: Combine the good bits of the commands above into a `gmx-search`
command.

Third pass: Connect one some "good" grep program to `fzf`, and output/edit
selected file.

Fourth pass: throw in a full-text search engine into the mix.

### Deleting a file

`gmx-rm <filename>` should do `git rm <filename>`.


## Development roadmap

### Phase 1: Proof of concept

Hack everything together in bash scripts to nail down the best API.


### Phase 2: Rewrite components

Components should be rewritten, preserving PoC functionality, to reflect a more
robust and maintainable solution.

There is no specific tech stack in mind for this phase, but will probably be
either Python, Go, or a hybrid script based system in which components are
language agnostic.

A hybrid approach can leverage the best parts of different languages, for example:

* Use Python to create a clear and simple CLI, which (system) calls other
  components accordingly.
* Use Go for performance sensitive tasks like searching.
* Use simple bash scripts where nothing more advanced is required.
