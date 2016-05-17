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

Garnet also has the facility to define type classes, that is,
overloading of functions to specialize them to specific types.  This
allows the definition of abstract types and subtype relationships.

In Garnet, *names* are bound to *values*.  This binding is
immutable?  It also does not necessarily imply a slot in memory for
that binding.  However, it is possible to define variables, which as the name implies can be mutated at runtime.

Numbers
~~~~~~~

Booleans
~~~~~~~~

Arrays
~~~~~~

References
~~~~~~~~~~

Characters and strings
~~~~~~~~~~~~~~~~~~~~~~

Structures
~~~~~~~~~~

Atomic types
~~~~~~~~~~~~

Functions
~~~~~~~~~

Variant types
~~~~~~~~~~~~~

Unit
~~~~

Pointers
~~~~~~~~

Generic types
~~~~~~~~~~~~~

.. todo::

  Option, result, closures, SIMD vectors, slices, tuples

.. todo::

  SUBTYPING!  Let's see.  We can have normal classes/subclasses, Haskelly typeclasses, C#-y interfaces, Go-y protocols, whatever the hell Rust uses these days...

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

.. todo::

   Vectors of ints and floats may be quite useful, as SIMD
   operations.  16-bit floats may also be useful.  Are there
   standardized 128-bit floats?
   SIMD operations could be defined simply on tuples of numbers...

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
   useful.  But the inclusion of the option type as a primitive
   nicely encompasses their functionality.

Stack references are a special type of reference that CAN refer to
things in locally-allocated memory.  A stack reference to an item of
type ``foo`` is written ``$foo``.  These have a few limitations as
well:

* They can NOT be created anywhere *except* on the stack; they cannot
  "escape" the stack into heap memory,
* They can ONLY refer to items created in the current stack frame or
  previous stack frames; they can NOT refer to items on the heap, or
  items allocated "further up" the stack.  The compiler enforces this
  invariant for you.  It may not be possible to enforce it 100%
  accurately, in which case the compiler should be conservative and
  force you to be too.  At worst, you are doing a little extra
  copying.

The purpose of all this bother is to prevent references to items in
stack frames which then vanish when the function they are for returns.

A function type is a first-class function.  It is unfortunately
*not* a closure, which is a function plus the local environment the
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

.. sidebar:: Implementation notes

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

   Subtype Mongling

   ``unit`` is the bottom type, which no value is potentially a member
   of.  Meanwhile, C's ``void *`` is the top type, which every value
   is potentially a member of.  Do we need a top type?  Think about
   it.  Interestingly, in C#/Java-y systems, the top type is
   ``object``, because anything can be casted to ``object``.  In
   Common Lisp, of course, ``t`` is the top type and ``nil`` the
   bottom type...

   Well we *need* varargs, because without them printf is awful.  And
   we *need* some kind of strong typing for varargs, because printf 
   (well, scanf) introduces potential for hilarious bugs and potential
   security implications because it's not strongly typed.  So we
   *need* a top type so anything can be fed into the printf
   function.

   So we *need* RTTI to make it so that you can get the right function
   to print X where X is potentially any type.  (Amazing how such
   complicated things come out of such simple requirements.)  

   One *potential* way to handle it is The Modula 2 Dodge, where
   printf takes an array of strings and we just have lots of functions
   to convert things into strings.  Another might be The OCaml Dodge,
   where printf takes a tuple and a bit of magic happens (I think it
   involves the compiler decoding the format string and figuring out
   what the types should be).  Or we could just have a top type, which would
   probably consist of a fat pointer with a reference to an object and
   a pointer/index to a type record.  But unless we want all pointers
   to be fat pointers and all value types to have a reference to a
   type record as well, or all values to have a pointer to a type
   reference, we need a way to mongle data to and from these
   fat pointers, either manually or (preferably) automatically.

   But you can't have a subtyping system like objects or typeclasses
   without *always* keeping that pointer to the type record around,
   because if you have methods that can be overridden... say B
   inherits from A.  A has a method A.foo() and B overrides it to make
   B.foo().  You have a function that takes an A and gets
   handed a B, and it calls B.foo(), and B's version of foo gets
   called, not A's.  So that pointer there to an A actually points to
   a B, and what foo() gets called must be able to be discovered at
   runtime.

   This is why in C++, methods are not virtual by default (like C#,
   unlike Java) because it means that methods that can *never* be
   overridden never need to be resolved at runtime via the object's
   vtable.  That means if an object has no virtual methods (or, to use
   Java terms, all final methods, or the object itself is marked
   final) then you can represent them fully with a bare pointer and
   some information that's possible to attain at compile time.  This
   is why structs in C# can't inherit, too, but only implement
   interfaces.  (XXX: But does this mean that interfaces are always
   fully resolvable at compile time?  I THINK so...  Find out more!)

   SO.  Possible ways of doing this:

   * Have structs and objects be entirely separate, with different
     properties, like C# does it.  Structs are bare and have no RTTI,
     objects have RTTI.  This isn't *awful* but sort of irritates me.
     C#'s semantics for struct vs. object in general aren't awful, but
     do have some gotchas, and the main one might be that it's
     impossible to put objects on the stack.  *BUT*, if "objects" can
     extend a struct (add new members to it), then they *can't* be put
     on the stack anyway without terrible things potentially
     happening.  

   * ONLY have what C# calls interfaces, on the assumption that they
     are fully resolvable at compile time (ie, never need a vtable).
     Need to think about this more.

   * Compile-time magic?

   * Tedious manual tagging and untagging of types, probably
     involving some sort of new pointer type and functions/special
     forms to convert between them and the broad invariant that it's
     easy to convert fat to thin pointers and hard (or at least
     potentially unsafe) to convert thin pointers to fat.

