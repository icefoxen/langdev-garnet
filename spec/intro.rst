Introduction
============

Purpose
-------

Garnet is language intended for system-level programming: writing
operating systems, device drivers, embedded systems, real-time
programs such as games, etc. It is essentially supposed to fill the
niche currently occupied by C (and to some extent C++). C is real good
for 1970-something. But we can do better now.

The goal of Garnet is thus to be a system-level language, one that is
simple to use and understand, convenient to use and powerful and safe
enough to be actually useful.  Generally it seeks to have a useful
small set of features rather than provide everything under the sun.

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
   

Roadmap
-------

For my own purposes, here's a useful little roadmap for things to do
when designing and implementing this language:

* Atomic types and basic expressions
* Module system
* Typedefs
* Compound types
* Pattern matching
* Reference types
* Type inference
* Low level code/memory access
* Subtypes & type inference
* Multimethods?
* Exceptions/non-local exits/returns
