#!/bin/bash -Eeu

# Added beside the compiler the base image put in /etc/rescript, rather than
# into a prefix of their own, because a start-point symlinks that one directory
# in as its node_modules: that is how node finds jest, and how the ReScript
# compiler finds the package a kata's rescript.json names.
#
# rescript is deliberately absent: it comes from the base image. Naming it here
# would let this image drift to a different compiler from its siblings, which
# is the thing having a base image is for.
npm install --prefix /etc/rescript \
  @glennsl/rescript-jest \
  jest

# The compiler writes its build output beside the sources it compiles, and a
# kata runs as sandbox. The base image set this for what it installed; these
# packages are new.
chown -R sandbox /etc/rescript
