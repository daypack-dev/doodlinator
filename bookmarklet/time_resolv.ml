open Js_of_ocaml

let choice ~no_pref ~maybe_pref (target : Timere.t) =
  let () = Js.Unsafe.global##.console##log (Js.string (Printf.sprintf "target: %s" (Timere.to_sexp_string target))) in
  let has_overlap_with_no =
    Timere.inter [no_pref; target]
    |> Timere.resolve
    |> Result.get_ok
    |> Fun.negate OSeq.is_empty
  in
  let has_overlap_with_maybe =
    Timere.inter [maybe_pref; target]
    |> Timere.resolve
    |> Result.get_ok
    |> Fun.negate OSeq.is_empty
  in
  if has_overlap_with_no then
    let () = Js.Unsafe.global##.console##log (Js.string ("choice: No")) in
    Crawler.No
  else
    if has_overlap_with_maybe then
      let () = Js.Unsafe.global##.console##log (Js.string ("choice: Maybe")) in
      Crawler.Maybe
    else
      let () = Js.Unsafe.global##.console##log (Js.string ("choice: Yes")) in
      Crawler.Yes
