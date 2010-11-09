use strict;
use Plack::Test;
use Test::More;
use HTTP::Request::Common;

use Plack::Middleware::Test::StashWarnings;
use Plack::Request;

my $app = sub {
    my $req = Plack::Request->new(shift);
    my $name = $req->param('name');
    return [ 200, ["Content-Type", "text/plain"], ["Hello $name!"] ];
};

my @warnings;
local $SIG{__WARN__} = sub {
    push @warnings, @_;
};

{
    my $mw = Plack::Middleware::Test::StashWarnings->new;
    my $new_app = $mw->wrap($app);

    test_psgi $new_app, sub {
        my $cb = shift;

        my $res = $cb->(GET "/");
        like $res->content, qr/Hello !/;
        is $res->content_type, 'text/plain';
    };

    is @warnings, 0, "no warnings yet";
}

is @warnings, 1, "caught one warning";
like $warnings[0], qr/Unhandled warning: Use of uninitialized value (?:\$name )?in concatenation/;

done_testing;

