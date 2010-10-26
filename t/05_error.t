use strict;
use warnings;
use Test::These;


{
    my $t = test_these {
        error { return 1 };
    };

    my $c = $t->{_sub_error};

    is ref($c), 'CODE';
    is $c->(), 1;
};




done_testing;
