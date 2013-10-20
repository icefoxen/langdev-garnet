Concepts
========

Types, values, and binding
--------------------------

Garnet is a statically, strongly typed language.  All types are
determined at compile time; no implicit runtime checking is
performed.  Additionally, it requires an explicit conversion to change
one type into another, except in certain cases where such a conversion
cannot lose data (ie, converting a 32-bit int to a 64-bit double).

Most of the time the compiler is able to infer the types of variables
from context and some minimal information provided by the programmer
(such as the types of arguments and return types in function
definitions).  However it is always possible to explicitly state the
type of a variable, for the sake of clarity or for those cases where
the compiler can't handle it or doesn't do what the programmer wants.

There are also parameterized types, the ability to define a type or
function as being based on another, nonspecific type, such as being
able to have an array of integers, an array of floats, etc.

Garnet also includes some kind of object system or such.

There's also going to be some kind of facility for subtyping and
abstract types, such as defining "number" to be a member of/implement
the interface "comparable", and thus having the option to write a
function that does not require its inputs and outputs to be a specific
type, but merely a type that implements "comparable".

.. todo:: Rewrite the above and ponder object systems more.

In Garnet, *names* are bound to *values*.  This binding is
immutable???  It also does not necessarily imply a slot in memory for
that binding...  Think about this!  

.. todo::

   FFS, figure out whether we're going to do names-as-binding-values
   or variables-are-slots.  Basically are most values mutable, or
   immutable?  It's a good damn question.  

.. todo::

   Think about object system!  A paper on C# describes the CLR's type
   system as not-entirely-static as it supports run-time type tests,
   checked coercions, and reflection.  These are ALL nice things to
   have, man!  And they *should*  be able to be done entirely
   statically given that we can't create new types at runtime.  Though
   it might also need objects to contain a pointer saying "This is my
   type record", so.  A split system of flat structs with no extra
   overhead  and heavyweight objects with vtables and type records is
   sort of tempting now.

Garnet has two broad categories of types, atomic types and compound types.

Atomic types
~~~~~~~~~~~~

Atomic types are generally small and, as the name suggests, are not
composed of any sub-pieces besides bytes and bits.  They are thus
usually considered immutable and have copy semantics; you do not
usually have references to atomic types, though it is possible.

Atomic types include:

* Integers
* Floating-point numbers
* Characters
* References
* Stack references
* Functions
* Options
* Booleans
* The ``unit`` type
* Pointers

Each of these are described below.

Integers are a family of types that represent integers of various
sizes.  The integer types are::

   int8 int16 int32 int64 uint8 uint16 uint32 uint64

The number suffix specifies how many bits are used to represent the
integer, and a "u" prefix denotes that the integer is unsigned instead
of signed, which is the default.  Any smaller integer may be used in
place of a larger integer without an explicit type conversion
expression, as long as they are either both signed or both unsigned.

Additionally there are a couple shortcuts for commonly-used integer
types:

* ``int`` is a shortcut for ``int32``
* ``byte`` is a shortcut for ``uint8``

Floats are standard IEEE754 floating-point numbers, either 32 or 64
bits long.  Like integers, smaller floats can be automatically
converted to larger ones if necessary.  Integers can also be
automatically converted to a larger-size float.  The float types are::

   float32 float64

Like integers, thre are a couple shortcuts:

* ``single`` is a shortcut for ``float32``
* ``double`` is a shortcut for ``float64``

Characters, type ``char``, are UTF-8 Unicode characters.

References are a special type that refer to another value; ``^foo``
denotes a reference to a value of type ``foo``.  This lets you
implement linked data structures, pass-by-reference semantics, and all
that other good stuff.  You can access the value the reference refers
to through the ``^`` operator, thus: ``foo^``.

References have a few limitations to make life better.  References may
not refer to items in locally-allocated memory (ie, items on the stack).
References have no "null" value; a reference always either refers to
something, or is invalid (such as if the item it refers to has been
deallocated).

.. sidebar:: Design notes

   References being non-nullable was a bit of a sticking point,
   because nullable references are *useful*.  Not necessary, but
   useful.  But the inclusion of the ``option`` type as a primitive
   nicely encompasses their functionality.

Stack references are a special type of reference that CAN refer to
things in locally-allocated memory.  A stack reference to an item of
type ``foo`` is written ``$foo``.  These have a few limitations as
well:

* They can NOT be created anywhere *except* on the stack; they cannot
  "escape" the stack into heap memory,
* They can ONLY refer to items created in the current stack frame or
  previous stack frames; they can NOT refer to items on the heap, or
  items allocated "further up" the stack.

The purpose of all these bother is to prevent references to items in
stack frames which then vanish when the function they are for returns.

A function type is a first-class function.  It is unfortunately
``not`` a closure, which is a function plus the local environment the
function was defined in, because memory allocation for closures gets
sort of awful pretty quickly.  So in practice it is just a bare
function pointer.  A function that takes two integers and returns a
double has the following type signature: ``fun(int, int : double)``.

