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

#"CTB_ANIO" "CTB_MES" "CTB_DIA" 

ambienteinicializado(){

	return 1;
}

buscarIndice(){

	CONT=0
	indice=99
	while [ $CONT -lt ${#nombres_campos[*]} ]; do

			if [[ $1 == ${nombres_campos[CONT]} ]]; then
				indice=$CONT
			fi
	    	
	        let CONT=CONT+1 
	done
	#return indice

}

reemplazarSeparadorDecimal(){

	valorModif=$(echo "$1" | tr $separadorDec ",");
	nuevaLinea+=$valorModif
}

formatearFecha(){

	valorFormato=${formatos[$indice]}
	echo $valorFormato
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
		*) nuevaLinea+=$separadorSalida'hola'$separadorSalida'hola'$separadorSalida'hola'
		;;
	esac

}

grabarFechaYusuario(){

fecha=($(date "+%d/%m/%Y"))

nuevaLinea+=$separadorSalida$fecha$separadorSalida'usuario01'

}

calcularMontoRestante(){

	buscarIndice 'MT_PRES'
	#Devuelve en el 
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
	#let mt_rest_dec=${mt_pres[1]}+${mt_impago[1]}+${mt_inde[1]}+${mt_innode[1]}-${mt_deb[1]}
	#echo mt_rest_dec
	mt_rest=$mt_rest_entero
	#if [[ mt_rest_dec > 99 ]]; then

	#	mt_rest=${#mt_rest_dec}

	#else

	#	mt_rest=$mt_rest_entero','$mt_rest_dec

	#fi
}

darformatoSalida(){

	CONTADOR=0
	buscarIndice 'CTB_FE'
	echo $indice
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
					echo $indice
				fi 
			else
			formatoCampo=${formatos[$indice]}
			primerCaracter=${formatoCampo:0:1}
			case "$primerCaracter" in
			
				'$') nuevaLinea+=${vec[$indice]} 
				;;
				'c') reemplazarSeparadorDecimal ${vec[$indice]} 
				;;
				*)  echo 'la puta madre' 
				;;
			esac
				
 				#nuevaLinea+=${vec[$indice]}
				echo $indice	
	    	fi
	        let CONTADOR=CONTADOR+1 
	done
	grabarFechaYusuario
	
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

separadorSalida=';';
nuevaLinea=$sistema;

darformatoSalida
#j=0

# reemplazar por el registroReal
#while [  $j -lt ${#vec[*]} ];
#do
# nuevaLinea+=$separadorSalida
# nuevaLinea+=${vec[j]}
# let j=j+1
#done 

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
#echo 'El interprete proceso todos los archivos que habia disponibles'
#exit 1
#$PID_INTERPRETE=""