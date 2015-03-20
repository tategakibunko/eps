(*
  types.ml
  Copyright (c) 2015 - by Masaki WATANABE
  LICENSE: see LICENSE
*)

type ast = statement list

and statement =
  | PrepareStatement of fun_name * arguments * expr

and fun_name = string

and arguments = expr list

and expr =
  | IdentExpr of string
  | IntExpr of int
  | FloatExpr of float
  | BoolExpr of bool
  | TextExpr of string
  | SqlExpr of string
  | ArgumentExpr of expr * expr * expr option
  | TypeExpr of ps_type

(** prepared statement type *)
and ps_type =
  | Tint
  | Tfloat
  | Tbool
  | Ttext

