#!/bin/bash
# By José Puga for Óptima Quantum
VERSION=0.0.1
MODEL_NAME="falcon7b"

LOG_FILE="$MODEL_NAME-$(date +%y%m%d-%H%M%S).log"
CONFIG_FILE="$MODEL_NAME-config.json"

UVICORN_PORT=8088
UVICORN_HOST=127.0.0.1 # Usar 0.0.0.0 para broadcast
UVICORN_URL="http://127.0.0.1:$UVICORN_PORT/chat"

echo "Chat Bash v$VERSION."

if ! command -v &>/dev/null jq; then
    echo "Hace falta instalar jq para procesar JSON en Bash."
    exit 1
fi

echo "Sesión guardada en $LOG_FILE. Usar CTR-C para salir"

# Hay que crear el fichero de configuración si no existe.
if [[ ! -f "$CONFIG_FILE" ]]; then
    cat > "$CONFIG_FILE" <<EOF
{
    "max_new_tokens": 200,
    "repetition_penalty": 1.2,
    "temperature": 0.7,
    "top_p": 0.9
}
EOF
    echo "Archivo de configuración creado: $CONFIG_FILE"
fi

set -x

uvicorn "$MODEL_NAME:app" \
    --host $UVICORN_HOST \
    --port $UVICORN_PORT \
    --reload &>/dev/null & # Quitar la redireccion null para depurar.
UVICORN_PID=$!
echo "Proceso: $UVICORN_PID"

#Comprobar que el servidor FastAPI se haya lanzado
if [[ -z "$UVICORN_PID" || "$UVICORN_PID" -le 0 ]]; then
    echo "Error $UVICORN_PID al iniciar el servidor uvicorn"
    exit 1
fi

Cleanup() {
    echo -e "\nCerrando Uvicorn..."
    kill -9 $UVICORN_PID
    exit 0
}

# Capturar CTRL-C para cerrar el uvicron
trap Cleanup SIGINT

# Pausa de 1 segundo para darle tiempo a uvicorn a lanzarse
sleep 1
echo ""

while read -r -p ">" line
do
    printf ">%s\n" "$line" >> "$LOG_FILE"

    # Antes de enviar la linea, leemos los parámetros del modelo del json
    max_new_tokens=$(jq -r '.max_new_tokens' "$CONFIG_FILE")
    repetition_penalty=$(jq -r '.repetition_penalty' "$CONFIG_FILE")
    temperature=$(jq -r '.temperature' "$CONFIG_FILE")
    top_p=$(jq -r '.top_p' "$CONFIG_FILE")

    # Esta linea se muestra en el chat y en el log, una forma cómoda de ver los parámetros.
    # Los pongo abreviado para facilitar la lectura.
    model_info="max_tok=$max_new_tokens. rep_pen=$repetition_penalty. temp=$temperature. top_p=$top_p"
    echo "$model_info" | tee -a "$LOG_FILE"

    json_response=$(curl -X POST "$UVICORN_URL" \
        -H "Content-Type: application/json" \
        -d "{
            \"prompt\": \"$line\",
            \"max_new_tokens\": $max_new_tokens,
            \"repetition_penalty\": $repetition_penalty,
            \"temperature\": $temperature,
            \"top_p\": $top_p}")

    echo "$json_response" >> responses.log

    response=$(echo "$json_response" | jq -r '.response')
    printf "\nBot: %s\n" "$response" | tee -a "$LOG_FILE"
done