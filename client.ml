open Lwt

(* Connects the client socket to the server *)
let connect_socket ?(addr = Common.sock_addr) () =
  let open Lwt_unix in
  Common.catcher (fun () -> connect Common.sock addr) "Failed to connect"

(* This will handle the connection *)
let handler conn () =
  let fd = conn in
  let ic = Lwt_io.of_fd ~mode:Lwt_io.Input fd in
  let oc = Lwt_io.of_fd ~mode:Lwt_io.Output fd in
  (* if one of these two promises finish we want to be disconnected *)
  let receiver =
    Common.catcher
      (fun () -> Common.handle_receive "Server" ic oc ())
      "Failed to receive messages"
  in
  let inputs =
    Common.catcher (fun () -> Common.handle_input oc ()) "Failed to read inputs"
  in
  Lwt.choose [ receiver; inputs ] >>= fun () ->
  Logs_lwt.info (fun m -> m "Disconnected from the server")

(* [sockaddr_of_string addr] converts a string of type
   "ip:number" or "number" to ADDR_INET
   note: if no ip is provided it will default to 127.0.0.1
*)
let sockaddr_of_string addr =
  let open Unix in
  let l = String.split_on_char ':' addr |> Array.of_list in
  if Array.length l = 1 then
    let port = int_of_string l.(0) in
    ADDR_INET (Unix.inet_addr_loopback, port)
  else
    let listen_address = Unix.inet_addr_of_string l.(0) in
    let port = int_of_string l.(1) in
    ADDR_INET (listen_address, port)

let client () () =
  let rec ask_addr () =
    Logs_lwt.app (fun m ->
        m "Addr (ex: 127.0.0.1:8000) or just a port (ex: 8000): ")
    >>= fun () ->
    Lwt_io.read_line_opt Lwt_io.stdin >>= function
    | Some addr -> (
        try
          let addr = sockaddr_of_string addr in
          connect_socket ~addr ()
        with _ -> Logs_lwt.err (fun m -> m "Invalid address") >>= ask_addr)
    | None -> connect_socket ()
  in
  ask_addr () >>= handler Common.sock
