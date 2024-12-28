import json
from fastapi import FastAPI, Body
from transformers import AutoModelForCausalLM, AutoTokenizer

app = FastAPI()

model_name = "tiiuae/falcon-7b"
tokenizer = AutoTokenizer.from_pretrained(model_name)
model = AutoModelForCausalLM.from_pretrained(model_name, trust_remote_code=True, device_map="auto")

def load_config():
    with open("config.json", "r") as f:
        return json.load(f)

@app.post("/chat")
async def chat(prompt: str = Body(..., embed=True)):
    # Cargar configuración dinámica desde config.json
    config = load_config()
    max_new_tokens = config.get("max_new_tokens", 200)
    repetition_penalty = config.get("repetition_penalty", 1.2)
    temperature = config.get("temperature", 0.7)
    top_p = config.get("top_p", 0.9)

    # Generar respuesta con parámetros dinámicos
    inputs = tokenizer(prompt, return_tensors="pt")
    outputs = model.generate(
        **inputs,
        max_new_tokens=max_new_tokens,
        repetition_penalty=repetition_penalty,
        temperature=temperature,
        top_p=top_p
    )
    response = tokenizer.decode(outputs[0], skip_special_tokens=True)
    return {"response": response}
