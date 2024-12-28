# Chat test con Falcon 7B
Esto es **una prueba de concepto** para entrenar la IA de Falcon 7B.

El principio es probarlo en cualquier momento sin preocuparse de instalaciones manuales. Basta tener un linux con python y seguir las instrucciones.


## Ficheros que contiene el proyecto
- `setup.sh`:
  - Crea el Entorno Virtual (EV)
  - Lo activa
  - Descarga todos los paquetes necesarios para el proyecto

- `chat.sh`:
  - Un simple chat en Bash, ideal si queremos probar de forma rápida sin tener que instalar nada más. 
  - Crea también logs de cada sesión en el formato `falcon7b-AAMMDD-hhmm.log`
  - Para evitar conflictos, lanza su propio uvicorn (servidor FastAPI) en otro puerto y gestiona su conexión.

- `falcon7b-config.json`:
  - Contiene los parámetros para entrenar al modelo, puede editarse mientras se chatea antes de lanzar una petición. El chat monstrará también dicha configuración junto a la respuesta.
  - Partiendo de una base podemos definir:
    - Respuestas coherentes:
      - repetition_penalty=1.2
      - temperature=0.7
      - top_p=0.9
    - Respuestas creativas:
      - repetition_penalty=1.0
      - temperature=1.0
      - top_p=0.95

- `falcon7b.py`: 
  - Usado por `chat.sh`, no hace falta ejecutarlo directamente. Ejecuta las llamadas al motor IA.


## Instrucciones
```bash
git clone https://github.com/josepuga/test-falcon7b
cd test-falcon7b
source ./setup.sh
``` 

Si no hubo error, sólo queda ejecutar el chat

```bash
./chat.sh
```

## Ejemplo de sesión
