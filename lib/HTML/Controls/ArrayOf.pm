package HTML::Controls::ArrayOf;
use strict;
use vars '$VERSION';
use warnings;
use base 'HTML::Controls::Base';

$VERSION='0.1';

=head1 NAME

HTML::Controls::ArrayOf - base abstract class for a control array

=head1 SYNOPSIS

   package HTML::Controls::MyArray;
   use base 'HTML::Controls::ArrayOf';

   sub new {
     my $self=$_[0]->SUPER::new($_[1]);
     # do some initialization
     $self->_populate($_[2]);
     return $self;
   }

   sub _create_item {
     return HTML::Controls::Something->new($_[1],$stuff);
   }

   package MyController;

   my $arr = HTML::Controls::MyArray->new('name',$howMany);

This is an abstract base class for arrays of control, i.e. to treat a
variable number of homogeneous controls as a single thing. Think
"array of controls". If you want a hash of controls (fixed number,
disomogeneous controls), see L<HTML::Controls::CompositeOf>.

=head1 VALUE FORMAT

The internal representation of the array value is an array
reference, containings the sub-controls' values.

=head1 METHODS TO REDEFINE

=head2 C<_create_item>

You must redefine this method to return a new sub-control. The name
you give it is irrelevant, since it will be overwritten by one
calculated by L</_name_item>.

=head1 REDEFINED PUBLIC METHODS

=head2 C<new>

The constructor takes the array's name and a specification for the
sub-controls. It calls L</_populate> with this specification to create
them.

=cut

sub new {
  my ($class,$name,$items)=@_;
  my $self=$class->SUPER::new($name);
  $self->_populate($items);
  return $self;
}

=head2 C<setData>

This method takes an array reference as specified in L</VALUE
FORMAT>. All exisisting sub-controls are deleted, and new one are
created (calling L</_create_item>) and assigned the passed data. Note
that, because of this, a call to C<setData> can change the size of the
array.

=cut

sub setData {
  my ($self,$list)=@_;
  $self->_clear_items();
  for (0..$#$list) {
    my $item=$self->_create_item();
    $item->setName($self->_name_item($_));
    $item->setData($list->[$_]);
    $self->_add_item($item);
  }
  $self->_validate_value();
}

=head2 C<setDataFromPost>

This is the method where most of the complexity resides: it sets each
sub-control to the value extracted from the passed request, removing
and adding sub-controls if required.

It assumes that a request parameter of the form "${arrayname}_del_\d+"
requests the removal of the sub-control at the position indicated by
the number, and that a parameter of the form "${arrayname}_add_\d+"
requests a new sub-control to be added after the position indicated.

At the end, oll sub-controls get renamed, to insure the proper
ordering and the correspondance between positions and sub-controls'
names.

Calls L</_validate_value> after removing sub-controls and setting
values, but before adding new sub-controls. Tis is because, usually,
newly created controls have no valid value.

=cut

sub setDataFromPost {
  my ($self,$request)=@_;
  my $action;my $name=$self->{name};

  $self->_clear_items();
  for (0..($request->param("${name}_size")-1)) {
    my $item=$self->_create_item();
    $item->setName($self->_name_item($_));
    $self->_add_item($item);
  }
  
  # togliamo roba?
  for (keys %{$request->parameters}) {
    if (/^${name}_del_(\d+)$/) {
      $action=$1;
    }
  }
  if (defined $action) {
    $self->_delete_item($action-1);
  }
  
  for (@{$self->_get_items()}) {
    $_->setDataFromPost($request);
  }

  $self->_validate_value();

  # aggiungiamo roba?
  $action=undef;
  for (keys %{$request->parameters}) {
    if (/^${name}_add_(\d+)$/) {
      $action=$1;
    }
  }
  if (defined $action) {
    my $item=$self->_create_item();
    $item->setName($self->_name_item($action));
    $self->_insert_item($action,$item);
  }

  my $i=0;
  for (@{$self->_get_items()}) {
    $_->setName($self->_name_item($i++));
  }
}

=head2 C<isDataValid>

This method returns false if C<< $self->getErrors() >> or any
sub-control's C<getErrors()> returns a non-empty array reference.

=cut

