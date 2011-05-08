#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include <vterm.h>
#include <vterm_input.h>

#include "Callbacks.h"

typedef VTerm* Term_VTerm;

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

int term_putglyph_translate
  (const uint32_t chars[], int  width, VTermPos pos, void *user) {
    term_putglyph(chars, width, pos, user);
}

MODULE = Term::VTerm PACKAGE = Term::VTerm::Callbacks

PROTOTYPES: ENABLE

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


MODULE = Term::VTerm PACKAGE = Term::VTerm

PROTOTYPES: DISABLE

# new (%config)

#     Returns a new VT102 object with options specified in %config (see the
#     OPTIONS section for details).

Term_VTerm
_create(rows, cols)
int rows
int cols
CODE:
    RETVAL = vterm_new(rows, cols);
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

AV *
get_size(vt)
Term_VTerm vt
PREINIT:
int rows;
int cols;
SV *sv_rows;
SV *sv_cols;
CODE:
    vterm_get_size(vt, &rows, &cols);
    # check types first.
    sv_rows = newSViv(rows);
    sv_cols = newSViv(cols);

    RETVAL = newAV();
    av_push(RETVAL, sv_rows);
    av_push(RETVAL, sv_cols);
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


void
attr_pack(fg, bg, bo, fa, st, ul, bl, rv)


# attr_unpack ($data)

# Returns a list of the contents of the given packed attribute settings, of
# the form ($fg,$bg,$bo,$fa,$st,$ul,$bl,$rv).

# $fg and $bg are the ANSI foreground and background text colours, and $bo, $fa,
# $st, $ul, $bl, and $rv are flags (1 = on, 0 = off) for bold, faint, standout,
# underline, blink and reverse respectively.

void
attr_unpack(data)

# callback_call ($name, $par1, $par2)

#     Calls the callback $name (eg 'ROWCHANGE') with parameters $par1 and $par2,
#     as if the VT102 module had called it. Does nothing if that callback has not
#     been set with callback_set ().

void
callback_call(name, param1, param2)

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
callback_set(callback, ref, param2)

# option_read ($option)

#     Returns the current value of terminal option $option (see OPTIONS for
#     details), or undef if that option does not exist. Note that you cannot
#     read the terminal size with this call; use size() for that.


# option_set ($option, $value)

#     Sets the current value of terminal option $option to $value, returning the
#     old value or undef if no such terminal option exists or you have specified
#     an undefined $value. Note that you cannot resize the terminal with this
#     call; use resize() for that.

# resize ($cols, $rows)

#     Resizes the VT102 terminal to cols columns by rows rows, eg $vt->resize
#     (80, 24). The virtual screen is cleared first.

void
resize(cols, rows)

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
row_attr(row, startcol, endcol)

# row_plaintext ($row, [$startcol, $endcol])

#     Returns the textual contents of row $row (or undef if out of range), with
#     unused characters being represented as spaces. If $startcol and $endcol
#     are defined, only returns the part of the row between columns $startcol
#     and $endcol inclusive instead of the whole row.

void
row_plaintext(row, startcol, endcol)


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
row_sgrext(row, startcol, endcol)

# sgr_change ($source, $dest)

#     Returns a string containing ANSI/ECMA-48 escape sequences to change
#     colours and attributes from $source to $dest, which are both packed
#     attributes (see attr_pack). This is used internally by row_sgrtext.

void
sgr_change(source, dest)


# cols ()

#     Return the number of columns in the VT102 object.

int
cols()


# rows ()

#     Return the number of rows in the VT102 object.
int
rows()

# size ()

#     Return a pair of values (columns,rows) denoting the size of the terminal
#     in the VT102 object.

void
size()

# x ()

#     Return the current cursor X co-ordinate (1 being leftmost).  Note: It is
#     possible for the current X co-ordinate to be 1 more than the number of
#     columns. This happens when the end of a row is reached such that the next
#     character would wrap on to the next row.

int
x()



# y ()

#     Return the current cursor Y co-ordinate (1 being topmost).

int
y()

# cursor ()

#     Return the current cursor state (1 being on, 0 being off).
int
cursor()

# xtitle ()

#     Return the current xterm window title.
SV *
xtitle()

# xicon ()

#     Return the current xterm window icon name.
SV *
xicon()

# status ()

#     Return a list of values ($x,$y,$attr,$ti,$ic), where $x and $y are the
#     cursor co-ordinates (1,1 = top left), $attr is a packed version of the
#     current attributes (see attr_unpack), $ti is the xterm window title, and
#     $ic is the xterm window icon name.

void
status()

# version ()

#     Return the version of the Term::VTerm  module being used.

SV *
version()


void
DESTROY(vt)
Term_VTerm vt
PPCODE:
    printf("Being destroyed!");
    # g_free((VTerm*)vt->inbuffer);
    # g_free((VTerm*)vt->outbuffer);
    # g_free(vt)

