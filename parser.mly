%{
(*
  parser.mly
  Copyright (c) 2015 - by Masaki WATANABE
  LICENSE: see LICENSE
*)

open Utils
open Types

let type_expr = function
  | "int" -> TypeExpr(Tint)
  | "float" -> TypeExpr(Tfloat)
  | "bool" -> TypeExpr(Tbool)
  | "text" -> TypeExpr(Ttext)
  | name -> failwith @@ spf "undefined type:%s" name

let argument_with_default argument default =
  match argument with
    | ArgumentExpr(ident, ps_type, _) -> ArgumentExpr(ident, ps_type, default)
    | _ -> failwith "syntax error"
%}

%token PREPARE
%token LPAREN
%token RPAREN
%token COLON
%token COMMA
%token EQUAL
%token AS
%token EOF

%token <int> INT
%token <float> FLOAT
%token <string> STRING
%token <bool> BOOL

%token <string> SQL
%token <string> IDENT
%token <string> TYPE

%start input
%type <Types.ast> input

%%

input:
| statements EOF { $1 }
;

statements:
| statement { [$1] }
| statement statements { $1 :: $2 }
;

statement:
| PREPARE IDENT LPAREN arguments RPAREN SQL {
  PrepareStatement($2, $4, SqlExpr($6))
}
;

arguments:
| argument { [$1] }
| argument COMMA arguments { $1 :: $3 }
;

argument:
| argument_left { $1 }
| argument_left EQUAL argument_right {
  argument_with_default $1 (Some $3)
}
;

argument_left:
| IDENT COLON TYPE {
  ArgumentExpr(IdentExpr($1), type_expr $3, None)
}
;

argument_right:
| INT { IntExpr($1) }
| FLOAT { FloatExpr($1) }
| BOOL { BoolExpr($1) }
| STRING { TextExpr($1) }
;
