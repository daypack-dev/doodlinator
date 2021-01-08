open Js_of_ocaml

exception Selector_not_found of string

let query_all node s =
  Dom.list_of_nodeList (node##querySelectorAll (Js.string s))

let query node s =
  Js.Opt.get
    (node##querySelector (Js.string s))
    (fun () -> raise @@ Selector_not_found s)

let query_inner_html node s =
  Js.to_string @@
  (query node s)##.innerHTML

type choice = Yes | No | Maybe

type column = {
  time : Timere.t ;
  action : choice -> unit ;
}

let doodle () =
  let tz_field =
    Option.get @@
    (Dom_html.getElementById_coerce "d-timeZoneField" Dom_html.CoerceTo.input)
  in
  let tz_string =
    Js.to_string tz_field##.value
  in
  let () =
    Js.Unsafe.global##.console##log (Js.string tz_string)
  in
  let%lwt tz_json_req =
    (Js_of_ocaml_lwt.XmlHttpRequest.get
      (Printf.sprintf
         "https://raw.githubusercontent.com/daypack-dev/timere/main/tzdb-json/%s.json" tz_string
      )
    )
  in
  let tz_json_string = tz_json_req.content in
  let tz = Result.get_ok @@ Timere.Time_zone.of_json_string tz_json_string in
  let () =
    Js.Unsafe.global##.console##log (Js.string tz_json_string)
  in
  let columns = query_all Dom_html.document "li.d-option" in
  let on_column (col : Dom_html.element Js.t) =
    let time_start = query_inner_html col ".d-timeStart" in
    let time_end_exc = query_inner_html col ".d-timeEnd" in
    let date_groups = query_all col ".d-dateGroup" in
    let cur = Timere.cur_timestamp () in
    let search_start =
      Timere.(of_timestamp cur)
    in
    let time =
      match date_groups with
      | [x] ->
        let month = query_inner_html x ".d-month" in
        let day = query_inner_html x ".d-date" in
        let start =
          Result.get_ok @@
          Timere_parse.timere
            (Printf.sprintf "%s %s %s"
               month day time_start
            )
        in
        let end_exc =
          Result.get_ok @@
          Timere_parse.timere
            (Printf.sprintf "%s %s %s"
               month day time_end_exc
            )
        in
        Timere.(
          after (Duration.make ~days:366() ) search_start
            (
              with_tz tz
                (between_exc (Duration.make ~days:366 ()) start end_exc)
            )
        )
      | [x; y] ->
        let month_start = query_inner_html x ".d-month" in
        let day_start = query_inner_html x ".d-date" in
        let month_end = query_inner_html y ".d-month" in
        let day_end = query_inner_html y ".d-date" in
        let start =
          Result.get_ok @@
          Timere_parse.timere
            (Printf.sprintf "%s %s %s"
               month_start day_start time_start
            )
        in
        let end_exc =
          Result.get_ok @@
          Timere_parse.timere
            (Printf.sprintf "%s %s %s"
               month_end day_end time_end_exc
            )
        in
        Timere.(
          after (Duration.make ~days:366() ) search_start
            (
              with_tz tz
              (between_exc (Duration.make ~days:366 ()) start end_exc)
            )
        )
      | _ ->
        failwith "Unexpected case"
    in
    let input = query col "input" in
    let action = function
      | Yes -> input##click
      | No -> ()
      | Maybe -> input##click ; input##click
    in
    { time ; action }
  in
  Lwt.return (List.map on_column columns)
