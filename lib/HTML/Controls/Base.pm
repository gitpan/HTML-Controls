package HTML::Controls::Base;
use strict;
use vars '$VERSION';
use warnings;
use Template;
use Path::Class;

$VERSION='0.1';

=head1 NAME

HTML::Controls::Base - base class for the controls

=head1 SYNOPSIS

This module defines an abstract class, from which all the other
controls must inherit. It defines all the basic, shared behaviour.

For an overview on how to use this framework, see
L<HTML::Controls|HTML::Controls>.

=head1 PUBLIC METHODS

=head2 C<new>

The constructor. Takes the name of the control, which must ba a valid
HTML identifier. The returned object has no valid data.

=cut

sub new {
  my ($class,$name)=@_;
  return bless {name=>$name,value=>undef},$class;
}

=head2 C<setData>

This method takes a scalar value (that can be a reference), and uses
it to set the control's current value. It calls L</_preprocess_value>
to convert the passed value before storing it in C<< $self->{value} >>.
Then it calls L</_validate_value>.

You should override this method if you need more complex manipulations.

=cut

sub setData {
  my ($self,$value)=@_;
  $self->{value}=$self->_preprocess_value($value);
  $self->_validate_value();
}

=head2 C<setDataFromPost>

This method takes a HTTP request object (like a L<CGI|CGI> object, a
L<Apache::Request|Apache::Request> object, or something similar), and
uses it to set the control's current value. It uses the control's name
to extract the value from the request, calls L</_preprocess_value> to
convert it and then stores it in C<< $self->{value} >>. Then it calls
L</_validate_value>.

You should override this method if your data gets sent as more than
one field.

=cut

sub setDataFromPost {
  my ($self,$request)=@_;
  $self->{value}=$self->_preprocess_value($request->param($self->{name}));
  $self->_validate_value();
}

=head2 C<isDataValid>

Returns a true value if L</getErrors> returns C<undef> or an empty
array reference.

You should never need to override this method: override
L</_validate_value> instead.

=cut

sub isDataValid {
  my ($self)=@_;
  my $err=$self->getErrors();
  return !(defined $err and @{$err});
}

=head2 C<getData>

Returns the value stored in the control (a scalar).

You should probably override this method if you overrode L</setData> or
L</setDataFromPost>.

=cut

sub getData {
  my ($self)=@_;
  return $self->{value};
}

=head2 C<getErrors>

Returns an array reference of errors found during the last call to
L</_validate_value>.

You should never override this method.

=cut

sub getErrors {
  my ($self)=@_;
  return $self->{errors};
}

=head2 C<getName>

Returns the name of this control, as set by the constructor or L</setName>.

=cut

sub getName {
  my ($self)=@_;
  return $self->{name};
}

=head2 C<setName>

Sets the name of the control. It must ba a valid HTML identifier.

You should not override this method. For a case in which it is
necessary, see
L<HTML::Controls::CompositeOf|HTML::Controls::CompositeOf> and
L<HTML::Controls::ArrayOf|HTML::Controls::ArrayOf>.

=cut

sub setName {
  my ($self,$name)=@_;
  $self->{name}=$name;
}

=head2 C<form>

Returns a string containing (X)HTML code to put inside a C<form>
element. It calls L</_render>.

Don't override this method: see L</_body_template_name> and
L</_body_template_parms>.

=cut

sub form {
  my ($self)=@_;
  return $self->_render($self->_body_template_name(),
                        $self->_body_template_parms());
}

=head2 C<head>

Returns a string containing (X)HTML code to put inside the C<head>
element. It calls L</_render>.

Don't override this method: see L</_head_template_name> and
L</_head_template_parms>.

=cut

sub head {
  my ($self)=@_;
  return $self->_render($self->_head_template_name(),
                        $self->_head_template_parms());
}

=head2 C<templateDir>

Returns the directory in which the template file for this control is
stored. It is used by
L<HTML::Controls::templateProvider|HTML::Controls/templateProvider>.

By default it returns a directory called C<tmpl> placed in the same
directory where the source file for the module resides.

=cut

sub templateDir {
  my ($class)=@_;
  $class=ref($class) if ref($class);
  $class=~s{::}{/}g;$class.='.pm';
  my $file=$INC{$class};
  return file($file)->dir->subdir('tmpl')
}

=head2 C<setTemplateObject>

