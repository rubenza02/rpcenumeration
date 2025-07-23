#!/bin/bash


function mostrar_ayuda {
    echo -e "\e[34mUso: $0 -s <IP_DEL_SERVIDOR> [-u <USUARIO> -p <CONTRASEÑA>] [-n] -f <FUNCION>\e[0m"
    echo
    echo -e "\e[34mOpciones:\e[0m"
    echo -e "  -s, --server       IP del servidor"
    echo -e "  -u, --user         Usuario (opcional, solo necesario si no se usa -n)"
    echo -e "  -p, --password     Contraseña (opcional, solo necesario si no se usa -n)"
    echo -e "  -n, --nullsession  Usar sesión nula (anónima)"
    echo -e "  -f, --function     Función a ejecutar"
    echo -e "                     Funciones disponibles:"
    echo -e "                     - \e[32menum_users\e[0m"
    echo -e "                     - \e[32menum_groups\e[0m"
    echo -e "                     - \e[32menum_shares\e[0m"
    echo -e "                     - \e[32menum_group_members\e[0m"
    echo -e "                     - \e[32menum_password_policy\e[0m"
    echo -e "                     - \e[32muser_info\e[0m"
    echo -e "                     - \e[32menum_printers\e[0m"
    echo -e "                     - \e[32mquery_server_info\e[0m"
    echo -e "                     - \e[32mquerydispinfo\e[0m"
    echo -e "                     - \e[32mfull_report\e[0m"
    echo -e "  -h, --help         Mostrar esta ayuda"
}


SERVER_IP=""
USERNAME=""
PASSWORD=""
FUNCTION=""
NULLSESSION=0


while [[ "$#" -gt 0 ]]; do
    case $1 in
        -s|--server) SERVER_IP="$2"; shift ;;
        -u|--user) USERNAME="$2"; shift ;;
        -p|--password) PASSWORD="$2"; shift ;;
        -n|--nullsession) NULLSESSION=1 ;;
        -f|--function) FUNCTION="$2"; shift ;;
        -h|--help) mostrar_ayuda; exit 0 ;;
        *) echo -e "\e[31mOpción desconocida: $1\e[0m"; mostrar_ayuda; exit 1 ;;
    esac
    shift
done


if [[ -z "$SERVER_IP" || -z "$FUNCTION" ]]; then
    echo -e "\e[31mError: faltan argumentos.\e[0m"
    mostrar_ayuda
    exit 1
fi


if [[ $NULLSESSION -eq 1 ]]; then
    USERNAME=""
    PASSWORD=""
fi


function enum_users {
    echo -e "\e[34mEnumerando usuarios en el servidor $SERVER_IP...\e[0m"
    printf "\e[1;34m%-20s %-10s\e[0m\n" "Usuario" "RID"
    printf "\e[1;34m%-20s %-10s\e[0m\n" "------" "---"
    rpcclient -U "$USERNAME%$PASSWORD" -c "enumdomusers" $SERVER_IP | while read -r line; do
        if [[ $line =~ user:\[([^\]]+)\]\ rid:\[([^\]]+)\] ]]; then
            printf "\e[1;32m%-20s %-10s\e[0m\n" "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}"
        fi
    done | column -t
}

function enum_groups {
    echo -e "\e[34mEnumerando grupos en el servidor $SERVER_IP...\e[0m"
    printf "\e[1;34m%-20s %-10s\e[0m\n" "Grupo" "RID"
    printf "\e[1;34m%-20s %-10s\e[0m\n" "-----" "---"
    rpcclient -U "$USERNAME%$PASSWORD" -c "enumdomgroups" $SERVER_IP | while read -r line; do
        if [[ $line =~ group:\[([^\]]+)\]\ rid:\[([^\]]+)\] ]]; then
            printf "\e[1;32m%-20s %-10s\e[0m\n" "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}"
        fi
    done | column -t
}

function enum_shares {
    echo -e "\e[34mEnumerando recursos compartidos en el servidor $SERVER_IP...\e[0m"
    printf "\e[1;34m%-20s %-10s\e[0m\n" "Recurso" "Tipo"
    printf "\e[1;34m%-20s %-10s\e[0m\n" "-------" "----"
    rpcclient -U "$USERNAME%$PASSWORD" -c "netshareenum" $SERVER_IP | while read -r line; do
        if [[ $line =~ netname:\[([^\]]+)\]\ type:\[([^\]]+)\] ]]; then
            printf "\e[1;32m%-20s %-10s\e[0m\n" "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}"
        fi
    done | column -t
}