The option type is, for once, actually a type to make life easier
instead of harder.  Essentially it lets you turn any value into
something that can be that-value-or-null.  It could be implemented
using union types, but is common enough to deserve some syntactic
sugar of its own.  Thus ``?int`` represents a type that could be
``null`` or an ``int``.  

.. sidebar:: Implementation note

   The option type generally is implemented like a union type, by
   adding an extra value that records whether or not the value is
   null.  However, it'd be nice to be able to do without this overhead
   in many cases, and so it should often be possible to use an
   out-of-band value to represent ``null`` rather than storing an
   extra word or byte or whatever.  In particular, null references can
   be references to the address 0, like null pointers in C.  Using
   other out-of-band values for ``null`` is something to think about
   in the future, such as perhaps an invalid UTF-8 value for
   ``char`` or a particular NaN for a floating-point type.  However,
   there are two problems: One, we should be sure that such values are
   REALLY out-of-band.  For instance, one might read a ``?char`` from a
   file with an invalid UTF-8 value, and thus the reader will have to
   detect whether what it just read is equivalent to the ``null``
   value and convert it to something else.  Or some actual floating
   point computation might produce the NaN value that is used for
   ``null``.  And so on.

   The second issue is that these optimizations *must* be standardized
   and documented into an ABI for different implementations to
   inter-operate successfully.  Which then makes them mandatory, as
   well.  So currently, the only optimization is representing a null
   reference as a pointer to address 0.

Option values cannot be directly accessed or converted to other types;
they must be accessed via the null-coalescing operator ``??`` (stolen
wholesale from C#).  The expression ``a ?? b`` returns the value of
``a`` if it is non-null, or ``b`` otherwise.  The ``match`` expression
can also be used, for example ``match a with null -> foo; x -> bar;
end``.

.. todo::

   Solidify syntax of ``null`` or something to jibe a bit better with
   whatever you come up with for unions.  Basically, should it be
   ``:null``?  I dunno.

Booleans are simply another union with two values, ``true`` and
``false``.  It should be noted that nothing can be implicitly
converted to a boolean; constructs such as ``if 0 then ...`` or ``if
null then ...`` are type errors.

The ``unit`` type is even simpler; it is a union with only one value,
``unit``.  Nothing can be turned into a ``unit`` value, and it cannot
be converted into anything else.  Its purpose is to serve as a
stand-in type when there is no useful data to convey; a function that
returns nothing actually returns one value of type ``unit``.  C's
``void`` type always pissed me off on a vague but fundamental level.
The type "this has no type" is weird and awkward to think about.

.. todo::

   ``unit`` is the top type, which no value is potentially a member
   of.  Meanwhile, C's ``void`` is the bottom type, which every value
   is potentially a member of.  Do we need a bottom type?  Think about
   it.  Interestingly, in C#/Java-y systems, the bottom type is
   ``object``, because anything can be casted to ``object``.

Lastly, we have the type ``pointer``.  A pointer is an untyped
reference to raw memory.  Pointers may be (explicitly) converted to
integers of the appropriate size for the platform, and vice versa.
They may have pointer arithmatic done to them via the ``+`` and ``-``
operators.  They are there for when it is necessary to access memory
in this low-level fashion, such as performing memory-mapped I/O.  They
are not a general-purpose tool.

.. todo::

   It is worth considering whether pointers should be typed; a pointer
   to an int32 conveys a lot more information than just a pointer.
   They probably SHOULD be typed, since that tells the assembler
   whether this load is a load-byte, a load-word, and so on.
   Otherwise you default to load-word and have to either discard or
   munge together words to get values of different sizes, which sounds
   more irritating than it should be.

.. todo::

   Mutability is still an issue.

   But immutability of the heap only works really well with
   GC... right?

   It's sort of hard to have life both ways; either everything is a
   mutable cell, or everything is an immutable value.  Hrmbl.

   Strings are immutable, too!

.. todo::

   SYMBOLS.

Compound types
~~~~~~~~~~~~~~

Compound types are values that are constructed from multiple other
values.  Compound types are still value types and thus have copy
semantics, just like atomic types; use references for reference
semantics.  The compound types are:

* Arrays
* Slices
* Strings
* Tuples
* Structs
* Unions

.. sidebar:: Design notes

   An idea that I ponder is having references be implicit for
   compound types, such that ``var t : foo`` would actually be a reference to a
   foo, and ``[]foo`` an array of references to foo's.  Then one would
   have an "inline" operator that would change a reference to an
   immediate value; let us use ``@``.

   This is tempting because usually you *do* want reference semantics
   for compound types, as demonstrated by Java and C# where classes are
   reference types by definition, and the plethora of ``typedef *foo
   foo_t`` statements in C code.

   However this would make some weird inconsistencies which bother
   me.  Namely, ``[]int`` would be (a slice referring to) an array of
   immediate integers.  But ``[]foo`` would be an array of references
   to foo's, while ``[]@foo`` would be an array of immediate foo's.
   Then what happens when you write ``[]@int``?  It's more or less
   meaningless; it might be ignored or it might be invalid.  But then
   what if you want an array of references to integers, for whatever
   reason?  You need some way to write ``[]^int`` anyway, so you
   haven't even managed to remove ``^`` from the language.

   But is there any real reason to have a reference to a lone ``int``,
   or some other value type?  There is, if it is an out-value for a
   function.  But then you can have an ``out`` specifier for a
   function argument instead, which will do that job.  Anything else?
   Maybe if you really don't want to copy some of the relatively large
   value types such as options or slices, but that's getting into
   nit-picking territory...

   But I am also extremely wary of saying "Well obviously there's no
   use for X so we'll just remove it".  Someone out there will always
   have a good reason for wanting it.  Or, at least, a bad reason.
   And, critically, it's a pretty fundamental semantic thing, so if I
   take it out there's not really any way to substitute it safely.

   I think that in the end we have to KISS and say that consistency is
   the only real choice, so, explicit pointers.

Arrays are fixed-length sequences of values.  For instance,
``[10]int`` is an array of 10 ``int``.  Arrays are indexed in the
usual manner, such as ``foo[3]`` gets the 4th element from the array
``foo``.  All array accesses are bounds-checked at runtime, unless the
compiler can prove it's unnecessary (or perhaps is told not to do such
things).

