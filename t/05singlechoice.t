#!/usr/bin/perl
use Test::More 'no_plan';
use HTML::Controls;
use Test::MockObject;
use Test::Exception;

ok(grep {$_ eq 'HTML::Controls::SingleChoice'} HTML::Controls->controls(),'esiste');

throws_ok {HTML::Controls::SingleChoice->new('pick')} qr{need a list.*/05single},'missing list';

my $list=[qw(a b c)];
my $w=HTML::Controls::SingleChoice->new('pick',$list);

my $form=$w->form();
like($form,
     qr{
        <select [^>]*?
         name=["']pick["'] [^>]*> \s*
         <option.*? value="" .*?> .* scegli .*</option.*?> \s*
         <option.*? value="0" .*?>a</option.*?> \s*
         <option.*? value="1" .*?>b</option.*?> \s*
         <option.*? value="2" .*?>c</option.*?> \s*
        </select
      }x,'field');

$w->setData('b');
$form=$w->form();
like($form,
     qr{
         <option.*? selected .*?>b</option.*?> \s*
      }x,'preset value');


my $data=Test::MockObject->new();
my $val='valore non valido';
$data->mock('param',sub {
              if ($_[1] eq 'sel') {
                return $val;
              } else {return};
            });
$data->set_always('parameters',{sel=>$val});
$w=HTML::Controls::SingleChoice->new('sel',$list);

$w->setDataFromPost($data);
ok(!$w->isDataValid(),'invalid');
like($w->form(),qr{\bserve un valore\b},'errore mostrato');
$val=5;
$w->setDataFromPost($data);
ok(!$w->isDataValid(),'invalid');
like($w->form(),qr{\bserve un valore\b},'errore mostrato');
$val='';
$w->setDataFromPost($data);
ok(!$w->isDataValid(),'invalid');
like($w->form(),qr{\bserve un valore\b},'errore mostrato');
$val=1;
$w->setDataFromPost($data);
ok($w->isDataValid(),'valid');
unlike($w->form(),qr{\bselezione impossibile\b},'errore non mostrato');
is($w->getData(),'b','value');
