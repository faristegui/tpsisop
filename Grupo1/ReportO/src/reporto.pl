use Text::CSV;

sub Reporto {
    my ($pais,$sistema,$rango) = @_;
    sub readCSV {
        my ($path,$separator) = @_;
        my $csv_parser = Text::CSV->new({ sep_char => ',' });
        open(my $data, '<', $path) or die "No se pudo leer archivo' $path'\n";
        my @lista = ();
        while (my $linea = <$data>) {
            chomp $linea;
            if ($csv_parser->parse($linea)) {
                my @campos = $csv_parser->fields();
                push(@lista,@campos);
            }else{
                warn "Una linea del archivo no pudo ser parseada: $linea\n";
            }
        }
        return @lista;
    }
    my $self = {
        'clase' => sub { 'ReportO' },
        'pais' => sub { $pais },
        'sistema' => sub { $sistema },
        'rango' => sub { $rango },
        'sistemaValido?' => sub {
            $vm = $ENV{'VM'}; 
            if(!($vm eq "")){
                return 1;
            }else{
                return 0;
            }
        },
        'archivoMaestro' => sub {
            my $maestro_path = $ENV{'ARCHIVO_MAESTRO_DIR'};
            if(defined($maestro_path)){
               my @maestro = readCSV($maestro_path,',');
               return @maestro;
            }else{
                die "El archivo maestro esta indefinido, chequee las variables de ambiente\n";
            }
        },
        'filtrar' => sub { #Espera un array de lineas
            my @contenido = @{$_[0]};
            return @contenido;
        },
        'imprimirVariablesDeAmbiente' => sub {
            foreach (sort keys %ENV) { 
                print "$_  =  $ENV{$_}\n"; 
            }
        }
    };
    return $self;
}

return 1