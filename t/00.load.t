# Module load test
use Test::More tests => 1;

BEGIN {
	use_ok( 'WebService::Zussar' );
}

diag( "Testing WebService::Zussar $WebService::Zussar::VERSION" );

