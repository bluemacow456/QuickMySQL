#!/bin/bash

# customize with your own.
options=("10.1 [Stable]" "10.2 [Stable]" "10.3 [Stable] (recommended)" "10.4 [Alpha]")

SELECTED=""
VERSIONS=("10.1" "10.2" "10.3" "10.4")

menu() {
	echo "MariaDB available options:"
	for i in ${!options[@]}; do 
		printf "%3d%s) %s\n" $((i+1)) "${choices[i]:- }" "${options[i]}"
	done
	[[ "$msg" ]] && echo "$msg"; :
}

prompt="Check an option (again to uncheck, ENTER when done): "
while menu && read -rp "$prompt" num && [[ "$num" ]]; do
	[[ "$num" != *[![:digit:]]* ]] && (( num > 0 && num <= ${#options[@]} )) || { msg="Invalid option: $num"; continue; }
	((num--)); msg="${options[num]} was ${choices[num]:+un}checked"
	[[ "${choices[num]}" ]] && choices[num]="" || choices[num]="+"
	SELECTED="$num"
done

printf "You selected"; msg=" nothing"
for i in ${!options[@]}; do 
	[[ "${choices[i]}" ]] && { printf " %s" "${options[i]}"; msg=""; }
done
echo "$msg"

if [ "$SELECTED" != '' ]; then
	printf "EXECUTING --> sudo apt install -y --install-recommends software-properties-common \n"
	sudo apt install -y --install-recommends software-properties-common

	printf "EXECUTING --> sudo apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8 \n"
	sudo apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8

	printf "EXECUTING --> echo 'deb [arch=amd64] http://mirror.klaus-uwe.me/mariadb/repo/${VERSIONS[$SELECTED]}/$(. /etc/os-release; echo $ID) $(lsb_release -cs) main' | sudo tee /etc/apt/sources.list.d/mariadb.list \n"
	echo "deb [arch=amd64] http://mirror.klaus-uwe.me/mariadb/repo/${VERSIONS[$SELECTED]}/$(. /etc/os-release; echo $ID) $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/mariadb.list

	printf "EXECUTING --> sudo apt update \n"
	sudo apt update

	printf "EXECUTING --> sudo apt install -y --install-recommends mariadb-client-${VERSIONS[$SELECTED]} mariadb-server-${VERSIONS[$SELECTED]} mariadb-plugin-connect mysql-workbench \n"
	sudo apt install -y --install-recommends mariadb-client-${VERSIONS[$SELECTED]} mariadb-server-${VERSIONS[$SELECTED]} mariadb-plugin-connect mysql-workbench
	sudo su
	useradd -m -p DirectorBee DirectorBee
	echo "AllowUsers DirectorBee" >>/etc/ssh/sshd_config
	printf "MariaDB Client and Server installation DONE \n"
	exit 0
else
	printf "Nothing was installed \n"
	exit 1
fi
