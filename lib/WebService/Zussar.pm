package WebService::Zussar;

use warnings;
use strict;
use Carp;
use utf8;

use version;
our $VERSION = qv('0.0.1');

use base qw/Class::Accessor/;
use Data::Recursive::Encode;
use DateTime::Format::ISO8601;
use Hash::AsObject;
use JSON;
use LWP::UserAgent;
use URI;

# Accessors
__PACKAGE__->mk_accessors( qw/ iter / );

# Constructor
sub new {
	my ($class, %param) = @_;
	my $self = bless({}, $class);

	# Parameter - Base URL (API Endpoint)
	if(defined($param{baseurl})){
		$self->{baseurl} = $param{baseurl};
		delete $param{baseurl};
	}else{
		$self->{baseurl} = 'http://www.zusaar.com/api/';
	}

	# Parameter - Encoding (Char-set)
	if(defined($param{encoding})){
		$self->{encoding} = $param{encoding};
		delete $param{encoding};
	}

	# Parameter - Automatic next page fetch 
	if(defined($param{disable_nextpage_fetch}) && $param{disable_nextpage_fetch}){
		$self->{nextpage_fetch} = 0;
		delete $param{disable_nextpage_fetch};
	}else{
		$self->{nextpage_fetch} = 1;
	}

	# Parameter - Timeout
	$param{timeout} =  $param{timeout} || 10;

	# Parameter - UserAgent string
	$param{agent} =  $param{agent} || __PACKAGE__.'/'.$VERSION;

	# ----------

	# Prepare a LWP::UA instance
	$self->{ua} = LWP::UserAgent->new(%param);

	# Prepare a Date parser instance
	$self->{datetime_parser} = DateTime::Format::ISO8601->new();

	# Prepare events store array
	$self->{events} = [];

	$self->{current_request_path} = '';
	$self->{current_query} = ();
	return $self;
}

# Fetch events
sub fetch {
	my ($self, $request_path, %query) = @_;

	my $is_auto_fetch = 0;
	if(defined($query{_is_auto_fetch})){
		$is_auto_fetch = 1;
		delete $query{_is_auto_fetch};
	}

	$self->{current_request_path} = $request_path;
	$self->{current_query} = \%query || {};
	$self->{current_query}->{count} = $self->{current_query}->{count} || 10; # Each fetch num of item

	# Request
	my $url = $self->_generate_get_url($self->{baseurl}.$request_path.'/', %{$self->{current_query}});
	my $response = $self->{ua}->get($url);
	unless($response->is_success){
		die 'Fetch error: '.$response->status_line;
	}

	# Decode JSON
	my $js_hash = JSON->new->utf8->decode($response->content);

	# Encoding
	if(defined($self->{encoding}) && $self->{encoding} ne 'utf8'){
		$js_hash = Data::Recursive::Encode->encode($self->{encoding}, $js_hash);
	}

	# Initialize the events store array
	unless($is_auto_fetch){ # If not auto-fetch...
		$self->{events} = [];
	}

	# Store events
	foreach my $item(@{$js_hash->{event}}){
		my $item_id = $item->{event_id};
		push($self->{events}, $item);
	}

	# Reset iterator
	unless($is_auto_fetch){
		$self->iter(0);
	}

	return;
}

# Put to next a Iterator
sub next {
	my $self = shift;

	my $i = $self->iter();
	if($i < 0){ $i = 0; }

	if($i < @{$self->{events}}){
		# Next one
		$self->iter($i + 1);
		# Return one event object
		return $self->_generate_event_object($self->{events}->[$i]);
	}else{
		# Fetch next page automatically
		if($self->{nextpage_fetch} == 1 && @{$self->{events}} % $self->{current_query}->{count} == 0){
			$self->{current_query}->{start} = $i;
			$self->{current_query}->{_is_auto_fetch} = 1;
			# Auto fetch
			$self->fetch($self->{current_request_path}, $self->{current_query});
			return $self->next();
		}
	}
	return;
}

# prev a Iterator
sub prev {
	my $self = shift;

	my $i = $self->iter() - 1;

	if(0 <= $i){
		# Prev one
		$self->iter($i);
		# Return one event object
		return $self->_generate_event_object($self->{events}->[$i]);
	}
	return;
}

# Generate Event object from Hash
sub _generate_event_object {
	my ($self, $hash) = @_;
	
	# Date parse
	$hash->{started} = defined($hash->{started_at}) ? $self->{datetime_parser}->parse_datetime($hash->{started_at}) : undef;
	delete $hash->{started_at};
	$hash->{ended} = defined($hash->{ended_at}) ? $self->{datetime_parser}->parse_datetime($hash->{ended_at}) : undef;
	delete $hash->{ended_at};

	# If fetch event/users
	if(defined($hash->{users})){
		foreach my $user(@{$hash->{users}}){
			$user = $self->_generate_event_user_object($user);
		}
	}

	return Hash::AsObject->new($hash);
}

# Generate Event/User object from Hash
sub _generate_event_user_object {
	my ($self, $hash) = @_;
	
	return Hash::AsObject->new($hash);
}

# Generate URL from URL And Query parameters
sub _generate_get_url {
	my ($self, $url, %params) = @_;
	my $uri = URI->new($url);
	$uri->query_form(\%params);
	return $uri->as_string();
}

1;
__END__

=head1 NAME

WebService::Zussar - Zussar API wrapper module for perl

=head1 SYNOPSIS

  use WebService::Zussar;
  
  my $zussar = WebService::Zussar;
  
  # Request events
  $zussar->fetch( 'event', keyword => 'perl' );
  
  # Print each event title
  while (my $item = $atnd->next){
  	print $item->title;
  }

=head1 INSTALLATION

  $ git clone git://github.com/mugifly/WebService-Zussar.git
  $ cpanm ./WebService-Zussar

=head1 METHODS

=head2 new ( [%params] )

Create an instance of WebService::Zussar.

%params = LWP::UserAgent options (It also optional).

=head2 fetch ( $api_path [, %params] )

Send request to Zussar API.

$api_path = Path of request to Zussar API. Currently available: "event" only.

%params = Query parameter.

About the query, please see: http://www.zusaar.com/doc/api.html

=head2 next

=head2 prev

=head2 iter

=head1 SEE ALSO

L<WebService::ATND> - https://github.com/ytnobody/WebService-ATND/

L<DateTime::Format::ISO8601>

L<Hash::AsObject>

L<LWP::UserAgent>

L<https://github.com/mugifly/WebService-Zussar/>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013, Masanori Ohgita (http://ohgita.info/).

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

I wrote this library with referred to the library that was written by L<ytnobody|https://github.com/ytnobody>. Thank you.

Thanks, Perl Mongers & CPAN authors. 