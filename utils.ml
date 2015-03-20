(*
  utils.ml
  Copyright (c) 2015 - by Masaki WATANABE
  LICENSE: see LICENSE
*)

let (@@) f g = f g
let (+>) f g = g f
let spf = Printf.sprintf

let try_finally fn ~finally =
  try
    let ret = fn() in
    let () = finally () in
    ret
  with error ->
    finally ();
    raise error
