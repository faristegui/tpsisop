#! /usr/bin/env bash	

source log.sh
LOGFILE="interpretO.log";
directorioActual="$EJECUTABLES"

tablaCampos="$MAESTROS/T2.tab"
tablaSeparadores="$MAESTROS/T1.tab"
entrada="$ACEPTADOS"
salida="$PROCESADOS"
dirDup="dup"
colisiones=0



ambienteinicializado(){

	return 1;
}

darformatoSalida(){

	echo 'formatoSalida'
}

grabarRegistro(){

if [ ! -d $salida ]; then

	mkdir $directorioActual'/procesados'

fi

nombreArch='prestamos.'$codigo_pais

if [ ! -f $salida'/'$nombreArch ]; then

	>$salida'/'$nombreArch

fi
#salida=$salida'/'$nombreArch

darformatoSalida

separadorSalida=';';
nuevaLinea=$codigo_pais$separadorSalida$sistema;
j=0

# reemplazar por el registroReal
while [  $j -lt ${#vec[*]} ];
do
 nuevaLinea+=$separadorSalida
 nuevaLinea+=${vec[j]}
 let j=j+1
done 

echo $nuevaLinea >>$salida'/'$nombreArch

}

moverArchivo(){

if [ ! -d $salida ]; then

	mkdir $directorioActual'/procesados'

fi

fecha=($(date "+%Y-%m-%d"))

if [ ! -d $salida'/'$fecha ]; then

	mkdir $salida'/'$fecha

fi

if [ -f $salida'/'$fecha'/'$(basename $1) ]; then

    let colisiones=colisiones+1
	mv $1 $1'-'$colisiones

if [ ! -d $salida'/'$fecha'/'$dirDup ]; then

	mkdir $salida'/'$fecha'/'$dirDup

fi

	mv $1'-'$colisiones $salida'/'$fecha'/'$dirDup

else
	
	mv $1 $salida'/'$fecha

fi

}

evaluarAlfaNum(){

	return 1;
}

evaluarNumero(){

	return 1;
}

evaluarFecha(){

	return 1;
}

evaluarCampo(){

	IFS=''
	#identificarFormato
	#echo $2
	formatoCampo=$2
	#echo $formatoCampo
	primerCaracter=${formatoCampo:0:1}
	case "$primerCaracter" in
	
		'$') evaluarAlfaNum $1 $2 
	    ;;
		'c') evaluarNumero $1 $2 
	    ;;
		*)  evaluarFecha $1 $2 
	    ;;
	esac

}

ambienteinicializado

if [ $? -eq 1 ]; then

	echo "El ambiente se encuentra correctamente inicializado"

else

	echo "No se encuentra inicializado el ambiente"

fi



#INICIO RECORRIDO DE DIRECTORIO CON ARCHIVOS ACEPTADOS

for i in $(ls $entrada)
do
    IFS="-" read -ra codigos <<< "$i"
    codigo_pais=${codigos[0]};
    sistema=${codigos[1]};
	archivo=$entrada'/'$i;

	# INICIO - obtiene los separadores de campo y decimales
	backIFS=$IFS
	vec=()
	while IFS='' read -r linea || [[ -n "$linea" ]]; do
		
		IFS="-" read -ra vec <<< "$linea"
	    if [[ "${vec[0]}" == $codigo_pais && ${vec[1]} == $sistema ]]; then

	    	separador=${vec[2]};
	    	separadorDec=${vec[3]};

	    fi

	done < "$tablaSeparadores"
	IFS=$backIFS

	# FIN - obtiene los separadores de campo y decimales

	# INICIO - rellena el contenido de dos vectores de campos (nombre y formatos)

	backIFS=$IFS
	vec=()
	formatos=();
    nombres_campos=();
	while IFS='' read -r linea || [[ -n "$linea" ]]; do

		IFS="-" read -ra vec <<< "$linea"
	    if [[ "${vec[0]}" == $codigo_pais && ${vec[1]} == $sistema ]]; then

	    	formatos+=(${vec[4]});
	    	nombres_campos+=(${vec[2]});

	    fi

	done < "$tablaCampos"
	IFS=$backIFS
	# FIN - rellena el contenido de dos vectores de campos (nombre y formatos)

	# INICIO - recorrer archivos de prestamos

	backIFS=$IFS
	while IFS='' read -r linea || [[ -n "$linea" ]]; do
		
		vec=()
		IFS="$separador" read -ra vec <<< "$linea"
		campoCorrecto=1;
		CONTADOR=0;

	    while [[  $CONTADOR -lt ${#formatos[*]} && $campoCorrecto == 1 ]]; do

	    	#este if remplaza los campos vacios por 0 para evitar que se pasen mal por parametro
	    	if [[ ${vec[CONTADOR]} == '' ]];then
				vec[CONTADOR]=0;
			fi
	        evaluarCampo ${vec[CONTADOR]} ${formatos[CONTADOR]} ${nombres_campos[CONTADOR]}
	        campoCorrecto=$?
	        let CONTADOR=CONTADOR+1 
	    done

	    # si todos los campos del registro son validos guarda el registro en el archivo correspondiente
	    if [ $campoCorrecto -eq 1 ]; then

	    	echo 'registroOk'
	    	grabarRegistro

	    else

	    	log "registroRechazado"
	    	echo 'registroRechazado'

	    fi

	done < "$archivo"
	IFS=$backIFS
	
	moverArchivo "$archivo"
	# FIN - recorrer archivo de prestamos
done
#FIN RECORRIDO DE DIRECTORIO CON ARCHIVOS ACEPTADOS
#grabarRegistro