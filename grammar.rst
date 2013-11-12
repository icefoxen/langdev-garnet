Grammar
=======

Yay ebnf!

Okay, Sphinx was the right choice for this.

The special terminal symbols "number", "char", "id", and so on are
exactly what they sound like.  I could define them down to characters,
but, meh.

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
   function_decl: "def" `id` "(" [`arglist`] [":" `typespec`] ")" {`expr`} "end"
   type_decl: "type" `typespec` [`genericspec`] "=" `typedeclbody`
   typedeclbody: `typespec` |
               : `structdecl` |
	       : `uniondecl`
   structdecl: "struct" {`structmember`} "end"
   structmember: `id` `typespec`
   uniondecl: "union" {`unionmember`} "end"
   unionmember: `id` [`typespec`] ";"
   interface_decl: "interface" "end"
   implementation_decl: "implement" "end"
   arglist: id `typespec` {"," id `typespec`}
   expr: `binexpr` |
       : `unaryexpr` |
       : `varexpr` |
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
   unaryexpr: `unaryop` `expr`
   varexpr: "var" id [`typespec`] "=" expr
   funcallexpr:
   ifexpr:
   matchexpr:
   whileexpr:
   forexpr:
   foreachexpr:
   tryexpr:
   withexpr:
   assignexpr:
   typespec: `idchain` [`genericspec`] | 
           : `typeprefix` `typespec`
   typeprefix: "?" | "$" | "^" | "[" [`value`] "]"
   genericspec: "<" `typespec` ">"
   idchain: id {"." id}
   lit: number | char | string | `arraylit` | `structlit` | `tuplelit`
   arraylit: "[" "]"
   structlit: id "{" "}"
   tuplelit: "{" "}"
   value: id | `lit` | `seqaccess` | `structaccess`
   seqaccess: `expr` "[" `expr` "]"
   structaccess: `expr` "." `idchain`
   binop: "+" | "-"
   unaryop: "-" | "not"
   assignexpr: 
