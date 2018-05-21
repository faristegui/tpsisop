#!/usr/bin/perl
use lib 'src';
require 'reporto.pl';

my ($opcion,$pais, $sistema,$desde,$hasta) = @ARGV;
my $reporto = &Reporto();

system("clear");

if(($#ARGV + 1) == 0){
    useReporto(0);
}elsif(defined($opcion) && $opcion eq '-a' && ($#ARGV + 1) >= 1){
    print("AYUDA!\n");
}elsif(defined($opcion) && $opcion eq '-g' && ($#ARGV + 1) >= 1){
    useReporto(1);
}

sub menu {
    my ($modo) = @_;
    print("-------------------------------------\n");
    print(" [1] Recomendacion\n");
    print(" [2] Divergencia % \n");
    print(" [3] Divergencia \$ \n");
    print(" [9] Limpiar consola\n");
    print(" [0] Salir \n");
    print("-------------------------------------\n");
    my $opcion = <STDIN>;
    if($opcion == 1){
        system("clear");
        recomendacion();        
        menu($modo);
    }elsif($opcion == 2){
        system("clear");
        divergenciaEnPorcentaje();
        menu($modo);
    }elsif($opcion == 3){
        system("clear");
        divergenciaEnPesos();
        menu($modo);
    }elsif($opcion == 9){
        system("clear");
        menu($modo);
    }elsif($opcion == 0){
        system("clear");
        exit;
    }else{
        print("Comando Invalido!\n");
        menu($modo)
    }
}

sub useReporto {
    my($guardar) = @_;
    if($reporto->{'sistemaValido?'}()){
        if($guardar){   
            print("Corriendo reportO en modo GUARDAR...\n");
            menu($guardar);
        }else{
            menu($guardar);
            print("Corriendo reportO...\n");
        }
    }else{
        print("El sistema no se encuentra inicializado correctamente!\n");
        putsVariablesDeAmbiente();
    }
}


sub recomendacion {
    print("-> Se ha elegido la opcion 'Recomendacion'\n");
}

sub divergenciaEnPorcentaje {
    print("-> Se ha elegido la opcion 'Divergencia %'\n");
}

sub divergenciaEnPesos {
     print("-> Se ha elegido la opcion 'Divergencia \$'\n");
}