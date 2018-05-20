#!/usr/bin/perl
use lib 'src';
require 'reporto.pl';

my $reporto = &Reporto("Argentina","SAP",{'desde' => "03/11/2007",'hasta' => "03/11/2008"});

if($reporto->{'sistemaValido?'}()){
    print("El sistema se encuentra inicializado correctamente, se prosigue....\n")
}else{
    print("El sistema no se encuentra inicializado correctamente!\n")
}