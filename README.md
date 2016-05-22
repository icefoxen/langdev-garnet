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
fit together.  Things that will almost certainly be put in include:

* Integer overflow protection
* Closures
* Exceptions/conditions/other stack unwinding mechanisms (require
  destructors)
* Hygenic macro system
* Traits/interfaces/typeclasses
* Fancy pointer types (unique pointers, refcounted pointers, etc)
* Lifetime analysis/regions
* C interface



Things I am not so sure about include:

* Dynamic dispatch/multimethods
* Dynamic dispatch/multimethods (multimethods are complex, traits can do dynamic dispatch)
* Objects/subtypes/struct extension (we don't really need objects if we have traits; struct
extension is sometimes useful but sometimes not...  hmm.)
* Operator definition (syntactic sugar, we can leave it out)
* Function arg overloading (syntactic sugar, we can leave it out)
* Null-coalescing operator (maybe definable if we can define operators)
* RTTI/introspection

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

## Memory safety ponderments

The hard ones are dynamic memory errors: danglign pointer, double free, memory leak

Dangling pointers in the stack can be detected statically, if we restrict pointers to only pointing to current or
earlier stack frames.

Having unique pointers seems to work pretty well.  shared and weak pointers helps too.

That, plus destructors, seems to do the trick I think.  When something goes out of scope, if it's a unique pointer,
then we know it's, well, unique, and the thing it is pointing to can go away.  If it's a shared pointer, then the
refcounting happens.

# Compiler

Right now the plan is to write the compiler in OCaml using LLVM as a
backend, and either Menhir or camlp4 to generate the parser and such.  