Lastly, we have the the pointer type, ``ptr<>``.  A pointer is a
reference to raw memory that mostly evade the type-checker.
Pointers can be created from a value with the ``ptrOf()`` function and
can be dereferenced with the ``deref()`` function toretrieve the
contents of memory essentially with no promise that it is 
the type that you think it is.  ``setref()`` can be used to set the
contents of pointed-to to a value
For instance::

  let f float = 10.5
  let pf ptr<int> = ptrOf(f)
  let i int = deref(pf)

The above program will interpret the memory occupied by the floating
point number ``f`` as an integer.  

Furthermore, pointers may be explicitly converted to
raw memory addresses and vice versa, may have pointer arithmatic done
to them via the ``+`` and ``-``, which increment or decrement the
address by a multiple of the size of the type the pointer thinks it is
pointing at.  They are not bounds checked and thus
can wander off into arbitrary parts of memory, which allows
programmers to invoke the much-renowned undefined behavior::

  let a [5]int = [1,2,3,4,5]
  let pa ptr<int> = ptrOf(a)
  pa <- pa + 3  -- pa now points to the a[3]
  pa <- pa + 3  -- Now pointing off the end of the array
  deref(pa)     -- Undefined
  setref(pa, 5) -- More undefined

.. todo::

   Figure out good names for the ptrOf() and deref() and setref() operators.  

.. todo::

   Mutability is still an issue.

   But immutability of the heap only works really well with
   GC... right?

   It's sort of hard to have life both ways; either everything is a
   mutable cell, or everything is an immutable value.  Hrmbl.

   Strings are immutable, too!

.. todo::

   SYMBOLS.  But *can* you make symbols without dynamic allocation?
   Well, THEORETICALLY, you could have a symbol table as a fixed
   length array that gets filled at runtime, but that's silly.  The
   goal is basically to turn a variable-length string into a
   fixed-length number, but if we use some sort of hashing we'll have
   collisions and need to resolve them and life gets silly.  Symbols
   can be implemented as a library.

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
   compound types, such that ``var t foo`` would actually be a reference to a
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
``[10]int`` is an array of 10 ``int``.  Arrays are zero-indexed with
a C-like cyntax, such that ``foo[3]`` gets the 4th element from the array
``foo``.  All array accesses are bounds-checked at runtime, unless the
compiler can prove it's unnecessary (or perhaps is told not to do such
things).

A slice is a reference to an array which knows how long the array is.
Thus through slices you can handle arrays of variable or unknown
length, dynamically allocate them, and so on.  ``[]int`` is a slice
referring to an array of ``int``.  

.. sidebar:: Implementation notes

   Should slices be implemented as pointer+length, or pointer to
   beginning of array+pointer to end of array?  Hm.

Strings are simply arrays of ``char``.  Strings are immutable.

.. todo::

   Are strings slices of ``char``?

.. todo::

   2D arrays?

