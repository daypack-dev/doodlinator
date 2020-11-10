open Js_of_ocaml

let noPref : Daypack_lib.Time_expr_ast.t =
  let v = Js.Unsafe.global##.noPref in
  Marshal.from_string v 0

let maybePref : Daypack_lib.Time_expr_ast.t =
  let v = Js.Unsafe.global##.maybePref in
  Marshal.from_string v 0

let () =
  let l = Crawler.doodle () in
  List.iter (fun {Crawler. time ; action } ->
      Time_resolv.choice time |> action
    ) l;
  ()
