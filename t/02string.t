#!/usr/bin/perl
use Test::More 'no_plan';
use HTML::Controls;
use Test::MockObject;

ok(grep {$_ eq 'HTML::Controls::String'} HTML::Controls->controls(),'esiste');

my $w=HTML::Controls::String->new('field1');

my $form=$w->form();
like($form,
     qr{
        <input \s [^>]*?
        name=["']field1["'] [^>]*
        >
      }x,'field name');
like($form,
     qr{
        <input \s [^>]*?
        value=["']["'] [^>]*
        >
      }x,'field value');

$w=HTML::Controls::String->new('field2');
$w->setData(q{contenuto "'});
$form=$w->form();
like($form,
     qr{
        <input \s [^>]*?
        name=["']field2["'] [^>]*
        >
      }x,'field name');
like($form,
     qr{
        <input \s [^>]*?
        value="contenuto\ &quot;'" [^>]*
        >
      }x,'field value');

my $data=Test::MockObject->new();
my $val='valore del campo';
$data->mock('param',sub {
              if ($_[1] eq 'field2') {
                return $val;
              } else {return};
            });
$data->set_always('parameters',{field2=>$val});

$w->setDataFromPost($data);
ok($w->isDataValid(),'valid');
is($w->getData(),$val,'value');

$val=undef;
$w->setDataFromPost($data);
ok(!$w->isDataValid(),'invalid');
$form=$w->form();
like($form,qr{\bserve un valore\b},'errore mostrato');
