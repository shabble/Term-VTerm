#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include <vterm.h>
#include <vterm_input.h>
#include "glib.h"

#include "Callbacks.h"
#include "Terminal.h"

static VTermStateCallbacks cb = {
  .putglyph     = term_putglyph_translate,
  .movecursor   = term_movecursor,
  .copyrect     = term_copyrect,
  .copycell     = term_copycell,
  .erase        = term_erase,
  .setpenattr   = term_setpenattr,
  .settermprop  = term_settermprop,
  .setmousefunc = term_setmousefunc,
  .bell         = term_bell,
};

typedef struct {
     int stuff;
} cell_attrs;

typedef struct {
     unsigned int fg_col;
     unsigned int bg_col;
     gboolean reverse;
} term_pen;

typedef struct {
     unsigned char fg_col;
     unsigned char bg_col;
     char  content;
     cell_attrs attrs;
} term_cell;

struct _VT_EVERYTHING {
     term_cell **cells;
     VTermPos cursor;
     HV* callbacks;
};

typedef struct _VT_EVERYTHING VT_EVERYTHING;

static void init_callback_table(VT_EVERYTHING *e) {
     
     e->callbacks = newHV();
}

static void deinit_callback_table(VT_EVERYTHING *stuff) {
     hv_undef(stuff->callbacks);
     Safefree(stuff->callbacks);
}

static void perl_add_callback(VT_EVERYTHING s, char *name, SV* func) {
     hv_store(s->callbacks, name, strlen(name), func, 0);
}

static void perl_del_callback(char *name) {
}

static SV* perl_find_callback(VT_EVERYTHING s, char *name) {
     SV **svpp = hv_fetch(s->callbacks, name, strlen(name), 0);
     if (svpp != NULL) {
          SV* svp = *svpp;
          return svp;
     } else {
          croak("Couldn't find a matching callback for %s", name);
     }
}

static void perl_call_callback(char *name, SV* cb_name, SV* cb_param1) {

     SV* callback = perl_find_callback(name);
     // check its a coderef.
     if (!SvROK(callback)) {
          croak("Callback must be a reference");

     }
     if (SvTYPE(SvRV(callback)) != SVt_PVCV) {
          croak("Callback must be a CODEREF");
     }

     dSP;
     int count;

     ENTER;
     SAVETMPS;
     PUSHMARK(SP);

     /* params onto stack */

     XPUSHs(sv_2mortal(newSViv(a)));
     XPUSHs(sv_2mortal(newSViv(b)));
     PUTBACK;

     count = call_sv(callback, G_EVAL|G_SCALAR);

     SPAGAIN;
     /* Check the eval first */
     if (SvTRUE(ERRSV)) {
          printf ("Uh oh - %s\n", SvPV_nolen(ERRSV));
          POPs;
     } else {
          if (count != 1) {
               croak("call_Subtract: wanted 1 value from 'Subtract', got %d\n",
                     count);
          }
          printf ("%d - %d = %d\n", a, b, POPi);
     }
     /* cleanup */
     PUTBACK;
     FREETMPS;
     LEAVE;
}

static void init_screen(int rows, int cols) {
     // allocate some cells space

}

static void deinit_screen() {
     // free the cell data.
}

/* int term_putglyph_translate */
/*   (const uint32_t chars[], int  width, VTermPos pos, void *user) { */
/* /\*    term_putglyph(chars, width, pos, user); *\/ */
/* } */

MODULE = Term::VTerm PACKAGE = Term::VTerm

PROTOTYPES: DISABLE

Term_VTerm
_create(rows, cols)
int rows
int cols
CODE:
     RETVAL =  vterm_new(rows, cols);
OUTPUT:
    RETVAL

