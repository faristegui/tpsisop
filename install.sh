#! /usr/bin/env bash

parametro=$1
#ruta=$(pwd)
GRUPO=$PWD

log() {
    echo "$GRUPO-$USER-$@-"[$(date "+%Y-%m-%d %H:%M")] >> "logFile.log"
}

crearConfig()
{
	dirActual=$GRUPO
	echo "ejecutables-$dirActual/$dirEjecutables-$USER-"[$(date "+%Y-%m-%d %H:%M")] >> "instalacion.config"
	echo "maestros-$dirActual/$dirMaestros-$USER-"[$(date "+%Y-%m-%d %H:%M")] >> "instalacion.config"
	echo "entrada-$dirActual/$dirEntrada-$USER-"[$(date "+%Y-%m-%d %H:%M")] >> "instalacion.config"
	echo "aceptados-$dirActual/$dirNovedadesAceptadas-$USER-"[$(date "+%Y-%m-%d %H:%M")] >> "instalacion.config"
	echo "rechazados-$dirActual/$dirRechazados-$USER-"[$(date "+%Y-%m-%d %H:%M")] >> "instalacion.config"
	echo "procesados-$dirActual/$dirProcesados-$USER-"[$(date "+%Y-%m-%d %H:%M")] >> "instalacion.config"
	echo "reportes-$dirActual/$dirReportes-$USER-"[$(date "+%Y-%m-%d %H:%M")] >> "instalacion.config"
	echo "logs-$dirActual/$dirLogs-$USER-"[$(date "+%Y-%m-%d %H:%M")] >> "instalacion.config"
	log "Creado Archivo Config"
}

crearDirectorios()
{
	echo -e "Creando directorios de instalación...\n"
	mkdir "dirconf"
	log "Creado Directorio-dirconfig"
	echo -e "Creando directorios de configuración...\n"
	mkdir "InstallFiles"
	log "Creado Directorio InstallFiles (Backup)"
	echo -e "Creando directorios de backup...\n"
	mkdir $dirEjecutables
	log "Creado Directorio Ejecutables /$dirEjecutables"
	echo -e "Creando directorios de ejecutables...\n"
	mkdir $dirMaestros
	log "Creado Directorio Archivos Maestros /$dirMaestros"
	echo -e "Creando directorios de archivos maestros...\n"
	mkdir $dirEntrada
	log "Creado Directorio Archivos De Entrada /$dirEntrada"
	echo -e "Creando directorios de archivos de entrada...\n"
	mkdir $dirNovedadesAceptadas
	log "Creado Directorio Archivo De Novedades Aceptadas /$dirNovedadesAceptadas"
	echo -e "Creando directorios de archivos de novedades aceptadas...\n"
	mkdir $dirRechazados
	log "Creado Directorio Archivos Rechazados /$dirRechazados"
	echo -e "Creando directorios de archivos rechazados...\n"
	mkdir $dirProcesados
	log "Creado Directorio Archivos Procesados /$dirProcesados"
	echo -e "Creando directorios de archivos procesados...\n"
	mkdir $dirReportes
	log "Creado Directorio Archivos De Reporte /$dirReportes"
	echo -e "Creando directorios de archivos de reporte...\n"
	mkdir $dirLogs
	log "Creado Directorio Archivos De Log /$dirLogs"
	echo -e "Creando directorios de Log...\n"
}

