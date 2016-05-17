Grammar
=======

The Garnet grammar, in EBNF.  It does not handle operator precedence.

The special terminal symbols "number", "char", "id", and so on are
exactly what they sound like.  I could define them down to characters,
but, meh.

.. todo::
   Const-by-default? Consts vs. globals vs. readonly?

   XXX: Should consts be able to only be initialized to a value?
   What about things like array and struct literals?  If we make
   it so that values must always be initialized, we SHOULD have some
   nice shorthand for them...  Something like `var foo [100]int = 0`

   Errors, exceptions, conditions...

.. productionlist:: 
   program: {`declaration`}
   declaration: `variable_decl` |
              : `const_decl` |
	      : `function_decl` |
	      : `namespace_decl`
	      : `type_decl`
	      : `interface_decl`
	      : `implementation_decl`
   variable_decl: "var" id `typespec` "=" `lit`
   const_decl: "const" id `typespec` "=" `lit`
   namespace_decl: "namespace" `idchain` `program` "end"
   function_decl: "def" `id` [`genericspec`] "(" [`argdecllist`] [":" `typespec`] ")" {`expr`} "end"
   type_decl: "type" `typespec` [`genericspec`] "=" `typedeclbody`
   typedeclbody: `typespec` |
               : `structdecl` |
	       : `uniondecl`
   structdecl: "struct" {`structmember`} "end"
   structmember: `id` `typespec`
   uniondecl: "union" {`unionmember`} "end"
   unionmember: `id` [`typespec`] ";"
   interface_decl: "interface" id [`genericspec`] {`interfacemember`} "end"
   interfacemember: `function_decl` |
                  : "virtual" `funcsignature`
   implementation_decl: "implement" id [`genericspec`] "end"
   argdecllist: id `typespec` {"," id `typespec`}
   expr: `binexpr` |
       : `unaryexpr` |
       : `varexpr` |
       : `constexpr` |
       : `funcallexpr` |
       : `value` |
       : `ifexpr` |
       : `matchexpr` |
       : `whileexpr` |
       : `forexpr` |
       : `foreachexpr` |
       : `tryexpr` |
       : `throwexpr` |
       : `withexpr` |
       : `assignexpr` |
       : `castexpr` |
       : `castasexpr`
   binexpr: `expr` `binop` `expr`
   binop: "+" | "-" | "*" | "/" | "%" | "and" | "or" | "xor" | "|" |
        : "&" | "^" | "==" | "/=" | "<" | ">" | "<=" | ">="
   unaryexpr: `unaryop` `expr`
   unaryop: "-" | "not" | "~"
   varexpr: "var" `varbody`
   constexpr: "const" `varbody`
   varbody: id [`typespec`] "=" `expr`
   funcallexpr: `idchain` [`genericspec`] "(" {`arglist`} ")"
   arglist: `expr` {"," `expr`}
   ifexpr: "if" `expr` "then" {`expr`} {"elif" {`expr`}} ["else" {`expr`}] "end"
   matchexpr: "match" `expr` "with" {`matchcase`} "end"
   matchcase: `matchexpression` "->" {`expr`} ";"
   matchexpression: XXX
   whileexpr: "while" `expr` "do" {`expr`} "end"
   forexpr: "for" [`expr`] ";" [`expr`] ";" [`expr`] "do" {`expr`} "end"
   foreachexpr: "foreach" `varbody` "do" {`expr`} "end"
   tryexpr: "try" {`expr`} {"catch" id `typespec` "do" {`expr`}} ["finally" {`expr`}] "end"
   throwexpr: "throw" `expr`
   withexpr: "with" `varbody` {"," `varbody`} "do" {`expr`} "end"
   assignexpr: `lvalue` "<-" `expr`
   lvalue: `idchain` | `seqaccess` | `structaccess`
   castexpr: "cast" `genericspec` "(" `expr` ")"
   castasexpr: `expr` "as" `typespec`
   typespec: `idchain` [`genericspec`] | 
           : `typeprefix` `typespec`
	   : `funcsignature`
   typeprefix: "?" | "$" | "^" | "[" [`value`] "]"
   funcsignature: "fun" `genericspec` `argtypes`
   argtypes: "(" [`typespec` {"," `typespec`} [":" `typespec` ")"
   genericspec: "<" `typespec` {"," `typespec`} ">"
   idchain: id {"." id}
   lit: number | char | string | `arraylit` | `structlit` | `tuplelit` | `unionlit`
   arraylit: "[" [`expr` {"," `expr`}] "]"
   structlit: id "{" [`structfield` {"," `structfield`}] "}"
   structfield: id "=" `expr`
   tuplelit: "{" [`expr` {"," `expr`}] "}"
   unionlit: id `lit`
   value: id | `lit` | `seqaccess` | `structaccess`
   seqaccess: `expr` "[" `expr` "]"
   structaccess: `expr` "." `idchain`


Revision 1
----------

The basic stuff.  Variables, functions, math, if's, loops, and that's it.


.. productionlist:: 
   program: {`declaration`}
   declaration: `let_decl` |
        : `function_decl` |
        : `type_decl`
   let_decl: "let" id `typespec` "=" `lit`
   function_decl: "def" `id` "(" [`argdecllist`] ")" [":" `typespec`] {`expr`} "end"
   type_decl: "type" `typespec` "=" `typedeclbody`
   typedeclbody: `typespec`
   argdecllist: id `typespec` {"," id `typespec`}
   expr: `binexpr` |
       : `unaryexpr` |
       : `letexpr` |
       : `funcallexpr` |
       : `value` |
       : `ifexpr` |
       : `whileexpr` |
       : `forexpr` |
       : `withexpr` |
       : `assignexpr`
       : `castexpr`
   binexpr: `expr` `binop` `expr`
   binop: "+" | "-" | "*" | "/" | "%" | "and" | "or" | "xor" | "|" |
        : "&" | "^" | "==" | "/=" | "<" | ">" | "<=" | ">="
   unaryexpr: `unaryop` `expr`
   unaryop: "-" | "not" | "~"
   letexpr: "let" `varbody`
   varbody: id [`typespec`] "=" `expr`
   funcallexpr: id "(" {`arglist`} ")"
   arglist: `expr` {"," `expr`}
   ifexpr: "if" `expr` "then" {`expr`} {"elif" {`expr`}} ["else" {`expr`}] "end"
   whileexpr: "while" `expr` "do" {`expr`} "end"
   forexpr: "for" [`expr`] ";" [`expr`] ";" [`expr`] "do" {`expr`} "end"
   assignexpr: `lvalue` "<-" `expr`
   lvalue: id
   castexpr: `expr` "as" `typespec`
   typespec: id | 
       : `funcsignature`
   funcsignature: "fun" `argtypes`
   argtypes: "(" [`typespec` {"," `typespec`} [":" `typespec` ")"
   lit: number | char | string
   value: id | `lit`


Revision 2
----------

Reference types

Changes: Stack and heap references, function types, local functions, lambda's.

.. productionlist::
   typespec: id | 
        : `typeprefix` `typexpec
        : `funcsignature`
   typeprefix: "^" | "$"


.. productionlist:: 
   program: {`declaration`}
   declaration: `let_decl` |
        : `function_decl` |
        : `type_decl`
   let_decl: "let" id `typespec` "=" `lit`
   function_decl: "def" `id` "(" [`argdecllist`] ")" [":" `typespec`]  {`expr`} "end"
   type_decl: "type" `typespec` "=" `typedeclbody`
   typedeclbody: `typespec`
   argdecllist: id `typespec` {"," id `typespec`}
   expr: `binexpr` |
      : `unaryexpr` |
      : `letexpr` |
      : `funcallexpr` |
      : `value` |
      : `ifexpr` |
      : `whileexpr` |
      : `forexpr` |
      : `withexpr` |
      : `assignexpr`
      : `castexpr`
   binexpr: `expr` `binop` `expr`
   binop: "+" | "-" | "*" | "/" | "%" | "and" | "or" | "xor" | "|" |
        : "&" | "^" | "==" | "/=" | "<" | ">" | "<=" | ">="
   unaryexpr: `unaryop` `expr`
   unaryop: "-" | "not" | "~"
   letexpr: "let" `varbody`
   varbody: id [`typespec`] "=" `expr`
   funcallexpr: id "(" {`arglist`} ")"
   arglist: `expr` {"," `expr`}
   ifexpr: "if" `expr` "then" {`expr`} {"elif" {`expr`}} ["else" {`expr`}] "end"
   whileexpr: "while" `expr` "do" {`expr`} "end"
   forexpr: "for" [`expr`] ";" [`expr`] ";" [`expr`] "do" {`expr`} "end"
   assignexpr: `lvalue` "<-" `expr`
   lvalue: id
   castexpr: `expr` "as" `typespec`
   typespec: id | 
        : `typeprefix` `typexpec
        : `funcsignature`
   typeprefix: "^" | "$"
   funcsignature: "fun" `argtypes`
   argtypes: "(" [`typespec` {"," `typespec`} [":" `typespec` ")"
   lit: number | char | string
   value: id | `lit`



Revision 3
----------

Compound types and pattern matching

Arrays and slices should be a thing.  An array is the actual static array referred to directly, a slice is a a pointer and length to an array.

Changes: Array type, slice type, array reference expr and lvalue, struct type, struct field reference and lvalue, tuple type, tuple literals, tuple destructuring let.  Array and struct literals.

Revision 4
----------

Module system

Changes: module/namespace declarations, import, from x import y, module qualified names

Revision 5
----------

Generics and type inference

Changes: Make type qualifiers on let optional, add generic qualifiers to typedefs, functions, type qualifiers...

Revision 6
----------

Low level junk and memory access

Changes: Pointers, unsafe regions?

Revision 7
----------

Macros

Revision 8
----------

Interfaces, multimethods?, objects?, typeclasses?, traits?  Some kind of subtyping system, but recall the goal is to keep things fairly generic and minimalistic.

Ideally, it should be possible to implement these in Garnet using the macro system...  