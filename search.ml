open Lwt
open Cohttp
open Cohttp_lwt_unix

let callback _conn req body =
  body |> Cohttp_lwt_body.to_string >>= (fun body ->
    let query = req |> Request.uri |> Uri.verbatim_query in
    let uri = Uri.of_string (match query with
        | Some q ->
            if (Str.string_match (Str.regexp "^!") q 0)
            then
              "https://duckduckgo.com?q=" ^ q
            else
              "https://www.google.com/#q=" ^ q
        | None ->
            "https://www.google.com")
    in
    Server.respond_redirect ~uri:uri ())

let server =
  Server.create ~mode:(`TCP (`Port 8000)) (Server.make ~callback ())

let () = ignore (Lwt_main.run server)
