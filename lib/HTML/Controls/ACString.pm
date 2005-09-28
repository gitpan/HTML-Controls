package HTML::Controls::ACString;
use strict;
use vars '$VERSION';
use warnings;
use base 'HTML::Controls::String';
use Carp;

$VERSION='0.1';

=head1 NAME

HTML::Controls::ACString - clas for an auto-completing string control

=head1 SYNOPSIS

  my $localAC=HTML::Controls::ACString->new('name1',\@completions,{jsurl=>'/js'});
  my $AJAXAC=HTML::Controls::ACString->new('name2',$completion_url,{jsurl=>'/js'});

This class implements a string control with auto-completion
capabilities using the Prototype and script.aculo.us JavaScript
libraries.

Note: right now it does I<not> use L<HTML::Prototype|HTML::Prototype>
or
L<Template::Plugin::HTML::Prototype|Template::Plugin::HTML::Prototype>,
but it might in the future to simplify template maintenance.

=head1 USAGE REQUIREMENTS

For the generated controls to work, you must serve the appropriate
JavaScript libraries under the URL that you specify as the C<jsurl>
option to the constructor. The files needed are: C<prototype.js> from
L<http://prototype.conio.net/>; C<controls.js>, C<effects.js> from
L<http://script.aculo.us/>.

If you use the AJAX auto-completer, you will need to handle C<POST>
requests to the URL you gave to the constructor and return XML
documents having a C<< <ul> >> root element and the various completion
possibilities as C<< <li> >> children. See
L<http://wiki.script.aculo.us/scriptaculous/show/Ajax.Autocompleter>
for details.

=head1 VALUE FORMAT

Just a scalar, this class derives from
L<HTML::Controls::String|HTML::Controls::String>.

=head1 REDEFINED PUBLIC METHODS

=cut

# params:
# complets:
#  string -> URL per i date
#  aref   -> lista dei dati
# opts: hashref (solo se complets isa string)
#  quelle di Autocompleter.Local
#  jsurl -> base url per i pezzi JS

=head2 C<new>

The constructor. Takes the control's name, a completion specification,
and various options.

The completion can be specified as either a reference to an array
containing strings, in which case the control will use the "local
auto-completer"; or as a scalar containing a URL to use for the AJAX
auto-completer (see L</USAGE REQUIREMENTS>).

The options are passed as a hash reference. The hash must contain a
C<jsurl> key, whose value must be the URL under which the JavaScript
libraries can be found (see L</USAGE REQUIREMENTS>). If the control is
using the "local auto-completer", these other options can be passed:

=over 4

=item C<choices>

how many choices to present to the user, at most. Defaults to 4.

=item C<ignore_case>

if case should be ignored while looking for completions. Defaults to true.

=item C<partial_chars>

how many characters to enter before triggering a partial match. Defaults to 2.

=item C<partial_search>

whether to search for completions at the beginning of every I<word> in
every item, or just at the beginning of each whole item. Defaults to
true, which selects the first behaviour.

=item C<full_search>

if both this and C<partial_search> are true, search for completions
anywhere in each item. Defaults to false.

=back

See also L</_ac_local_opts>, L</_ac_local_defaults>, L</_ac_ajax_opts>
and L</_ac_ajax_defaults> to change recognized options and defaults in
your sub-classes.

=cut

sub new {
  my ($class,$name,$complets,$opts)=@_;
  my $self=$class->SUPER::new($name);
  my (@opts,%defaults);
  if (ref($complets) eq 'ARRAY') {
    # uso Local
    $self->{acstyle}='local';
    $self->{acitems}=[@$complets];
    @opts=$self->_ac_local_opts();
    %defaults=$self->_ac_local_defaults();
  } else {
    # uso Ajax
    $self->{acstyle}='ajax';
    $self->{acurl}=$complets;
    @opts=$self->_ac_ajax_opts();
    %defaults=$self->_ac_ajax_defaults();
  }
  if (defined $opts->{jsurl}) {
    $self->{jsurl}=$opts->{jsurl};
  } else {
    local $Carp::CarpLevel=2;
    croak('option "jsurl" is required');
  }
  $self->{opts}={};
  for (@opts) {
    $self->{opts}{$_}=
      defined $opts->{$_}
        ? $opts->{$_}
        : $defaults{$_};
  }
  return $self;
}

=head1 REDEFINED PROTECTED METHODS

=head2 C<_head_template_name>

Returns C<'acstring-head.wt'>. The stock template outputs the C<<
<script> >> elements to load the JavaScript libraries, and a CSS
fragment to give a basic style to the completions' pop-up.

=cut

sub _head_template_name {
  'acstring-head.wt';
}

=head2 C<_head_template_parms>

Calls the inherited method, then L</_add_template_parms> to add the
data needed for the auto-completer.

=cut

sub _head_template_parms {
  my ($self)=@_;
  my $ret=$self->SUPER::_head_template_parms();
  $self->_add_template_parms($ret);
  return $ret;
}

=head2 C<_body_template_name>

Returns C<'acstring-head.wt'>. The stock template outputs the C<<
<input> >> element, the C<< <div> >> for the completions, and the
JavaScript call to attach the auto-completer.

=cut

sub _body_template_name {
  'acstring.wt';
}

=head2 C<_body_template_parms>

Calls the inherited method, then L</_add_template_parms> to add the
data needed for the auto-completer.

=cut

sub _body_template_parms {
  my ($self)=@_;
  my $ret=$self->SUPER::_body_template_parms();
  $self->_add_template_parms($ret);
  return $ret;
}

=head1 ADDITIONAL METHODS

=head2 C<_add_template_parms>

This is a utility method, called by both L</_body_template_parms> and
L</_head_template_parms>. It adds to the passed hash reference:

=over 4

=item C<jsurl>

The URL for the JavaScript libraries

=item C<acstyle>

C<'local'> or C<'ajax'>

=item C<acitems>

if using the "local auto-completer", the array of possible completions

=item C<acurl>

if using the AJAX auto-completer, the URL to call to obtain the completions

=item C<opts>

the options hash, as passed to the constructor, with missing values
filled in by defaults.

=back

=cut

sub _add_template_parms {
  my ($self,$data)=@_;
  @$data{qw(jsurl acstyle acitems acurl acopts)}=
    ($self->{jsurl},$self->{acstyle},$self->{acitems},$self->{acurl},$self->{opts});
}

=head2 C<_ac_local_opts>

Returns a list of acceptable option names for the "local
auto-completer" (C<choices>, C<partial_search>, C<full_search>,
C<partial_chars>, C<ignore_case>).

=cut

sub _ac_local_opts {
  return qw(choices partial_search full_search partial_chars ignore_case);
}

=head2 C<_ac_local_defaults>

Returns a hash (I<not> a reference) containing default values for all
the options returned by L</_ac_local_opts>. See L</new> for the
values.

=cut

sub _ac_local_defaults {
  return (
          choices => 4,
          partial_search => 1,
          full_search => 0,
          partial_chars => 2,
          ignore_case => 1,
         );
}

=head2 C<_ac_ajax_opts>

Returns a list of acceptable option names for the AJAX
auto-completer. Right now, the empty list.

=cut

sub _ac_ajax_opts { () };

=head2 C<_ac_ajax_defaults>

Returns a hash (I<not> a reference) containing default values for all
the options returned by L</_ac_ajax_opts>. Right now, the empty hash.

=cut

sub _ac_ajax_defaults { () };


=head1 COPYRIGHT

Copyright 2005 Gianni Ceccarelli, All Rights Reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;