HV *
init2(vt)
Term_VTerm vt
CODE:
     RETVAL = newHV();
     sv_2mortal((SV*)RETVAL);

     VT_EVERYTHING *stuff = g_new0(VT_EVERYTHING, 1);
     init_callback_table(stuff);

     /* const char *term_name = "_term"; */
     /* const char *stuff_name = "_stuff"; */
     hv_stores(RETVAL, "_term",  (SV*)vt);
     hv_stores(RETVAL, "_stuff", (SV*)stuff);
OUTPUT:
     RETVAL

Term_VTerm
get2(hash)
HV *hash
CODE:
    SV **tmp = hv_fetchs(hash, "_term", 0);
    if (tmp != NULL) {
         RETVAL = (Term_VTerm)*tmp;
    } else {
         croak("Retval is sadly NULL");
    }
OUTPUT:
    RETVAL


SV *
test()
CODE:
    const char *foo = "Hello, World!";
    RETVAL = newSVpv(foo, strlen(foo));
OUTPUT:
    RETVAL

SV *
test_obj(vt)
Term_VTerm vt
CODE:
    const char *foo = "Hello, World!";
    RETVAL = newSVpv(foo, strlen(foo));
OUTPUT:
    RETVAL



void
set_utf8(vt, val)
Term_VTerm vt
int val
PPCODE:
    vterm_parser_set_utf8(vt, val);

# process ($string)

#     Processes the string $string (which can be zero-length), updating the
#     VT102 object accordingly and calling any necessary callbacks on the way.

void
process(vt, bytes)
Term_VTerm vt
SV* bytes
PREINIT:
    STRLEN len;
    char *byte_ptr;
PPCODE:
    if (!SvPOK(bytes)) {
        croak("Parameter must be a string");
    }
    byte_ptr = SvPV(bytes, len);
    vterm_push_bytes(vt, byte_ptr, len);


# reset ()
#     Resets the object to its "power-on" state.

void
reset(vt, state)
Term_VTerm vt
VTermState *state
PPCODE:
    vterm_state_reset(state);


# attr_pack ($fg,$bg,$bo,$fa,$st,$ul,$bl,$rv)

# Returns the packed version of the given attribute settings, which are given in
# the same order as returned by attr_unpack. The packed version will be a
# binary string not longer than 2 bytes.
# TODO: Do thesee things need to be method calls? Or can they be exported?

void
attr_pack(vt, fg, bg, bo, fa, st, ul, bl, rv)
Term_VTerm vt
char fg
char bg
char bo
char fa
char st
char ul
char bl
char rv
PPCODE:

# attr_unpack ($data)

# Returns a list of the contents of the given packed attribute settings, of
# the form ($fg,$bg,$bo,$fa,$st,$ul,$bl,$rv).

# $fg and $bg are the ANSI foreground and background text colours, and $bo, $fa,
# $st, $ul, $bl, and $rv are flags (1 = on, 0 = off) for bold, faint, standout,
# underline, blink and reverse respectively.

void
attr_unpack(vt, data)
Term_VTerm vt
SV *data
PPCODE:

# callback_call ($name, $par1, $par2)

#     Calls the callback $name (eg 'ROWCHANGE') with parameters $par1 and $par2,
#     as if the VT102 module had called it. Does nothing if that callback has not
#     been set with callback_set ().

void
callback_call(vt, name, param1, param2)
Term_VTerm vt
SV *name
SV *param1
SV *param2
PPCODE:

# callback_set ($callback, $ref, $private)

#     Sets the callback callback to function reference ref with private data $private.
#     See the section on CALLBACKS below.

#      BELL          BEL (beep, \007) character received
#      CLEAR         screen about to be cleared
#      OUTPUT        data (arg1) to be sent back to data source
#      ROWCHANGE     screen row (row number is argument 1) content has changed
#      SCROLL_DOWN   about to scroll down (arg1=top row, arg2=num to scroll)
#      SCROLL_UP     about to scroll up (ditto)
#      UNKNOWN       unknown/unsupported code (arg1=name, arg2=code/sequence)
#      STRING        string received (arg1=source, eg PM, APC, arg2=string)
#      XICONNAME     xterm icon name to be changed to arg1
#      XWINTITLE     xterm title name to be changed to arg1
#      LINEFEED      line feed about to be processed (arg1=row)
#      GOTO          cursor about to be moved (args=new pos)
void
callback_set(vt, callback, ref, param2)
Term_VTerm vt
SV *callback
SV *ref
SV *param2
PPCODE:

# option_read ($option)

#     Returns the current value of terminal option $option (see OPTIONS for
#     details), or undef if that option does not exist. Note that you cannot
#     read the terminal size with this call; use size() for that.

void
option_read(vt, option)
Term_VTerm vt
SV *option
PPCODE:

# option_set ($option, $value)

#     Sets the current value of terminal option $option to $value, returning the
#     old value or undef if no such terminal option exists or you have specified
#     an undefined $value. Note that you cannot resize the terminal with this
#     call; use resize() for that.

# resize ($cols, $rows)

#     Resizes the VT102 terminal to cols columns by rows rows, eg $vt->resize
#     (80, 24). The virtual screen is cleared first.

void
resize(vt, cols, rows)
Term_VTerm vt
int cols
int rows
PPCODE:

# row_attr ($row, [$startcol, $endcol])

#     Returns the attributes for row $row (or undef if out of range) as a string
#     of packed attributes, each character cell's attributes being 2 bytes
#     long. To unpack the attributes for a given cell, use substr(), eg
#     $attr=substr($row,4,2) would set $attr to the attributes for cell 3 (steps
#     of 2: 0 .. 2 .. 4, so 4 means the 3rd character). You would then use the
#     attr_unpack() method to unpack that character cell's attributes.

#     If $startcol and $endcol are defined, only returns the part of the row
#     between columns $startcol and $endcol inclusive instead of the whole row.
#     row_text ($row, [$startcol, $endcol])

#     Returns the textual contents of row $row (or undef if out of range), with
#     totally unused characters being represented as NULL (\0). If $startcol and
#     $endcol are defined, only returns the part of the row between columns
#     $startcol and $endcol inclusive instead of the whole row.


void
row_attr(vt, row, startcol, endcol)
Term_VTerm vt
int row
int startcol
int endcol
PPCODE:

# row_plaintext ($row, [$startcol, $endcol])

#     Returns the textual contents of row $row (or undef if out of range), with
#     unused characters being represented as spaces. If $startcol and $endcol
#     are defined, only returns the part of the row between columns $startcol
#     and $endcol inclusive instead of the whole row.

void
row_plaintext(vt, row, startcol, endcol)
Term_VTerm vt
int row
int startcol
int endcol
PPCODE:


# row_sgrtext ($row, [$startcol, $endcol])

#     Returns the textual contents of row $row (or undef if out of range), with
#     unused characters being represented as spaces, and ANSI/ECMA-48 escape
#     sequences (CSI SGR) used to set the colours and attributes as
#     appropriate. If $startcol and $endcol are defined, only returns the part
#     of the row between columns $startcol and $endcol inclusive instead of the
#     whole row.

#     Use row_sgrtext to get a row if you want to output it to a real terminal
#     and preserve all colours, bold, etc.

void
row_sgrext(vt, row, startcol, endcol)
Term_VTerm vt
int row
int startcol
int endcol
PPCODE:

# sgr_change ($source, $dest)

#     Returns a string containing ANSI/ECMA-48 escape sequences to change
#     colours and attributes from $source to $dest, which are both packed
#     attributes (see attr_pack). This is used internally by row_sgrtext.

void
sgr_change(vt, source, dest)
Term_VTerm vt
SV *source
SV *dest
PPCODE:

# cols ()

#     Return the number of columns in the VT102 object.


SV *
cols(vt)
Term_VTerm vt
PREINIT:
int rows;
int cols;
CODE:
    vterm_get_size(vt, &rows, &cols);
    RETVAL = newSViv(cols);
