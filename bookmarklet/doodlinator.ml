open Js_of_ocaml

let noPref : Timere.t =
  let v = Js.Unsafe.global##.noPref in
  Result.get_ok @@ Timere.of_sexp_string v

let maybePref : Timere.t =
  let v = Js.Unsafe.global##.maybePref in
  Result.get_ok @@ Timere.of_sexp_string v

let () =
  let l = Crawler.doodle () in
  List.iter (fun {Crawler. time ; action } ->
      Time_resolv.choice time |> action
    ) l;
  ()