Tuples are fixed-length sequences like arrays, except that not all the
values in a tuple need to be the same length.  For instance, ``{int,
float, char}`` denotes a 3-item sequence where the first item is an
``int``, the second a ``float``, and the third a ``char``.  You can
reference the members of a tuple just like array members, so
``someTuple[0]`` will return the first member of the variable
``someTuple``.  Unlike arrays, tuples are immutable.

Structs are just like tuples except they *must* have a type name
specified and their elements have names as well.  Structs are also
mutable, just to keep you on your toes.

Unions are a special type that allows the program to represent a
variable that may be one of several different types, and discover
which it is at runtime.  For this the union implicitly includes a
field containing type information; a union member may also consist of
a this tag alone with no additional information attached to it, which
would be similar to an ``enum`` in C.  


Scope
-----

Garnet is a block-structured language, as most are these days.  This
means that any names defined within a block (a function body, the body
of a for loop, etc) are temporary and may not be referenced outside of
that block.  A name defined within a block may *not* be the same as
another name outside of that block; you cannot "shadow" names.

.. todo::

   Objects with deconstructors that call automagically when they leave
   the current scope sounds sort of handy really.

Namespaces
----------

.. sidebar:: Design notes

   This is pretty much entirely lifted from C#, without qualms.

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

.. todo::

   Steal Go's init() functions?  Maybe.

Exceptions
----------

Try, catch, finally, with XXX: Destructors

.. sidebar:: Design notes

   Exceptions were another sticking point for a while, but in the end
   the commonly-used system provides a nice combination of power and
   usefulness.  It was very tempting to employ a more powerful error
   handling and recovery system such as Common Lisp's conditions, but
   that complicated the runtime too much and required more
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

   Well, matching by type is basically the same as matching by label,
   where the label is ``type-WHATEVER``.  So.  You'd have to match any
   supertype of it as well, so that will be a little weird, but it's
   doable; you just have to have a list of things you COULD match
   against.


Interfaces
----------

An interface is a new type defined from a set of
specific functions (methods) operating on a particular existing type.
Interfaces allow the programmer to define types in terms of general
behaviors, and then potentially have several data types that implement
these behaviors, such as a ``Sequence`` data type being implemented
via an array, linked list, or other underlying representation.
Interfaces may also inherit from each other, thus defining a specific
subtype from a more general supertype, allowing a certain amount of
polymorphism.  A type may implement any number of interfaces as well.

Interfaces in Garnet are much the same as interfaces in
Java or C#, and provide a subtyping mechanism for Garnet that is 
simple, flexible, and meshes well with existing types and
functions.  Interfaces are also low overhead, requiring little in the
way of extra storage and only simple method dispatch.

An interface is defined by specifying a set of methods,
either *virtual* methods which are to be filled in later when the
interface is implemented for a particular type, or *concrete* methods
with a function body.  This allows concrete methods to define uniform
behavior in the case that there are one or two primitive operations
that enable a host of other potential functionality.

Here is an example of an interface defining simple comparison
methods in terms of a to-be-defined ``cmp`` method::

  interface Comparable =
     -- Returns <0 if one item is less than the other,
     -- >0 if it is greater, or 0 if they are the same.
     virtual cmp(Comparable, Comparable : int)

     def lt(a Comparable, b Comparable : bool)
        cmp(a, b) < 0
     end

     def gt(a Comparable, b Comparable : bool)
        cmp(a, b) > 0
     end

     def eq(a Comparable, b Comparable : bool)
        cmp(a, b) = 0
     end

     -- For brevity we'll leave out lte() and gte()
  end

Any type can then implement the ``Comparable`` interface by defining
all of the virtual methods::

  implement Comparable on int
     def cmp(int a, int b : int)
        if a > b then 1
	elif a < b then -1
	else 0
	end
      end
   end

So now any value of type ``int`` can be used anywhere that
``Comparable`` type is expected::

  var f Comparable = 10
  var g Comparable = 20
  f.lt(g) -- Returns true

This also demonstrates the method call syntax in ``f.lt(g)``, which is
equivalent to ``lt(f,g)``.

