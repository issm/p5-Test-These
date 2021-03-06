use strict;
use warnings;
use Test::These;


#--------------------------------------------------------------------------------
#
# error_each as arrayref
#
#--------------------------------------------------------------------------------
{
    my $t = test_these {
        error_each [
            sub {
                return 'hoge';
            },
            sub {
                return 'fuga';
            },
            0,
        ];
    };

    my $subs = $t->{_subs_error};
    is ref($subs), 'ARRAY';
    for my $v (@$subs) {
        ok defined $v;
        like ref($v), qr/^(CODE)?$/;  # 'CODE' or ''
    }
};




#--------------------------------------------------------------------------------
#
# error_each as hashref
#
#--------------------------------------------------------------------------------
{
    my $t = test_these {
        error_each +{
            foo => sub {
                return 'hoge';
            },
            bar => sub {
                return 'fuga';
            },
            baz => 'foo',
        };
    };

    my $subs = $t->{_subs_error};
    is ref($subs), 'HASH';
    for my $v (values %$subs) {
        ok defined $v;
        like ref($v), qr/^(CODE)?$/;    # 'CODE' or ''
    }
};





done_testing;
