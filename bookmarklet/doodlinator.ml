open Js_of_ocaml

let noPref : Timere.t =
  let v = Js.to_string @@ Js.Unsafe.js_expr {|document.getElementById("timere").noPref|} in
  let () = Js.Unsafe.global##.console##log (Js.string v) in
  Result.get_ok @@ Timere.of_sexp_string v

let maybePref : Timere.t =
  let v = Js.to_string @@ Js.Unsafe.js_expr {|document.getElementById("timere").maybePref|} in
  let () = Js.Unsafe.global##.console##log (Js.string v) in
  Result.get_ok @@ Timere.of_sexp_string v

let () =
  let l = Crawler.doodle () in
  List.iter (fun {Crawler. time ; action } ->
      Time_resolv.choice time |> action
    ) l;
  ()
