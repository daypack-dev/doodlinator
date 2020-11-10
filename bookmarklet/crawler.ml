open Js_of_ocaml

exception Selector_not_found of string

let query_all node s =
  Dom.list_of_nodeList (node##querySelectorAll(Js.string s))

let query node s =
  Js.Opt.get
    (node##querySelector(Js.string s))
    (fun () -> raise @@ Selector_not_found s)

type choice = Yes | No | Maybe
  
type column = {
  time : Daypack_lib.Time_expr_ast.t ;
  action : choice -> unit ;
}

let doodle () =
  let columns = query_all Dom_html.document "li.d_options" in
  let on_column (node : Dom_html.element Js.t) =
    let (!) s =
      String.lowercase_ascii @@ Js.to_string (query node s)##.innerHTML
    in
    let time_str =
      Printf.sprintf "%s . %s . %s to %s"
        !"d-month" !"d-date" !"d-timeStart" !"d-timeEnd"
    in 
    let time =
      Result.get_ok @@ Daypack_lib.Time_expr.of_string time_str
    in
    let input = query node "input" in
    let action = function
      | Yes -> input##click
      | No -> ()
      | Maybe -> input##click ; input##click
    in
    { time ; action }
  in
  List.map on_column columns
