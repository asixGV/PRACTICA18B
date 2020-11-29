#!/bin/bash
# >&2 --> Ens redirigeix un fluxe a un file descriptor.
# ens redirigeix stdout a stderr 1>&2 o >&2
# ens redirigeix stderr a stdout 2>&1 o >&1

#
#  Ens creara uns usuaris de prova
#  useradd -m pablo
#  useradd -m ivan
#  useradd -m marta
#  useradd -m pepi
#


#Funcio usage:
usage () {
        echo -e "\nUsage: ${0} [-d] -r[] [-a] USER ..." >&2
        echo 'Disable/delete/backup a local Linux account.' >&2
	echo '  -d  Disable account' >&2
	echo '  -r  Remove the account' >&2
	echo '  -a  Creates an archive of the home directory associated with the account(s).' >&2
	exit 1

}
checkUser () {
	
	idUser=`id -u $1`
	if id "$1" >/dev/null 2>&1; then
	
		if (( $idUser >  1000 ));	
			then
				echo -e "--> L'usuari existeix, i té un UID de més de 1000\n"
				return 10
			else
				echo -e "--> L'usuari $1 ha de tindre un UID de més de 1000\n"
				echo -e "--> ID actual de $1 és $idUser"
				exit 1
		fi
		else
			exit 1

	fi
}	

log() {
  local MESSAGE="${@}"
  if [[ "${VERBOSE}" = 'true' ]]
  then
    echo "${MESSAGE}"
  fi
  logger -t luser-demo10.sh "${MESSAGE}" #pots veure missatge: tail -1 /var/log/syslog
}

backup_dir() {
  echo "Comenca backup de $1"
  #local DIR= echo $1
  local userPath=`getent passwd $1 | cut -f6 -d:`

  # Make sure the file exists.
  if [[ -n "${userPath}" ]]
   then
    echo "Es un directori"
    local BACKUP_FILE="/archives/$(basename ${userPath}).$(date +%F-%N)"
    echo "Backing up ${userPath} to ${BACKUP_FILE}."
	if [ ! -d "/archives" ]; then
		`mkdir /archives`
    fi
    # The exit status of the function will be the exit status of the cp command.
    tar -zcvpf /${BACKUP_FILE}.tar.gz $userPath 
  else
    # The file does not exist, so return a non-zero exit status.
    echo NO existeix
    return 1
  fi
}

if [ `whoami` != 'root' ]
  then
    printf "\nHauries de ser usuari root per poguer executar aquest script.
Contacta amb algun administrador.\nGràcies.\n\n";
    exit 1;
fi

#echo "digues el nom d'usuari"
#read a
#checkUser "$a"

#Parse the options
while getopts :d:r:a: o; do
    # OPTIND és variable interna de  getops, índex 
    #echo "OPTIND: $OPTIND OPTARG: $OPTARG"
    case "${o}" in
	# OPTARG és una variable pròpia de getops i va canviant a cada 
	# iteració: representa el valor l'opció que està tractant
        d)
                USERdisable=$OPTARG
                # Make sure the UID of the account is at least 1000.
		checkUser "$USERdisable" 
		#Volem un valor de 10 pq si checkUser es correcte en tots els parametres ens retornarà 10.	
		#jaDeshabilitat=sudo cat /etc/shadow | grep $USERdisable | cut -d':' -f 2
		if [ "echo $? == 10" ]
			then
				echo -e "Correcte!, procedint a desactivar-lo.\n"
				echo -ne '#####                   (33%)\r'
				sleep 1
				echo -ne '#############           (66%)\r'
				sleep 1
				echo -ne '#######################(100%)\r'
				echo -ne '\n'
				usermod -L $USERdisable
				echo -e "--> Usuari, $USERdisable, desactivat correctament...\n"
				cat /etc/shadow | grep $USERdisable
				echo -e "Si veus un  !  al costat de $USERdisable, l'usuari ha sigut deshabilitat correctament.\n"
			else	
				echo -e "L'usuari ja esta deshabilitat"
				exit 1
			fi						
		
			  #deshabilitat usuari
			  #comprova usuari deshabilitat
			  #tot ho fa la funció checkUser
           	    ;;
		r)
		    USERremove=$OPTARG
		    # Make sure the UID of the account is at least 1000.
				# elimina usuari
				# Check user is deleted.
				checkUser "$USERremove"
		
				if [ "echo $? == 10" ];
					then
						echo -e "Correcte!, preparant procediments per a esborrar a $USERremove.\n"
						echo -ne '#####                   (33%)\r'
						sleep 1
						echo -ne '#############           (66%)\r'
						sleep 1
						echo -ne '#######################(100%)\r'
						echo -ne '\n'
						echo -e "D'acord, s'esborraràn els directoris recursivament de /home, /var/spool/mail de $USERremove"
						cat /etc/shadow| grep $USERremove
						
						userdel -r -f $USERremove >/dev/null 2>&1


				fi

			;;




				
		   
		a)
			USERbackup=$OPTARG
			checkUser "$USERbackup"
			if [ "echo $? == 10" ];
				then
					backup_dir $USERbackup

			fi
			# Make sure the UID of the account is at least 1000. 
			#crida a la funcio que fa el backup de la home de lusuari
		    	;;
	#entra aquí quan s'introdueix opció però no pas argument, sent aquest
	#obligatori
        :)
            echo "ERROR: Option -$OPTARG requires an argument"
            usage
            ;;
	#entra aqui quan l'opció no és vàlida
        \?)
            echo "ERROR: Invalid option -$OPTARG"
            usage
            ;;
    esac
done


if [ $OPTIND == 1 ]
then
	echo "Sense cap opció o paràmetre:\n"
	usage
	
fi







