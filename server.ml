open Lwt

(* Creates a new TCP socket *)
let create_socket () =
  let open Lwt_unix in
  let _ =
    Common.catcher
      (fun () ->
        bind Common.sock @@ Common.sock_addr >>= fun () ->
        return @@ listen Common.sock 1)
      "Failed to bind the address"
    (* Common.catcher *)
    (* ( bind Common.sock @@ Common.sock_addr >>= fun () -> *)
    (*   return @@ listen Common.sock 1 ) *)
    (* "Failed to bind the address" *)
  in
  Common.sock

let accept_connection conn =
  Logs_lwt.info (fun m -> m "User connected") |> ignore_result;
  let fd, _ = conn in
  let ic = Lwt_io.of_fd ~mode:Lwt_io.Input fd in
  let oc = Lwt_io.of_fd ~mode:Lwt_io.Output fd in
  let hi = Common.handle_input oc () in
  let hr = Common.handle_receive "Client" ic oc () in
  (* if one of these two promises finish we want to cancel the other
     and move on
     to handle more connections*)
  Lwt.choose [ hi; hr ] >>= fun () ->
  Lwt.cancel hi;
  Lwt.cancel hr;
  return_unit >>= fun () -> Logs_lwt.info (fun m -> m "User disconnected")

(* Creates a new server to handle connections *)
let create_server sock =
  let open Lwt_unix in
  let rec serve () =
    Common.catcher
      (fun () -> accept sock >>= accept_connection >>= serve)
      "Failed to accept a new connection"
  in
  serve

let server () =
  let sock = create_socket () in
  create_server sock
