#!/bin/bash
## by Zanobox, july 12th 2015

## Quelques variables

downl_dir=$HOME/bin/src
build_dir=$HOME/bin/opendcp-build

[ -z `which opendcp_xml` ] && no_odcp=true

if [ $no_odcp ]; then

	starting_place=`pwd`

	## Tester si on a les droits d'admin
	test_admin=`groups | sed s/.*sudo.*/ok_sudo/ | grep sudo`
	if [ "x$test_admin" == "xok_sudo" ]; then
		echo -e "...On a les droits d'administrateur, on continue."
	else
		echo -e "Désolé, il faut les privilèges d'administrateur pour effectuer l'installation."
		exit 0
	fi
	
	# Ajouter le répertoire ~/bin au PATH
	#~ if [ -d "$HOME/bin" ] ; then
		#~ PATH="$HOME/bin:$PATH"
	#~ fi
	
	## Récupérer les sources
	
	[ ! -d $downl_dir ] && mkdir -p $downl_dir

	# Download opendcp
	cd $downl_dir
	if ! [ -f $downl_dir/master.zip ]; then
		echo
		echo -e "...téléchargement d' opendcp-master dans $downl_dir"
		wget https://github.com/tmeiczin/opendcp/archive/master.zip	
	fi
	
	# Unzip
	if ! [ -d $downl_dir/opendcp-master ]; then
		echo
		echo -e "...extraction d' opendcp-master dans $downl_dir" 
		unzip $downl_dir/master.zip
	fi
	
	
	## Resolution de dépendances manquantes
	
	# Pour commencer, il faudra cmake
	if [ -z `which cmake` ]; then 
		echo
		echo -e "...installation de cmake (mot de passe requis pour sudo)"
		sudo apt-get install -y cmake
	else
		echo
		echo -e "...cmake  déjà présent"
	fi
	
	# If not openssl
	if [ -z `which openssl` ]; then 
		echo
		echo -e "...installation de openssl on the system (mot de passe requis pour sudo)"
		sudo apt-get install -y g++
	else
		echo
		echo -e "...openssl  déjà présent"
	fi

	# If not /usr/bin/zlib
	if [ -z `which g++` ]; then 
		echo
		echo -e "...installation de g++ on the system (mot de passe requis pour sudo)"
		sudo apt-get install -y g++
	else
		echo
		echo -e "...g++  déjà présent"
	fi

	# If not pkg-config
	if [ -z `which pkg-config` ]; then 
		echo
		echo -e "...installation de pkg-config on the system (mot de passe requis pour sudo)"
		sudo apt-get install -y pkg-config
	else
		echo
		echo -e "...pkg-config  déjà présent"
	fi

	# If not git
	if [ -z `which git` ]; then 
		echo
		echo -e "...installation de git on the system (mot de passe requis pour sudo)"
		sudo apt-get install -y git
	else
		echo
		echo -e "...git  déjà présent"
	fi

	# Pour satisfaire cmake, il va falloir disposer des
	# paquets de développement de certaines bibliothèques.
	echo
	echo -e "...essai d'installation de bibliothèques -dev (mot de passe requis pour sudo)"

	sudo apt-get install -y \
		libssl-dev \
		libxml2-dev \
		libxslt1-dev \
		libxmlsec1-dev \
		libexpat1-dev \
		libtiff5-dev
		

	## Running cmake
	echo -e "Options disponibles :"
	echo -e "\t1) CLI (ligne de commande seulement)"
	echo -e "\t2) GUI (interface graphique + CLI)"
	echo -e "\t3) Paquet .deb pour debian (pour gDebi par exemple)"
	echo -e "\t4) Paquet .rpm pour les RedHat like."
	echo -en " :>"; read choice
	echo
	echo -e "...préparation du paquet avec cmake (mot de passe requis pour sudo)"
	case $choice in
		1)
			## Pre-build CLI only
			echo -e "...CLI only"
			option='-DENABLE_GUI=ON'
		;;
		2)
			## Pre-build GUI
			echo -e "...full GUI"
			option='-DENABLE_GUI=ON'
			
			# If not qt4/qt5
			if [ -z `which qt4-qmake` ]; then 
				echo
				echo -e "...installation de qt4-qmake (mot de passe requis pour sudo)"
				sudo apt-get install -y qt4-qmake
			else
				echo
				echo -e "...qt4-qmake déjà présent"
			fi
		;;
		3)
			## Pre-build DEB package
			echo -e "...paquet Debian"
			option='-DDEB=ON'
		;;
		3)
			## Pre-build RPM package
			echo -e "...paquet RPM"
			option='-DRPM=ON'
		;;
		*)
			echo -e "Option invalide. Relancer le script."
			exit 0
		;;
	esac
	
	
	## Starting the real deal
	
	[ ! -d $build_dir ] && mkdir -p $build_dir
	
	cd $build_dir
	
	sudo cmake \
		-DOPENSSL_ROOT_DIR=/usr/lib/i386-linux-gnu/ \
		-DCMAKE_CXX_COMPILER_ID=GNU \
		$option \
		$downl_dir/opendcp-master \
		|| exit 0

	## Make
	echo
	echo -e "...compilation et installation d'OpenDCP (mot de passe requis pour sudo)"
	sudo make 
	
	case $choice in
		3|4)
			## Si on voulait un paquet
			make package
		;;
		*)
			## Pour une installation locale
			sudo make install
		;;
	esac
	
	## Back
	cd $starting_place
	exit 0

else
	echo -e "...OpenDCP est déjà installé sur cette machine."
	exit 0
fi
