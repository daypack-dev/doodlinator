open Js_of_ocaml

let choice ~no_pref ~maybe_pref (target : Timere.t) =
  let () = Js.Unsafe.global##.console##log (Js.string (Printf.sprintf "target: %s" (Timere.to_sexp_string target))) in
  (* let () =
   *   Timere.inter [no_pref; target]
   *   |> Timere.resolve
   *   |> Result.get_ok
   *   |> OSeq.take 5
   *   |> OSeq.iter (fun x ->
   *       (
   *         Js.Unsafe.global##.console##log
   *           (Js.string (Timere.sprintf_interval x)))
   *     )
   * in *)
  let has_overlap_with_no =
    Timere.inter [no_pref; target]
    |> Timere.resolve
    |> Result.get_ok
    |> Fun.negate OSeq.is_empty
  in
  let has_overlap_with_maybe =
    (* Timere.inter [maybe_pref; target]
     * |> Timere.resolve
     * |> Result.get_ok
     * |> OSeq.take 5
     * |> Fun.negate OSeq.is_empty *)
    false
  in
  if has_overlap_with_no then
    Crawler.No
  else
    if has_overlap_with_maybe then
      Crawler.Maybe
    else
      Crawler.Yes
