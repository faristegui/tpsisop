#!/usr/bin/perl
use lib 'src';
require 'reporto.pl';

my ($opcion,$pais, $sistema,$desde,$hasta) = @ARGV;
my $reporto = &Reporto();

system("clear");

if(($#ARGV + 1) == 0){
    useReporto(0);
}elsif(defined($opcion) && $opcion eq '-a' && ($#ARGV + 1) >= 1){
   ayuda();
}elsif(defined($opcion) && $opcion eq '-g' && ($#ARGV + 1) >= 1){
    useReporto(1);
}

sub ayuda {
     print("\n");
     print(" USO:   ./start.pl -[opcion] [pais] [sistema] [desde] [hasta]\n");
     print("\n");
     print(" opcion:\n");
     print("    a: Imprime este mensaje de ayuda.\n");
     print("    g: Pone a ReportO en modo 'guardar'.\n");
     print("\n");
     print(" params:\n");
     print("    [pais]:      Indica por cual pais filtrar.\n");
     print("    [sistema]:   Indica por cual sistema filtrar.\n");
     print("    [desde]:     Indica el inicio del rango de fechas por el cual filtrar.\n");
     print("    [hasta]:     Indica el fin del rango de fechas por el cual filtrar.\n");
     print("\n\n");
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
        system("clear");
        print("-> Comando Invalido!\n");
        menu($modo)
    }
}

sub useReporto {
    my($guardar) = @_;
    if($reporto->{'sistemaValido?'}()){
        @maestroFiltrado = filtrarMaestro($pais,$sistema,$desde,$hasta);
        putsLdL(@maestroFiltrado);
        if($guardar){   
            print("Corriendo reportO en modo 'guardar'...\n");
            menu($guardar);
        }else{
            print("Corriendo reportO...\n");
            menu($guardar);
        }
    }else{
        print("------------------------------------------------------\n");
        print("El sistema no se encuentra inicializado correctamente!\n");
        print("------------------------------------------------------\n");
        putsVariablesDeAmbiente();
    }
}

sub filtrarMaestro {
    my ($pais,$sistema,$desde,$hasta) = @_;
    @maestro = $reporto->{'archivoMaestro'}();
    if(defined($pais)){
        @maestro = $reporto->{'filtrarPorPaisDistinto'}(\@maestro, $pais);
    }
    if(defined($sistema)){
        @maestro = $reporto->{'filtrarPorSistemaDistinto'}(\@maestro, $sistema);
    }
    if(defined($desde) && defined($hasta)){
        @maestro = $reporto->{'filtrarPorNoEnRangoDeFechas'}(\@maestro, {'desde' => fromStringAFecha($desde),'hasta' => fromStringAFecha($hasta)});
    }
    return @maestro;
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