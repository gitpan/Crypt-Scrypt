use strict;
use warnings;
use ExtUtils::MakeMaker;

use lib qw(inc);
use Devel::CheckLib;

check_lib_or_exit(
    lib => [qw(crypto)],
);

my %conf = (
    NAME           => 'Crypt::Scrypt',
    AUTHOR         => 'gray <gray@cpan.org>',
    LICENSE        => 'perl',
    VERSION_FROM   => 'lib/Crypt/Scrypt.pm',
    ABSTRACT_FROM  => 'lib/Crypt/Scrypt.pm',
    PREREQ_PM      => { XSLoader => 0, },
    BUILD_REQUIRES => { 'Test::More' => 0.82, },

    CCFLAGS  => '-Wall',
    DEFINE   => '-DHAVE_CONFIG_H',
    INC      => '-Isrc -Isrc/src -Isrc/src/lib/crypto'
              . ' -Isrc/src/lib/scryptenc -Isrc/src/lib/util',
    LIBS     => '-lcrypto',
    MYEXTLIB => 'src/.libs/libscrypt$(LIB_EXT)',

    META_MERGE => {
        resources => {
            repository => 'http://github.com/gray/crypt-scrypt',
        },
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES    => 'Crypt-Scrypt-*' },
);

my $eumm_version =  do {
    no warnings 'numeric';
    eval $ExtUtils::MakeMaker::VERSION;
};
delete $conf{META_MERGE} if $eumm_version < 6.46;
$conf{PREREQ_PM} = {
    %{ $conf{PREREQ_PM} || {} }, %{ delete $conf{BUILD_REQUIRES} },
} if ($conf{BUILD_REQUIRES} and $eumm_version < 6.5503);

WriteMakefile(%conf);


sub MY::postamble {
    return <<"    MAKE_FRAG";
\$(MYEXTLIB): src/Makefile
\tcd src && \$(MAKE) \$(PASSTHRU)

src/Makefile:
\tcd src && ./configure

clean::
\tcd src && \$(MAKE) distclean

authortest:
\t\$(MAKE) -e \$(TEST_TYPE) TEST_FILES="xt/*.t"
    MAKE_FRAG
}

sub MY::dist_test {
    my $self = shift;
    return $self->MM::dist_test . <<"    MAKE_FRAG";
\tcd \$(DISTVNAME) && \$(MAKE) authortest \$(PASTHRU)
    MAKE_FRAG
}