moverArchivos()
{
#Copio los archivos en la carpeta correspondiente
	cp -f PPI.mae $dirMaestros/PPI.mae
	log "Copiado Archivo Maestro PPI.mae"
	cp -f p-s.mae $dirMaestros/p-s.mae
	log "Copiado Archivo Maestro P-S.mae"
	cp -f T1.tab $dirMaestros/T1.tab
	log "Copiado Archivo Maestro T1.tab"
	cp -f T2.tab $dirMaestros/T2.tab
	log "Copiado Archivo Maestro T2.tab"

#Muevo los archivos de instalación a la carpeta de backup
	mv -f PPI.mae InstallFiles/PPI.mae
	log "Movido Archivo Maestro a InstallFiles PPI.mae"
	mv -f p-s.mae InstallFiles/p-s.mae
	log "Movido Archivo Maestro  a InstallFiles PS.mae"
	mv -f T1.tab InstallFiles/T1.tab
	log "Movido Archivo Maestro a InstallFiles T1.tab"
	mv -f T2.tab InstallFiles/T2.tab
	log "Movido Archivo Maestro a InstallFiles T2.tab"
}

validarPerl()
{
	#VALIDO SI PERL ESTA INSTALADO EN EL SISTEMA
	VALOR=$(command -v perl)
	if [ ! -z "$VALOR" -a "$VALOR" != " " ]; then
		echo "Perl está correctamente instalado."
		Version=$(perl -v | grep 'This is perl' | sed "s/This is perl \([0-9]\),.*/\1/")
		if (($Version >= 5)); then
			echo -e "Version de Perl: $Version"
		fi
	else
		echo "Ha ocurrido un error. Es necesaria una instalación de Perl 5 o superior para continuar."
		exit 1
	fi
}

validarDirectorio()
{
	dirValido=true

	if [ "$auxDir" = "$dirConfiguracion" ]
	then
		echo -e "El nombre dirconf es un nombre reservado. (Se utilizara el nombre asignado por defecto)\n"
		dirValido=false
	fi
	
	while read -r line
	do
		if [ ! -d "$line" ]; then
			if [ "$auxDir" = "$line" ]; then
				echo -e "El nombre $auxDir ya existe. (Se utilizara el nombre asignado por defecto)\n"
				dirValido=false
				
			fi		
		fi
	done <<<"$directoriosExistentes"

	directoriosExistentes[$contadorDirectorios]=$auxDir
}

modoReparacion(){
	if [ -f "$GRUPO/dirconf/instalacion.config" ]; then
		carpetasACrear=$(cut -d- -f 2 "dirconf/instalacion.config")
		contador=0
		
		echo -e "\n\nDirectorios de instalación:\n\n"
		while read -r line
	  		do
			carpetas[$contador]="$line"

			echo ${carpetas[$contador]}			

			if [ ! -d "$line" ]; then
				mkdir -p "$line"
				log "Reparando directorio $line"
			fi
			contador+=1
		done <<<"$carpetasACrear"

		#Archivos ejecutables
		ejecutables=$(find "InstallFiles" -type f -iname "*.sh" -o -iname "*.pl" -o -iname "*.pm")
		while read -r line
		do
			cp "$line" "${carpetas[0]}"
			log "Reparando archivos ejecutables. $line"
		done <<<"$ejecutables"
		#Archivos maestros
		maestros=$(find "InstallFiles" -type f -iname "*.mae" -o -iname "*.tab")
		while read -r line
		do
			cp "$line" "${carpetas[1]}"
			log "Reparando archivos maestros. $line"
		done <<<"$maestros"
  	else
    		echo "No hay instalacion previa, nada para reparar."
		log "Modo reparacion finalizado. No hay instalación para reparar."
  	fi
}

