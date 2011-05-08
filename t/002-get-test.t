#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;
use Data::Dumper;

BEGIN {
    use_ok 'Term::VTerm';
}

{
    my $str = Term::VTerm::test(); # functional interface.
    is($str, 'Hello, World!', 'test returns correct value');
}
{
    my $vt = new_ok 'Term::VTerm', [];
    my $str = $vt->test_obj;
    is($str, 'Hello, World!', 'test returns correct value');
}

done_testing;

