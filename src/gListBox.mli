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

open Gtk
open GObj
open GContainer

(** {3 GtkListBoxRow} *)

(** @gtkdoc gtk GtkListBoxRow *)
class list_box_row_signals : [> Gtk.list_box_row] obj ->
  object
    inherit GContainer.container_signals
    method activate : callback:(unit -> unit) -> GtkSignal.id
    method notify_activatable : callback:(bool -> unit) -> GtkSignal.id
    method notify_selectable : callback:(bool -> unit) -> GtkSignal.id
  end

(** A single row in a {!list_box}
    @gtkdoc gtk GtkListBoxRow *)
class list_box_row : ([> Gtk.list_box_row] as 'a) obj ->
  object
    inherit GContainer.bin
    val obj : 'a obj
    method connect : list_box_row_signals
    method as_row : Gtk.list_box_row obj
    method index : int
    method changed : unit -> unit
    method activatable : bool
    method set_activatable : bool -> unit
    method selectable : bool
    method set_selectable : bool -> unit
  end

(** @gtkdoc gtk GtkListBoxRow *)
val list_box_row :
  ?activatable:bool ->
  ?selectable:bool ->
  ?border_width:int ->
  ?width:int ->
  ?height:int ->
  ?packing:(widget -> unit) -> ?show:bool -> unit -> list_box_row

(** {3 GtkListBox} *)

(** @gtkdoc gtk GtkListBox *)
class list_box_signals : [> Gtk.list_box] obj ->
  object
    inherit GContainer.container_signals
    method row_selected :
      callback:(Gtk.list_box_row obj option -> unit) -> GtkSignal.id
    method row_activated :
      callback:(Gtk.list_box_row obj -> unit) -> GtkSignal.id
    method selected_rows_changed : callback:(unit -> unit) -> GtkSignal.id
    method select_all : callback:(unit -> unit) -> GtkSignal.id
    method unselect_all : callback:(unit -> unit) -> GtkSignal.id
    method notify_selection_mode :
      callback:(Tags.selection_mode -> unit) -> GtkSignal.id
    method notify_activate_on_single_click :
      callback:(bool -> unit) -> GtkSignal.id
  end

(** A vertical list of rows, with selection, filtering and sorting support
    @gtkdoc gtk GtkListBox *)
class list_box : ([> Gtk.list_box] as 'a) obj ->
  object
    inherit GContainer.container
    val obj : 'a obj
    method connect : list_box_signals
    method prepend : widget -> unit
    method insert : widget -> pos:int -> unit
    method get_selected_row : list_box_row option
    method select_row : list_box_row option -> unit
    method unselect_row : list_box_row -> unit
    method select_all : unit -> unit
    method unselect_all : unit -> unit
    method get_row_at_index : int -> list_box_row option
    method get_row_at_y : int -> list_box_row option
    method set_placeholder : widget option -> unit
    method invalidate_filter : unit -> unit
    method invalidate_sort : unit -> unit
    method invalidate_headers : unit -> unit
    (** @param f compare two rows; same contract as [Stdlib.compare] *)
    method set_sort_func : (list_box_row -> list_box_row -> int) -> unit
    (** @param f return [true] to keep a row visible *)
    method set_filter_func : (list_box_row -> bool) -> unit
    method set_header_func :
      (list_box_row -> list_box_row option -> unit) -> unit
    method selected_foreach : (list_box_row -> unit) -> unit
    method selection_mode : Tags.selection_mode
    method set_selection_mode : Tags.selection_mode -> unit
    method activate_on_single_click : bool
    method set_activate_on_single_click : bool -> unit
  end

(** @gtkdoc gtk GtkListBox *)
val list_box :
  ?selection_mode:Tags.selection_mode ->
  ?activate_on_single_click:bool ->
  ?border_width:int ->
  ?width:int ->
  ?height:int ->
  ?packing:(widget -> unit) -> ?show:bool -> unit -> list_box
