#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include <vterm.h>
#include <vterm_input.h>


typedef VTerm* Term_VTerm;

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
    vterm_set_utf8(vt, val);


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

