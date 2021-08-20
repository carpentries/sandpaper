# At the moment, {sandpaper} has no method to manage dependencies in a lesson, 
# you just have to have them installed on your machine. 
#
# I _could_ simply drop in the dependency management that we have for the styles
# repository, but I want to avoid the situation where I accidentally clobber a
# maintainer's R installation. 
#
# These are my notes that I have about renv and what it does. 
#
# The global cache
# ----------------
#
# The global cache is a really cool concept and it's well executed. It's a cache
# of packages used across renv projects. 
# When you do an interactive snapshot in {renv} the first time, it will give
# you the output from `renv::consent()`, however, if it's non-interactive, then
# you will not get the prompt and it will create the default 
#
# All you need is lock
# --------------------
#
# First: you don't _need_ anything more than a lockfile for _renv_:
#   <https://twitter.com/JosiahParry/status/1352294664607576068>
#
# You can do your work and `renv::snapshot()` when you are done and it creates
# a renv.lock for you: yay!
#
# The drawback here is that you cannot snapshot a package that does not
# currently exist on your computer (I tried addng a demonstration of the cowsay
# package, but it refused to enter the lockfile).
#
# The solution here is to run renv::record() with the discovered dependencies
# for the lockfile. 
#
# Use it
# ------
#
# I don't know when it became part of renv, but there is a function called 
# `renv::use()`, which takes in a vector of packages _or_ a lockfile and will
# determine if they need to be installed, install them to the cache and then 
# set a temporary library for that session. 
#
# THIS SEEMS TO BE THE THING WE WANT:
#  
#  - doesn't isntall into the user's default library
#  - uses a temporary library with the cache
#
# The only drawback right now is the fact that if we use a lockfile for the 
# source, we run into the same problem that we had when we used a lockfile with
# restorex
#
#
