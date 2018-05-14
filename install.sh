parametro=$1

log() {
    echo [$(date "+%Y-%m-%d %H:%M")]"$USER-$PWD-$@" >> "logFile.log"
}

crearConfig()
{
	dirActual=$PWD
	echo "ejecutables-$dirActual/$dirEjecutables-$USER-"[$(date "+%Y-%m-%d %H:%M")] >> "instalacion.config"
	echo "maestros-$dirActual/$dirMaestros-$USER-"[$(date "+%Y-%m-%d %H:%M")] >> "instalacion.config"
	echo "entrada-$dirActual/$dirEntrada-$USER-"[$(date "+%Y-%m-%d %H:%M")] >> "instalacion.config"
	echo "aceptados-$dirActual/$dirNovedadesAceptadas-$USER-"[$(date "+%Y-%m-%d %H:%M")] >> "instalacion.config"
	echo "rechazados-$dirActual/$dirRechazados-$USER-"[$(date "+%Y-%m-%d %H:%M")] >> "instalacion.config"
	echo "procesados-$dirActual/$dirProcesados-$USER-"[$(date "+%Y-%m-%d %H:%M")] >> "instalacion.config"
	echo "reportes-$dirActual/$dirReportes-$USER-"[$(date "+%Y-%m-%d %H:%M")] >> "instalacion.config"
	echo "logs-$dirActual/$dirLogs-$USER-"[$(date "+%Y-%m-%d %H:%M")] >> "instalacion.config"
	log "CreadoArchivoConfig"
}

crearDirectorios()
{
	command clear
	echo -e "Creando directorios de instalación...\n"
	mkdir "dirconf"
	log "CreadoDirectorio-dirconfig"
	echo -e "Creando directorios de configuración...\n"
	mkdir "InstallFiles"
	log "CreadoDirectorio-InstallFiles-Backup"
	echo -e "Creando directorios de backup...\n"
	mkdir $dirEjecutables
	log "CreadoDirectorioEjecutables-$dirEjecutables"
	echo -e "Creando directorios de ejecutables...\n"
	mkdir $dirMaestros
	log "CreadoDirectorio-ArchivosMaestros-$dirMaestros"
	echo -e "Creando directorios de archivos maestros...\n"
	mkdir $dirEntrada
	log "CreadoDirectorio-ArchivosDeEntrada-$dirEntrada"
	echo -e "Creando directorios de archivos de entrada...\n"
	mkdir $dirNovedadesAceptadas
	log "CreadoDirectorio-ArchivoDeNovedadesAceptadas-$dirNovedadesAceptadas"
	echo -e "Creando directorios de archivos de novedades aceptadas...\n"
	mkdir $dirRechazados
	log "CreadoDirectorio-ArchivosRechazados-$dirRechazados"
	echo -e "Creando directorios de archivos rechazados...\n"
	mkdir $dirProcesados
	log "CreadoDirectorio-ArchivosProcesados-$dirProcesados"
	echo -e "Creando directorios de archivos procesados...\n"
	mkdir $dirReportes
	log "CreadoDirectorio-ArchivosDeReporte-$dirReportes"
	echo -e "Creando directorios de archivos de reporte...\n"
	mkdir $dirLogs
	log "CreadoDirectorio-ArchivosDeLog-$dirLogs"
	echo -e "Creando directorios de Log...\n"
}

moverArchivos()
{
#Copio los archivos en la carpeta correspondiente
	cp -f PPI.mae $dirMaestros/PPI.mae
	log "Copiado-ArchivoMaestroPPI"
	cp -f p-s.mae $dirMaestros/p-s.mae
	log "Copiado-ArchivoMaestroPS"
	cp -f T1.tab $dirMaestros/T1.tab
	log "Copiado-ArchivoMaestroT1"
	cp -f T2.tab $dirMaestros/T2.tab
	log "Copiado-ArchivoMaestroT2"
#Muevo los archivos de instalación a la carpeta de backup

	mv -f PPI.mae InstallFiles/PPI.mae
	log "Movido-ArchivoMaestroPPI"
	mv -f p-s.mae InstallFiles/p-s.mae
	log "Movido-ArchivoMaestroPS"
	mv -f T1.tab InstallFiles/T1.tab
	log "Movido-ArchivoMaestroT1"
	mv -f T2.tab InstallFiles/T2.tab
	log "Movido-ArchivoMaestroT2"
}

modoReparacion()
{
	echo "Iniciando instalador en modo reparación..."

	# Existe instalación previa. Hay que borrar todos los directorios
		echo "Reparacion finalizada"
#	else
		echo "No se ha encontrado una instalación previa."
#	fi
}

validarPerl()
{
	#VALIDO SI PERL ESTA INSTALADO EN EL SISTEMA
	VALOR=$(command -v perl)
	if [ ! -z "$VALOR" -a "$VALOR" != " " ]; then
		echo "Perl está correctamente instalado."
		Version=$(perl -v | grep 'This is perl' | sed "s/This is perl \([0-9]\),.*/\1/")
		if (($Version >= 5)); then
			echo "Version de Perl: $Version"
		fi
	else
		echo "Ha ocurrido un error. Es necesaria una instalación de Perl 5 o superior para continuar."
		exit 1
	fi
}

validarDirectorio()
{
	dirconf=true
	if [ "$auxDir" = "$dirConfiguracion" ]
	then
		echo -e "El nombre dirconf es un nombre reservado. (Se utilizara el nombre asignado por defecto)\n"
		dirconf=false
	fi
}

