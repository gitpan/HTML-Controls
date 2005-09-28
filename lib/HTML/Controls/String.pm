package HTML::Controls::String;
use strict;
use vars '$VERSION';
use warnings;
use base 'HTML::Controls::Base';

$VERSION='0.1';

=head1 NAME

HTML::Controls::String - class for a simple string control

=head1 SYNOPSIS

   my $string = HTML::Controls::String->new('name');

This class implements a simple string control, using just a
C<< <input type="text"> >> element.

=head1 REDEFINED PROTECTED METHODS

=head2 C<_body_template_name>

Returns C<'string.wt'>, which contains a single C<input> field.

=cut

sub _body_template_name {
  'string.wt';
}

=head1 NOTES

The C<_validate_value> is I<not> redefined, meaning that any string
(even the empty one) is considered valid.

=head1 COPYRIGHT

Copyright 2005 Gianni Ceccarelli, All Rights Reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;
