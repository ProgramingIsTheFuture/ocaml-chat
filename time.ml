type t = { mutable sent : float; mutable received : float }

let time = { sent = 0.0; received = 0.0 }

let empty_time () =
  time.received <- 0.0;
  time.sent <- 0.0

let set_sent_time () = time.sent <- Unix.gettimeofday ()
let set_received_time () = time.received <- Unix.gettimeofday ()

(* converts the time from last request to string *)
let get_time () =
  let r = time.received in
  let s = time.sent in
  let t = r -. s in
  let () = empty_time () in
  Format.sprintf "Time: %f" t
