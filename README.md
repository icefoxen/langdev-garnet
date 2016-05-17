# Garnet: A systems programming language.

I kind of want to make it the system-level equivalent of Lua.  Small,
simple, easy to port, easy to mess around with the innards of.
Because C++ and Rust are none of those things, and I think there's
call for such a thing.  C is those things, but C is nearly 45 years
old and has many things in it that we can do better now.  Like a
module system, and bounds-checked arrays, and so on.  I'm currently
kind of feeling like it should... at the risk of sounding like X11,
define mechanism more than policy.  Have simple parts that can be
combined in powerful ways, instead of having complex systems
with lots of moving parts.  Again, somewhat like Lua.

One key goal is to have *total* compile-time memory safety with no
garbage collection, like Rust.  I'm not sure we're going to get there,
but we will see.

So my road map is to make fundamental features work:

* Functions
* Arrays, structs, tuples
* References and slices
* Function references (with no environment)
* Type inference and casting
* Generics
* Pattern matching
* Immutable by default
* Module/namespace system

Then we can ponder more advanced features and see how we want them to
fit together.  Things to investigate include:

* Closures
* Hygenic macro system
* Dynamic dispatch/multimethods
* Traits/interfaces/typeclasses
* Lifetime analysis/regions
* Fancy pointer types (unique pointers, refcounted pointers, etc)
* Exceptions/conditions/other stack unwinding mechanisms (require
  destructors)
* Closures
* Objects/subtypes/struct extension
* Operator definition
* Function arg overloading
* Null-coalescing operator (maybe definable if we can define
operators)
* RTTI/introspection
* C interface

## Considerations

The only thing I really know I want for sure is macros, 'cause they
make code generation awesome and easy; hopefully lots
of other things can be implemented in terms of them.

Dynamic dispatch is more or less necessary for printf() to work
properly.  THOUGH, macros might be able to handle that, with
sufficient compile-time introspection...  The way Rust does it is
actually pretty nice, it seems.

If we are going to have some kind of stack analysis to ensure you can
never return a pointer to value that then goes out of scope...  that
is basically a subset of simple LIFO region analysis a la Cyclone.

# Compiler

Right now the plan is to write the compiler in OCaml using LLVM as a
backend, and either Menhir or camlp4 to generate the parser and such.  
