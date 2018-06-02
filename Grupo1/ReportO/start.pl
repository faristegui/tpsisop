#!/usr/bin/perl
use lib 'src';
require 'reporto.pl';

my ($opcion,$pais, $sistema,$desde,$hasta) = @ARGV;
my $reporto = &Reporto();
system("clear");

if(!defined($pais)){
   print("Por favor defina un pais\n");
   exit;
}

if(!defined($sistema)){
   print("Por favor defina un sistemab\n");
   exit;
}

if(defined($opcion) && $opcion eq '-a' && ($#ARGV + 1) >= 1){
   ayuda();
}elsif(defined($opcion) && $opcion eq '-g' && ($#ARGV + 1) >= 1){
    useReporto(1);
}else{
    useReporto(0);
}

sub ayuda {
     print("\n");
     print(" USO:   ./start.pl -[opcion] [pais]* [sistema]* ([desde] [hasta])\n");
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
    my ($guardar) = @_;
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
        @resultado = recomendacion();  
        if($guardar){

        }else{
            putsLdL(@resultado);
        }      
        menu($guardar);
    }elsif($opcion == 2){
        system("clear");
        divergenciaEnPorcentaje();
        menu($guardar);
    }elsif($opcion == 3){
        system("clear");
        divergenciaEnPesos();
        menu($guardar);
    }elsif($opcion == 9){
        system("clear");
        menu($guardar);
    }elsif($opcion =~ "[0-9]" && $opcion == 0){
        system("clear");
        exit;
    }else{
        system("clear");
        print("-> Comando Invalido!\n");
        menu($guardar);
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
        print(" El sistema no se encuentra inicializado correctamente!\n");
        print("------------------------------------------------------\n");
        putsVariablesDeAmbiente();
    }
}

sub filtrarMaestro {
    my ($pais,$sistema,$desde,$hasta) = @_;
    my @maestro = $reporto->{'archivoMaestroPPI'}();
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
    my @procesados = $reporto->{'archivosProcesadosPais'}($pais);
    my @comparaciones = $reporto->{'comparar'}(\@maestroFiltrado,\@procesados);
    return @comparaciones;
}

sub divergenciaEnPorcentaje {
    print("-> Se ha elegido la opcion 'Divergencia %'\n");
}

sub divergenciaEnPesos {
     print("-> Se ha elegido la opcion 'Divergencia \$'\n");
}