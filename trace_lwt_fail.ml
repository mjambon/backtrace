open Lwt

let bind = Lwt.backtrace_bind

let z () =
  if bool_of_string "false" then
    print_endline "z";
  Lwt_unix.sleep 0.001

let a () =
  bind (fun e -> try raise e with e -> e) (z ()) (fun () ->
    if true then
      raise (Invalid_argument "test")
    else
      return ()
  )

let b () =
  bind (fun e -> try raise e with e -> e) (z ()) (fun () ->
    bind (fun e -> try raise e with e -> e) (a ()) (fun () ->
      z ()
    )
  )

let main () =
  catch
    (fun () ->
       bind (fun e -> try raise e with e -> e) (z ()) (fun () ->
         b ()
       )
    )
    (fun e ->
       print_endline (Printexc.to_string e);
       print_string (Printexc.get_backtrace ());
       return ()
    )

let () =
  Printexc.record_backtrace true;
  Lwt_main.run (main ())
