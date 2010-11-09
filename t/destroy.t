use strict;
use Plack::Test;
use Test::More;

BEGIN {
    plan skip_all => "Perls before 5.10 break this DESTROY-based test"
        if $] < 5.010;
}

use HTTP::Request::Common;
use Plack::Builder;
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
    my $t = builder {
        enable "Test::StashWarnings";
        $app;
    };

    test_psgi $t, sub {
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

