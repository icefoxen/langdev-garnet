Expressions
===========

Literal values
--------------

* Integer
* Float
* Char
* Unit?
* Arrays
* Slices?
* Strings
* Tuples
* Structs
* Unions
* Functions


Math & logic
------------


Type casting
------------

C# is real good here. It has several typecasts:

* "(type) expr", which casts the result of expr to type and throws
  an exception if it can't be,
* "expr as type", which casts the result of expr to type and returns
  null if it can't be, 

It also has "expr is type" which returns true if "expr as type" will
not return null. Handy. 

A ``typeof`` operator is probably also a good idea.

Variable binding
----------------

Function calls
--------------

Array indexing
--------------

Slices
------

Structures
----------

Choice
------

If and match and null-coalescing

Iteration
---------

While, for, foreach

Exception handling
------------------

Try, throw, with...
