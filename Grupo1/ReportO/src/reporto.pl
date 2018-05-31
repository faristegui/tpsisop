sub Reporto {
    sub readCSV {
        my ($params) = @_;
        my $path = $params->{'path'};
        open(my $data, '<', $path) or die "No se pudo leer archivo: $path'\n";
        my @lista = ();
        my $conteoLineasNoParseadas = 0;
        while (my $linea = <$data>) {
            chomp($linea);
            my @campos = split($params->{'separador'},$linea);
            push(@lista,[@campos]);
        }
        close($data);
        return @lista;
    }
    sub filtrarLdL {
        my ($params) = @_;
        my @filtrado = ();
        foreach my $lista (@{$params->{'ldl'}}) {
            if(!($params->{'criteria'}(@$lista[$params->{'numeroDeCampo'}]))) {
                push(@filtrado,[@$lista]);
            }
        }
        return @filtrado;
    }
    my $self = {
        'clase' => sub { 'ReportO' },
        'sistemaValido?' => sub {
            my $maestro_path = $ENV{'MAESTROS'};
            my $ejecutables_path = $ENV{'EJECUTABLES'};
            my $novedades_path = $ENV{'NOVEDADES'};
            my $aceptados_path = $ENV{'ACEPTADOS'};   
            my $rechazados_path = $ENV{'RECHAZADOS'};    
            my $procesados_path = $ENV{'PROCESADOS'};
            my $reportes_path = $ENV{'REPORTES'};
            my $logs_path = $ENV{'LOGS'};     
            if(defined($maestro_path) && defined($ejecutables_path) && defined($novedades_path) && defined($aceptados_path) && defined($rechazados_path) && defined($procesados_path) && defined($reportes_path) && defined($logs_path)){
                return 1;
            }else{
                return 0;
            }
        },
        'archivoMaestro' => sub {
            my $maestro_path = $ENV{'MAESTROS'};
            if(defined($maestro_path) && $maestro_path ne ""){
               my @maestro = readCSV({'path' => $maestro_path, 'separador' => ';'});
               return @maestro;
            }else{
                die "El directorio 'maestros' esta indefinido, chequee las variables de ambiente\n";
            }
        },
        'archivosProcesadosPais' => sub {
            my ($pais) = @_;
            my $procesados_path = $ENV{'PROCESADOS'};
            my @procesados = ();
            if(defined($maestro_path) && $maestro_path ne ""){
                $archivos = $procesados_path . "/*.$pais";
                foreach $archivo (<$archivos>) {
                   my @procesado = readCSV({'path' => $procesados_path . "/" . $archivo , 'separador' => ';'});
                   push(@procesados,@procesado);
                }
                return @procesados;
            }else{
                die "El directorio 'procesados' esta indefinido, chequee las variables de ambiente\n";
            }
        },
        'filtrarPorSistemaDistinto' => sub {
            my ($ldl,$filtro_value) = @_;
            my @filtradoPorSistema = filtrarLdL({
                'ldl' => $ldl,
                'numeroDeCampo' => 1,
                'criteria' => sub {
                    my ($sistema) = @_;
                    if($sistema ne $filtro_value){
                        return 1;
                    }else{
                        return 0;
                    }
                }
            });
            return @filtradoPorSistema;
        },
        'filtrarPorPaisDistinto' => sub {
            my ($ldl,$filtro_value) = @_;
            my @filtradoPorSistema = filtrarLdL({
                'ldl' => $ldl,
                'numeroDeCampo' => 0,
                'criteria' => sub {
                    my ($pais) = @_;
                    if($pais ne $filtro_value){
                        return 1;
                    }else{
                        return 0;
                    }
                }
            });
            return @filtradoPorSistema;
        },
        'filtrarPorNoEnRangoDeFechas' => sub {
            my ($ldl,$rango) = @_;
            my @filtradoPorSistema = filtrarLdL({
                'ldl' => $ldl,
                'numeroDeCampo' => 6,
                'criteria' => sub {
                    my ($fecha_string) = @_;
                    my $fecha = fromStringAFecha($fecha_string);
                    my $cmpDesde = DateTime->compare($fecha, $rango->{'desde'});
                    my $cmpHasta = DateTime->compare($fecha, $rango->{'hasta'});
                    if(!($cmpDesde >= 0 && $cmpHasta <= 0)){
                        return 1;
                    }else{
                        return 0;
                    }
                }
            });
            return @filtradoPorSistema;
        }                
    };
    return $self;
}

sub putsVariablesDeAmbiente { 
    foreach (sort keys %ENV) { 
        print "$_  =  $ENV{$_}\n"; 
    }
}

sub fromStringAFecha {
    my ($string) = @_;
    my ($dia,$mes,$anio) = split('/',$string);
    my $fecha = DateTime->new( year => $anio, month => $mes, day => $dia); 
    return $fecha;
}

sub putsLista {
    my (@lista) = @_;
    foreach my $elem (@lista) {
        print " ($elem)";
    }
    print "\n";
}

sub putsLdL {
    my (@lista_de_listas) = @_;
    foreach my $lista (@lista_de_listas) {
        print " List:";
        foreach my $elem (@$lista) {
            print " ($elem)";
        }
        print "\n ";
    }
}

return 1