use strict;
use warnings;
use Test::More;
use Test::These;

#--------------------------------------------------------------------------------
#
# as arrayref
#
#--------------------------------------------------------------------------------
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

{
    my $t = test_these {
        cases '';
    };

    is ref($t->{cases}), 'ARRAY';
};



#--------------------------------------------------------------------------------
#
# as hashref
#
#--------------------------------------------------------------------------------
{
    my $cases = +{
        foo => 1,
        bar => [],
        baz => {},
    };

    my $t = test_these {
        cases $cases;
    };

    my $c = $t->{cases};
    is ref($c), 'HASH';

    is $c->{$_}, $cases->{$_}  for keys %$cases;
};



done_testing;
