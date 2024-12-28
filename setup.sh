#!/bin/bash
# By José Puga for Óptima Quantum
#
# Este script:
# · Crear el Entorno Virtual (EV) para Falcon 7B
# · Activa el EV
# · Instala las dependencias del proyecto.

LOCAL_PACKAGES="fastapi uvicorn transformers accelerate bitsandbytes"
GLOBAL_PACKAGES="" # Por si hiciera falta...

# El código debe de estar en una función para que funcione 'return', si está
# activo un source, el exit cerraría la shell. La forma de salir es mediante
# return a través de una función.

Setup() {
    # Comprobar que el script se llama con 'source'
    if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then 
        echo "Ejecutar con 'source $0' o '. $0'"
        echo "Esto es necesario para que se cree el Entorno Virtual en la shell actual."
        echo ""
        exit 1 
    fi

    # No ejecutar con EV activo
    if [[ "$VIRTUAL_ENV" != "" ]]; then
        echo "El Entorno Virtual debe estar desactivado con 'deactivate'"
        return 1
    fi

    if [[ -d ./venv ]]; then
        echo "El Entorno Virtual ./venv ya existe. Borrar para crearlo de nuevo"
        return 1
    fi

    # Sin EV activo aún, comprobar dependencias paquetes globales.
    MISSING_PACKAGES=""
    echo -n "Comprobando dependencias globales..."
    for gp in $GLOBAL_PACKAGES; do
        if ! pip show "$gp" &>/dev/null; then
            MISSING_PACKAGES="$MISSING_PACKAGES $gp"
        fi
    done
    if [[ -n "$MISSING_PACKAGES" ]]; then
        echo "Faltan paquetes!!!. Instalar sin EV con:"
        echo "pip install $MISSING_PACKAGES"
    else
        echo "Todo instalado."
    fi

    # Crear el entorno virtual
    echo "Creando EV..."
    if ! python -m venv venv; then
        return 1
    fi

    # Activar el entorno virtual
    echo "Activando EV..."
    if ! source venv/bin/activate; then
        return 1
    fi

    # Instalar librerías en el entorno virtual
    echo "Instalando librerías en el EV..."
    if ! pip install -v $LOCAL_PACKAGES; then
        return 1
    fi

    echo "Instalación y activación del EV completadas. Ya puedes ejecutar ./chat.sh."
    echo "Recuerda salir del EV cuando acabes con 'deactivate'."
}

Setup