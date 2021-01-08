open Js_of_ocaml

let no_pref : Timere.t =
  let v = Js.to_string @@ Js.Unsafe.js_expr {|document.getElementById("timere").noPref|} in
  let () = Js.Unsafe.global##.console##log (Js.string (Printf.sprintf "no_pref : %s" v)) in
  Result.get_ok @@ Timere.of_sexp_string v

let maybe_pref : Timere.t =
  let v = Js.to_string @@ Js.Unsafe.js_expr {|document.getElementById("timere").maybePref|} in
  let () = Js.Unsafe.global##.console##log (Js.string (Printf.sprintf "maybe_pref : %s" v)) in
  Result.get_ok @@ Timere.of_sexp_string v

let () =
  Lwt.async (fun () ->
      let%lwt l = Crawler.doodle () in
      List.iter (fun {Crawler. time ; action } ->
          Time_resolv.choice ~no_pref ~maybe_pref time |> action
        ) l;
      Lwt.return_unit
    )
