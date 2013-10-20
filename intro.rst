Introduction
============

Purpose
-------

Garnet is language intended for system-level programming: writing
operating systems, device drivers, embedded systems, real-time
programs such as games, etc. It is essentially supposed to fill the
niche currently occupied by C (and to some extent C++). C is real good
for 1970-something. But we can do better now.

To this end, simplicity and convenience (both of implementation and of
use) are more important than offering every possible feature.  It
should be complete and offer some of the niceness of modern
programming languages, but when a design decision leads to a choice
between a simple and a complex option, the simple one should generally
be chosen.  Often the simple option is "omit the feature" or "let the
programmer implement it themselves".

While low-level code can be written in a number of languages,
including crazy ones like C#, Haskell, and Go... most of the time this
requires complex and ill-documented knowledge of the language's
runtime and implementation, or special modifications to the
implementation. This makes life harder. One of the goals of Garnet, as
a relatively low-level language, is to make it easy to write low-level
code. That means having a simpler implementation, where it is
relatively easy to understand what is happening on the machine
level. It also means having a lightweight runtime that can operate
with low overhead and almost no infrastructure, so that you don't need
to do a lot of work to be able to use the language on bare metal. As a
rule of thumb... if a language feature makes it impossible to use this
language on an Arduino, it is probably not appropriate. 

Notation
--------

This document uses an extended BNF grammer notation. ``|`` denotes
alternation, nonterminals are written ``thus``, terminals are enclosed
in "quotes".  Expressions that may be repeated zero or more times are
enclosed in curly braces ``{ }``, and expressions that are repeated zero
or one time are enclosed in square brackets ``[ ]``.

.. sidebar:: Design notes

   I have also left in sidebars describing in more detail *why* certain
   design decisions were made; they are not necessary for understanding
   the language, but are helpful, if only for me, for making the
   language design more coherent.
   
