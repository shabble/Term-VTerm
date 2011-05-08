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

int term_putglyph_translate(const uint32_t chars[], int  width, VTermPos pos, void *user) {

}

MODULE = Term::VTerm PACKAGE = Term::VTerm::Callbacks

PROTOTYPES: ENABLE

int
term_putglyph(chars, width, pos, user)
unsigned int *chars
int width
VTermPos pos
void *user
PPCODE:

int
term_movecursor(pos, oldpos, visible, user)
VTermPos pos
VTermPos oldpos
int visible
void *user
PPCODE:

int
term_copyrect(dest, src, user)
VTermRect dest
VTermRect src
void *user
PPCODE:


int
term_copycell(destpos, srcpos, user)
VTermPos destpos
VTermPos srcpos
void *user
PPCODE:


int
term_erase(rect, user)
VTermRect rect
void *user
PPCODE:


int
term_setpenattr(attr, val, user)
VTermAttr attr
VTermValue *val
void *user
PPCODE:

int
term_settermprop(prop, val, user);
VTermProp prop
VTermValue *val
void *user
PPCODE:

int
term_setmousefunc(func, data, user)
VTermMouseFunc func
void *data
void *user
PPCODE:

int
term_bell(chars, width, pos, user)
void *user
PPCODE:





MODULE = Term::VTerm PACKAGE = Term::VTerm

PROTOTYPES: DISABLE

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


void
reset(vt, state)
Term_VTerm vt
VTermState *state
PPCODE:
    vterm_state_reset(state);


# need access to vterm_internal.h for this, and it's too much effort.
# SV *
# get_utf8(vt)
# Term_VTerm vt
# CODE:
#     RETVAL = newSViv(((struct _VTerm *)vt)->is_utf8);
# OUTPUT:
#     RETVAL



void
DESTROY(vt)
Term_VTerm vt
PPCODE:
    printf("Being destroyed!");
    # g_free((VTerm*)vt->inbuffer);
    # g_free((VTerm*)vt->outbuffer);
    # g_free(vt)

