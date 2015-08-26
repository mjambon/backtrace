(*
   Complete stack trace:

     ocamlopt -o trace.opt -g -inline 0 trace.ml
     ./trace.opt

   Incomplete stack trace:

     ocamlopt -o trace.opt -g trace.ml
     ./trace.opt
*)

let nothing () =
  if bool_of_string "false" then
    print_endline "nothing"

let a () =
  if true then
    raise (Invalid_argument "test")

let b () =
  a ();
  nothing ()

let main () =
  try b ()
  with e ->
    print_endline (Printexc.to_string e);
    print_string (Printexc.get_backtrace ())

let () =
  Printexc.record_backtrace true;
  main ()
