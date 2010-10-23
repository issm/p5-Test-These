use strict;
use warnings;
use Test::More;
use Test::These;


{
    my $t = test_these {
        success { return 1 };
    };

    my $c = $t->{_sub_success};

    is ref($c), 'CODE';
    is $c->(), 1;
};




done_testing;
