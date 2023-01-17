exception NotValidChoice

let () =
  let choice = Sys.argv.(1) in
  Logs.set_reporter (Logs_fmt.reporter ());
  Logs.set_level @@ Some Logs.Debug;
  let r =
    match choice with
    | "s" | "server" -> Server.server ()
    | "c" | "client" -> Client.client ()
    | _ -> raise NotValidChoice
  in
  Lwt_main.run @@ r () |> ignore
