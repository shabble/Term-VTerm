#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;

if ( not $ENV{TEST_AUTHOR} ) {
    my $msg = 'Author test.  Set $ENV{TEST_AUTHOR} to a true value to run.';
    plan( skip_all => $msg );
}

eval "use Test::Pod 1.14"; ## no critic (ProhibitStringyEval)
plan skip_all => "Test::Pod 1.14 required for testing POD" if $@;
all_pod_files_ok();
