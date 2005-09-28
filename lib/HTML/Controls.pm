package HTML::Controls;
use strict;
use vars '$VERSION';
use warnings;
use Module::Pluggable::Fast
  name=>'_controls',
  search=>['HTML::Controls'],
  require=>1;
use Template::Provider;

=head1 NAME

HTML::Controls - framework for complex controls/widgets in HTML

=head1 Version

Version 0.1

=cut

$VERSION='0.1';

=head1 SYNOPSIS

  use HTML::Controls;

  # in your request-handling sub
  my $w=HTML::Controls::Date('date_field');
  if ($request->method eq 'POST') { # or something to that effect
   $w->setDataFromPost($request);
   if ($w->isDataValid()) {
    my $date=$w->getData();
    # do what you need with the data
   } else {
    # data not complete or invalid: cope with it
   }
  }
  print some_html_up_to_head();
  print $w->head();
  print a_lot_of_html_closing_head_and_apening_a_form();
  print $w->form();
  print a_lot_of_html_closing_the_form();

This module is the front-end to the HTML::Controls framework.

The aim of this framework is to facilitate the development of modular
controls to ease the handling of complex HTML forms. For example, the
C<HTML::Controls::Date> in the example could be rendered as a single
C<input> field, or three separate fields, or a pop-up calendar written
in JavaScript, and you should have to change nothing in your code.

=head1 DESCRIPTION

This module exists mostly to load the other C<HTML::Controls::*>, via
C<Module::Pluggable::Fast>. In this section we'll look at the
underlying ideas of the framework, and only later we'll look at the
methods defined here.

As you can see from the example in the synopsis, the life-cycle of a
control is more or less the following:

=over 4

=item construction

you create the controls you need with the C<new> method, passing (at
least) their name, and possibly some other data (see the specific
control's module for details)

=item setting data

using the C<setData> method, you can give the control some initial
values. These values are passed in I<internal representation> (again,
see each module for details). On the other hand, if you received a
data from the user (via a C<POST> or C<GET> request), you should pass
the request to the control using the C<setDataFromPost>, so that it
can update itself. The request should implement at least C<param>
method like the one in L<CGI|CGI>. Some controls might require a
C<parameters> method, that returns a reference to a hash containig all
passed parameters

=item validating data

if you set the data, especially from a user request, you should test
if it is valid with the C<isDataValid> method

=item getting the data back

if the data is valid, you can get it (in I<internal representation>)
with the C<getData> method

=item outputting the form

to obtain the HTML output, you have to use the C<head> and C<form>
methods, to get a string to emit inside the HTML element of the same
name. Note that you should not assume much about this output, save
that: 

=over 8

=item *

it is valid (X)HTML

=item *

it presents the user with a way to input the data you need

=item *

when submitted, said data will be read correctly by the
C<setDataFromPost> method

=back

In other words, these methods produce an I<external representation> of
the data, and the whole point is to allow you not to worry about it.

=back

=head2 Relation to other modules

This framework uses the Template Toolkit to create the HTML fragments,
but does not require that you use it. If you do use it, there will be
some glue to avoid creating a different L<Template|Template> object
for each control (as it happens right now).

I do integration testing using L<Catalyst|Catalyst>, but everything
should work as well using L<CGI|CGI>, or anything that can parse a
request into an object and send strings to the browser.

=cut

my @controls=_controls();

=head1 METHODS

=head2 C<controls>

returns the list of the names of all the modules found in the
C<HTML::Controls::> namespace

=cut

sub controls {
  return @controls;
}

=head2 C<templateProvider>

returns a L<Template::Provider|Template::Provider> object that looks
for template files in all the directories specified by the various
controls. See
L<HTML::Controls::Base::templateDir|HTML::Controls::Base/templateDir>

=cut

sub templateProvider {
  my %dirs;
  for (controls()) {
    $dirs{$_->templateDir}=undef;
  }
  return Template::Provider
    ->new({
           INCLUDE_PATH=>[keys %dirs],
           RELATIVE=>1,
          });
}

=head1 AUTHOR

Gianni Ceccarelli C<< <dakkar@thenautilus.net> >>

=head1 TODO

=over 4

=item *

better integration with TT2

=item *

more AJAX controls

=item *

more and better tests

=item *

better-looking templates

=item *

factor the templates to allow easy CSS styling

=back

=head1 BUGS

No bugs in the functionality are known.

Please report any bugs or feature requests to
C<bug-html-controls@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 COPYRIGHT

Copyright 2005 Gianni Ceccarelli, All Rights Reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;
