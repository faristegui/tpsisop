#! /usr/bin/env bash	

source log.sh
LOGFILE="interpretO.log"
directorioActual="$EJECUTABLES"

tablaCampos="$MAESTROS/T2.tab"
tablaSeparadores="$MAESTROS/T1.tab"
entrada="$ACEPTADOS"
salida="$PROCESADOS"
dirDup="dup"
colisiones=0
nombresSalida=("CTB_ESTADO" "PRES_ID" "MT_PRES" "MT_IMPAGO")
nombresSalida+=("MT_INDE" "MT_INNODE" "MT_DEB" "MT_REST" "PRES_CLI_ID" "PRES_CLI")
 

buscarIndice(){

	CONT=0
	indice=99
	while [ $CONT -lt ${#nombres_campos[*]} ]; do

			if [[ $1 == ${nombres_campos[CONT]} ]]; then
				indice=$CONT
			fi
	    	
	        let CONT=CONT+1 
	done

}

reemplazarSeparadorDecimal(){

	valorModif=$(echo "$1" | tr $separadorDec ",");
	nuevaLinea+=$valorModif
}

formatearFecha(){

	valorFormato=${formatos[$indice]}
	valorCampo=${vec[$indice]}

	case "${valorFormato:0:7}" in

		'ddmmyy1') nuevaLinea+=$separadorSalida${valorCampo:6:4}$separadorSalida${valorCampo:3:2}$separadorSalida${valorCampo:0:2}
		;;
		'ddmmyy8') nuevaLinea+=$separadorSalida${valorCampo:4:4}$separadorSalida${valorCampo:2:2}$separadorSalida${valorCampo:0:2}
		;;
		'yymmdd1') nuevaLinea+=$separadorSalida${valorCampo:0:4}$separadorSalida${valorCampo:5:2}$separadorSalida${valorCampo:8:2}
		;;
		'yymmdd8') nuevaLinea+=$separadorSalida${valorCampo:0:4}$separadorSalida${valorCampo:4:2}$separadorSalida${valorCampo:6:2}
		;;
		*) nuevaLinea+=$separadorSalida'ERROR'$separadorSalida'ERROR'$separadorSalida'ERROR'
		;;
	esac

}

grabarFechaYusuario(){

fecha=($(date "+%d/%m/%Y"))

nuevaLinea+=$separadorSalida$fecha$separadorSalida$USER

}

calcularMontoRestante(){

	buscarIndice 'MT_PRES'
	IFS="$separadorDec" read -ra mt_pres <<< "${vec[$indice]}"
	buscarIndice 'MT_IMPAGO'
	IFS="$separadorDec" read -ra mt_impago <<< "${vec[$indice]}"
	buscarIndice 'MT_INDE'
	IFS="$separadorDec" read -ra mt_inde <<< "${vec[$indice]}"
	buscarIndice 'MT_INNODE'
	IFS="$separadorDec" read -ra mt_innode <<< "${vec[$indice]}"
	buscarIndice 'MT_DEB'
	IFS="$separadorDec" read -ra mt_deb <<< "${vec[$indice]}"
	let mt_rest_entero=${mt_pres[0]}+${mt_impago[0]}+${mt_inde[0]}+${mt_innode[0]}-${mt_deb[0]}
	mt_rest=$mt_rest_entero
}

darformatoSalida(){

	CONTADOR=0
	buscarIndice 'CTB_FE'
	formatearFecha
	while [ $CONTADOR -lt ${#nombresSalida[*]} ]; do

			buscarIndice ${nombresSalida[CONTADOR]}
			nuevaLinea+=$separadorSalida
			if [ $indice -eq 99 ]; then

				if [ ${nombresSalida[CONTADOR]} == "MT_REST" ]; then

					calcularMontoRestante
					nuevaLinea+=$mt_rest
				else
 					nuevaLinea+=$indice
				fi 
			else
			formatoCampo=${formatos[$indice]}
			primerCaracter=${formatoCampo:0:1}
			case "$primerCaracter" in
			
				'$') nuevaLinea+=${vec[$indice]} 
				;;
				'c') reemplazarSeparadorDecimal ${vec[$indice]} 
				;;
			esac	
	    	fi
	        let CONTADOR=CONTADOR+1 
	done
	grabarFechaYusuario
}

