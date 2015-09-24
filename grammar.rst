Grammar
=======

The Garnet grammar, in EBNF.  It does not handle operator precedence.

The special terminal symbols "number", "char", "id", and so on are
exactly what they sound like.  I could define them down to characters,
but, meh.

.. todo::

   XXX: Should consts be able to only be initialized to a value?
   What about things like array and struct literals?  If we make
   it so that values must always be initialized, we SHOULD have some
   nice shorthand for them...  Something like `var foo [100]int = 0`

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

Step one, the basic stuff.  Variables, functions, math, if's, loops, and that's it.


.. productionlist:: 
   program: {`declaration`}
   declaration: `let_decl` |
        : `function_decl` |
        : `type_decl`
   let_decl: "let" id `typespec` "=" `lit`
   function_decl: "def" `id` "(" [`argdecllist`] [":" `typespec`] ")" {`expr`} "end"
   type_decl: "type" `typespec` "=" `typedeclbody`
   typedeclbody: `typespec` |
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

Step two, reference types

Revision 3
----------

Step three, compound types and pattern matching

Revision 4
----------

Step four, module system

Revision 5
----------

Step five, generics and type inference

Revision 6
----------

Step six, low level junk and memory access

Revision 7
----------

Step seven, interfaces, multimethods?
