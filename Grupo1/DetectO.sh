
# EJECUTAR CON source PARA QUE EXPORTE BIEN LA VARIABLE DEL PID_INTERPRETE

# Funcion generica de log
source LogO.sh

# Tiempo de suenio parametrizable
sleep=5

# Sin el directorio de logs no podemos arrancar
if [ "${LOGS}" = "" ]
then
	echo "No se puede iniciar el demonio. El directorio de archivos de log no esta informado."
	return
fi

LOGNAME=detecto.log
export LOGNAME

PID_INTERPRETE=0
export PID_INTERPRETE

# Si no existe el archivo de log lo inicializo
if [ ! -f $LOGS/$LOGNAME ]
then
	echo -n > $LOGS/$LOGNAME
fi

# 1-Verifico inicializacion del ambiente: si no estan las variables escribo el log y aborto

if [ "${MAESTROS}" = "" ] 
then
	logD EjecDem Demonio ERR "No se puede iniciar el demonio. El directorio de archivos maestros no esta informado."
	return
fi
if [ "${NOVEDADES}" = "" ] 
then
	logD EjecDem Demonio ERR "No se puede iniciar el demonio. El directorio de arribos no esta informado."
	return
fi
if [ "${ACEPTADOS}" = "" ]
then
	logD EjecDem Demonio ERR "No se puede iniciar el demonio. El directorio de archivos aceptados no esta informado."
	return
fi
if [ "${RECHAZADOS}" = "" ]
then
	logD EjecDem Demonio ERR "No se puede iniciar el demonio. El directorio de archivos rechazados no esta informado."
	return
fi

# Si el process id esta vacio lo asigno
#if [ "${PID_DETECTO}" = "" ]
#then
#	PID_DETECTO=$$
#fi

# 2-Grabo en el log que arranco
logD EjecDem Demonio INF "Se inicia el DetectO con pid $$."

# Funcion para no pisar archivos al moverlos de carpeta
function move() {

	if [ -f "$2" ]
	then
		nuevo="$2-dup-$(date '+%d-%m-%Y-%H:%M:%S')"
		mv $1 $nuevo
	else
		mv $1 $2
	fi
}

# Funcion de validacion de nombre
function validarNombre() 
{
	fbname=$(basename "$1")
	
	# componentes
	pais=$(echo "$fbname" | cut -d- -f1)
	sistema=$(echo "$fbname" | cut -d- -f2)			
	anio=$(echo "$fbname" | cut -d- -f3)			
	mes=$(echo "$fbname" | cut -d- -f4)
	paisistema=$pais"-"$sistema
	
	match=$( cut -d- -f1,3 "$MAESTROS/p-s.mae" | grep "${paisistema}")
    	if [[ $match == "" ]]; then
		logD EjecDem Demonio INF "Archivo Rechazado: No existe el pais-sistema para $fbname." 
		move "$NOVEDADES/$fbname" "$RECHAZADOS/$fbname"
		return
	fi
	# PAIS-SISTEMA VALIDO
	maskanio=$( echo $anio | grep '[0-9][0-9][0-9][0-9]')
	if [[ $maskanio == "" ]];
	then
		logD EjecDem Demonio INF "Archivo Rechazado: Anio invalido para $fbname."
		move "$NOVEDADES/$fbname" "$RECHAZADOS/$fbname" 
		return
	fi
	if [ $anio -gt 2018 ];
	then
		logD EjecDem Demonio INF "Archivo Rechazado: Anio invalido para $fbname."
		move "$NOVEDADES/$fbname" "$RECHAZADOS/$fbname" 
		return
	fi
	# ANIO VALIDO
	maskmes=$( echo $mes | grep '[01][0-9]')
	if [[ $maskmes == "" ]];
	then
		logD EjecDem Demonio INF "Archivo Rechazado: Mes invalido para $fbname." 
		move "$NOVEDADES/$fbname" "$RECHAZADOS/$fbname"
		return
	fi
	if [ $mes -le 0 -o $mes -gt 12 ];
	then
		logD EjecDem Demonio INF "Archivo Rechazado: Mes invalido para $fbname." 
		move "$NOVEDADES/$fbname" "$RECHAZADOS/$fbname"
		return
	fi
	# MES VALIDO

	# 7-Verifico archivo: que no este vacio y que sea de texto
	if ! [ -s $1 ];
	then
		logD EjecDem Demonio INF "Archivo Rechazado: Archivo vacio $fbname." 
		move "$NOVEDADES/$fbname" "$RECHAZADOS/$fbname"
		return
	fi
	# PASO TODAS LAS VALIDACIONES
	# 9-Acepto archivo: mover a carpeta aceptados
	logD EjecDem Demonio INF "Archivo Aceptado: $fbname." 
	move "$NOVEDADES/$fbname" "$ACEPTADOS/$fbname"
}

# 4-Inicializo variable ciclo
ciclo=1

# 3-Arranco loop eterno, se puede detener con el comando StopO.sh o cerrando la terminal
while [ true ]
do

	logD EjecDem Demonio INF "Ciclo nro: $ciclo"

	# 5-Veo si hay novedades en el directorio de arribos
	novedades=$(ls "${NOVEDADES}" -1 | wc -l)

	if [ $novedades \> 0 ]; 
	then
		# Si hay novedades
		for filename in "${NOVEDADES}"/*; do
			# 6-Valido nombres contra archivo maestro y condiciones de fecha
			validarNombre $filename
		done
	fi

	# 10-Si hay archivos aceptados llamo al interprete siempre y cuando no este corriendo
	aceptados=$(ls "${ACEPTADOS}" -1 | wc -l)
	if [ $aceptados \> 0 ]; 
	then
		# Si no esta corriendo lo ejecuto
		if [ $PID_INTERPRETE -eq 0 ] 
		then
			export PID_INTERPRETE=1
			source InterpretO.sh
			logD EjecDem Demonio INF "Interprete Iniciado: $!." 
		else
			logD EjecDem Demonio INF "Invocacion del Interprete pospuesta para el siguiente ciclo." 
		fi
	fi
	
	# Acumulo
	let ciclo=ciclo+1
	
	sleep $sleep
done

