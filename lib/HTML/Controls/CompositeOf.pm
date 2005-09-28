package HTML::Controls::CompositeOf;
use strict;
use vars '$VERSION';
use warnings;
use base 'HTML::Controls::Base';

$VERSION='0.1';

=head1 NAME

HTML::Controls::CompositeOf - base abstract class for a control set

=head1 SYNOPSIS

   package HTML::Controls::MyComposite;
   use base 'HTML::Controls::CompositeOf';

   sub new {
     my $self=$_[0]->SUPER::new($_[1]);
     # create sub-controls
     return $self;
   }

   sub _validate_value {
     my ($self)=@_;
     $self->{errors}=undef;
     $self->SUPER::_validate_value();
     # perform additional validations
   }

   package MyController;

   my $comp = HTML::Controls::MyComposite->new('name',$stuff);

This is an abstract base class for sets of control, i.e. to treat
multiple, disomogeneous controls as a single thing. Think "hash of
controls". If you want an array of controls (variable numbered,
homogeneous controls), see L<HTML::Controls::ArrayOf>.

=head1 VALUE FORMAT

The internal representation of the composite value is a hash
reference, whose keys are the "short" names of the sub-controls, and
whose values are the corresponding controls' values.

=head1 METHODS TO REDEFINE

=head2 C<new>

As seen in the synopsis, you must redefine the constructor to populate
the composite. To that end, you should instantiate each sub-control,
and pass it to the L</_set_sub> method:

   my $sub1=HTML::Controls::Something->new('tmpname');
   $self->_set_sub('realname',$sub1);

Note that the name you pass to the constructor is replaced by a new,
generated "long" name, based on the name you pass to L<_set_sub>. The
name that you pass to L<_set_sub> is the "short" name used to refer to
that sub-control in the value hash and template parameters.

=head2 C<_validate_value>

If you need to perform cross-validation or something similar, you
should override this method. Remember to always call the inherited
method, and to add all errors you find to the C<< $self->{errors} >>
array. For example:

  sub _validate_value {
    my ($self)=@_;
    $self->{errors}=undef;
    $self->SUPER::_validate_value();
    if ($self->_get_sub('sub1')->getData() >
        $self->_get_sub('sub2')->getData()) {
      push @{$self->{errors}}, 'sub1 must be less than sub2';
    }
  }

=head2 Template methods

You must redefine C<_body_template_name> and/or
C<_head_template_name>, otherwise no output will be generated. You can
redefine C<_body_template_parms> and/or C<_head_template_parms> if you
need to pass additional data to your templates.

=head1 REDEFINED PUBLIC METHODS

=head2 C<setData>

This method iterates through the sub-controls, and if the
sub-control's "short" name is present as a key in the passed hash
reference, the corresponding value is passed to that sub-control's
C<setData>.

=cut

sub setData {
  my ($self,$struct)=@_;
  for ($self->_get_sub_names()) {
    next unless exists $struct->{$_};
    $self->_get_sub($_)->setData($struct->{$_});
  }
  $self->_validate_value();
}

=head2 C<setDataFromPost>

This method iterates through the sub-controls, calling each one's
C<setDataFromPost> with the passed request.

=cut

sub setDataFromPost {
  my ($self,$request)=@_;
  for ($self->_get_sub_names()) {
    $self->_get_sub($_)->setDataFromPost($request);
  }
  $self->_validate_value();
}

=head2 C<isDataValid>

This method returns false if C<< $self->getErrors() >> or any
sub-control's C<getErrors()> returns a non-empty array reference.

=cut

sub isDataValid {
  my ($self)=@_;
  my $ret=1;
  for ($self->_get_sub_names()) {
    $ret &&= $self->_get_sub($_)->isDataValid();
  }
  my $err=$self->getErrors();
  $ret &&= !(defined $err and @{$err});
  return $ret;
}

=head2 C<getData>

This method iterates through the sub-controls, populating the return
hash with the values obtained from each one's C<getData>.

=cut

sub getData {
  my ($self)=@_;
  my $ret={};
  for ($self->_get_sub_names()) {
    $ret->{$_}=$self->_get_sub($_)->getData();
  }
  return $ret;
}

=head2 C<setName>

This method sets the composite's name, and propagates the change to
each sub-control, using L</_name_sub> to calculate their "long" names.

=cut

sub setName {
  my ($self,$name)=@_;
  $self->SUPER::setName($name);
  for ($self->_get_sub_names()) {
    $self->_get_sub($_)->setName($self->_name_sub($_));
  }
}

=head2 C<setTemplateObject>

This method sets the composite's template engine, and propagates the
change to each sub-control.

=cut

sub setTemplateObject {
  my ($self,$t)=@_;
  $self->SUPER::setTemplateObject($t);
  for ($self->_get_sub_names()) {
    $self->_get_sub($_)->setTemplateObject($t);
  }
}

=head1 REDEFINED PROTECTED METHODS

=head2 C<_validate_value>

This method iterates through the sub-controls, calling each one's
C<_validate_value>. Note that this deos I<not> populate the
composite's C<error> array. See L</isDataValid>.

=cut

sub _validate_value {
  my ($self)=@_;
  for ($self->_get_sub_names()) {
    $self->_get_sub($_)->_validate_value();
  }
}

=head2 C<_body_template_parms>

Calls the inherited method, then L</_add_template_parms> to add the
sub-controls.

=cut

sub _body_template_parms {
  my ($self)=@_;
  my $ret=$self->SUPER::_body_template_parms();
  $self->_add_template_parms($ret);
  return $ret;
}

=head2 C<_head_template_parms>

Calls the inherited method, then L</_add_template_parms> to add the
sub-controls.

=cut

sub _head_template_parms {
  my ($self)=@_;
  my $ret=$self->SUPER::_head_template_parms();
  $self->_add_template_parms($ret);
  return $ret;
}

=head1 ADDITIONAL METHODS

=head2 C<_add_template_parms>

This is a utility method, called by both L</_body_template_parms> and
L</_head_template_parms>. It adds to the passed hash reference all the
sub-controls, using their "short" names as keys.

=cut

sub _add_template_parms {
  my ($self,$data)=@_;
  for ($self->_get_sub_names()) {
    $data->{$_}=$self->_get_sub($_);
  };
}

=head2 C<_name_sub>

Calculates a sub-control's "long" name from its "short" name. The
generated name is:

   $composite_name . '_' . $short_name

=cut

sub _name_sub {
  my ($self,$subname)=@_;
  my $name=$self->{name} . '_' . $subname;
  return $name;
}

=head2 C<_set_sub>

Takes a "short" name and a control, and adds it as a new
sub-control. The sub-control's name is changed to the "long" name
calculated by L</_name_sub>.

=cut

sub _set_sub {
  my ($self,$name,$w)=@_;
  $w->setName($self->_name_sub($name));
  $self->{subs}->{$name}=$w;
}

=head2 C<_get_sub_names>

Returns a list of all sub-controls' "short" names.

=cut

sub _get_sub_names {
  my ($self)=@_;
  return keys %{$self->{subs}};
}

=head2 C<_get_sub>

Given a sub-control's "short" name, returns the corresponding control,
or C<undef> in no such control exists.

=cut

sub _get_sub {
  my ($self,$name)=@_;
  return unless exists $self->{subs}->{$name};
  return $self->{subs}->{$name};
}

=head1 COPYRIGHT

Copyright 2005 Gianni Ceccarelli, All Rights Reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;
