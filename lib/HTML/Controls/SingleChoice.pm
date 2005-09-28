package HTML::Controls::SingleChoice;
use strict;
use vars '$VERSION';
use warnings;
use base 'HTML::Controls::Base';
use Carp;

$VERSION='0.1';

=head1 NAME

HTML::Controls::SingleChoice - class for a single choice ("select") control

=head1 SYNOPSIS

   my $sc = HTML::Controls::SingleChoice->new('name',@items);

This class implements a control for choosing one item among an
array. It uses the standard C<< <select><option>... >> HTML field.

=head1 REDEFINED PUBLIC METHODS

=head2 C<new>

This class' contructor takes, in addition to the control's name, an
array or array reference containing the items the user has to choose
from. Using the stock template, these items will be displayed directly
as given (but passed through the HTML filter).

=cut

sub new {
  my ($class,$name,@rest)=@_;
  my $self=$class->SUPER::new($name);
  do {
    local $Carp::CarpLevel=2;
    croak("I need a list")
  } unless (@rest>0);
  
  if (ref($rest[0]) eq 'ARRAY') {
    $self->{list}=$rest[0];
  } else {
    $self->{list}=[@rest];
  }
  return $self;
}

=head2 C<setData>

Thi method is redefined I<not> to call L</_preprocess_value>. It just
stores the passed value.

=cut

sub setData {
  my ($self,$value)=@_;
  $self->{value}=$value;
  $self->_validate_value();
}

=head1 REDEFINED PROTECTED METHODS

=head2 C<_preprocess_value>

This method converts the posted value (an integer, see the template
file) into the intended (internal) value. It just uses the posted
integer as an index into the items array. Returns C<undef> if the
pastod value was not an integer, or was nto a valid index.

=cut

sub _preprocess_value {
  my ($self,$value)=@_;
  return unless $value=~/^\d+$/;
  local $@;
  no warnings;
  my $ret;
  eval {
    $ret=$self->{list}->[int($value)];
  };
  return $ret unless $@;
  return;
}

=head2 C<_body_template_name>

Returns C<'singlechoice.wt'>.

=cut

sub _body_template_name {
  'singlechoice.wt';
}

=head2 C<_body_template_parms>

Calls the
L<inherited method|HTML::Controls::Base/_body_template_parms>,
then adds to the hash a reference to the items array, with the koy
C<list>.

=cut

sub _body_template_parms {
  my ($self)=@_;
  my %ret=%{$self->SUPER::_body_template_parms()};
  %ret=(%ret,
        list=>$self->{list}
       );
  return \%ret;
}

=head1 COPYRIGHT

Copyright 2005 Gianni Ceccarelli, All Rights Reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;
