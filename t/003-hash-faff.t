#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;
use Data::Dumper;

BEGIN {
    use_ok 'Term::VTerm';
}

my $vt = new_ok 'Term::VTerm', [];
ok(defined $vt, 'VT is defined');

my $bar = $vt->init2();
isa_ok($bar, 'HASH');
my $baz = Term::VTerm::get2($bar);
isa_ok($baz, 'Term::VTerm');


    

my @size = $baz->size();
is ($size[0], 80, 'default cols correct');
is ($size[1], 24, 'default rows correct');

#     # $vt->set_thing("Bacon", "Tasty");
#     # is ($vt->get_thing("Bacon"), "Tasty", "bacon?");

# }
# {

#     my $vt = new_ok 'Term::VTerm', [rows => 50, cols => 100];
#     is_deeply([$vt->size], [100, 50], 'correct non-default size');
#     is($vt->cols, 100, 'cols correct');
#     is($vt->rows, 50,  'rows correct');

#     $vt->set_utf8(1);
# }

done_testing;