grabarRegistro(){

if [ ! -d $salida ]; then

	mkdir $directorioActual'/procesados'

fi

nombreArch='prestamos.'$codigo_pais

if [ ! -f $salida'/'$nombreArch ]; then

	>$salida'/'$nombreArch

fi

separadorSalida=';';
nuevaLinea=$sistema;

darformatoSalida

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

mv $1 $salida'/'$fecha

}

chequeaProcesado(){

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
	log "El archivo $(basename $1) se encontraba duplicado en el directorio se renombro como $(basename $1)'-'$colisiones"

	if [ ! -d $salida'/'$fecha'/'$dirDup ]; then

		mkdir $salida'/'$fecha'/'$dirDup

	fi

	mv $1'-'$colisiones $salida'/'$fecha'/'$dirDup
	return 1

fi

return 0

}

evaluarAlfaNum(){

	campo=$1
	formatoAlfa=$2
	long=$(echo "${#formatoAlfa}-1" | bc)
	formatoAlfa=${formatoAlfa:1:$long}
	cant=$(echo $formatoAlfa | sed "s/^\([0-9]*\)\./\1/")
	cant=${cant::-1}
	posibles="^.\{1,$cant\}"
	alfa_val=$(echo "$campo" | sed "s/$posibles/Es valido/")
	if [[ $alfa_val == 'Es valido' ]]; then
		return 1;
	else
		msg="error en el campo: $3"
		return 0;
	fi
}

evaluarNumero(){

	campo=$1
	cantEntera=$(echo $2 | sed "s/^commax\([0-9]*\)\.\([0-9]*\)*/\1/")
	cantDecimal=$(echo $2 | sed "s/^commax\([0-9]*\)\.\([0-9]*\)*/\2/")
	cantEntera=${cantEntera::-1}
	cantDecimal=${cantDecimal::-1}
	posibles="^\([0-9]\{1,$cantEntera\}$\|[0-9]\{1,$cantEntera\}$separadorDec[0-9]\{1,$cantDecimal\}\)$"
	es_val=$(echo "$campo" | sed "s/$posibles/Es valido/")

	if [[ $es_val == 'Es valido' ]]; then
		return 1
	else
		msg="error en el campo: $3"
		return 0
	fi
}

evaluarFecha(){
	valorFormato=$2
	valorCampo=$1

	dias_29="\(0[1-9]\|[1-2][0-9]\)"
	dias_30="\(0[1-9]\|[1-2][0-9]\|30\)"
	dias_31="\(0[1-9]\|[1-2][0-9]\|3[0-1]\)"
	mes_29="02"
	mes_30="\(04\|06\|09\|11\)"
	mes_31="\(01\|03\|05\|07\|08\|10\|12\)"

	case "${valorFormato:0:7}" in

		'ddmmyy1') posibles="^\($dias_29.$mes_29.[0-9]\{4\}\|$dias_30.$mes_30.[0-9]\{4\}\|$dias_31.$mes_31.[0-9]\{4\}\)"
		;;
		'ddmmyy8') posibles="^\(\($dias_29$mes_29[0-9]\{4\}\)\|\($dias_30$mes_30[0-9]\{4\}\)\|\($dias_31$mes_31[0-9]\{4\}\)\)"
		;;
		'yymmdd1') posibles="^\(\([0-9]\{4\}.$mes_29.$dias_29\)\|\([0-9]\{4\}.$mes_30.$dias_30\)\|\([0-9]\{4\}.$mes_31.$dias_31\)\)"
		;;
		'yymmdd8') posibles="^\(\([0-9]\{4\}$mes_29$dias_29\)\|\([0-9]\{4\}$mes_30$dias_30\)\|\([0-9]\{4\}$mes_31$dias_31\)\)"
		;;
		
	esac

	fecha_val=$(echo "$valorCampo" | sed "s/$posibles/Es valido/")

	if [ ${#fecha_val} -eq 10 ]; then

		fecha_val=${fecha_val::-1}
	
	fi
	if [[ $fecha_val == 'Es valido' ]]; then
		return 1
	else
		msg="error en el campo: $3"
		return 0
	fi	
}

evaluarCampo(){

	IFS=''
	formatoCampo=$2
	primerCaracter=${formatoCampo:0:1}
	case "$primerCaracter" in
	
		'$') evaluarAlfaNum $1 $2 $3
	    ;;
		'c') evaluarNumero $1 $2 $3
	    ;;
		*)  evaluarFecha $1 $2 $3
	    ;;
	esac

}

