open Lwt_unix

(* This is data that both the client and the server uses *)
let listen_address = Unix.inet_addr_loopback
let port = 8000
let sock_addr = ADDR_INET (listen_address, port)
let sock = socket PF_INET SOCK_STREAM 0

(* Lwt.catch was repetitive
   usage
   [catcher f msg] where we catch the Unix error
   from the f function and fail with the msg message.
*)
let catcher f msg =
  Lwt.catch f (function
    | Unix.Unix_error _ -> Lwt.fail_with msg
    | e -> Lwt.fail e)

(* Handles input from the server side *)
let rec handle_input oc () =
  let open Lwt in
  Lwt_io.read_line_opt Lwt_io.stdin >>= fun server_msg ->
  match server_msg with
  | Some msg ->
      let () = Time.set_sent_time () in
      Lwt_io.write_line oc msg >>= handle_input oc
  | None -> return_unit

(* Handles income messages from the client *)
let rec handle_receive name ic oc () =
  let open Lwt in
  Lwt_io.read_line_opt ic >>= fun msg ->
  match msg with
  | Some msg ->
      let confirmation_msg = "Message received" in
      if msg <> confirmation_msg then
        Logs_lwt.app (fun m -> m "%s: %s" name msg) >>= fun () ->
        Lwt_io.write_line oc confirmation_msg >>= handle_receive name ic oc
      else
        let () = Time.set_received_time () in
        let time = Time.get_time () in
        Logs_lwt.app (fun m -> m "System: %s | %s" msg time)
        >>= handle_receive name ic oc
  | None -> return_unit