instalacion()
{
	directoriosExistentes=""
	echo -e "\n\n\n************* Bienvenido a la instalación de CONTROL-O.*************\n\n\n"
	echo -e "Durante la instalación deberá configurar nombres de directorios necesarios para la configuración del sistema.\n(Presionar enter para elegir el valor por defecto)"

	echo -e "\nIngrese el nombre del directorio para los archivos ejecutables (Ej: ../$dirEjecutables): "
	read auxDir
	contadorDirectorios=0
	validarDirectorio
	log "Solicita Directorio Ejecutables / Respuesta: $auxDir"
	if [ "$auxDir" != "" ] && [ "$dirValido" != "false" ]
	then
		dirEjecutables=$auxDir
	fi

	echo -e "\nIngrese el nombre del directorio para los archivos maestros o tablas del sistema (Ej: ../$dirMaestros): "
	read auxDir
	contadorDirectorios=1
	validarDirectorio
	log "Solicita Directorio Maestros / Respuesta: $auxDir"
	if [ "$auxDir" != "" ] && [ "$dirValido" != "false" ]
	then
		dirMaestros=$auxDir 
	fi

	echo -e "\nIngrese el nombre del directorio para los archivos externos o de entrada (Ej: ../$dirEntrada): "
	read auxDir
	contadorDirectorios=2
	validarDirectorio
	log "Solicita Directorio Entrada / Respuesta: $auxDir"
	if [ "$auxDir" != "" ] && [ "$dirValido" != "false" ]
	then
		dirEntrada=$auxDir 
	fi

	echo -e "\nIngrese el nombre del directorio para los archivos de novedades aceptadas (Ej: ../$dirNovedadesAceptadas): "
	read auxDir
	contadorDirectorios=3
	validarDirectorio
	log "Solicita Directorio Novedades / Respuesta: $auxDir"
	if [ "$auxDir" != "" ] && [ "$dirValido" != "false" ]
	then
		dirNovedadesAceptadas=$auxDir 
	fi

	echo -e "\nIngrese el nombre del directorio para los archivos rechazados (Ej: ../$dirRechazados): "
	read auxDir
	contadorDirectorios=4
	validarDirectorio
	log "Solicita Directorio Rechazados / Respuesta: $auxDir"
	if [ "$auxDir" != "" ] && [ "$dirValido" != "false" ]
	then
		dirRechazados=$auxDir 
	fi

	echo -e "\nIngrese el nombre del directorio para los archivos procesados (Ej: ../$dirProcesados): "
	read auxDir
	contadorDirectorios=4
	validarDirectorio
	log "Solicita Directorio Procesados / Respuesta: $auxDir"
	if [ "$auxDir" != "" ] && [ "$dirValido" != "false" ]
	then
		dirProcesados=$auxDir 
	fi

	echo -e "\nIngrese el nombre del directorio para los archivos de reportes (Ej: ../$dirReportes): "
	read auxDir
	contadorDirectorios=5
	validarDirectorio
	log "Solicita Directorio Reportes / Respuesta: $auxDir"
	if [ "$auxDir" != "" ] && [ "$dirValido" != "false" ]
	then
		dirReportes=$auxDir 
	fi

	echo -e "\nIngrese el nombre del directorio para los archivos de log (Ej: ../$dirLogs): "
	read auxDir
	contadorDirectorios=6
	validarDirectorio
	log "Solicita Directorio Logs / Respuesta: $auxDir"
	if [ "$auxDir" != "" ] && [ "$dirValido" != "false" ]
	then
		dirLogs=$auxDir 
	fi

	dirConfiguracion="dirconf"

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
		log "-Confirma Instalacion / Respuesta: NO"
		echo -e "\nInstalación cancelada...\n"
		instalacion
	done

	log "Confirma Instalacion / Respuesta: SI"
	
	crearDirectorios
	moverArchivos
	crearConfig

	echo "Instalación finalizada."
	log "Instalacion finalizada"
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

	if [ -f "$GRUPO/dirconf/instalacion.config" ]
	then 
		#Existe una instalación
		echo -e "¡Hay una instalación existente del sistema!\n\nSe iniciara el modo reparación."
		log "Iniciado Modo Reparacion"
		modoReparacion
		echo -e "\nModo reparacion finalizado correctamente."
		log "Finalizado modo reparacion."
	else
		instalacion
		mv -f instalacion.config dirconf/instalacion.config
		log "Movido Archivo Configuracion"
	fi
	
	mv -f logFile.log $dirLogs/logFile.log
fi