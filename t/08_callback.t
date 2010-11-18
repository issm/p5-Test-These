use strict;
use warnings;
use Test::These;


my $cases_as_arrayref = [
    1,
    'a',
    [ 1, 'a'],
    { a => 1,  b => 2 },
];

my $cases_as_hashref = +{
    a => 1,
    b => 'a',
    c => [ 1, 'a'],
    d => { a => 1,  b => 2 },
};




#--------------------------------------------------------------------------------
#
# cases as arrayref with success
#
#--------------------------------------------------------------------------------
{
    my $t = test_these {
        case $cases_as_arrayref;

        code { return ref shift };

        success {
            my ($v, $i, $c) = @_;
            like $i, qr/^[0-3]$/;

            if ($i == 0) {
                is $v, '';
                is $c, 1;
            }
            elsif ($i == 1) {
                is $v, '';
                is $c, 'a';
            }
            elsif ($i == 2) {
                is $v, 'ARRAY';
                is_deeply $c, [ 1, 'a' ];
            }
            elsif ($i == 3) {
                is $v, 'HASH';
                is_deeply $c, { a => 1,  b => 2 };
            }
        };
    };
};




#--------------------------------------------------------------------------------
#
# cases as arrayref with error
#
#--------------------------------------------------------------------------------
{
    my $t = test_these {
        case $cases_as_arrayref;

        code { die 'error!' };

        error {
            my ($msg, $i, $c) = @_;
            like $msg, qr/^error!/;
            like $i, qr/^[0-3]$/;

            if ($i == 0) {
                is $c, 1;
            }
            elsif ($i == 1) {
                is $c, 'a';
            }
            elsif ($i == 2) {
                is_deeply $c, [ 1, 'a' ];
            }
            elsif ($i == 3) {
                is_deeply $c, { a => 1,  b => 2 };
            }
        };
    };
};




#--------------------------------------------------------------------------------
#
# cases as arrayref with success_each
#
#--------------------------------------------------------------------------------
{
    my $t = test_these {
        case $cases_as_arrayref;

        code { return ref shift };

        success_each [
            sub {
                my ($v, $i, $c) = @_;
                is $v, '';
                is $i, 0;
                is $c, 1;
            },
            sub {
                my ($v, $i, $c) = @_;
                is $v, '';
                is $i, 1;
                is $c, 'a';
            },
            sub {
                my ($v, $i, $c) = @_;
                is $v, 'ARRAY';
                is $i, 2;
                is_deeply $c, [ 1, 'a' ];
            },
            sub {
                my ($v, $i, $c) = @_;
                is $v, 'HASH';
                is $i, 3;
                is_deeply $c, { a => 1, b => 2 };
            },
        ];
    };
};




#--------------------------------------------------------------------------------
#
# cases as arrayref with error_each
#
#--------------------------------------------------------------------------------
{
    my $t = test_these {
        case $cases_as_arrayref;

        code { die 'error!' };

        error_each [
            sub {
                my ($msg, $i, $c) = @_;
                like $msg, qr/^error!/;
                is $i, 0;
                is $c, 1;
            },
            sub {
                my ($msg, $i, $c) = @_;
                like $msg, qr/^error!/;
                is $i, 1;
                is $c, 'a';
            },
            sub {
                my ($msg, $i, $c) = @_;
                like $msg, qr/^error!/;
                is $i, 2;
                is_deeply $c, [ 1, 'a' ];
            },
            sub {
                my ($msg, $i, $c) = @_;
                like $msg, qr/^error!/;
                is $i, 3;
                is_deeply $c, { a => 1, b => 2 };
            },
        ];
    };
};




#--------------------------------------------------------------------------------
#
# cases as hashref with success_each
#
#--------------------------------------------------------------------------------
{
    my $t = test_these {
        case $cases_as_hashref;

        code { return ref shift };

        success_each +{
            a => sub {
                my ($v, $k, $c) = @_;
                is $v, '';
                is $k, 'a';
                is $c, 1;
            },
            b => sub {
                my ($v, $k, $c) = @_;
                is $v, '';
                is $k, 'b';
                is $c, 'a';
            },
            c => sub {
                my ($v, $k, $c) = @_;
                is $v, 'ARRAY';
                is $k, 'c';
                is_deeply $c, [ 1, 'a' ];
            },
            d => sub {
                my ($v, $k, $c) = @_;
                is $v, 'HASH';
                is $k, 'd';
                is_deeply $c, { a => 1, b => 2 };
            },
        };
    };
};




#--------------------------------------------------------------------------------
#
# cases as hashref with error_each
#
#--------------------------------------------------------------------------------
{
    my $t = test_these {
        case $cases_as_hashref;

        code { die 'error!' };

        error_each +{
            a => sub {
                my ($msg, $k, $c) = @_;
                like $msg, qr/^error!/;
                is $k, 'a';
                is $c, 1;
            },
            b => sub {
                my ($msg, $k, $c) = @_;
                like $msg, qr/^error!/;
                is $k, 'b';
                is $c, 'a';
            },
            c => sub {
                my ($msg, $k, $c) = @_;
                like $msg, qr/^error!/;
                is $k, 'c';
                is_deeply $c, [ 1, 'a' ];
            },
            d => sub {
                my ($msg, $k, $c) = @_;
                like $msg, qr/^error!/;
                is $k, 'd';
                is_deeply $c, { a => 1, b => 2 };
            },
        };
    };
};





done_testing;
