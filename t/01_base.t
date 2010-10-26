use strict;
use Test::More;
use Test::These;
use Try::Tiny;

my $isa = 'Test::These';


{
    my $t = test_these {};
    isa_ok $t, $isa;
};


{
    my $t = test_these {
        cases   [];
        code    {};
        success {};
        error   {};
    };
    isa_ok $t, $isa;
};


{
    my $t = test_these {
        cases  +{};
        code    {};
        success {};
        error   {};
    };
    isa_ok $t, $isa;
};


{
    my $t = test_these {
        cases +{};
        code   {};
        success_each +{};
        error_each   +{};
    };
    isa_ok $t, $isa;
};


{
    my $t = test_these {
        cases  [];
        code   {};
        success_each [];
        error_each   [];
    };
    isa_ok $t, $isa;
};


# error
{
    try {
        my $t = test_these {
            cases +{};
            code   {};
            success_each [];  # bad
            error_each   [];  # bad
        };
        isa_ok $t, $isa;
        fail 'Should fail';
    }
    catch {
        ok shift;
    };
};


# error
{
    try {
        my $t = test_these {
            cases +{};
            code   {};
            success_each +{};
            error_each    [];  # bad
        };
        isa_ok $t, $isa;
        fail 'Should fail';
    }
    catch {
        ok shift;
    };
};



done_testing;
