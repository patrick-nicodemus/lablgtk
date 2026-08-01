(**************************************************************************)
(*    Lablgtk - Examples                                                  *)
(*                                                                        *)
(*    This code is in the public domain.                                  *)
(*    You may freely copy parts of it in your application.                *)
(*                                                                        *)
(**************************************************************************)

(* $Id$ *)

let main () =
  GMain.init ();
  let window = GWindow.window ~title:"GtkListBox" ~border_width:10 () in
  window#connect#destroy ~callback:GMain.quit;

  let vbox = GPack.vbox ~spacing:6 ~packing:window#add () in

  let entry = GEdit.entry ~packing:vbox#pack () in

  let scroll =
    GBin.scrolled_window ~hpolicy:`NEVER ~vpolicy:`AUTOMATIC
      ~height:250 ~packing:vbox#add ()
  in
  let list_box =
    GListBox.list_box ~selection_mode:`MULTIPLE
      ~packing:scroll#add_with_viewport ()
  in

  (* row#get_oid is stable across the separately-allocated OCaml wrappers
     that set_sort_func/set_filter_func/etc. create around the same
     underlying GtkListBoxRow, so it works as a hashtable key. *)
  let names : (int, string) Hashtbl.t = Hashtbl.create 16 in
  let name_of_row (row : GListBox.list_box_row) =
    Hashtbl.find names row#get_oid
  in

  List.iter
    (fun name ->
      let row = GListBox.list_box_row ~packing:list_box#add () in
      GMisc.label ~text:name ~xalign:0.0 ~packing:row#add () |> ignore;
      Hashtbl.add names row#get_oid name)
    [ "Alice"; "Bob"; "Charlie"; "Dana"; "Erin";
      "Frank"; "Grace"; "Heidi"; "Ivan"; "Judy" ];

  (* Sort rows alphabetically by name. *)
  list_box#set_sort_func (fun r1 r2 ->
    compare (name_of_row r1) (name_of_row r2));

  let contains ~needle haystack =
    let nl = String.length needle and hl = String.length haystack in
    let rec loop i = i + nl <= hl && (String.sub haystack i nl = needle || loop (i+1)) in
    nl = 0 || loop 0
  in
  (* Filter rows using the text typed into the entry as a substring match. *)
  list_box#set_filter_func (fun row ->
    let needle = String.lowercase_ascii entry#text in
    contains ~needle (String.lowercase_ascii (name_of_row row)));
  entry#connect#changed ~callback:(fun () -> list_box#invalidate_filter ());

  list_box#connect#row_activated ~callback:(fun row ->
    Printf.printf "Activated row: %s\n%!" (Hashtbl.find names (Gobject.get_oid row)));

  window#show ();
  GMain.main ()

let _ = main ()
