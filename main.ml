(*
  main.ml
  Copyright (c) 2015 - by Masaki WATANABE
  LICENSE: see LICENSE
*)

open Utils
open Types

let () =
  let usage = "pfs.exe -input [input file] -format [ocaml|sql]" in
  let filename = ref "" in
  let format = ref "ocaml" in
  Arg.parse [
    ("-format", Arg.String (fun s -> format := s), "-format [output format]");
    ("-input", Arg.String (fun s -> filename := s), "-input [filename]");
  ] ignore usage;
  if !filename = "" then begin
    print_endline usage;
    failwith "invalid args"
  end;
  let inchan = open_in !filename in
  let lexbuf = Lexing.from_channel inchan in
  let ast = Parser.input Lexer.main lexbuf in
  (match !format with
    | "sql" -> print_endline @@ String.concat "\n" @@ List.map Emit.Sql.code ast
    | "ocaml" -> print_endline @@ String.concat "\n" @@ List.map Emit.OCaml.code ast
    | other -> failwith @@ spf "undefined format:%s" other);
  close_in inchan
      


