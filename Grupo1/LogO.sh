
#FORMATO LOG
#CAMPO-FECHA-USUARIO-ORIGEN-TIPO-MENSAJE

#PARAMETROS LOG
#CAMPO, ORIGEN, TIPO, MENSAJE

function log()
{
	# Si el archivo de log pesa mas de 200kb = 204800b se trunca y se dejan las ultimas 50 lineas 2048000
	filesize=$(stat -c%s $DIR_LOGS/$LOGNAME)
	if [ $filesize -gt 2048000 ]
	then
		echo "Log truncado" > templog
		echo "$(tail -n 50 detecto.log)" >> templog
		mv templog $DIR_LOGS/$LOGNAME	
	fi

	# Grabo log
	echo "$1-$(date '+%d-%m-%Y %H:%M:%S')-$USER-$2-$3-$4" >> $DIR_LOGS/$LOGNAME
}