#Chequea que el demonio este corriendo

#if [ -z "$PID_DETECTO" ] 
#then
#	echo "El proceso DetectO no esta corriendo, por lo que el interprete no puede ejecutarse"
#else

echo "El ambiente se encuentra correctamente inicializado"


#INICIO RECORRIDO DE DIRECTORIO CON ARCHIVOS ACEPTADOS

for i in $(ls $entrada)
do
    IFS="-" read -ra codigos <<< "$i"
    codigo_pais=${codigos[0]};
    sistema=${codigos[1]};
	archivo=$entrada'/'$i;

	chequeaProcesado $archivo

	if [ $? -eq 0 ];then

	# INICIO - obtiene los separadores de campo y decimales
	backIFS=$IFS
	vec=()
	while IFS='' read -r linea || [[ -n "$linea" ]]; do
		
		IFS="-" read -ra vec <<< "$linea"
	    if [[ "${vec[0]}" == $codigo_pais && ${vec[1]} == $sistema ]]; then

	    	separador=${vec[2]}
	    	separadorDec=${vec[3]}
			if [[ $separadorDec != "." ]]; then
				separadorDec=${separadorDec::-1}
			fi

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
	contadorRegistros=0
	backIFS=$IFS
	while IFS='' read -r linea || [[ -n "$linea" ]]; do
		
		vec=()
		let contadorRegistros=contadorRegistros+1
		IFS="$separador" read -ra vec <<< "$linea"
		campoCorrecto=1;
		CONTADOR=0;

	    while [[  $CONTADOR -lt ${#formatos[*]} && $campoCorrecto == 1 ]]; do

	    	#este if remplaza los campos vacios por 0 para evitar que se pasen mal por parametro
	    	if [[ ${vec[CONTADOR]} == '' ]];then
				vec[CONTADOR]='0'$separadorDec'0';
			fi
	        evaluarCampo ${vec[CONTADOR]} ${formatos[CONTADOR]} ${nombres_campos[CONTADOR]}
	        campoCorrecto=$?
	        let CONTADOR=CONTADOR+1 
	    done

	    # si todos los campos del registro son validos guarda el registro en el archivo correspondiente
	    if [ $campoCorrecto -eq 1 ]; then

	    	grabarRegistro
			log 'Archivo: '$i' - Registro nº'$contadorRegistros' correctamente cargado'

	    else

	    	log 'Archivo: '$i' - Registro nº'$contadorRegistros' rechazado por '$msg''

	    fi

	done < "$archivo"
	IFS=$backIFS

	moverArchivo "$archivo"
	fi
	# FIN - recorrer archivo de prestamos
done
#FIN RECORRIDO DE DIRECTORIO CON ARCHIVOS ACEPTADOS
echo 'El interprete proceso todos los archivos que habia disponibles'
#fi
#PID_INTERPRETE=""