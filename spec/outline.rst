Outline
=======
This is just a sketch, so far.

Statements
----------

Modules
~~~~~~~

C#-style dynamic namespaces?  How coupled should namespaces be to
files/compilation units?  I feel like C# probably has the best way in
having them completely decoupled, though we probably just want to have
namespaces defined per-file instead of having them be a block.

::

   use Module
   use Module.Submodule.*
   use Module as M

Functions
~~~~~~~~~

::
   
  def foo(x:i8, y:f32) bool =
    expr
  end


We do need varargs, but we aren't going to bother with unknown types,
default args, named args, or any of that BS yet.  KISS.

::

  def format(formatString:string, args:[]string) string =
    ...
  end


Honestly we could just define this to be syntactic sugar, so that::

  format(x, y, z)

gets turned into::

  format(x, [y,z])

which is nicely simple.  This might be doable with macros.  A
Python-style `*` operator might be nice, too.

Global var/const
~~~~~~~~~~~~~~~~

::
   
   let x:i32 = something()
   let mut y:i32 = x+5

Consts must be resolvable at compile time.  Or can the compiler just
figure it out for us and do the Right Thing?  Do we want it to?

::
   
   const x:i32 = 5


Typedef
~~~~~~~

::
   
   type int = i32


Struct
~~~~~~

::
   
  type mystruct = struct
    x: i32
    y: someOtherType
  end


Union
~~~~~

Comma, semicolon or pipe as a separator here?

Right now we're going with a semicolon.

Might want to consider consistency with the struct definition syntax.

::

  type intOption = union
    Some(i32);
    None;
  end


Expressions
-----------

Let
~~~

::
   
   let x:i32 = 0
   let mut y:f32 = 0.0


Assign
~~~~~~

::
   
   let mut x:i32 = 0
   x <- 10


If
~~

Dangling else's are lame.

::


  if foo then
    bar
  end

  if foo then
    bar
  else
    bop
  end

While
~~~~~

::


   while foo do
      bar
   end


For
~~~

Might not be necessary, depending on how efficient iterators are::

  for i:i32 = 0; i < 10; i <- i + 1 do 
    bar
  end


Foreach
~~~~~~~

::
   
   foreach i:i32 in range(10) do
      bar
   end

Match
~~~~~

Comma or semicolon here should match the union definition::

  match expr with
    Some(x) -> x;
    None -> something;
  end

Type conversions
~~~~~~~~~~~~~~~~

Converting types into one another::

  let x:i32 = 10
  let y:f32 = x as f32

Not sure yet what this should do in the case of failure.  Depends on
what error-handling mechanisms we have.  It will either return an
option, which then has to be null-coalesced, or throw an exception.
Probably return an option, and have an ``??`` operator that will
return a default value if none, and an ``?!`` or ``!!`` operator that
will raise an exception (of some kind) if none.  (Not sure which
syntax looks more startled; I think ``?!`` captures the gist of the
operation better.)
  
Types
-----

Functions
~~~~~~~~~

::
   
   let square:fn(i32):i32 = fn x -> x*x


Arrays
~~~~~~

Go uses ``[5]int``, Rust uses ``[int;5]``, C uses ``int[5]``...

I guess the Go style makes the most sense, we have container, then the
thing it contains.  I honestly sorta dislike it for this purpose, but
we want it to be consistent.

Arrays are a fixed size known at compile time (or maybe at least at runtime)::
  
  let somearray:[5]i32 = [1,2,3,4,5]


Slices
~~~~~~

Slices are variable size, their length is checked at runtime.  They
basically consist of a length and a pointer to an array.

Yes, I'm lifting this wholesale from Rust.

::

   let someslice:[]i32 = [1,2,3,4,5]
   let slice2:[]i32 = someslice[1,3]


Or maybe::

  let slice2:[]i32 = someslice[1:3]
  
Or::
  
  let slice2:[]i32 = someslice[1..3]


Tuples
~~~~~~

Not going to worry about construction or deconstruction in function
calls or any of that sort of thing yet, just assignments and matches.::

  let sometuple:(i32, f32) = (5, 5.0)
  let (x,y):(i32, f32) = sometuple


Unions
~~~~~~

::

   type intOption = union
      Some(i32);
      None;
   end

   let x:intOption = Some(3)
   let y:intOption = None


To disambiguate, if necessary::

  let x:intOption = intOption.None
  let y:floatOption = floatOption.None


With explicit types it's not necessary, but when we infer types it
might be nice.

References (simple)
~~~~~~~~~~~~~~~~~~~

This is probably gonna change as time goes on.::

  let x:^int = 5
  let y:int = ^x


Here, the reference is mutable, what it refers to is not::

  let mut x:^int = &5
  let y:^int = x
  x <- &6
  print(^y) -- prints 6
  
The address-of operator and the semantics of it are still undefined
right now.  Also need to think more about the immutability and
implications of it.

Strings
~~~~~~~

::
   
   "UTF-8 string"
   
   b"byte string"
   
   """
   Multi-line literal string
   """
   

Generics
~~~~~~~~

::

   type Option<T> = union
      Some(T);
      None;
   end

   let o1:Option<i32> = Some(5)
   let o2:Option<f32> = Some(5.0)



Other stuff
-----------

Comments
~~~~~~~~

::
   
   -- this style?
   // Or this style?
   # Maybe even this style?

   /* this style? */
   --[[ Maybe this style or something?
   I don't really have a reason to not want C style for block comments...
   ]]

Block comments can be nested.
   
Things to ponder
----------------

with expression
~~~~~~~~~~~~~~~

::

   with some_expr() as f do
      do_stuff_with_f
   end


Needs destructors to be meaningful.


Parenless function calls
~~~~~~~~~~~~~~~~~~~~~~~~

Really sorta needs currying to be useful with operators like `(|>)`
and such.

Increment/decrement syntax
~~~~~~~~~~~~~~~~~~~~~~~~~~

``+=`` and ``-=`` operators are sorta nice, especially in loops.