OUTPUT:
    RETVAL

# rows ()

#     Return the number of rows in the VT102 object.
SV *
rows(vt)
Term_VTerm vt
PREINIT:
int rows;
int cols;
CODE:
    vterm_get_size(vt, &rows, &cols);
    RETVAL = newSViv(rows);
OUTPUT:
    RETVAL

# size ()
#     Return a pair of values (columns,rows) denoting the size of the terminal
#     in the VT102 object.

void
size(vt)
Term_VTerm vt
PREINIT:
int rows;
int cols;
SV *sv_rows;
SV *sv_cols;
PPCODE:
    vterm_get_size(vt, &rows, &cols);
    # check types first.
    sv_rows = newSViv(rows);
    sv_cols = newSViv(cols);

    EXTEND(SP, 2);
    PUSHs(sv_2mortal(sv_cols));
    PUSHs(sv_2mortal(sv_rows));


# x ()
#     Return the current cursor X co-ordinate (1 being leftmost).  Note: It is
#     possible for the current X co-ordinate to be 1 more than the number of
#     columns. This happens when the end of a row is reached such that the next
#     character would wrap on to the next row.

int
x(vt)
Term_VTerm vt
CODE:


# y ()
#     Return the current cursor Y co-ordinate (1 being topmost).
int
y(vt)
Term_VTerm vt
PPCODE:

# cursor ()
#     Return the current cursor state (1 being on, 0 being off).
int
cursor(vt)
Term_VTerm vt
PPCODE:

# xtitle ()
#     Return the current xterm window title.
SV *
xtitle(vt)
Term_VTerm vt
CODE:
    RETVAL = newSV(0);
OUTPUT:
    RETVAL


# xicon ()
#     Return the current xterm window icon name.
SV *
xicon(vt)
Term_VTerm vt
CODE:
    RETVAL = newSV(0);
OUTPUT:
    RETVAL


# status ()

#     Return a list of values ($x,$y,$attr,$ti,$ic), where $x and $y are the
#     cursor co-ordinates (1,1 = top left), $attr is a packed version of the
#     current attributes (see attr_unpack), $ti is the xterm window title, and
#     $ic is the xterm window icon name.

void
status(vt)
Term_VTerm vt
PPCODE:

# version ()

#     Return the version of the Term::VTerm  module being used.

SV *
version(vt)
Term_VTerm vt
CODE:
    RETVAL = newSV(0);
OUTPUT:
    RETVAL

# Destructor, clean up everything.
void
DESTROY(vt)
Term_VTerm vt
PPCODE:
    printf("Being destroyed!");
    # g_free((VTerm*)vt->inbuffer);
    # g_free((VTerm*)vt->outbuffer);
    # g_free(vt)

# int
# term_putglyph(chars, width, pos, user)
# unsigned int *chars
# int width
# VTermPos pos
# void *user
# PPCODE:

# int
# term_movecursor(pos, oldpos, visible, user)
# VTermPos pos
# VTermPos oldpos
# int visible
# void *user
# PPCODE:

# int
# term_copyrect(dest, src, user)
# VTermRect dest
# VTermRect src
# void *user
# PPCODE:


# int
# term_copycell(destpos, srcpos, user)
# VTermPos destpos
# VTermPos srcpos
# void *user
# PPCODE:


# int
# term_erase(rect, user)
# VTermRect rect
# void *user
# PPCODE:


# int
# term_setpenattr(attr, val, user)
# VTermAttr attr
# VTermValue *val
# void *user
# PPCODE:

# int
# term_settermprop(prop, val, user);
# VTermProp prop
# VTermValue *val
# void *user
# PPCODE:

# int
# term_setmousefunc(func, data, user)
# VTermMouseFunc func
# void *data
# void *user
# PPCODE:

# int
# term_bell(chars, width, pos, user)
# void *user
# PPCODE:
