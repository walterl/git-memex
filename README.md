# `git-memex` - Your git-based memory extension

git-memex is a simple, file-based, git backed personal knowledge base.


## Installation

All commands below should be executed from the repository root.

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
mkvirtalenv -p $(which python3) pygmx
pip install beautifulsoup4==4.8.0 html2text==2019.9.26 lxml==4.4.1 Markdown==3.1.1 requests==2.22.0
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
expansion is limited to expanding URLs into Markdown links, with the fetch page
title as the link text.

Next a file name is computed from the temporary file's contents. The file name
is computed from the first Markdown title, or first line from the contents. Any
slashes are replaced with hyphens (`-`), and `.md` is appended.

If the `-r` command-line flag was given, your editor will be opened a second
time, after content expansion but before the file name is determined. This
affords you the opportunity to review the expanded content, and apply any
manual changes you may desire.

If you specified a directory with the `-d <dir>` command-line option, the new
file will be added in the specified directory. The directory is created if it
does not exist.

The functionality is optimized for uses cases like the following. Run `gmx-add`
and add the following content:

```markdown
# https://duckduckgo.com

My default search engine.
```

You should see the following output:

```
 ✔  New file: DuckDuckGo — Privacy, simplified.md
```

Note that the page title was fetched and used as the file name.

Looking at the new file, the URL was also transformed into a Markdown link:

```
cat "DuckDuckGo\ —\ Privacy,\ simplified.md"
# [DuckDuckGo — Privacy, simplified.](https://duckduckgo.com/)

My default search engine.
```

### Editing an existing file

Run `gmx-edit <filename>` to open the specified file in your text editor. After
saving the file, the file's content is expanded just like in `gmx-add`, and the
file name updated according to the new title. If the file name has changed, the
file will be renamed.

If the `-r` command-line flag was given, your editor will be opened a second
time, after content expansion but before the file name is determined. This
affords you the opportunity to review the expanded content, and apply any
manual changes you may desire.

### Searching for a file

Since all data in a git-memex database are just text in normal files in a git
repository, you can use any system utilities for searching for a specific item:
* `grep`, `ag`, ...
* `git ls-files`
* While not implemented in git-memex, any full-text search engine can be used to index and search the repository contents.

### Moving/renaming a file

`gmx-mv <src> <dest>` wraps `git mv <src> <dest>`.

### Deleting a file

`gmx-rm <filename>`. It does `git rm <filename>`.

### Committing external changes

Since git-memex data is stored in a git repository, but git-memex does not
depend the repository state, you are free to use any git functionality that you
want to.

If you want to quickly commit all uncommitted changes, the `gmx-commit` command
will do so after displaying a short change summary (`git status -s`).

If you specify the `-r` command-line flag, you will be prompted for
confirmation before the commit is performed.


## Debugging

Running any git-memex command with the `GMX_DEBUG` environmental variable set
to a non-empty value, will produce debugging output.


## Development status

Development is currently in **Phase 1: Proof of concept**

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
* [ ] Test implementation for a while
* [ ] Add utility to convert rich text (HTML) on the clipboard, to Markdown text.


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

* Use Python to create a clear and simple CLI, which (system) calls other components accordingly.
* Use Go for performance sensitive tasks like searching.
* Use simple bash scripts where nothing more advanced is required.

#### TODO

* [ ] Implement search functionality, optimized for text search in a git repository.
  * [ ] First pass: Use `grep`, `git grep`, `ag`, or anything else the user wants.
  * [ ] Second pass: Combine the good bits of the commands above into a
        `gmx-search` command.
  * [ ] Third pass: Connect one some "good" grep program to `fzf`, and
        output/edit selected file.
  * [ ] Fourth pass: throw in a full-text search engine into the mix.
