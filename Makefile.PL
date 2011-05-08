use strict;
use warnings;
use Cwd;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

unless(header_found())
{
    die <<"END";
ERROR: Can't find vterm.h header.

If the library is not installed, you will need to install it. If it is
installed somewhere other than /usr or /usr/local, you need to set the
following environment variables:

    VTERM_LIBDIR should contain the path to the vterm library
    VTERM_INCDIR should contain the path to the vterm include files

END
}

unless(lib_found())
{
    die <<"END";
ERROR: Can't find vterm library.

If the library is not installed, you will need to install it. If it is
installed somewhere other than /usr or /usr/local, you need to set the
following environment variables:

    VTERM_LIBDIR should contain the path to the vterm library
    VTERM_INCDIR should contain the path to the vterm include files

END
}

WriteMakefile(
              NAME              => 'Term::VTerm',
              AUTHOR            => 'shabble <shabble+cpan@metavore.org>',
              VERSION_FROM      => 'lib/Term/VTerm.pm', # finds $VERSION
              ABSTRACT_FROM     => 'lib/Term/Vterm.pm',
              PL_FILES          => {},
              LIBS              => [ lib_loc() ],
              INC               => header_loc(),
              PREREQ_PM         => {
                                    'Test::More'        => 0,
                                    'Carp'              => 0,
                                    'MooseX::Declare'   => 0,
                                   },
              dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
              clean               => {
                                      FILES => 'Term-VTerm-* VTerm.inl'
                                     },
             );


sub header_loc {
    my $dir = header_found();
    die "Still can't find headers" unless $dir;
    my $loc =  "-I" . $dir . "/cprops";
    print "Header location is: $loc\n";
    return $loc;
}

sub lib_loc {
    my $dir = lib_found();
    die "Still can't find library" unless $dir;
    chomp(my $glib = qx/pkg-config --libs glib-2.0/);

    my $loc = "-L" . $dir . " -lvterm $glib";
    print "Library location is: $loc\n";
    return $loc;
}

sub header_found {
    my @dirs = (
                qw(/usr/include /usr/local/include /opt/local/include),
                $ENV{LIBVTERM_INCDIR}
               );

    foreach my $dir (@dirs) {
        return $dir if defined $dir && -e "$dir/vterm.h" && defined -e "$dir/vterm_input.h";
    }

    return;
}

sub lib_found {
    my @dirs = (
                qw(/usr/local/lib64 /usr/lib64 /lib64 /usr/lib /usr/local/lib),
                qw(/opt/local/lib), $ENV{VTERM_LIBDIR}
               );

    foreach my $dir (@dirs) {
        return $dir
          if defined $dir
            && (-e "$dir/libvterm.so" || -e "$dir/libvterm.dylib");
    }

    return;
}
