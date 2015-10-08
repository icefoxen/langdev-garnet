%{
(* parse.mly
   Parser for Dumblang
   Fairly simple; the syntax isn't exactly complicated.
   Each rule builds up part of an abstract syntax tree, which then has
   various fun things done to it by semant.ml.

   Simon Heath
   20ish/4/2005
*)


let print_bop () = print_endline "Bop!";;


%}
%token LPAREN RPAREN
%token NAMESPACE IMPORT AS PERIOD TYPE EQUAL STRUCT END COLON
%token DATA CARAT PERCENT COMMA LBRACE RBRACE LBRACKET RBRACKET
%token GLOBAL CONST DEF LET IF THEN ELIF ELSE FOR DO WHILE
%token LARROW RARROW BREAK RETURN FUN MATCH WITH DOLLAR UNDERSCORE
%token ADD SUB MUL DIV EQ NEQ GT LT GTE LTE

%type <int list> main 
%start main
%%
main: LPAREN RPAREN {[1]}
%% 

