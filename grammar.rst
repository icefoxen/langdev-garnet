Grammar
=======

Yay ebnf!

Okay, Sphinx was the right choice for this.

The special terminal symbols "number", "char", "id", and so on are
exactly what they sound like.  I could define them down to characters,
but, meh.

.. todo::

   XXX: Should consts be able to only be initialized to a value?
   What about things like arrays and structs?

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
   function_decl: "def" `id` "(" [`argdecllist`] [":" `typespec`] ")" {`expr`} "end"
   type_decl: "type" `typespec` [`genericspec`] "=" `typedeclbody`
   typedeclbody: `typespec` |
               : `structdecl` |
	       : `uniondecl`
   structdecl: "struct" {`structmember`} "end"
   structmember: `id` `typespec`
   uniondecl: "union" {`unionmember`} "end"
   unionmember: `id` [`typespec`] ";"
   interface_decl: "interface" XXX "end"
   implementation_decl: "implement" XXX "end"
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
       : `withexpr` |
       : `assignexpr`
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
   matchexpression: 
   whileexpr: "while" `expr` "do" {`expr`} "end"
   forexpr: "for" [`expr`] ";" [`expr`] ";" [`expr`] "do" {`expr`} "end"
   foreachexpr: "foreach" `varbody` "do" {`expr`} "end"
   tryexpr: "try" {`expr`} {"catch" id `typespec` "do" {`expr`}} ["finally" {`expr`}] "end"
   withexpr: "with" `varbody` {"," `varbody`} "do" {`expr`} "end"
   assignexpr: `lvalue` "<-" `expr`
   lvalue: `idchain` | `seqaccess` | `structaccess`
   typespec: `idchain` [`genericspec`] | 
           : `typeprefix` `typespec`
   typeprefix: "?" | "$" | "^" | "[" [`value`] "]"
   genericspec: "<" `typespec` ">"
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

