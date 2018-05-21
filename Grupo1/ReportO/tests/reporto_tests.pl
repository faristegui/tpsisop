#!/usr/bin/perl
use diagnostics; 
use warnings;   
use strict;
use v5.18;
use Test::More qw( no_plan ); # for the is() and isnt() functions
require 'runner/tests_runner.pl';

#-----Import here things to test-----
    use lib 'src';
    require 'reporto.pl';
# -----------------------------------

# assertion subrutines 
#   is(actual,expected,err_msg)
#   isnt(actual,expected,err_msg)

my $reporto = undef;

sub before {
  $reporto = &Reporto();
  # putsVariablesDeAmbiente();
}

my $tests = {
    'debeObtenerElNombreDelaClase' => sub {
        is($reporto->{'clase'}(),"ReportO");
    },
    'debeEncontrarUnSistemaValido' => sub {
        is($reporto->{'sistemaValido?'}(), 1);
    },
    'debeEncontrarUnSistemaNoValido' => sub {
        my $vm = $ENV{'ARCHIVO_MAESTRO_DIR'};
        $ENV{'ARCHIVO_MAESTRO_DIR'} = "";
        is($reporto->{'sistemaValido?'}(), 0);
        $ENV{'ARCHIVO_MAESTRO_DIR'} = $vm;
    },
    'debeFiltrarArchivoMaestroPorSistema' => sub {
        my @maestro = $reporto->{'archivoMaestro'}();
        #$reporto->{'putsLdL'}(@maestro);
        my @maestroFiltrado = $reporto->{'filtrarPorSistema'}(\@maestro, "A");
        ok(scalar(@maestroFiltrado) <= scalar(@maestro));
    }
};

sub after {
    print "Finished testing reporto.pl\n"; 
}

before();
runTests($tests);
after();
return 1
