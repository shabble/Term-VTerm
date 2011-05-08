#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include <vterm.h>
#include <vterm_input.h>

MODULE = Term::VTerm PACKAGE = Term::VTerm

PROTOTYPES: DISABLE

VTerm *
_create()
CODE:
    RETVAL = vterm_new(24, 80);
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
VTerm *	vt
CODE:
    const char *foo = "Hello, World!";
    RETVAL = newSVpv(foo, strlen(foo));
OUTPUT:
    RETVAL