function enum_group_members {
    echo -e "\e[34mEnumerando miembros de grupos en el servidor $SERVER_IP...\e[0m"
    printf "\e[1;34m%-20s %-20s\e[0m\n" "Grupo" "Miembro"
    printf "\e[1;34m%-20s %-20s\e[0m\n" "-----" "-------"
    rpcclient -U "$USERNAME%$PASSWORD" -c "enumalsgroups domain" $SERVER_IP | while read -r line; do
        if [[ $line =~ group:\[([^\]]+)\]\ member:\[([^\]]+)\] ]]; then
            printf "\e[1;32m%-20s %-20s\e[0m\n" "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}"
        fi
    done | column -t
}

function enum_password_policy {
    echo -e "\e[34mEnumerando políticas de contraseña en el servidor $SERVER_IP...\e[0m"
    rpcclient -U "$USERNAME%$PASSWORD" -c "getdompwinfo" $SERVER_IP
}

function user_info {
    echo -e "\e[34mIntroduzca el nombre del usuario para obtener información:\e[0m"
    read user
    echo -e "\e[34mObteniendo información del usuario $user en el servidor $SERVER_IP...\e[0m"
    rpcclient -U "$USERNAME%$PASSWORD" -c "queryuser $user" $SERVER_IP
}

function enum_printers {
    echo -e "\e[34mEnumerando impresoras en el servidor $SERVER_IP...\e[0m"
    printf "\e[1;34m%-20s %-10s\e[0m\n" "Impresora" "Descripción"
    printf "\e[1;34m%-20s %-10s\e[0m\n" "---------" "-----------"
    rpcclient -U "$USERNAME%$PASSWORD" -c "enumprinters" $SERVER_IP | while read -r line; do
        if [[ $line =~ printername:\[([^\]]+)\]\ description:\[([^\]]+)\] ]]; then
            printf "\e[1;32m%-20s %-10s\e[0m\n" "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}"
        fi
    done | column -t
}

function query_server_info {
    echo -e "\e[34mConsultando configuración del servidor $SERVER_IP...\e[0m"
    rpcclient -U "$USERNAME%$PASSWORD" -c "srvinfo" $SERVER_IP
}

function querydispinfo {
    echo -e "\e[34mConsultando información de la disposición del servidor $SERVER_IP...\e[0m"
    rpcclient -U "$USERNAME%$PASSWORD" -c "querydispinfo" $SERVER_IP
}

function full_report {
    echo -e "\e[34mGenerando informe completo para el servidor $SERVER_IP...\e[0m"
    
    echo -e "\n\e[1;34mEnumerando usuarios...\e[0m"
    enum_users
    
    echo -e "\n\e[1;34mEnumerando grupos...\e[0m"
    enum_groups
    
    echo -e "\n\e[1;34mEnumerando recursos compartidos...\e[0m"
    enum_shares
    
    echo -e "\n\e[1;34mEnumerando miembros de grupos...\e[0m"
    enum_group_members
    
    echo -e "\n\e[1;34mObteniendo políticas de contraseña...\e[0m"
    enum_password_policy
    
    echo -e "\n\e[1;34mObteniendo información del usuario (especificar nombre)...\e[0m"
    user_info
    
    echo -e "\n\e[1;34mEnumerando impresoras...\e[0m"
    enum_printers
    
    echo -e "\n\e[1;34mConsultando información del servidor...\e[0m"
    query_server_info
    
    echo -e "\n\e[1;34mConsultando información de la disposición...\e[0m"
    querydispinfo
}


case $FUNCTION in
    enum_users) enum_users ;;
    enum_groups) enum_groups ;;
    enum_shares) enum_shares ;;
    enum_group_members) enum_group_members ;;
    enum_password_policy) enum_password_policy ;;
    user_info) user_info ;;
    enum_printers) enum_printers ;;
    query_server_info) query_server_info ;;
    querydispinfo) querydispinfo ;;
    full_report) full_report ;;
    *) echo -e "\e[31mFunción desconocida: $FUNCTION\e[0m"; mostrar_ayuda; exit 1 ;;
esac

