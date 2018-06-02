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
        'archivoMaestroPPI' => sub {
            my $maestro_path = $ENV{'MAESTROS'} . "/PPI.mae";
            if(defined($maestro_path) && $maestro_path ne ""){
               my @maestro = readCSV({'path' => $maestro_path, 'separador' => ';'});
               return @maestro;
            }else{
                die "El directorio 'maestros' esta indefinido, chequee las variables de ambiente\n";
            }
        },
        'archivosProcesadosPais' => sub {
            my ($pais) = @_;
            my $procesados_path = $ENV{'PROCESADOS'} . "/*.$pais";
            my @procesados = ();
            if(defined($procesados_path) && $procesados_path ne ""){
                foreach $archivo (glob $procesados_path) {
                   my @procesado = readCSV({'path' => $archivo , 'separador' => ';'});
                   push(@procesados,@procesado);
                }
                return @procesados;
            }else{
                die "El directorio 'procesados' esta indefinido, chequee las variables de ambiente\n";
            }
        },
        'comparar' => sub {
            my @maestro = @{$_[0]};
            my @prestamos_pais = @{$_[1]};
            my @comparaciones = ();
            foreach my $reg_maestro (@maestro) {
                s/,/./g for @$reg_maestro;
                # print("reg_maestro\n");
                # putsLista(@$reg_maestro);
                my $monto_restante_maestro = @$reg_maestro[9] + @$reg_maestro[10] + @$reg_maestro[11] + @$reg_maestro[12];
                # print("Monto restante maestro: $monto_restante_maestro\n");
                foreach my $reg_prestamos_pais (@prestamos_pais) {
                    s/,/./g for @$reg_prestamos_pais;
                    my $a = @$reg_maestro[3];
                    my $b = @$reg_prestamos_pais[2];
                    if((@$reg_maestro[7] eq @$reg_prestamos_pais[5]) && (@$reg_maestro[2] eq @$reg_prestamos_pais[1]) && (@$reg_maestro[3] eq @$reg_prestamos_pais[2])){
                        # print("reg_prestamos\n");
                        # putsLista(@$reg_prestamos_pais);
                        my $monto_restante_prestamos_pais = @$reg_prestamos_pais[5] + @$reg_prestamos_pais[7] + @$reg_prestamos_pais[8] + @$reg_prestamos_pais[9];
                        # print("Monto restante prestamos: $monto_restante_prestamos_pais\n");
                        my $diff_montos = $monto_restante_maestro - $monto_restante_prestamos_pais;
                        if((@$reg_maestro[5] eq "SMOR") && (@$reg_prestamos_pais[4] ne "SMOR")){
                            my $recomendacion = "RECAL";
                            my @comparacion = (@$reg_maestro[0],@$reg_maestro[1],@$reg_maestro[7],$recomendacion,@$reg_maestro[5],@$reg_prestamos_pais[4],$monto_restante_maestro,$monto_restante_prestamos_pais,$diff_montos,@$reg_maestro[2],@$reg_maestro[3],@$reg_maestro[4],@$reg_prestamos_pais[3]);
                            # putsLista(@comparacion);
                            push(@comparaciones,[@comparacion]);
                        }elsif($monto_restante_maestro < $monto_restante_prestamos_pais){
                            my $recomendacion = "RECAL";                        
                            my @comparacion = (@$reg_maestro[0],@$reg_maestro[1],@$reg_maestro[7],$recomendacion,@$reg_maestro[5],@$reg_prestamos_pais[4],$monto_restante_maestro,$monto_restante_prestamos_pais,$diff_montos,@$reg_maestro[2],@$reg_maestro[3],@$reg_maestro[4],@$reg_prestamos_pais[3]);
                            # putsLista(@comparacion);                                
                            push(@comparaciones,[@comparacion]);
                        }else{
                            my $recomendacion = "NO-RECAL";
                            my @comparacion = (@$reg_maestro[0],@$reg_maestro[1],@$reg_maestro[7],$recomendacion,@$reg_maestro[5],@$reg_prestamos_pais[4],$monto_restante_maestro,$monto_restante_prestamos_pais,$diff_montos,@$reg_maestro[2],@$reg_maestro[3],@$reg_maestro[4],@$reg_prestamos_pais[3]);
                            # putsLista(@comparacion);                            
                            push(@comparaciones,[@comparacion]);
                        }
                        last;
                    }
                }
            }
            return @comparaciones;
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