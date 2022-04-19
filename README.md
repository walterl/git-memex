# `git-memex` - Your git-based memory extension

git-memex is a simple, file-based, git backed personal knowledge base (PKB).


## Installation

All commands below should be executed from the source repository.

It was developed on an Ubuntu based Linux distribution.

### Install scripts into `$PATH`
Symlink all `src/gmx-*.sh` files into a directory in your `$PATH`. For example,
using `$HOME/.local/bin/`, run the following from the repository root:

```bash
for i in $PWD/src/gmx-*.sh; do
  ln -s "$i" $HOME/.local/bin/$(basename "$i" .sh)
done
```

### Install Python environment

As per the instructions from `src/python`:

```bash
mkvirtualenv pygmx
pip install -r src/pygmx/requirements.txt
```

If you want to use a different Python environment, be sure to update
`src/python` accordingly.


## Usage

### Initialize directory for git-memex
Run `gmx-init` in the directory that you would like to store your git-memex
database in.

The working directory must _not_ already be a git repository before running
`gmx-init`.

A `README.md` and `.ignore` file is added automatically. You are welcome to
`gmx-rm` one or both of them, if you wish.

### Adding a file

Run `gmx-add`. git-memex will open a temporary Markdown file in your favorite
editor. Add your content here, then save and exit the editor.

After exiting, the content in the file will be expanded. Currently content
expansion is limited to expanding URLs into Markdown links, with the fetched
URL's page title as the link text.

Next a file name is computed from the temporary file's contents. The file name
is computed from the first Markdown title, or first line from the contents. Any
slashes and pipes are replaced with hyphens (`-`), and `.md` is appended.

It is highly recommended that you organise your files into a directory tree, to
make it easier to find in the future. Do so by specifying a directory with the
`<dir>` command-line option. The new file will be added in the specified
directory. The directory is created if it doesn't exist.

If the `-r` command-line flag was given, your editor will be opened a second
time, after content expansion but before the file name is determined. This
affords you the opportunity to **r**eview the expanded content, and apply any
manual changes you may desire.

The functionality is optimized for uses cases like the following. Run
`gmx-add privacy/software` and add the following content:

```markdown
# https://signal.org/

Secure instant messaging app for desktop and mobile.
```

You should see the following output:

```
 ✔  New file: privacy/software/Signal >> Home.md
```

Note that the page title was fetched and used as the file name.

Note also that the `privacy` and `privacy/software` directories were
automatically created for the new file to be placed in.

Looking at the new file, the URL was also transformed into a Markdown link:

```
cat 'privacy/software/Signal >> Home.md'
# [Signal >> Home](https://signal.org/)

Secure instant messaging app for desktop and mobile.
```

### Editing an existing file

Run `gmx-edit <filename>` to open the specified file in your text editor. After
saving the file, the file's content is expanded just like in `gmx-add`, and the
file name updated according to the new title. If the file name has changed, the
file will be renamed.

If the `-r` command-line flag was given, your editor will be opened a second
time, after content expansion but before the file name is determined. This
affords you the opportunity to **r**eview the expanded content, and apply any
manual changes you may desire.

### Searching for a file

`gmx-find` allows you to fuzzy find a file by name (it wraps [`fzf`](https://github.com/junegunn/fzf)),
displaying previews for highlighted files.

Since all data in a git-memex database are just text in normal files in a git
repository, you can use any external utilities for searching:

* `grep`, `ag`, `rg` ...
* `git ls-files`
* While not implemented in git-memex, any full-text search engine can be used
  to index and search the repository contents.

### Moving/renaming a file

`gmx-mv <src> <dest>` wraps `git mv <src> <dest>`.

### Deleting a file

`gmx-rm <filename>`. It does `git rm <filename>`.

### Committing external changes

Since git-memex data is stored in a git repository, but git-memex does not
depend the repository state, you are free to use any git functionality that you
want to.

If you want to quickly and simply commit all uncommitted changes, the
`gmx-commit` command will do so after displaying a short change summary (`git
status -s`).

If you specify the `-r` (_review_) command-line flag, you will be prompted for
confirmation before the commit is performed.


## Debugging

Running any git-memex command with the `GMX_DEBUG` environmental variable set
to a non-empty value, will produce debugging output.


## Development status

Development is currently in **prototype** stage.

The code is still very immature, but I've successfully and productively been
using git-memex for my PKB since September 2019.

See _Development Roadmap_ below for more information.

### TODO
* [X] Add `gmx-init` command.
* [X] Add `gmx-add` command.
* [X] Add `gmx-mv` command to allow moving/renaming of files.
* [X] Add `gmx-rm` command to removal of files.
* [X] Add `gmx-edit` command to manage editing of managed files.
* [X] Add `gmx-commit` command to commit any manual changes.
* [X] `gmx-add`: Add `-d` switch to specify directory for new entry.
* [X] `gmx-add`: Add `-r` switch for reviewing changes (if any) of content expansion.
* [X] `gmx-edit`: Add `-r` switch for reviewing changes (if any) of content expansion.
* [X] Migrate required Unmind code to git-memex repo.
* [X] Test implementation for a while
* [X] Add utility to convert rich text (HTML) on the clipboard, to Markdown text.
  * Hooked together `xclip` and `pandoc` in a [vim mapping](https://github.com/walterl/dotfiles/blob/2db52c8e6c4140f17160535c6e906f5042f7ee3a/_config/nvim/ftplugin/markdown.vim#L18-L21=).


## Development roadmap

### Phase 1: Proof of concept

Hack everything together in bash scripts to nail down the best API.


### Phase 2: Use prototype for PKB

The best way to learn about what users need is to be one. Using git-memex for
my PKB will highlight any needs or required improvements.


### Phase 3: Rewrite components

Components should be rewritten, preserving prototype functionality, to reflect
a more robust and maintainable solution.

There is no specific tech stack in mind for this phase, but will probably be
either Python, Go, or a hybrid script based system in which components are
language agnostic.

A hybrid approach can leverage the best parts of different languages, for example:

* Use Python to create a clear and simple CLI, which (system) calls other components accordingly.
* Use Go for performance sensitive tasks like searching.
* Use simple bash scripts where nothing more advanced is required.

#### TODO

* [ ] Implement search functionality, optimized for text search in a git repository.
  * [ ] First pass: Use `grep`, `git grep`, `ag`, or anything else the user wants.
  * [ ] Second pass: Combine the good bits of the commands above into a
        `gmx-search` command.
  * [ ] Third pass: Connect some "good" grep program to `fzf`, and
        output/edit selected file.
    * I.e. extend `gmx-find`
  * [ ] Fourth pass: throw in a full-text search engine into the mix.
