![alt tag](https://raw.githubusercontent.com/lateralblast/slug/master/slug.jpg)

SLUG
====

Set Laptop Up Gracefully

Introduction
------------

A script to help automate the setup of a Mac

At the moment it is a simple shell script, but I've tried to put in handling
where possible, e.g. don't add an entry to a file if it's aleady there and
don't install a package if it's already installed (although brew handles this anyway).

Usage
-----

```
slug (Set Up Laptop Gracefully) 0.1.0
Richard Spindler <richard@lateralblast.com.au>

Usage Information:

    a)
       Do everything
    b)
       Install brew package
    c)
       Install brew cask packages
    l)
       List packages
    f)
       Install fonts
    s)
       Install other packages
    z)
       Setup shells
    r)
       Install Ruby
    p)
       Install Python
    d)
       Set OS X defaults
    g)
       Install go
    V)
       Display version
```

Examples:
---------

Install everything:

```
./setup.sh -a
```

License
-------

This software is licensed as CC-BA (Creative Commons By Attrbution)

http://creativecommons.org/licenses/by/4.0/legalcode

