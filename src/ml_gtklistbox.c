/**************************************************************************/
/*                Lablgtk                                                 */
/*                                                                        */
/*    This program is free software; you can redistribute it              */
/*    and/or modify it under the terms of the GNU Library General         */
/*    Public License as published by the Free Software Foundation         */
/*    version 2, with the exception described in file COPYING which       */
/*    comes with the library.                                             */
/*                                                                        */
/*    This program is distributed in the hope that it will be useful,     */
/*    but WITHOUT ANY WARRANTY; without even the implied warranty of      */
/*    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the       */
/*    GNU Library General Public License for more details.                */
/*                                                                        */
/*    You should have received a copy of the GNU Library General          */
/*    Public License along with this program; if not, write to the        */
/*    Free Software Foundation, Inc., 59 Temple Place, Suite 330,         */
/*    Boston, MA 02111-1307  USA                                          */
/*                                                                        */
/*                                                                        */
/**************************************************************************/

/* $Id$ */

#include <string.h>
#include <gtk/gtk.h>
#include <caml/mlvalues.h>
#include <caml/alloc.h>
#include <caml/memory.h>
#include <caml/callback.h>
#include <caml/fail.h>

#include "wrappers.h"
#include "ml_glib.h"
#include "ml_gobject.h"
#include "ml_gdk.h"
#include "ml_gtk.h"
#include "gtk_tags.h"

/* Init all */

CAMLprim value ml_gtklistbox_init(value unit)
{
    /* Since these are declared const, must force gcc to call them! */
    GType t =
        gtk_list_box_get_type() +
        gtk_list_box_row_get_type();
    return Val_GType(t);
}

/* gtkListBox.h */

#define GtkListBox_val(val) check_cast(GTK_LIST_BOX,val)
#define GtkListBoxRow_val(val) check_cast(GTK_LIST_BOX_ROW,val)

ML_2 (gtk_list_box_prepend, GtkListBox_val, GtkWidget_val, Unit)
ML_3 (gtk_list_box_insert, GtkListBox_val, GtkWidget_val, Int_val, Unit)

CAMLprim value ml_gtk_list_box_get_selected_row(value lb)
{
  GtkListBoxRow *row = gtk_list_box_get_selected_row(GtkListBox_val(lb));
  return Val_option(row, Val_GtkWidget);
}

ML_2 (gtk_list_box_select_row, GtkListBox_val, GtkListBoxRow_val, Unit)
ML_2 (gtk_list_box_unselect_row, GtkListBox_val, GtkListBoxRow_val, Unit)
ML_1 (gtk_list_box_select_all, GtkListBox_val, Unit)
ML_1 (gtk_list_box_unselect_all, GtkListBox_val, Unit)

CAMLprim value ml_gtk_list_box_get_row_at_index(value lb, value idx)
{
  GtkListBoxRow *row =
    gtk_list_box_get_row_at_index(GtkListBox_val(lb), Int_val(idx));
  return Val_option(row, Val_GtkWidget);
}

CAMLprim value ml_gtk_list_box_get_row_at_y(value lb, value y)
{
  GtkListBoxRow *row =
    gtk_list_box_get_row_at_y(GtkListBox_val(lb), Int_val(y));
  return Val_option(row, Val_GtkWidget);
}

ML_2 (gtk_list_box_set_placeholder, GtkListBox_val, GtkWidget_val, Unit)
ML_1 (gtk_list_box_invalidate_filter, GtkListBox_val, Unit)
ML_1 (gtk_list_box_invalidate_sort, GtkListBox_val, Unit)
ML_1 (gtk_list_box_invalidate_headers, GtkListBox_val, Unit)

static gint ml_gtk_list_box_sort_func(GtkListBoxRow *row1,
                                      GtkListBoxRow *row2,
                                      gpointer user_data)
{
  value *clos = user_data;
  CAMLparam0();
  CAMLlocal3(ret, vrow1, vrow2);
  vrow1 = Val_GtkWidget(row1);
  vrow2 = Val_GtkWidget(row2);
  ret = callback2_exn(*clos, vrow1, vrow2);
  if (Is_exception_result(ret)) {
    CAML_EXN_LOG("ml_gtk_list_box_sort_func");
    CAMLreturnT(gint, 0);
  }
  CAMLreturnT(gint, Int_val(ret));
}

CAMLprim value ml_gtk_list_box_set_sort_func(value lb, value f)
{
  value *clos = ml_global_root_new(f);
  gtk_list_box_set_sort_func(GtkListBox_val(lb),
                             ml_gtk_list_box_sort_func,
                             clos, ml_global_root_destroy);
  return Val_unit;
}

static gboolean ml_gtk_list_box_filter_func(GtkListBoxRow *row,
                                            gpointer user_data)
{
  value *clos = user_data;
  CAMLparam0();
  CAMLlocal2(ret, vrow);
  vrow = Val_GtkWidget(row);
  ret = callback_exn(*clos, vrow);
  if (Is_exception_result(ret)) {
    CAML_EXN_LOG("ml_gtk_list_box_filter_func");
    CAMLreturnT(gboolean, FALSE);
  }
  CAMLreturnT(gboolean, Bool_val(ret));
}

CAMLprim value ml_gtk_list_box_set_filter_func(value lb, value f)
{
  value *clos = ml_global_root_new(f);
  gtk_list_box_set_filter_func(GtkListBox_val(lb),
                               ml_gtk_list_box_filter_func,
                               clos, ml_global_root_destroy);
  return Val_unit;
}

static void ml_gtk_list_box_header_func(GtkListBoxRow *row,
                                        GtkListBoxRow *before,
                                        gpointer user_data)
{
  value *clos = user_data;
  CAMLparam0();
  CAMLlocal3(ret, vrow, vbefore);
  vrow = Val_GtkWidget(row);
  vbefore = Val_option(before, Val_GtkWidget);
  ret = callback2_exn(*clos, vrow, vbefore);
  if (Is_exception_result(ret))
    CAML_EXN_LOG("ml_gtk_list_box_header_func");
  CAMLreturn0;
}

CAMLprim value ml_gtk_list_box_set_header_func(value lb, value f)
{
  value *clos = ml_global_root_new(f);
  gtk_list_box_set_header_func(GtkListBox_val(lb),
                               ml_gtk_list_box_header_func,
                               clos, ml_global_root_destroy);
  return Val_unit;
}

static void ml_gtk_list_box_foreach_func(GtkListBox *box, GtkListBoxRow *row,
                                         gpointer data)
{
  value vrow = Val_GtkWidget(row);
  value ret = callback_exn(*(value*)data, vrow);
  if (Is_exception_result(ret))
    CAML_EXN_LOG("ml_gtk_list_box_foreach_func");
}

CAMLprim value ml_gtk_list_box_selected_foreach(value lb, value f)
{
  CAMLparam2(lb, f);
  gtk_list_box_selected_foreach(GtkListBox_val(lb),
                                ml_gtk_list_box_foreach_func, &f);
  CAMLreturn(Val_unit);
}

/* gtkListBoxRow.h */

ML_1 (gtk_list_box_row_get_index, GtkListBoxRow_val, Val_int)
ML_1 (gtk_list_box_row_changed, GtkListBoxRow_val, Unit)
