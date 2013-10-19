Memory model
============

Memory management is one of the things that C makes harder than it
really should be.  Unfortunately, even with the best of modern design
principles and compiler technology, memory management is *hard*.  But
this is one of the main points where I hope Garnet will be an
improvement over existing languages.

There are three main things to consider, all of which are somewhat
intertwined:

* The *management* of memory, how it is allocated and deallocated and 
  the performance costs thereof both to the computer and the
  programmer, 
* The *safety* of memory, or how to prevent reading to or writing
  from memory that isn't what you think it is,
* And *aliasing* of memory, or how we can tell the compiler that two
  references in memory are never the same or never altered, allowing
  it to produce more optimal code for modern CPU's.

Garbage collection, either in the form of automatic reference counting
or tracing GC, very neatly solves all these problems.  Management is a
non-issue: You allocate memory, the GC frees it when it proves that
it's safe, and that can mean that allocation can simply be a bump
allocator and a copying collector can compact the heap for you to
boot.  Because of this, if you can never fabricate an arbitrary
pointer address, then it's impossible to end up with a pointer
pointing somewhere it shouldn't be; if there is a reference to an area
of memory, that area of memory is by definition allocated.  And with
this niceness it's possible to create runtimes such as those commonly
used in ML and Haskell, where everything is allocated on the heap and
most pointers are immutable, and because the pointers are immutable
the compiler can do a pretty good job of figuring out what they can
and can't be pointing to.  It's really slick.

Unfortunately, this comes with a price.  First, garbage collectors are
fairly large and complex pieces of software that are not suitable for
embedded systems.  Try putting a GC on an 8-bit microprocessor.
Second, garbage collectors have a performance cost either in time or
memory or both; even if the GC is very fast and efficient, it *will*
stop the execution of the program for an indeterminate amount of time
every so often, and most GC implementations aren't capable of
real-time performance.  I'd love it if they were, but alas.  And
finally, most systems with garbage collected memory don't give you the
freedom to work around the GC and write your own system for dealing
with these problems.  So garbage collection is not a suitable solution
for the problem domain this language is intended to solve.

Memory management
-----------------

The practical choices are C-style manual memory management, some sort
of manual or partially-automated reference counting, or some sort of
region allocation/static lifetime analysis.  Ideally, any of these
would be able to be implemented entirely in Garnet itself, without
needing anything/much in the way of language support.

Unfortunately, it'd be really nice if the standard library could
allocate memory, and for that it has to know something about the
semantics involved.  It MIGHT be possible to make a library that
allocates memory and allows you to tell it which arbitrary allocator
function to use, but doesn't free any memory.

For lack of anything better, right now we're going to assume we have
C-style malloc/free semantics.  We know it works, to some extent, and
manual reference counting is a very easy specialization of it, and we
know that also works (if we steal Cocoa's API).  Regions are a little
more special-case and need a little more thought.

.. todo::
   If we're going to have generalized destructors though, or tools
   such as ``auto_ptr`` or ``with`` that destroy objects
   automatically, we *need* some type-extension method that lets us
   have every type define a finalizer if need be.

   Or we need to do what C++ does and have the compiler check at
   compile time every place a generic is used and generate the
   appropriate code for it.

   Or basically select one option of: value type without destructor,
   reference type without destructor, value type with destructor,
   reference type with destructor.  In that case.

Memory safety
-------------

The traditional ways that a C program can corrupt memory are as
follows:

#. Out of bounds accesses, where a pointer is incremented out of
   bounds of the object (array or structure) it is supposed to be
   pointing to,
#. Dangling (or wild or stale) pointers, where a pointer refers to
   memory in the heap which has been freed, or freed and then
   re-allocated to a new object,
#. Double-free's, where a region of memory is deallocated more than
   once, which can confuse the memory manager at best or sneakily 
   free an object it's not supposed to at worst,
#. Out of bounds accesses and dangling pointers pointing into the
   stack are a bit of a special case, since they can potentially
   corrupt the stack, with the attendant security issues involved.
   It's also very easy to create a dangling pointer in the stack
   simply by having a pointer allocated on the heap pointing to an
   object in the stack, then returning from that stack frame.

All of these problems will, at best, result in an attempt to access
unmapped memory and crash the program.  At worst, they will subtly
write to memory in ways not intended, leading to bugs, security holes,
and hair-pulling on the part of the programmer.

Out of bounds accesses can be eliminated by removing the ability to
construct pointer addresses via pointer arithmatic or from arbitrary
integers. This however is sometimes necessary/very convenient for
low-level programming, such as when accessing memory-mapped device
registers. So instead the solution is to make it so that pointer
arithmatic and such is not *necessary* the way it is in C, and that
all array accesses are bounds-checked.  This is easy, and ensures you
won't create a wild pointer *unless* you are doing something such as
accessing memory-mapped device registers (at which point you need to
be very precise and careful anyway).

Dangling pointers can be solved by reference counting, but that's
about the only way.

Double-free's can't even be solved by reference counting.  While I
would love some kind of magical pointer that automatically zero's
itself when the object it is pointing to is deallocated, that's not
really feasible.  A good testing suite using tools such as valgrind
can detect when this happens though.  It's not even hard to do, it
just makes the program run very slowly.

Pointers pointing into old stack frames can actually be solved by
disallowing pointers from the heap into the stack.  This results in
you having two types of pointers, one allocated on the stack that can
point into the stack, and one allocated on the stack or the heap that
can only point into the heap.  The compiler should usually be able to
distinguish which is which automatically.  Once it knows which is
which it should be able to automatically detect when you're making a
pointer from outside a stack frame point at an object allocated within
the stack frame, and signal an error when this happens.  You also
cannot return stack pointers pointing at objects in the current stack
frame.  Essentially, this means that pointers can point from a stack
frame to areas of longer lifetime (heap objects or lower stack
frames), but not areas of shorter lifetime (higher stack frames).

An option I need to look into more is doing more of the static
lifetime analysis described above; it sounds really hopeful, but
everything I've seen suggests that in practice it leads to either a
very confusing explosion of pointer lifetime annotations, or very
complex and inefficient automatic systems.
