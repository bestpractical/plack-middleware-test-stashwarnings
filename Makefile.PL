use inc::Module::Install;
name 'Plack-Middleware-Test-StashWarnings';
all_from 'lib/Plack/Middleware/Test/StashWarnings.pm';
readme_from 'lib/Plack/Middleware/Test/StashWarnings.pm';
auto_set_repository;

requires 'Storable';
requires 'Plack::Test';
test_requires 'Test::More';

author_tests('xt');

WriteAll;
