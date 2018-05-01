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

echo -e "\n\n\n************* Bienvenido a la instalación de CONTROLO.*************\n\n\n"
echo -e "Durante la instalación deberá configurar nombres de directorios necesarios para la configuración del sistema.\n(Presionar enter para elegir el valor por defecto)"

dirEjecutables="bin"
echo -e "\nIngrese el nombre del directorio para los archivos ejecutables (Ej: ../bin): "
read auxDir
if [ "$auxDir" != "" ]
then
	dirEjecutables=$auxDir
fi

dirMaestros="maestro"
echo -e "\nIngrese el nombre del directorio para los archivos maestros o tablas del sistema (Ej: ../maestro): "
read auxDir
if [ "$auxDir" != "" ]
then
	dirMaestros=$auxDir 
fi


dirEntrada="recibidos"
echo -e "\nIngrese el nombre del directorio para los archivos externos o de entrada (Ej: ../recibidos): "
read auxDir
if [ "$auxDir" != "" ]
then
	dirEntrada=$auxDir 
fi

dirNovedadesAceptadas="novedades"
echo -e "\nIngrese el nombre del directorio para los archivos de novedades aceptadas (Ej: ../novedades): "
read auxDir
if [ "$auxDir" != "" ]
then
	dirNovedadesAceptadas=$auxDir 
fi

dirRechazados="rechazados"
echo -e "\nIngrese el nombre del directorio para los archivos rechazados (Ej: ../rechazados): "
read auxDir
if [ "$auxDir" != "" ]
then
	dirRechazados=$auxDir 
fi

dirProcesados="procesados"
echo -e "\nIngrese el nombre del directorio para los archivos procesados (Ej: ../procesados): "
read auxDir
if [ "$auxDir" != "" ]
then
	dirProcesados=$auxDir 
fi

dirReportes="reportes"
echo -e "\nIngrese el nombre del directorio para los archivos de reportes (Ej: ../reportes): "
read auxDir
if [ "$auxDir" != "" ]
then
	dirReportes=$auxDir 
fi

dirLogs="log"
echo -e "\nIngrese el nombre del directorio para los archivos de log: "
read auxDir
if [ "$auxDir" != "" ]
then
	dirLogs=$auxDir 
fi

dirRechazados="rechazados"
echo -e "\nIngrese el nombre del directorio para los archivos rechazados: "
read auxDir
if [ "$auxDir" != "" ]
then
	dirRechazados=$auxDir 
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

if [ "$confirma" = "S" ] || [ "$confirma" = "s" ]
then
	echo -e "\nIniciando instalación...\n"
else
	echo -e "\nInstalación cancelada...\n"
fi