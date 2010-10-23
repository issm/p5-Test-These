use strict;
use warnings;
use Test::More;
use Test::These;

{
    my $t = test_these {
        code { return 1 };
    };

    my $c = $t->{_sub_code};

    is ref($c), 'CODE';
    is $c->(), 1;
};




done_testing;
