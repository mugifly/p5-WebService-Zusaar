package WebService::Zussar;

use warnings;
use strict;
use Carp;
use utf8;

use version;
our $VERSION = qv('0.0.1');

use base qw/Class::Accessor/;
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
	}else{
		$self->{encoding} = 'utf8';
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

	$self->{current_request_path} = $request_path;
	$self->{current_query} = \%query || {};
	$self->{current_query}->{count} = $self->{current_query}->{count} || 10; # Each fetch num of item

	# Request
	my $url = $self->_generate_get_url($self->{baseurl}.'event/', %{$self->{current_query}});
	my $response = $self->{ua}->get($url);
	unless($response->is_success){
		die 'Fetch error: '.$response->status_line;
	}

	# Decode JSON
	my $js = JSON->new->utf8->decode($response->content);

	# Return iterator
	return $self->_generate_events_iterator($js);
}

# Put to next a Iterator
sub next {
	my $self = shift;

	my $i = $self->iter();
	if($i < @{$self->{events}}){
		$self->iter($i + 1);
		# Return one event object
		return $self->_generate_event_object($self->{events}->[$i]);
	}else{
		# Fetch next page automatically
		if($self->{nextpage_fetch} == 1 && @{$self->{events}} % $self->{current_query}->{count} == 0){
			$self->{current_query}->{start} = $i;
			# Auto fetch
			$self->fetch($self->{current_request_path}, $self->{current_query});
			return $self->next();
		}
		return;
	}
}

# Generate Events iterator
sub _generate_events_iterator {
	my ($self, $js) = @_;

	# Initialize the events store array
	$self->{events} = [];

	# Store events
	foreach my $item(@{$js->{event}}){
		my $item_id = $item->{event_id};
		push($self->{events}, $item);
	}

	# Reset iterator
	$self->iter(0);
}

# Generate Event object from Hash
sub _generate_event_object {
	my ($self, $hash) = @_;
	
	# Date parse
	$hash->{started_at} = defined($hash->{started_at}) ? $self->{datetime_parser}->parse_datetime($hash->{started_at}) : undef;
	$hash->{ended_at} = defined($hash->{ended_at}) ? $self->{datetime_parser}->parse_datetime($hash->{ended_at}) : undef;

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

Please see a README.pod or http://github.com/mugifly/WebService-Zussar/README.pod

=head1 SEE ALSO

L<https://github.com/mugifly/WebService-Zussar/>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013, Masanori Ohgita (http://ohgita.info/).

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

Thanks, Perl Mongers & CPAN authors. 