use strict;
use warnings;
use Test::More;
use Test::These;


{
    my $cases = [ 1, [], {} ];
    my $t = test_these {
        case $cases;
    };
    my $c = $t->{cases};


    is ref($c), 'ARRAY';
    is $#$c, $#{$cases};

    for my $i (0 .. $#$cases) {
        is $c->[$i], $cases->[$i];
    }
};

{
    my $t = test_these {
        cases [];
    };

    is ref($t->{cases}), 'ARRAY';
};




done_testing;