instalacion()
{
	command clear
	echo -e "\n\n\n************* Bienvenido a la instalación de CONTROL-O.*************\n\n\n"
	echo -e "Durante la instalación deberá configurar nombres de directorios necesarios para la configuración del sistema.\n(Presionar enter para elegir el valor por defecto)"

	echo -e "\nIngrese el nombre del directorio para los archivos ejecutables (Ej: ../$dirEjecutables): "
	read auxDir
	validarDirectorio
	log "SolicitaDirectorioEjecutables-Resp-$auxDir"
	if [ "$auxDir" != "" ] && [ "$dirconf" != "false" ]
	then
		dirEjecutables=$auxDir
	fi

	echo -e "\nIngrese el nombre del directorio para los archivos maestros o tablas del sistema (Ej: ../$dirMaestros): "
	read auxDir
	validarDirectorio
	log "SolicitaDirectorioEjecutables-Resp-$auxDir"
	if [ "$auxDir" != "" ] && [ "$dirconf" != "false" ]
	then
		dirMaestros=$auxDir 
	fi

	echo -e "\nIngrese el nombre del directorio para los archivos externos o de entrada (Ej: ../$dirEntrada): "
	read auxDir
	validarDirectorio
	log "SolicitaDirectorioEjecutables-Resp-$auxDir"
	if [ "$auxDir" != "" ] && [ "$dirconf" != "false" ]
	then
		dirEntrada=$auxDir 
	fi

	echo -e "\nIngrese el nombre del directorio para los archivos de novedades aceptadas (Ej: ../$dirNovedadesAceptadas): "
	read auxDir
	validarDirectorio
	log "SolicitaDirectorioEjecutables-Resp-$auxDir"
	if [ "$auxDir" != "" ] && [ "$dirconf" != "false" ]
	then
		dirNovedadesAceptadas=$auxDir 
	fi

	echo -e "\nIngrese el nombre del directorio para los archivos rechazados (Ej: ../$dirRechazados): "
	read auxDir
	validarDirectorio
	log "SolicitaDirectorioEjecutables-Resp-$auxDir"
	if [ "$auxDir" != "" ] && [ "$dirconf" != "false" ]
	then
		dirRechazados=$auxDir 
	fi

	echo -e "\nIngrese el nombre del directorio para los archivos procesados (Ej: ../$dirProcesados): "
	read auxDir
	validarDirectorio
	log "SolicitaDirectorioEjecutables-Resp-$auxDir"
	if [ "$auxDir" != "" ] && [ "$dirconf" != "false" ]
	then
		dirProcesados=$auxDir 
	fi

	echo -e "\nIngrese el nombre del directorio para los archivos de reportes (Ej: ../$dirReportes): "
	read auxDir
	validarDirectorio
	log "SolicitaDirectorioEjecutables-Resp-$auxDir"
	if [ "$auxDir" != "" ] && [ "$dirconf" != "false" ]
	then
		dirReportes=$auxDir 
	fi

	echo -e "\nIngrese el nombre del directorio para los archivos de log (Ej: ../$dirLogs): "
	read auxDir
	validarDirectorio
	log "SolicitaDirectorioEjecutables-Resp-$auxDir"
	if [ "$auxDir" != "" ]
	then
		dirLogs=$auxDir 
	fi

	dirConfiguracion="dirconf"

	command clear

	echo -e "\n\n"
	echo "*************************************************************"
	echo "********************* INSTALACIÓN LISTA *********************"
	echo "*************************************************************"

	echo -e "Listado de directorios: \n"

	echo -e "Configuración: /$dirConfiguracion \n"

	echo -e "Archivos ejecutables: /$dirEjecutables \n"

	echo -e "Archivos maestros o tablas del sistema: /$dirMaestros \n"

	echo -e "Archivos externos o de entrada: /$dirEntrada \n"

	echo -e "Archivos de novedades aceptadas: /$dirNovedadesAceptadas \n"

	echo -e "Archivos rechazados: /$dirRechazados \n"

	echo -e "Archivos procesados: /$dirProcesados \n"

	echo -e "Archivos de reportes: /$dirReportes \n"

	echo -e "Archivos de log: /$dirLogs \n"

	echo "*************************************************************"

	echo -e "\nSu instalación está lista. ¿Confirma la instalación? (S/N): "
	read confirma

	while [ [ "$confirma" != "S" ] || [ "$confirma" != "s" ] ]
	do
		log "-ConfirmaInstalacion-Resp-NO"
		echo -e "\nInstalación cancelada...\n"
		instalacion
	done

	log "ConfirmaInstalacion-Resp-SI"
	
	crearDirectorios
	moverArchivos
	crearConfig

	echo "Instalación finalizada."
}

#PROGRAMA PRINCIPAL

if [ "$parametro" = "-r" ]
then
	modoReparacion
else
	validarPerl
	# Seteo nombres de directorios por default
	dirEjecutables="bin"
	dirMaestros="maestro"
	dirEntrada="recibidos"
	dirNovedadesAceptadas="novedades"
	dirRechazados="rechazados"
	dirProcesados="procesados"
	dirReportes="reportes"
	dirLogs="log"
	dirConfiguracion="dirconf"

	if [ -f "dirconf/configuracion.conf" ]
	then 
		#Existe una instalación
		echo -e "Existe una instalación previa. ¿Que desea hacer? \n 1- Reparar la instalación. \n2- Instalar nuevamente"
		read opcion
		if [ "$opcion" = "1" ]
		then
			log "-IniciadoModoReparacion"
			modoReparacion
		else
			instalacion
		fi
	else
		instalacion
	fi
	mv -f instalacion.config dirconf/instalacion.config
	log "MovidoArchivoConfig"
	mv -f logFile.log $dirLogs/logFile.log
fi