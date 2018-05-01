clear

echo -e "\n\n\n************* Bienvenido a la instalación de CONTROLO.*************\n\n\n"
echo -e "Durante la instalación deberá configurar nombres de directorios necesarios para la configuración del sistema.\n(Presionar enter para elegir el valor por defecto)"

dirEjecutables="bin"
echo "\nIngrese el nombre del directorio para los archivos ejecutables (Ej: ../bin): "
read auxDir
if [ "$auxDir" != "" ]
then
	dirEjecutables=$auxDir
fi

dirMaestros="maestro"
echo "\nIngrese el nombre del directorio para los archivos maestros o tablas del sistema (Ej: ../maestro): "
read auxDir
if [ "$auxDir" != "" ]
then
	dirMaestros=$auxDir 
fi


dirEntrada="recibidos"
echo "\nIngrese el nombre del directorio para los archivos externos o de entrada (Ej: ../recibidos): "
read auxDir
if [ "$auxDir" != "" ]
then
	dirEntrada=$auxDir 
fi

dirNovedadesAceptadas="novedades"
echo "\nIngrese el nombre del directorio para los archivos de novedades aceptadas (Ej: ../novedades): "
read auxDir
if [ "$auxDir" != "" ]
then
	dirNovedadesAceptadas=$auxDir 
fi

dirRechazados="rechazados"
echo "\nIngrese el nombre del directorio para los archivos rechazados (Ej: ../rechazados): "
read auxDir
if [ "$auxDir" != "" ]
then
	dirRechazados=$auxDir 
fi

dirProcesados="procesados"
echo "\nIngrese el nombre del directorio para los archivos procesados (Ej: ../procesados): "
read auxDir
if [ "$auxDir" != "" ]
then
	dirProcesados=$auxDir 
fi

dirReportes="reportes"
echo "\nIngrese el nombre del directorio para los archivos de reportes (Ej: ../reportes): "
read auxDir
if [ "$auxDir" != "" ]
then
	dirReportes=$auxDir 
fi

dirLogs="log"
echo "\nIngrese el nombre del directorio para los archivos de log: "
read auxDir
if [ "$auxDir" != "" ]
then
	dirLogs=$auxDir 
fi

dirRechazados="rechazados"
echo "\nIngrese el nombre del directorio para los archivos rechazados: "
read auxDir
if [ "$auxDir" != "" ]
then
	dirRechazados=$auxDir 
fi

dirConfiguracion="dirconf"

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

if [ "$confirma" = "S" ] || [ "$confirma" = "s" ]
then
	echo -e "\nIniciando instalación...\n"
else
	echo -e "\nInstalación cancelada...\n"
fi