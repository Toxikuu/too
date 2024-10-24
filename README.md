# Too
Tox's "low-level" source-based package manager, built for LFS

# Archival
Too is a predecessor to gimme which is a predecessor to rid. Too is dead, but I'll keep this repo around. 

Also note, this project was never stable to begin with, so probably don't use it unless you either really know what you're doing or enjoy living life on the edge.

## Basic Usage
For demonstration purposes, let's walk through the installation of tree.

Clone this repo (I recommend cloning it from /):
```bash
git clone https://github.com/toxikuu/too.git && cd too
```

Source a file that exports some functions and sets some variables.
```bash
. /too/tools/sourcemedaddy
```

Now, you can install tree by running:
```bash
/too/bs/tree.sh -pscbkiC
```

That's a lot of flags! Here's what they mean:
```bash
# p - pull
# s - setup
# c - configure
# b - build
# k - check
# i - install
# C - cleanup
# r - remove
# u - update
```

To uninstall tree, run:
```bash
/too/bs/tree.sh -Cr
```

And to update to the newest version of the very actively-developed tree:
```bash
/too/bs/tree.sh -u
```

## Pro Tips
Write your own build scripts or edit existing ones. This package manager's power is that it abstracts away very little complexity. Make the most of that granular control!

You should only use this is you know what you're doing (i.e., you've build LFS).
