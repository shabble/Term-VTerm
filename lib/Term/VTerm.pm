use strict;
use warnings;

use MooseX::Declare;

class Term::VTerm {

    our $VERSION = '0.03';
    require XSLoader;
    XSLoader::load('Term::VTerm', $VERSION);

    has '_vt'
      => (
          is      => '',
          isa     => 'Term::VTerm',
          builder => '_build_vt',
          clearer => '_clear_vt',
          lazy    => 1,
          #handles => [qw/test_obj/ ], #qr/^.*$/,
         );

    sub _build_vt {
        return _create();
    }
    # method test {
    #     return $self->_test;
    # }

}

__END__

=pod

=head1 NAME

Term::VTerm - Perl bindings to the libvterm terminal library

=head1 SYNOPSIS

  use Term::VTerm;
  my $vterm = Term::VTerm->new;
  ...

=head1 DESCRIPTION

This module provides an interface to a I<libvterm>, a fast terminal parsing library.

=head2 EXPORT

Exports nothing.

=head2 METHODS

=over 4

=item test

returns a test string

=back

=head1 AUTHOR

shabble, E<lt>shabble+cpan@metavore.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by shabble

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.


=cut
