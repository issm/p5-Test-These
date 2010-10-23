use strict;
use Test::More;
use Test::These;

my $isa = 'Test::These';
my $t;

$t = test_these {};
isa_ok $t, $isa;
undef $t;


$t = test_these {
    cases   [];
    code    {};
    success {};
    error   {};
};
isa_ok $t, $isa;
undef $t;


done_testing 2;