A slice is a reference to an array which knows how long the array is.
Thus through slices you can handle arrays of variable or unknown
length, dynamically allocate them, and so on.  ``[]int`` is a slice
referring to an array of ``int``.  

.. sidebar:: Implementation note

   Should slices be implemented as pointer+length, or pointer to
   beginning of array+pointer to end of array?  Hm.

Strings are simply arrays of ``char``.  Strings are immutable.

.. todo::

   Are strings slices of ``char``?

Tuples are fixed-length sequences like arrays, except that not all the
values in a tuple need to be the same length.  For instance, ``{int,
float, char}`` denotes a 3-item sequence where the first item is an
``int``, the second a ``float``, and the third a ``char``.

Structs are just like tuples except they *must* have a type name
specified and their elements have names as well.

Unions are a special type that allows the combination of multiple
types.  


Scope
-----

Garnet is a block-structured language, as most are these days.  This
means that any names defined within a block (a function body, the body
of a for loop, etc) are temporary and may not be referenced outside of
that block.  A name defined within a block may *not* be the same as
another name outside of that block; you cannot "shadow" names.

.. todo::

   Objects with deconstructors that call automagically when they leave
   the current scope sounds sort of handy really.  Though also rather
   C++-y...

Namespaces
----------

In Garnet, all top-level declarations declare new values and types in
a *namespace*.  A namespace is simply a collection of values, types,
and other namespaces ("names"), and are arranged in a heirarchical
manner.  All names in a namespace are inaccessable from other
namespaces unless either they are prepended by the (absolute or
relative) namespace path from the current namespace, or an ``import``
directive of some kind explicitly makes one namespace visible from
another.

Ambiguities in namespace references are not allowed.  If the compiler
detects such an ambiguity, the program are invalid.  This isn't to say
that all possible namespace references must be unambiguous, simply
that ambiguous ones must be clarified.  For example::

  namespace Foo
    def baz(:int) 
      1
    end
  end

  namespace Bar
    def baz(:int)
      2
    end
  end

  baz()  -- Unknown name
  Foo.baz() -- Returns 1
  Bar.baz() -- Returns 2
  import Foo
  baz()  -- Returns 1
  import Bar
  baz()  -- Compiler error, ambiguous reference.

  namespace Quux
    def baz(:int)
      Foo.baz()
      Bar.baz()
    end
  end

Namespaces bear no relation to the source files the code is contained
in.  The same namespace can be defined in multiple source files in a
project and all names within that namespace are part of the same
collection.  

.. sidebar:: Design notes

   This is pretty much entirely lifted from C#, without qualms.

Exceptions
----------

.. sidebar:: Design notes

   Exceptions were another sticking point for a while, but in the end
   the commonly-used system provides a nice combination of power and
   usefulness.  It was very tempting to employ a more powerful error
   handling and recovery system such as Common Lisp's conditions, but
   in the end that complicated the runtime too much and required more
   power in the execution model and compiler than I really felt
   comfortable with.  I also contemplated a simpler system of simply
   returning error values, with some syntactic sugar to make it nicer,
   but the benefits of stack unwinding are huge and the ability to
   finalize items on exit from the stack frame is necessary even
   without stack unwinding.  So to continue the Lisp metaphor we would
   need ``BLOCK``, ``RETURN-FROM`` and ``UNWIND-PROTECT`` anyway no
   matter what, so one might as well take that extra small step and
   just put them together into the traditional exception-handling we
   all already know from languages like Java.

   One consideration is that ``BLOCK`` and ``RETURN-FROM`` choose the
   destination frame by explicit name, while ``throw`` and ``catch``
   match choose the destination frame by matching the type of the
   thrown argument.  This detail may be
   worth further pondering.

Interfaces
----------
