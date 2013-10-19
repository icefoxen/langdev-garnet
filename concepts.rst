Concepts
========

Types, values, and binding
--------------------------

Garnet is a statically, strongly typed language.  All types are
determined at compile time; no implicit runtime checking is
performed.  Additionally, it requires an explicit conversion to change
one type into another, except in 

Most of the time the compiler is able to infer the types of variables
from context and some minimal information provided by the programmer
(such as the types of arguments and return types in function
definitions).  However it is always possible to explicitly state the
type of a variable, for the sake of clarity or for those cases where
the compiler can't handle it or doesn't do what the programmer wants.

There is also parametric polymorphism, the ability to define a type or
function as being based on another, nonspecific type.  

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

Atomic types
~~~~~~~~~~~~

Int, float, char, reference, function, pointer, unit, option

These are value types.  Thus they are immutable and have copy semantics.

.. todo::

   Can references be null?!?!?!?!?  They HAVE to be able to be,
   because every value type needs to be able to be initialized
   to something!  Such as for struct initialization.  Right?

   No, because we have an option type, so any reference that needs to
   be nullable is just an option.  Then the compiler can look for
   option-containing-a-reference constructs and optimize it to 0 if
   null, or non-zero if non-null.

   But immutability of the heap only works really well with
   GC... right?

   It's sort of hard to have life both ways; either everything is a
   mutable cell, or everything is an immutable value.  Hrmbl.

   Separate types for nullable and non-nullable references is an
   option, I suppose.  But doesn't solve the whole
   mutability/immutability debate.

Compound types
~~~~~~~~~~~~~~

Array, struct, tuple, union, slice, string

.. note::

   An idea that I ponder is having references be implicit for
   compound types, such that ``var t : foo`` would actually be a reference to a
   foo, and ``[]foo`` an array of references to foo's.  Then one would
   have an "inline" operator that would change a reference to an
   immediate value; let us use ``@``.

   This is tempting because often you _do_ want reference semantics
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

Exceptions
----------

Interfaces
----------
