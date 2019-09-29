# `git-memex` - Your git-based memory extension

This is the root of your git-memex knowledge base.

It is a normal git repository, with some scripts to make operations easier.

You are welcome to delete this `README.md` file: `gmx-rm README.md`

## Usage

To use the database, `cd` to this directory and use any of the following
operations:

### Add an item
```bash
$ gmx-add
```

### Search for an item

Since data is stored in text files, you can use any of the system tools
available. For example: `git grep TODO`


### Delete an item

Note that this will delete the file from the git-memex directory (working
tree), but it will still exist in the history (git repository).

```bash
$ gmx-rm <filename>
```
