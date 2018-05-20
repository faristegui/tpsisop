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
  $reporto = &Reporto("Argentina","SAP",{'desde' => "03/11/2007",'hasta' => "03/11/2008"});
  # $reporto->{'imprimirVariablesDeAmbiente'}();
}

my $tests = {
    'debeObtenerElNombreDelaClase' => sub {
        is($reporto->{'clase'}(),"ReportO");
    },
    'debeObtenerElPais' => sub {
        is($reporto->{'pais'}(),"Argentina");
    },    
    'debeObtenerElSistema' => sub {
        is($reporto->{'sistema'}(),"SAP");
    }, 
    'debeObtenerElRangoDesde' => sub {
        my $rango = $reporto->{'rango'}();
        is($rango->{'desde'},"03/11/2007");
    },
    'debeObtenerElRangoHasta' => sub {
        my $rango = $reporto->{'rango'}();
        is($rango->{'hasta'},"03/11/2008");
    },
    'debeEncontrarUnSistemaValido' => sub {
        is($reporto->{'sistemaValido?'}(), 1);
    },
    'debeEncontrarUnSistemaNoValido' => sub {
        my $vm = $ENV{'VM'};
        $ENV{'VM'} = "";
        is($reporto->{'sistemaValido?'}(), 0);
        $ENV{'VM'} = $vm;
    }#,
    # 'debeFiltrarArchivoMaestro' => sub {
    #     my @maestro = $reporto->{'archivoMaestro'}();
    #     my @maestroFiltrado = $reporto->{'filtrar'}(\@maestro);
    #     ok(scalar(@maestroFiltrado) <= scalar(@maestro));
    # }
};

sub after {
    print "Finished testing reporto.pl\n"; 
}

before();
runTests($tests);
after();
return 1