Used to set the L<Template|Template> object used by this control. It
can be called by the application, to avoid instatiating a different
L<Template|Template> for each control. The passed object should use
the L<provider|Template::Provider> returned by
L<HTML::Controls::templateProvider|HTML::Controls/templateProvider>,
in addition to any other providers that may be needed.

=cut

sub setTemplateObject {
  my ($self,$t)=@_;
  $self->{template}=$t;
}

=head1 PROTECTED METHODS

These methods are intended to be overridable by subclasses, but not
callad by applications.

=head2 C<_preprocess_value>

Override this method to preprocess data (one scalar) coming from
either L</setData> or L</setDataFromPost>, before storing. Note that
this works only if the internal and external representation are very
similar or identical. If they differ, you should override one or both
of the C<setData*> methods.

By default it returns the value unchanged.

=cut

sub _preprocess_value {
  return $_[1];
}

=head2 C<_validate_value>

Override this method to check the validity of data already stored in
C<< $self->{value} >> or wherever you put it if you redefined
L</setData> or L</setDataFromPost>.

At the end of this method, C<< $self->{errors} >> should be C<undef>
or an empty array ref if there were no errors; otherwise it sholud
contain one string for each error, describing it. Localization of
these messages is delegated to the templates.

You should probably call the inherited method before doing your
checks. By default this method checks that the value is defined.

=cut

sub _validate_value {
  my ($self)=@_;
  $self->{errors}=
    (defined $self->{value})?undef:
      ['serve un valore'];
}

=head2 C<_render>

This method takes a template name and a hash reference, and uses the
object returned by L</_template> to obtain the output string. It dies
if the template engine encounters an error.

You should never need to override this method.

=cut

sub _render {
  my ($self,$tname,$tparms)=@_;
  return unless defined $tname;
  my $out;
  my $ret=$self->_template->process($tname,
                                     $tparms,
                                     \$out);
  unless ($ret) {die $self->_template->error()};
  return $out;
}

=head2 C<_template>

Returns the template processor to use to render the (X)HTML
strings. If no template object has been set (because this method has
never been called, and nobody used L</setTemplateObject>), it creates
a new L<Template|Template> object using the provider returned by
L<HTML::Controls::templateProvider|HTML::Controls/templateProvider>,
caching it.

You should never need to override this method.

=cut

sub _template {
  my ($self)=@_;
  unless ($self->{template}) {
    $self
      ->setTemplateObject(
                          Template->
                          new({
                               LOAD_TEMPLATES=> HTML::Controls::templateProvider(),
                              }));
  }
  return $self->{template};
}

=head2 C<_body_template_name>

Returns a string containing the name of the template file to use to
render the "form" for this control. It should return a filename
relative to the directory returned by L</templateDir>.

You I<must> override this method: by default it returns C<undef>,
causing L</_render> to return C<undef>.

=cut

sub _body_template_name {
  undef;
}

=head2 C<_body_template_parms>

Returns a hash reference that gets passed to the template engine when
rendering the "form" for this control. By default it passes the name,
the value (as stored>, and any errors found during validation.

You should override this method if your template requires more data
(e.g. you keep part of the value outside C<< $self->{value} >>). You
should remember to call the inherited method, and add your data to the
returned hash.

=cut

sub _body_template_parms {
  my ($self)=@_;
  +{
    name=>$self->{name},
    value=>$self->{value},
    errors=>$self->getErrors(),
   }
};

=head2 C<_head_template_name>

Returns a string containing the name of the template file to use to
render the "head" for this control. It should return a filename
relative to the directory returned by L</templateDir>.

You should override this method if you need special CSS or JavaScript
code. By default it returns C<undef>, causing L</_render> to return
C<undef>.

=cut

sub _head_template_name {
  undef;
}

=head2 C<_head_template_parms>

Returns a hash reference that gets passed to the template engine when
rendering the "head" for this control. By default it passes the name,
the value (as stored>, and any errors found during validation.

You should override this method if your template requires more data
(e.g. you keep part of the value outside C<< $self->{value} >>). You
should remember to call the inherited method, and add your data to the
returned hash.

=cut

sub _head_template_parms {
  my ($self)=@_;
  +{
    name=>$self->{name},
    value=>$self->{value},
    errors=>$self->{errors}
   }
};

=head1 COPYRIGHT

Copyright 2005 Gianni Ceccarelli, All Rights Reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;
