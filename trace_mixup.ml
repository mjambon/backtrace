external reraise : exn -> _ = "%reraise"

let nothing () =
  if bool_of_string "false" then
    print_endline "nothing"

let a () =
  if true then
    raise Exit

let anything () =
  try raise Exit
  with _ -> ()

let b () =
  nothing ();
  (try
     a ()
   with e ->
     anything ();
     reraise e
  );
  nothing ()

let main () =
  try b ()
  with e ->
    print_endline (Printexc.to_string e);
    print_string (Printexc.get_backtrace ())

let () =
  Printexc.record_backtrace true;
  main ()
