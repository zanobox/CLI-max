#!/bin/bash

## A few variables

downl_dir=$HOME/bin/src
build_dir=$HOME/bin/opendcp-build

[ -z `which opendcp_xml` ] && no_odcp=true

if [ $no_odcp ]; then

	starting_place=`pwd`

	## Tester si on a les droits d'admin
	test_admin=`groups | sed s/.*sudo.*/ok_sudo/ | grep sudo`
	if [ "x$test_admin" == "xok_sudo" ]; then
		echo -e "...We have admin capabilities, let's move on."
	else
		echo -e "Sorry, we need sudo privileges to install opendcp."
		exit 0
	fi
	
	# set PATH so it includes user's private bin if it exists
	#~ if [ -d "$HOME/bin" ] ; then
		#~ PATH="$HOME/bin:$PATH"
	#~ fi
	
	## Get sources
	
	[ ! -d $downl_dir ] && mkdir -p $downl_dir

	# Download opendcp
	cd $downl_dir
	if ! [ -f $downl_dir/master.zip ]; then
		echo
		echo -e "...downloading opendcp-master into $downl_dir"
		wget https://github.com/tmeiczin/opendcp/archive/master.zip	
	fi
	
	# Unzip
	if ! [ -d $downl_dir/opendcp-master ]; then
		echo
		echo -e "...extracting opendcp-master in $downl_dir" 
		unzip $downl_dir/master.zip
	fi
	
	
	## Resolve missing deps
	
	# First we need cmake
	if [ -z `which cmake` ]; then 
		echo
		echo -e "...installing cmake on the system (password required for sudo)"
		sudo apt-get install -y cmake
	else
		echo
		echo -e "...cmake already installed"
	fi
	
	# If not openssl
	if [ -z `which openssl` ]; then 
		echo
		echo -e "...installing openssl on the system (password required for sudo)"
		sudo apt-get install -y g++
	else
		echo
		echo -e "...openssl already installed"
	fi

	# If not /usr/bin/zlib
	if [ -z `which g++` ]; then 
		echo
		echo -e "...installing g++ on the system (password required for sudo)"
		sudo apt-get install -y g++
	else
		echo
		echo -e "...g++ already installed"
	fi

	# If not pkg-config
	if [ -z `which pkg-config` ]; then 
		echo
		echo -e "...installing pkg-config on the system (password required for sudo)"
		sudo apt-get install -y pkg-config
	else
		echo
		echo -e "...pkg-config already installed"
	fi

	# If not git
	if [ -z `which git` ]; then 
		echo
		echo -e "...installing git on the system (password required for sudo)"
		sudo apt-get install -y git
	else
		echo
		echo -e "...git already installed"
	fi

	# To avoid some problems with openssl and others
	# we try to install dev libraries
	echo
	echo -e "...trying to install libssl-dev on the system (password required for sudo)"

	sudo apt-get install -y \
		libssl-dev \
		libxml2-dev \
		libxslt1-dev \
		libxmlsec1-dev \
		libexpat1-dev \
		libtiff5-dev
		

	## Running cmake
	echo -e "Available options :"
	echo -e "\t1) CLI only"
	echo -e "\t2) full GUI"
	echo -e "\t3) .deb file for debian (e.g. gDebi)"
	echo -e "\t4) .rpm file for rpm package manager"
	echo -en " > "; read choice
	echo
	echo -e "...pre-building package with cmake (password required for sudo)"
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
				echo -e "...installing qt4-qmake on the system (password required for sudo)"
				sudo apt-get install -y qt4-qmake
			else
				echo
				echo -e "...qt4-qmake already installed"
			fi
		;;
		3)
			## Pre-build DEB package
			echo -e "...Debian package"
			option='-DDEB=ON'
		;;
		3)
			## Pre-build RPM package
			echo -e "...RPM package"
			option='-DRPM=ON'
		;;
		*)
			echo -e "Invalid option. Run again."
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
	echo -e "...compiling and installing (password required for sudo)"
	sudo make 
	
	case $choice in
		3|4)
			## If we had a debian package
			make package
		;;
		*)
			## For a regular install
			sudo make install
		;;
	esac
	
	## Back
	cd $starting_place
	exit 0

else
	echo -e "...OpenDCP is already installed on this system"
	exit 0
fi
