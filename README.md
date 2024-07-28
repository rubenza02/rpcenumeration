# RPCenumeration

Herramienta en bash creada para realizar una enumeracion y extraer toda la informacion posible de un dominio mediante rpcclient

Con esta herramienta podremos obtener la siguiente informacion del dominio:
- Enumerar usuarios del dominio
- Enumerar grupos del dominio
- Enumerar recursos compartidos
- Enumerar miembros de grupo
- Enumerar politicas de contraseña
- Enumerar informacion de un usuario valido
- Enumerar las impresoras
- Informacion del servidor
- Enumerar la informacion de tosdos los usuarios

# ¿COMO FUNCIONA?

Ejecutar la  herramienta, da lugar al siguiente panel de ayuda que nos ayudara a ver todas las funciones, que esta herramienta es capaz de realizar.
![image](https://github.com/user-attachments/assets/2baf0504-1931-4735-9f44-1d8424e4e104)


Para su correcto funcionamiento tendremos que indicar, la IP el usuario con su contraseña (Si no los conocemos indicar la funcion -n para ejecutar una null session), y por ultimo el modo de enumeracion que queremos utilizar.

![image](https://github.com/user-attachments/assets/af1a62f4-8435-44cd-b1f8-be81400e17bc)


## Instalación y uso

- Clonamos el respositorio en nuestro sistema
```
git clone https://github.com/rubenza02/rpcenumeration.git
```

- Le damos permisos de ejecucion al script en bash
```
chmod +x rpcenumeration.sh
```

- Ejcutamos el script pasandole los parametros obligatorios y los opcionales
```
./rpcenumeration.sh -s <IP> -u <USER> -p <PASSWORD> -f  MODE
```


