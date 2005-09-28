#!/usr/bin/perl
use Test::More 'no_plan';
use HTML::Controls;
use Test::MockObject;

ok(grep {$_ eq 'HTML::Controls::Number'} HTML::Controls->controls(),'esiste');

my $w=HTML::Controls::Number->new('field3');
my $data=Test::MockObject->new();
my $val='valore non valido';
$data->mock('param',sub {
              if ($_[1] eq 'field3') {
                return $val;
              } else {return};
            });
$data->set_always('parameters',{field3=>$val});

$w->setDataFromPost($data);
ok(!$w->isDataValid(),'invalid');
my $form=$w->form();
like($form,qr{serve un numero},'errore mostrato');

$val=' 12.34	';
$w->setDataFromPost($data);
ok($w->isDataValid(),'valid');
is($w->getData(),12.34,'value');
$form=$w->form();
unlike($form,qr{serve un},'errore non mostrato');
