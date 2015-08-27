open Lwt
open Printf

type loc = string

type traced = {
  exn: exn;
  mutable trace: loc list;
}

exception Traced of traced

let trace_loc e loc =
  match e with
  | Traced x ->
      x.trace <- loc :: x.trace;
      raise e
  | e ->
      raise (Traced { exn = e; trace = [loc] })

let trace_bt e =
  let bt = Printexc.get_backtrace () in
  trace_loc e bt

let needs_newline s =
  match s with
  | "" -> false
  | _ -> s.[String.length s - 1] <> '\n'

(* Print exception with wrapped trace, not the stack trace *)
let rec print_traced_exception buf e =
  match e with
  | Traced x ->
      print_traced_exception buf x.exn;
      List.iter (fun loc ->
         if needs_newline loc then
           bprintf buf "%s\n" loc
         else
           Buffer.add_string buf loc
      ) (List.rev x.trace)
  | e ->
      bprintf buf "%s\n" (Printexc.to_string e)

let print_regular_exception buf e =
  let stack_trace = Printexc.get_backtrace () in
  bprintf buf "%s\n%s"
    (Printexc.to_string e)
    stack_trace

let print_exception e =
  let buf = Buffer.create 500 in
  (match e with
   | Traced _ ->
       print_traced_exception buf e
   | e ->
       print_regular_exception buf e
  );
  Buffer.contents buf

let create_thread loc f x =
  catch
    (fun () ->
       try f x
       with e -> trace_bt e
    )
    (fun e -> trace_loc e loc)

let bind loc t f =
  t >>= create_thread loc f

let z () =
  if bool_of_string "false" then
    print_endline "z";
  Lwt_unix.sleep 0.001

let nothing () =
  if bool_of_string "false" then
    print_endline "nothing"

let a0 () =
  nothing ();
  nothing ();
  if true then
    raise (Invalid_argument "test");
  nothing ()

let a () =
  z () >>= create_thread __LOC__ @@ fun () ->
  a0 ();
  return ()

let b () =
  z () >>= create_thread __LOC__ @@ fun () ->
  a () >>= create_thread __LOC__ @@ fun () ->
  z ()

let main () =
  catch
    (fun () ->
       z () >>= create_thread __LOC__ @@ fun () ->
       b ()
    )
    (fun e ->
       printf "%s" (print_exception e);
       return ()
    )

let () =
  Printexc.record_backtrace true;
  Lwt_main.run (main ())
