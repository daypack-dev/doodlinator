open Js_of_ocaml

(** Error reporting *)

(* Crappy error reporting, to improve *)
let report_error s =
  Printf.eprintf "%s%!" s


(** Bookmarklet handling *)

let current_url = Url.Current.as_string

let bookmarklet_link =
  Option.get @@
  Dom_html.getElementById_coerce "bookmarklet" Dom_html.CoerceTo.a

let update_bookmarklet ~no ~maybe =
  let s =  Js.string @@ Format.asprintf {|javascript:(
function () {
var noPref = %S;
var maybePref = %S;
var script = document.createElement("script"); 
script.src = "%s/x.js"; 
document.body.appendChild(script);
} ) ();|}
      no maybe current_url
  in
  bookmarklet_link##.href := s


(** Textarea handling *)

let textarea_no = 
  Option.get @@
  Dom_html.getElementById_coerce "no-preference" Dom_html.CoerceTo.textarea
let textarea_maybe = 
  Option.get @@
  Dom_html.getElementById_coerce "maybe-preference" Dom_html.CoerceTo.textarea

let handler_area (area : Dom_html.textAreaElement Js.t) r f =
  let handler _ _ =
    begin match Timere_parse.timere @@ Js.to_string @@ area##.value with
      | Ok te -> r := te
      | Error s -> report_error s
    end;
    f ();
    false
  in
  let _ = Dom_events.listen area Dom_events.Typ.input handler in
  let _ = Dom_events.listen area Dom_events.Typ.change handler in
  let _ = handler () () in
  ()

let no_te = ref Timere.empty
let maybe_te = ref Timere.empty

let launch () =
  let no = Marshal.to_string !no_te [] in
  let maybe = Marshal.to_string !maybe_te [] in
  update_bookmarklet ~no ~maybe

(** Main *)

let () =
  handler_area textarea_no no_te launch;
  handler_area textarea_maybe maybe_te launch;
  ()
