#!/usr/bin/perl
use diagnostics; 
use warnings;   
use strict;
use DateTime;
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
        # putsLdL(@maestro);
        my @maestroFiltrado = $reporto->{'filtrarPorSistemaDistinto'}(\@maestro, "6");
        # print("------------------------------------------------------------------\n");
        # putsLdL(@maestroFiltrado);
        ok(scalar(@maestroFiltrado) <= scalar(@maestro));
    },
    'debeFiltrarArchivoMaestroPorPais' => sub {
        my @maestro = $reporto->{'archivoMaestro'}();
        # putsLdL(@maestro);
        my @maestroFiltrado = $reporto->{'filtrarPorPaisDistinto'}(\@maestro, "A");
        # print("------------------------------------------------------------------\n");
        # putsLdL(@maestroFiltrado);
        ok(scalar(@maestroFiltrado) <= scalar(@maestro));
    },
    'debeFiltrarArchivoMaestroNoEnRangoDeFechas' => sub {
        my @maestro = $reporto->{'archivoMaestro'}();
        # putsLdL(@maestro);
        my @maestroFiltrado = $reporto->{'filtrarPorNoEnRangoDeFechas'}(\@maestro, {'desde' => fromStringAFecha("03/11/2007"),'hasta' => fromStringAFecha("29/08/2008")});
        # print("------------------------------------------------------------------\n");
        # putsLdL(@maestroFiltrado);
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
