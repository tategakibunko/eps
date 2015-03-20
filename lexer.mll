{
(*
  lexer.mll
  Copyright (c) 2015 - by Masaki WATANABE
  LICENSE: see LICENSE
*)

open Utils
open Parser

let buf = Buffer.create 1024

let get_buf () =
  let sql = Buffer.contents buf in
  Buffer.clear buf;
  sql
}

let blank = [' ' '\t']
let ident_first_char = [ 'A'-'Z' 'a'-'z' ]
let ident_char =  [ 'A'-'Z' 'a'-'z' '_' '0'-'9' ]
let integer = ['0'-'9'] ['0'-'9']*
let float = ['0'-'9']+('.' ['0'-'9']*)? (['e' 'E'] ['+' '-']? ['0'-'9']+)?

rule main = parse
  | blank { main lexbuf }
  | '\n' { Lexing.new_line lexbuf; main lexbuf }
  | "/*" { comment lexbuf }
  | "prepare" { PREPARE }
  | "(" { LPAREN }
  | ")" { RPAREN }
  | "," { COMMA }
  | ":" { COLON }
  | "=" { EQUAL }
  | "int" { TYPE "int" }
  | "float" { TYPE "float" }
  | "bool" { TYPE "bool" }
  | "text" { TYPE "text" }
  | "as" { sql lexbuf }
  | "'" { quote_string_literal lexbuf }
  | '"' { dquote_string_literal lexbuf }
  | integer as i { INT (int_of_string i) }
  | float as f { FLOAT (float_of_string f) }
  | "true" { BOOL true }
  | "false" { BOOL false }
  | ident_first_char ident_char* as word { IDENT word }
  | eof { EOF }
  | _ {
    failwith @@ spf "lexer error:illegal token '%s'" (Lexing.lexeme lexbuf)
  }

and comment = parse
  | "*/" { main lexbuf }
  | _ { comment lexbuf }

and quote_string_literal = parse
  | '\'' { STRING (get_buf ()) }
  | _  {
    Buffer.add_char buf (Lexing.lexeme_char lexbuf 0);
    quote_string_literal lexbuf
  }

and dquote_string_literal = parse
  | '\"' { STRING (get_buf ()) }
  | _ {
    Buffer.add_char buf (Lexing.lexeme_char lexbuf 0);
    dquote_string_literal lexbuf
  }

and sql = parse
  | ';' { SQL (get_buf ()) }  
  | '\n' {
    Lexing.new_line lexbuf;
    Buffer.add_char buf ' ';
    sql lexbuf
  }
  | _ {
    Buffer.add_char buf (Lexing.lexeme_char lexbuf 0);
    sql lexbuf
  }
