use inc::Module::Install;
name 'Test-These';
all_from 'lib/Test/These.pm';

# requires '';

tests 't/*.t';
author_tests 'xt';

test_requires 'Test::More';
auto_set_repository;
auto_include;
WriteAll;
