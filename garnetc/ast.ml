(* Simple starter AST for Garnet.
 * Building this before building the parser makes sense!
 * We can change the syntax all we want and still have this
 * be the same.
 *)

type id = string;;
type lit =
  | Int of int
;;

type typespec =
  | SimpleType of id
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
  | Funcall of expr * expr list
  | Variable of id
  | Literal of lit
  | If of expr * expr * expr
  | While of expr * expr list
  | For of expr * expr * expr * expr list
  | Assign of expr * expr
  | Cast of expr * typespec
;;

type decl =
  | LetDecl of id * typespec * lit
  | TypeDecl of typespec * typespec
  | FunDecl of id * functionArg list * typespec * expr list
;;
