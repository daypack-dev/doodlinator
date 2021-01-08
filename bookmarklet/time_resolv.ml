(* Choose something! *)
let choice ~no_pref ~maybe_pref (target : Timere.t) =
  let has_overlap_with_no =
    Timere.inter [no_pref; target]
    |> Timere.resolve
    |> Result.get_ok
    |> Fun.negate OSeq.is_empty
  in
  if has_overlap_with_no then
    Crawler.No
  else
    let has_overlap_with_maybe =
      Timere.inter [maybe_pref; target]
      |> Timere.resolve
      |> Result.get_ok
      |> Fun.negate OSeq.is_empty
    in
    if has_overlap_with_maybe then
      Crawler.Maybe
    else
      Crawler.Yes
