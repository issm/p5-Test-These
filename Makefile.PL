use inc::Module::Install;
name 'Test-These';
all_from 'lib/Test/These.pm';

requires 'Carp';
requires 'Try::Tiny';

test_requires 'Test::More';

tests 't/*.t';
author_tests 'xt';

auto_set_repository;
auto_include;
WriteAll;
