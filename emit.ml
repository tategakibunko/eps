(*
  emit.ml
  Copyright (c) 2015 - by Masaki WATANABE
  LICENSE: see LICENSE
*)

open Utils
open Types

exception InvalidArgument of string

module Sql = struct
  let rec code = function
    | PrepareStatement(fun_name, args, SqlExpr(sql)) ->
      spf "prepare %s(%s) as %s;" fun_name (prep_fun_labels args) (prep_fun_body ~args ~sql);
    | _ -> raise @@ InvalidArgument "Sql.code"

  and prep_fun_labels args =
    String.concat ", " @@ List.map arg_ps_type_name args

  and prep_fun_body ~args ~sql =
    List.mapi (fun i arg -> (i, arg)) args
    +> List.fold_left (fun sql (i, arg) ->
      Pcre.replace ~pat:(arg_label_place_holder arg) ~templ:(spf "$$%d" (i+1)) sql
    ) sql

  and string_of_ps_type = function
    | Tint -> "int"
    | Tfloat -> "float"
    | Tbool -> "bool"
    | Ttext -> "text"

  and arg_label = function
    | ArgumentExpr(label, _, _) -> label
    | _ -> raise @@ InvalidArgument "arg_label"

  and arg_label_name = function
    | ArgumentExpr(IdentExpr(name), _, _) -> name
    | _ -> raise @@ InvalidArgument "arg_label_name"
      
  and arg_label_place_holder = function
    | ArgumentExpr(IdentExpr(name), _, _) -> "{" ^ name ^ "}"
    | _ -> raise @@ InvalidArgument "arg_label_place_holder"
      
  and arg_ps_type = function
    | ArgumentExpr(_, TypeExpr(ps_type), _) -> ps_type
    | _ -> raise @@ InvalidArgument "arg_ps_type"
      
  and arg_ps_type_name = function
    | ArgumentExpr(_, TypeExpr(ps_type), _) -> string_of_ps_type ps_type
    | _ -> raise @@ InvalidArgument "arg_ps_type_name"
end

module OCaml = struct
  let rec code statement =
    String.concat "\n" [
      prep_func statement;
      "";
      exec_func statement;
      "";
    ]

  and prep_func = function
    | PrepareStatement(fun_name, args, SqlExpr(sql)) as statement ->
      String.concat "\n" [
	spf "let %s =" (prep_fun_name fun_name);
	spf "  \"%s\"" (Sql.code statement);
      ]
    | _ -> raise @@ InvalidArgument "OCaml.prep_func"

  and exec_func = function
    | PrepareStatement(fun_name, args, SqlExpr(_)) ->
      String.concat "\n" [
	spf "let %s %s () =" (exec_fun_name fun_name) (exec_fun_labels args);
	spf "  %s" (exec_fun_body ~fun_name ~args);
      ]
    | _ -> raise @@ InvalidArgument "OCaml.exec_func"

  and prep_fun_name fun_name =
    "prep_" ^ fun_name

  and exec_fun_name fun_name =
    "exec_" ^ fun_name

  and exec_fun_labels args =
    String.concat " " @@ List.map exec_fun_label args

  and exec_fun_label = function
    | ArgumentExpr(IdentExpr(name), TypeExpr(ps_type), None) -> "~" ^ name
    | ArgumentExpr(IdentExpr(name), TypeExpr(ps_type), Some(defv)) -> spf "?(%s = %s)" name (defval ps_type defv)
    | _ -> raise @@ InvalidArgument "OCaml.exec_fun_label"

  and defval ps_type defv =
    match ps_type, defv with
      | Tint, IntExpr(i) -> string_of_int i
      | Tfloat, FloatExpr(f) -> string_of_float f
      | Tbool, BoolExpr(b) -> string_of_bool b
      | Ttext, TextExpr(s) -> spf "\"%s\"" s
      | _ -> raise @@ InvalidArgument "OCaml.defval"

  and exec_fun_body ~fun_name ~args =
    spf "Printf.sprintf \"execute %s(%s);\" %s" fun_name (exec_arg_fmts args) (exec_labels args)

  and exec_arg_fmts args =
    String.concat ", " @@ List.map exec_arg_fmt args

  and exec_arg_fmt arg =
    match Sql.arg_ps_type arg with
      | Tint -> "%d"
      | Tfloat -> "%f"
      | Tbool -> "%b"
      | Ttext -> "'%s'"

  and exec_labels args =
    String.concat " " @@ List.map Sql.arg_label_name args
end
