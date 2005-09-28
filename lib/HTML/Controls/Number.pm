package HTML::Controls::Number;
use strict;
use vars '$VERSION';
use warnings;
use base 'HTML::Controls::String';
use Regexp::Common;

$VERSION='0.1';

=head1 NAME

HTML::Controls::Number - class for a simple number control

=head1 SYNOPSIS

   my $number = HTML::Controls::Number->new('name');

This class implements a simple number control, using just a
C<< <input type="text"> >> element. The numbers are recognized
using L<Regexp::Common|Regexp::Common>.

=head1 REDEFINED PROTECTED METHODS

=head2 C<_validate_value>

Calls the L<inherited method|HTML::Controls::Base/_validate_value>,
then adds an error if the value does not match C<$RE{num}{real}>.

=cut

sub _validate_value {
  my ($self)=@_;
  $self->SUPER::_validate_value();
  my $v=$self->{value};
  unless ($v=~/$RE{num}{real}/) {
    push @{$self->{errors}},'serve un numero';
  }
}

=head2 C<_preprocess_value>

Strips leading and trailing whitespace.

=cut

sub _preprocess_value {
  my ($self,$value)=@_;
  $value=~s/^\s+//;$value=~s/\s+$//;
  return $value;
}

=head1 COPYRIGHT

Copyright 2005 Gianni Ceccarelli, All Rights Reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;
