# GtkListBox / GtkListBoxRow binding spec

## Scope

Bind `GtkListBox` and `GtkListBoxRow` (GTK3), following the existing
`.props` → `propcc` → hand-written `.ml`/`.c` pipeline used for
`GtkBox`/`GtkContainer` (see `src/gtkPack.props`, `src/gPack.ml`,
`src/ml_gtkpack.c`).

New files:
- `src/gtkListBox.props` — property/method/signal declarations for both classes
- `src/ml_gtklistbox.c`, `src/ml_gtklistbox.h` — hand-written C stubs
- `src/gListBox.ml`, `src/gListBox.mli` — high-level OCaml class API
- `src/dune` — register propcc rule + object file, `src/dune-prop.sexp` rule

## Class hierarchy

- `GtkListBox : GtkContainer`
- `GtkListBoxRow : GtkBin`

Both map onto existing lablgtk class ancestors (`Container`, `Bin`) already
defined in `gtkContainers.props` / `gtkBin.props`.

## GtkListBox

### Properties
| Name | Type | Access |
|---|---|---|
| `selection-mode` | `GtkSelectionMode` | Read/Write |
| `activate-on-single-click` | `gboolean` | Read/Write |

### Methods (direct mapping, no callback marshaling)
- `new : unit -> listbox obj`
- `prepend : [>`widget] obj -> unit`
- `insert : [>`widget] obj -> pos:int -> unit`
- `get_selected_row : listbox_row obj option`
- `get_selected_rows : listbox_row obj list` (3.14+)
- `select_row : [>`listbox_row] optobj -> unit`
- `unselect_row : [>`listbox_row] obj -> unit`
- `select_all : unit -> unit`
- `unselect_all : unit -> unit`
- `get_row_at_index : int -> listbox_row obj option`
- `get_row_at_y : int -> listbox_row obj option`
- `set_placeholder : [>`widget] optobj -> unit`
- `get_adjustment` / `set_adjustment`
- `invalidate_filter : unit -> unit`
- `invalidate_sort : unit -> unit`
- `invalidate_headers : unit -> unit`
- `drag_highlight_row` / `drag_unhighlight_row` (3.14+, may skip — DnD-only)
- `bind_model` (3.16+, may skip — needs GListModel binding, out of scope)

### Methods requiring closures (need custom stub pattern, not plain `method`)
GTK stores these as long-lived function pointers on the widget, so the stub
must register an OCaml closure as a root and free the old one on replace —
same pattern as `GtkTreeView`'s custom sort/filter funcs in `ml_gtktree.c`.
- `set_sort_func : (listbox_row obj -> listbox_row obj -> int) -> unit`
- `set_filter_func : (listbox_row obj -> bool) -> unit`
- `set_header_func : (listbox_row obj -> listbox_row obj option -> unit) -> unit`
- `selected_foreach : (listbox_row obj -> unit) -> unit` (one-shot closure, simpler — no need to persist)

### Signals
| Name | Args | Notes |
|---|---|---|
| `row-selected` | `listbox_row obj option` | |
| `row-activated` | `listbox_row obj` | |
| `selected-rows-changed` | — | |
| `select-all` | — | |
| `unselect-all` | — | |
| `activate-cursor-row` | — | action signal, low priority |
| `toggle-cursor-row` | — | action signal, low priority |
| `move-cursor` | — | complex enum args, likely skip |

## GtkListBoxRow

### Properties
| Name | Type | Access |
|---|---|---|
| `activatable` | `gboolean` | Read/Write |
| `selectable` | `gboolean` | Read/Write |

### Methods
- `new : unit -> listbox_row obj`
- `get_header : widget obj option` / `set_header : [>`widget] optobj -> unit`
- `get_index : int`
- `changed : unit -> unit`
- `is_selected : bool` (3.14+)
- `get_selectable` / `set_selectable` (redundant with property, may only expose property)
- `get_activatable` / `set_activatable` (same)

### Signals
- `activate` — action signal, no args

## Open questions
1. Minimum GTK3 version to target — several methods are 3.14/3.16-gated
   (`get_selected_rows`, `is_selected`, `bind_model`). Need to check what
   floor lablgtk currently assumes elsewhere before deciding what to include
   vs. `#if GTK_CHECK_VERSION` guard.
2. `bind_model` depends on `GListModel`, which isn't bound anywhere in this
   tree — treat as out of scope unless requested.
3. Row widgets: should `GListBox#add` accept a plain widget (auto-wrapped
   in a `GtkListBoxRow`, matching GTK's actual `gtk_container_add` behavior
   on `GtkListBox`) or require an explicit `listbox_row`? GTK does the
   auto-wrap itself, so `add` from `Container` should already work as-is
   without extra binding work.

## Phased plan
1. `.props` file with plain properties + non-callback methods + signals;
   get `propcc` output building and `gListBox.ml`/`.mli` wired into `gtk.ml`.
2. Hand-write `ml_gtklistbox.c` stubs for the plain methods.
3. Add closure-based `sort_func`/`filter_func`/`header_func` stubs, modeled
   on `ml_gtktree.c`'s custom sort function handling.
4. Example under `examples/` exercising selection, filtering, sorting.
