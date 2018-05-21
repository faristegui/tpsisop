sub Reporto {
    sub readCSV {
        my ($params) = @_;
        my $path = $params->{'path'};
        open(my $data, '<', $path) or die "No se pudo leer archivo: $path'\n";
        my @lista = ();
        my $conteoLineasNoParseadas = 0;
        while (my $linea = <$data>) {
            chomp($linea);
            my @campos = split($params->{'separator'},$linea);
            push(@lista,[@campos]);
        }
        close($data);
        return @lista;
    }
    sub filtrarLdL {
        my ($params) = @_;
        my @filtrado = ();

        #putsLdL(@{$params->{'ldl'}});
        foreach my $lista (@{$params->{'ldl'}}) {
            if($params->{'criteria'}(@$lista[$params->{'numeroDeCampo'}])) {
                push(@filtrado,[@$lista]);
            }
        }
        #putsLdL(@filtrado);
        return @filtrado;
    }
    my $self = {
        'clase' => sub { 'ReportO' },
        'sistemaValido?' => sub {
            $vm = $ENV{'ARCHIVO_MAESTRO_DIR'}; 
            if(!($vm eq "")){
                return 1;
            }else{
                return 0;
            }
        },
        'archivoMaestro' => sub {
            my $maestro_path = $ENV{'ARCHIVO_MAESTRO_DIR'};
            if(defined($maestro_path)){
               my @maestro = readCSV({'path' => $maestro_path, 'separator' => ';'});
               return @maestro;
            }else{
                die "El archivo maestro esta indefinido, chequee las variables de ambiente\n";
            }
        },
        'filtrarPorSistema' => sub { #Espera una lista de listas
            my ($ldl,$filtro) = @_;
            my @filtradoPorSistema = filtrarLdL({
                'ldl' => $ldl,
                'numeroDeCampo' => 0,
                'criteria' => sub {
                    my ($sistema) = @_;
                    if($sistema eq $filtro){
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