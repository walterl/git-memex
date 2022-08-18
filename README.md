# `git-memex` - Your git-based memory extension

git-memex is a simple, git backed personal knowledge base (PKB).

It's a **prototype** consisting of a handful of Bash scripts that simplifies
management of a git repo, garnished with Python scripts for automating common
tasks.

The source code is very simple, and users are encouraged to peak at and tinker
with it.

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

All git-memex commands are prefixed with `gmx-`, and will print usage
information when called with `-h`.

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

Unless the `-r` command-line flag was given, your editor will be opened a
second time, after content expansion but before the file name is determined.
This affords you the opportunity to **r**eview the expanded content, and apply
any manual changes you may desire.

The functionality is optimized for uses cases like the following. Run
`gmx-add privacy/software` and add the following content:

```markdown
# https://signal.org/

Secure instant messaging app for desktop and mobile.
```

Your editor should open after a short delay, containing the following content:

```markdown
# [Signal >> Home](https://signal.org/)

Secure instant messaging app for desktop and mobile.
```

Notice how the title has been replaced with a Markdown link. Close your editor.

You should then see the following output:

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

Unless the `-r` command-line flag was given, your editor will be opened a
second time, after content expansion but before the file name is determined.
This affords you the opportunity to **r**eview the expanded content, and apply
any manual changes you may desire.

### Searching for a file

