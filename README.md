# MED - Mobiusloopfour's Editor

Med is a simple, easy to use line based text editor.
Although inspired by `ED(1)`, it is not designed to be compatible
with it, and does not share the same commands.

## Getting statrted

First, you might want to set up the build system. Run `./autogen.sh && make`. When building using `make`, the executable is built
in `/src/`. To install it on your system, ensure there are no other programs called `mle`, and type `make install`.
To uninstall, simply open (or clone and `autogen.sh`) this repository, and type `make uninstall`.

### Editing

To start editing a file, type

-   `mle <FILE>` where FILE is a filename. IF it does not exist, it will be created when saving.

This will open med. The default user interface is rather empty... There are several commands available.
They are as follows:

-   `.list` (list) --- prints the document loaded in memory to the standard out.
-   `.add` (append/add) --- adds text to the end of the file. Type "." (without the quotes) to end append mode. To have a line with a single dot, type "\." (without the quotes). To have an empty line, type "\n" (without the quotes).
-   `.quit` (quit) --- exits, reminding to save if applicable
-   `.write` (write) --- write whats in the buffer to the path specified in the command line
-   `<NUMBER>.chg` (change) --- replace a single line with `<TEXT>`.
-   `<NUMBER>.insert` (insert) --- inserts text at `NUMBER`.
-   `<NUMBER>.x` (quick delete) --- Delete a single line.
-   `<RANGE>.print` (print) --- Print a range of lines (1 based indexing).
-   `<RANGE>.del` (delete) --- Delete a range of lines

All of these have short variants, that being their first letter (without a dot).
E.g: `$,$d` is equivalent to `$,$.del`

If you're confused about ranges, they are specified with `<START-NUM>,<END-NUM>`. Both `<START-NUM>` and `<END-NUM>` can be "$", in
which case they will be substituted by the first and last lines respectively.

Note that the `mle` will only start executing what's in the buffer once you hit enter.

## Known issues

As this is still a pre-release, there are still some bugs. Most notable are:

- The code might (?) soft-lock in some instances. Better state management will be added soon.

These issues will be fixed soon.