sub isDataValid {
  my ($self)=@_;
  my $ret=1;
  for (@{$self->_get_items()}) {
    $ret &&= $_->isDataValid();
  }
  my $err=$self->getErrors();
  $ret &&= !(defined $err and @{$err});
  return $ret;
}

=head2 C<getData>

This method iterates through the sub-controls, populating the return
array with the values obtained from each one's C<getData>.

=cut

sub getData {
  my ($self)=@_;
  my $ret=[];
  for (@{$self->_get_items()}) {
    push @$ret,$_->getData();
  }
  return $ret;
}

=head2 C<setName>

This method sets the composite's name, and propagates the change to
each sub-control, using L</_name_item> to calculate their new names.

=cut

sub setName {
  my ($self,$name)=@_;
  $self->SUPER::setName($name);
  for (0..$#{$self->_get_items()}) {
    $self->{items}->[$_]->setName($self->_name_item($_));
  }
}

=head2 C<setTemplateObject>

This method sets the array's template engine, and propagates the
change to each sub-control.

=cut

sub setTemplateObject {
  my ($self,$t)=@_;
  $self->SUPER::setTemplateObject($t);
  for (0..$#{$self->_get_items()}) {
    $self->{items}->[$_]->setTemplateObject($t);
  }
}

=head1 REDEFINED PROTECTED METHODS

=head2 C<_validate_value>

This method iterates through the sub-controls, calling each one's
C<_validate_value>. Note that this deos I<not> populate the
array's C<error> array. See L</isDataValid>.

=cut

sub _validate_value {
  my ($self)=@_;
  $self->{errors}=undef;
  for (@{$self->_get_items()}) {
    $_->_validate_value();
  }
}

=head2 C<_body_template_name>

Returns C<'array_of.wt'>. This template outputs a ordered list with
one sub-control per item, and provides buttons to add and remove
controls. If you wish to provide your own template, remember to
include this one, or provide equivalent functionality.

=cut

sub _body_template_name {
  'array_of.wt';
}

=head2 C<_body_template_parms>

Calls the inherited method, then sets the value of the C<item> key to
the array of sub-controls.

=cut

sub _body_template_parms {
  my ($self)=@_;
  my $ret=$self->SUPER::_body_template_parms();
  $ret->{items}=$self->_get_items();
  return $ret;
}

=head1 ADDITIONAL METHODS

=head2 C<_populate>

This method takes either a number (indicating how many sub-controls to
create) or an arry reference (containing initial data for the
sub-controls), and populates the sub-controls' array.

=cut

sub _populate {
  my ($self,$items)=@_;
  if (ref($items) eq 'ARRAY') {
    $self->setData($items);
  } else {
    $items||=1;
    for (0..($items-1)) {
      my $item=$self->_create_item();
      $item->setName($self->_name_item($_));
      $self->_add_item($item);
    }
  }
}

=head2 C<_name_item>

Calculates a sub-control's name from its position. The
generated name is:

   $array_name . '_' . ($position+1)

=cut

sub _name_item {
  my ($self,$num)=@_;
  my $name=$self->{name} . '_' . ($num+1);
  return $name;
}

=head2 C<_add_item>

Adds the given sub-control to the end of the sub-controls' array.

=cut

sub _add_item {
  my ($self,$item)=@_;
  push @{$self->{items}},$item;
}

=head2 C<_get_items>

Returns the whole sub-controls' array.

=cut

sub _get_items {
  my ($self)=@_;
  return $self->{items};
}

=head2 C<_clear_items>

Deletes all the sub-controls.

=cut

sub _clear_items {
  my ($self)=@_;
  $self->{items}=[];
}

=head2 C<_insert_item>

Given a position and a control, inserts it I<after> that position.

=cut

sub _insert_item {
  my ($self,$pos,$item)=@_;
  splice @{$self->{items}},$pos,0,$item;
}

=head2 C<_delete_item>

Deletes the sub-control at the given position.

=cut

sub _delete_item {
  my ($self,$pos)=@_;
  splice @{$self->{items}},$pos,1;
}

=head1 COPYRIGHT

Copyright 2005 Gianni Ceccarelli, All Rights Reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut


1;
