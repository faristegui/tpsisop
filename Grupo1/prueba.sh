#! /usr/bin/env bash	

source log.sh
LOGFILE="interpretO.log";
directorioActual=$(pwd);

tablaCampos="$directorioActual/T2.tab"
tablaSeparadores="$directorioActual/T1.tab"
entrada="$directorioActual/aceptados"



ambienteinicializado(){

	return 1;
}

grabarRegistro(){

salida="$directorioActual/procesados"
fecha=($(date "+%Y-%m-%d"))

if [ ! -d $salida'/'$fecha ]; then

	mkdir $salida'/'$fecha

}

salida=$salida'/'$fecha



grabarRegistro