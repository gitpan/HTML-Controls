#!/usr/bin/perl
use Test::More 'no_plan';
use HTML::Controls;
use Test::MockObject;

ok(grep {$_ eq 'HTML::Controls::Date'} HTML::Controls->controls(),'esiste');

my $w=HTML::Controls::Date->new('data');
my $form=$w->form();

for (qw(d m y)) {
  like($form,
       qr{
          <input \s [^>]*?
          name=["']data_$_["']
        }x,"field name $_");
}

$w->setData({y=>2005,m=>10,d=>23});
$form=$w->form();
like($form,
     qr{
        <input \s [^>]*?
        name=["']data_d["'] [^>]*?
        value=["']23["']
      }x,'field value _d');
like($form,
     qr{
        <input \s [^>]*?
        name=["']data_y["'] [^>]*?
        value=["']2005["']
      }x,'field value _d');
like($form,
     qr{
        <input \s [^>]*?
        name=["']data_m["'] [^>]*?
        value=["']10["']
      }x,'field value _d');


my $data=Test::MockObject->new();
my $y='2005';
my $m='14';
my $d='stica';
$data->mock('param',sub {
              if ($_[1] eq 'data_d') {
                return $d;
              } elsif ($_[1] eq 'data_m') {
                return $m;
              } elsif ($_[1] eq 'data_y') {
                return $y;
              } else {return};
            });
$data->set_always('parameters',
                  {
                   data_y=>$y,
                   data_m=>$m,
                   data_d=>$d,
                  });

$w=HTML::Controls::Date->new('data');
$w->setDataFromPost($data);
ok(!$w->isDataValid(),'invalid');
like($w->form(),qr{\bdata non valida\b},'errore mostrato');
$d='12';
$w->setDataFromPost($data);
ok(!$w->isDataValid(),'invalid');
$m='02';$d='29';
$w->setDataFromPost($data);
ok(!$w->isDataValid(),'invalid');
$d='28';
$w->setDataFromPost($data);
ok($w->isDataValid(),'valid');
is_deeply($w->getData(),{y=>2005,m=>2,d=>28},'value');
unlike($w->form(),qr{\bdata non valida\b},'errore non mostrato');