.. todo::

   The method call syntax is ambiguous with a function pointer in a
   struct, yo.  Does this matter?  Do we really want the 'this' for a
   method to just be the first argument?  That's how Go does it, I
   mean.  And Lua.  Think about it.
   
   XXX: Think about syntax for method calls!  Go methods *do*
   associate a function with a particular type.

   I sort of like Lua's foo:bar(arg) as shorthand for bar(foo, arg).
   That's more or less what I was imagining up until now.  But it
   looks like Go methods do some actual dispatch, which is something
   different.  Think more about how these things interact...

.. sidebar:: Implementation notes

   The tricky part was really coming up with a subtyping system that
   works but doesn't require tagging every single pointer or storing a
   vtable in every single structure.  I *believe* fits the bill;
   essentially, every variable that is an interface type is actually a
   2-tuple containing the item and a pointer to a record containing
   the virtual functions to implement the interface for the item's
   type.  Then whenever we turn, say, an ``int`` into a
   ``Comparable``, the compiler knows that you are working with an
   ``int`` and passes in the right interface record, which then gets
   kept around at runtime.  But if you ever want to make sure you
   don't use that extra information, for purposes of efficiency or
   memory layout or whatever, then you just don't use interface
   types.  The overhead is literally zero in that case.

   We could honestly implement C++/C#/Java style objects the same way,
   but objects run into hazards.  If A is an object, and B inherits
   from A and defines new members, then whenever we have an A on the
   stack, and then assign a B to it, either we can't because the extra
   members don't fit, or we slice those extra members off and **pray
   to all that is holy** that B didn't override any of A's methods to
   use those.  So in the end we can't in good concience have the
   ability to extend objects that might be on the stack.  We could
   define two entirely separate types of objects like C# does, one
   that always lives on the heap and one that generally doesn't.  But
   this is simpler, and seems to suffice without making our memory
   model less uniform.

   How the heck does Oberon handle this, anyway?

Interfaces can inherit from each other to define subtypes.  When
interface ``B`` is defined as inheriting from ``A``, it contains all
the methods of ``A`` and can add more of its own.  Thus in a game,
``PlayerSpaceship`` and ``EnemySpaceship`` may both be interfaces
inherited from ``PhysicsObject``, and thus have the same basic physics
calculations applied to them despite being different types.::

  interface PlayerSpaceship : PhysicsObject
     virtual handleInput()
  end

  interface EnemySpaceship : PhysicsObject
     virtual doAI()
  end

  def doPhysics(objs []PhysicsObject)
     ... 
  end


.. todo::

   Accessors might actually be really useful for this model.  Think
   about it.  

Run-time type information
-------------------------

Type traits: a struct for each type available at runtime, which has
metadata about each type... size, at least, probably a name-to-number
mapping for enums, stuff like that.  Look at C# more.

Note that this could easily be gotten as a method of the ``top``
interface.  If the RTTI record for a type includes pointer layout,
this would let you make a garbage collector just from introspection
(though it'd be slowish).  It wouldn't be _perfect_ because it would
still have issues with ints vs. pointers on the stack and in
registers; it would still have to be conservative, but perhaps better
than otherwise attainable.

A ``typeof`` operator.


Properties::

  Type name
  Size
  Interfaces (linked list)
  Pointer layout (maybe)
  If an enum, functions to turn ints to/from it


Generic types
-------------

Garnet allows you to specify that a type or function based on a type
that is unspecified in the declaration but rather declared where that
function or type is used.  This deferred or generic type isusually 
denoted ``T``.  The most familiar
examples of generic types would be the built-in collections such as arrays; you can have an
array of integers or an array of doubles, the type of the array
depends on the type of the array members.  You can define your own
types that have this property, for instance to make generic
collections::

  struct LinkedList<T> =
     member R
     next ?^LinkedList<T> 
  end

  let a LinkedList<int> = LinkedList { member = 10, next = null }
  let b LinkedList<double> = LinkedList { member = 3.1415, next = null }

You can also declare functions which take or return generic types,
such as this one that returns the first member of an arbitrary 2-tuple::

  def first<T1, T2>(tuple {T1, T2} : T1)
     tuple[0]
  end

Note that unlike interfaces, generic types contain no run-time
information; you cannot turn a generic type into a non-generic type.

.. todo::

   Look up what the C# spec says about these.

.. sidebar:: Implementation notes

   There's two real ways to do this.  One is to have ``T`` always be a
   reference, the other is to basically compile a copy of the
   function/type for each specialization of the wossname.  That is,
   OCaml style or C++ (and D?) style.  C# essentially does it via
   dynamic recompilation...
