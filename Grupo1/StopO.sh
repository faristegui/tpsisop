
if [ -z "$PID_DETECTO" ] 
then
	echo "El proceso DetectO no esta corriendo."
else
	kill $PID_DETECTO
	echo "Se elimino el proceso DetectO con PID: $PID_DETECTO"
	$PID_DETECTO=""
fi