`gmx-find` allows you to fuzzy find a file by name (it wraps [fzf](https://github.com/junegunn/fzf)),
displaying previews for highlighted files.

Since all data in a git-memex database are just text in normal files in a git
repository, you can use any external utilities for searching:

* `grep`, `ag`, `rg` ...
* `git ls-files`
* While not implemented in git-memex, any full-text search engine can be used
  to index and search the repository contents.

### Full-text search

Run `gmx-search -u` to create/update a full-text search index of all Markdown
files in your database. That index can be searched with
`gmx-search my search terms`.

`gmx-search` requires [washer](https://github.com/fiatjaf/washer) to be installed. Run `pip install --user washer` to 
install it.

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

Unless you specify the `-r` (_review_) command-line flag, you will be prompted
for confirmation before the commit is performed.


## Debugging

Running any git-memex command with the `GMX_DEBUG` environmental variable set
to a non-empty value, will produce debugging output.


## Development status

Development is currently in **prototype** stage.

The code is still very immature, but I've successfully and productively been
using git-memex for my PKB since September 2019.

See _Development Roadmap_ below for more information.

### TODO
- [X] Add `gmx-init` command.
- [X] Add `gmx-add` command.
- [X] Add `gmx-mv` command to allow moving/renaming of files.
- [X] Add `gmx-rm` command to removal of files.
- [X] Add `gmx-edit` command to manage editing of managed files.
- [X] Add `gmx-commit` command to commit any manual changes.
- [X] `gmx-add`: Add `-d` switch to specify directory for new entry.
- [X] `gmx-add`: Add `-r` switch for reviewing changes (if any) of content expansion.
- [X] `gmx-edit`: Add `-r` switch for reviewing changes (if any) of content expansion.
- [X] Migrate required Unmind code to git-memex repo.
- [X] Test implementation for a while
- [X] Add utility to convert rich text (HTML) on the clipboard, to Markdown text.
  - Hooked together `xclip` and `pandoc` in a [vim mapping](https://github.com/walterl/dotfiles/blob/2db52c8e6c4140f17160535c6e906f5042f7ee3a/_config/nvim/ftplugin/markdown.vim#L18-L21=).
- [ ] Support sub-db's created by symlinking to a sub-directory.
  - Doing `ln /my/db/some/topic ./subdb` and working in `subdb` should "just
    work", committing changes to the root db.
- [ ] `git-add`: Allow file name to be specified as CLI argument, in stead of computing from content.
- [ ] `gmx-edit`: Add option to avoid renaming changed file.
- [ ] Move on to phase 3: replace prototype with production-ready code.


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

* Use Python to create a clear and simple CLI, which dispatches to other components.
* Use Go for performance sensitive tasks like searching.
* Use simple bash scripts where nothing more advanced is required.

#### TODO

* [ ] Implement search functionality, optimized for text search in a git repository.
  * [ ] First pass: Use `grep`, `git grep`, `ag`, or anything else the user wants.
  * [ ] Second pass: Combine the good bits of the commands above into a
        `gmx-search` command.
  * [ ] Third pass: Connect some "good" grep program to fzf, and output/edit
        selected file.
    * I.e. extend `gmx-find`
  * [ ] Fourth pass: throw in a full-text search engine into the mix.


## Background

After several years of thinking about and tinkering with various PKB solutions,
git-memex implements the features I think are most important. Those features
are informed by the core values of _user freedom_, and _simplicity_, discussed
in more detail below.

At the end of the day git-memex is just a set of tools for managing a git
repository of (mostly) Markdown text files, with the git intricacies tucked
away, and a few time saving scripts sprinkled on top.

### User freedom
#### Privacy
When it comes to knowledge bases, it's all about the data. When it comes to
_personal_ data, it's all about users' control over their data. That is to say,
_privacy_.

git-memex is uncompromising in giving users complete control over their data.
That means no opaque service layer, no proprietary data formats, no stewardship
of users' data by third parties, and no unauthorised or implicit access to
users' data.

By default at least. It is always the user's prerogative to give up these data
freedoms as and when they see fit.

git-memex achieves this goal not only by being built on [free software](https://www.gnu.org/philosophy/free-sw.html), but by
_being_ [free software](./LICENCSE.md).

#### Portability
Also implied by _user freedom_, is the ability for users to work with their
data as and where they see fit. This informs much of git-memex's feature
design, not least of which the decision to support encoding of data as Markdown
text files.

Plain text is as ubiquitous a format as they come, with text editors available
for every computing platform. It's everywhere, and it's here to stay.

It's also easy to record changes (with git) in a space efficient manner.

Markdown moves the needle just enough towards the "richer" end of the scale to
not get in the way, while adding many useful features. It adds a critically
important feature necessary in a PKB: the ability to link to other data.

While Markdown is the first and (so far) only format officially supported by
git-memex, there is nothing preventing a user from adding non-Markdown files.

### Simplicity

#### Small scope
git-memex focuses intensively on its small scope, and aggressively contracts
out any work it can to other existing software. That way it remains small,
simple, and easy to change.

For example, rather than creating a TUI or GUI for accepting user input, we use
the user's configured `$EDITOR`.

Want to search through your database? Use `grep`.

Want to fuzzy find a file in your database? Use [fzf](https://github.com/junegunn/fzf) (as `gmx-find` does).

Want to keep a central, offsite copy of your database? `git push` it.

Want to sync your database to your phone? Use [Syncthing](https://syncthing.net). Or [Nextcloud](https://nextcloud.com).
Or whatever else you're already using.

git-memex aims to support the user in using their PKBs with existing software,
rather than duplicating or hard-coding functionality in git-memex.

#### Simple CLI
The focus on simplicity also informs the simple nature of the `gmx-*` commands.
It tries to abstract away all the nitty gritty details of the underlying git
repository.

#### Files and directories
Simplicity also means working with what users already know. Users know files
and directories, and have become accustomed to working with them.

Furthermore the [_user-subjective approach_](https://en.wikipedia.org/wiki/User-subjective_approach) supports allowing users to create
their own hierarchy for encoding project classification, importance and
context.

git-memex should come with guidelines for how to effectively structure PKB
data, but that is not yet implemented. (Mostly due to my ignorance on the
topic. Please let me know if you have any pointers!)


## Tips and tricks

### Easier access to `gmx-find`

Create a symlink to `gmx-find` in your git-memex repository, to run it more
easily, without polluting your environment with a contextless script/alias.

```bash
cd my_db
ln -s $(which gmx-find) ./q
# Now you can run gmx-find as ./q
./q
```

The same can be done for `gmx-search`.

### Use proxy to fetch page contents

Web pages are fetched with the [requests library](https://docs.python-requests.org/en/latest/), which respects `$http_proxy`
and `$https_proxy` environmental variables. Together with something like [direnv](https://github.com/direnv/direnv)
or [dotenv](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/dotenv), you can configure a proxy for when you're in your git-memex
repository directory.

```bash
echo 'http_proxy=socks5h://localhost:9050' > .env
```

_Note_: To use a SOCKS proxy server (e.g. Tor) ensure that [`requests[socks]`](https://docs.python-requests.org/en/latest/user/advanced/#socks) is
installed in your `pygmx` virtual environment.

### Paste rich text as Markdown

You'll often want to paste text into your PKB, copied from a web page. But how
can you convert your copied rich text to Markdown? [xclip](https://github.com/astrand/xclip) and [Pandoc](https://pandoc.org/) has you
covered!

```bash
xclip -selection clipboard -o -t text/html | pandoc -f html -t markdown --wrap=none 2> /dev/null
```

If you're a Vim user, you can hook that up to a custom mapping, like I did
[here](https://github.com/walterl/dotfiles/blob/818a49bfbc8695fda42dfbf48aec223b6fe0e19f/_config/nvim/ftplugin/markdown.vim#L20=).


## License

[![GPLv3](https://www.gnu.org/graphics/gplv3-with-text-136x68.png)](./LICENSE.md "GPLv3")
