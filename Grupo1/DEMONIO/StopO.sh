
if [ -z "$PID_DEMONIO" ] 
then
	echo "El proceso DetectO no esta corriendo."
else
	kill $PID_DEMONIO
	echo "Se elimino el proceso DetectO con PID: $PID_DEMONIO"
fi
