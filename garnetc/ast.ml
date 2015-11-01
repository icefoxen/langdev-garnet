(* Simple starter AST for Garnet.
 * Building this before building the parser makes sense!
 * We can change the syntax all we want and still have this
 * be the same.
 *)

type id = string;;
type lit =
  | Int of int
  | Float of float
  | String of string
  | ArrayLit of lit list
  | Char of char
  | Unit
;;

type typespec =
  | SimpleType of id
  | Ref of typespec
  | LocalRef of typespec
  | Array of typespec * int
  | Struct of (string * typespec) list
  | UnitType
  | NotDeclared
;;

type functionArg = string * typespec;;

type binop =
  | Add | Sub | Mul | Div | Mod | And | Or | Xor | BinaryOr
  | BinaryAnd | BinaryXor | Eq | Neq | Gt | Lt | Gte | Lte
;;

type uniop =
  | Negate
  | LogicalNot
  | BinaryNot
;;

type expr =
  | BinaryExpr of binop * expr * expr
  | UnaryExpr of uniop * expr
  | Let of id * typespec * expr
  | Variable of id * typespec * expr
  | Funcall of expr * expr list
  | Literal of lit
  | Var of id
  | ArrayDeref of expr * int
  | StructDeref of expr * string
  | If of expr * expr * expr
  | While of expr * expr list
  | For of expr * expr * expr * expr list
  | Assign of expr * expr
  | Cast of expr * typespec
  | Func of functionArg list * typespec * expr list
;;

type decl =
  | LetDecl of id * typespec * lit
  | TypeDecl of typespec * typespec
  | FunDecl of id * functionArg list * typespec * expr list
;;
