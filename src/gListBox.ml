(**************************************************************************)
(*                Lablgtk                                                 *)
(*                                                                        *)
(*    This program is free software; you can redistribute it              *)
(*    and/or modify it under the terms of the GNU Library General         *)
(*    Public License as published by the Free Software Foundation         *)
(*    version 2, with the exception described in file COPYING which       *)
(*    comes with the library.                                             *)
(*                                                                        *)
(*    This program is distributed in the hope that it will be useful,     *)
(*    but WITHOUT ANY WARRANTY; without even the implied warranty of      *)
(*    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the       *)
(*    GNU Library General Public License for more details.                *)
(*                                                                        *)
(*    You should have received a copy of the GNU Library General          *)
(*    Public License along with this program; if not, write to the        *)
(*    Free Software Foundation, Inc., 59 Temple Place, Suite 330,         *)
(*    Boston, MA 02111-1307  USA                                          *)
(*                                                                        *)
(*                                                                        *)
(**************************************************************************)

(* $Id$ *)

open Gaux
open Gtk
open GtkBase
open GtkListBoxProps
open OgtkListBoxProps
open GObj
open GContainer

class list_box_row_signals obj = object
  inherit container_signals_impl obj
  inherit list_box_row_sigs
end

class list_box_row obj = object
  inherit [[> Gtk.list_box_row]] bin_impl obj
  inherit list_box_row_props
  method connect = new list_box_row_signals obj
  method as_row = (obj :> Gtk.list_box_row obj)
  method index = ListBoxRow.get_index obj
  method changed () = ListBoxRow.changed obj
  method is_selected = ListBoxRow.is_selected obj
  method header = may_map (ListBoxRow.get_header obj) ~f:(new widget)
  method set_header (w : widget option) =
    ListBoxRow.set_header obj (Gpointer.optboxed (may_map w ~f:as_widget))
end

let list_box_row ?activatable ?selectable =
  ListBoxRow.make_params [] ?activatable ?selectable ~cont:(
  pack_container ~create:(fun p -> new list_box_row (ListBoxRow.create p)))

class list_box_signals obj = object
  inherit container_signals_impl obj
  inherit list_box_sigs
end

class list_box obj = object
  inherit [[> Gtk.list_box]] container_impl obj
  inherit list_box_props
  method connect = new list_box_signals obj
  method prepend w = ListBox.prepend obj (as_widget w)
  method insert w ~pos = ListBox.insert obj (as_widget w) ~pos
  method get_selected_row =
    may_map (ListBox.get_selected_row obj) ~f:(new list_box_row)
  method get_selected_rows =
    List.map (new list_box_row) (ListBox.get_selected_rows obj)
  method select_row (r : list_box_row option) =
    ListBox.select_row obj (Gpointer.optboxed (may_map r ~f:(fun r -> r#as_row)))
  method unselect_row (r : list_box_row) = ListBox.unselect_row obj r#as_row
  method select_all () = ListBox.select_all obj
  method unselect_all () = ListBox.unselect_all obj
  method get_row_at_index i =
    may_map (ListBox.get_row_at_index obj i) ~f:(new list_box_row)
  method get_row_at_y y =
    may_map (ListBox.get_row_at_y obj y) ~f:(new list_box_row)
  method set_placeholder (w : widget option) =
    ListBox.set_placeholder obj (Gpointer.optboxed (may_map w ~f:as_widget))
  method adjustment =
    may_map (ListBox.get_adjustment obj) ~f:(new GData.adjustment)
  method set_adjustment (a : GData.adjustment option) =
    ListBox.set_adjustment obj
      (Gpointer.optboxed (may_map a ~f:GData.as_adjustment))
  method invalidate_filter () = ListBox.invalidate_filter obj
  method invalidate_sort () = ListBox.invalidate_sort obj
  method invalidate_headers () = ListBox.invalidate_headers obj
  method set_sort_func (f : list_box_row -> list_box_row -> int) =
    ListBox.set_sort_func obj
      (fun r1 r2 -> f (new list_box_row r1) (new list_box_row r2))
  method set_filter_func (f : list_box_row -> bool) =
    ListBox.set_filter_func obj (fun r -> f (new list_box_row r))
  method set_header_func (f : list_box_row -> list_box_row option -> unit) =
    ListBox.set_header_func obj
      (fun r before ->
        f (new list_box_row r) (may_map before ~f:(new list_box_row)))
  method selected_foreach (f : list_box_row -> unit) =
    ListBox.selected_foreach obj (fun r -> f (new list_box_row r))
end

let list_box ?selection_mode ?activate_on_single_click =
  ListBox.make_params [] ?selection_mode ?activate_on_single_click ~cont:(
  pack_container ~create:(fun p -> new list_box (ListBox.create p)))
