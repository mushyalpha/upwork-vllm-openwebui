#!/usr/bin/env bash
# Start vLLM + Open WebUI on a stock RunPod GPU pod (no nested Docker).
set -euo pipefail

cd "$(dirname "$0")"

export HF_HOME="${HF_HOME:-/workspace/hf-cache}"
mkdir -p "$HF_HOME" /workspace/open-webui /workspace/logs

echo "==> GPU"
nvidia-smi

if ! python3 -c "import vllm" >/dev/null 2>&1; then
  python3 -m pip install -U --ignore-installed cryptography vllm
fi
if ! command -v open-webui >/dev/null 2>&1; then
  python3 -m pip install -U --ignore-installed cryptography open-webui
fi

if curl -sf http://127.0.0.1:8000/health >/dev/null 2>&1; then
  echo "==> vLLM already healthy on :8000"
else
  echo "==> Starting vLLM on :8000 (first model download can take 5–15 min)"
  nohup python3 -m vllm.entrypoints.openai.api_server \
    --model Qwen/Qwen2.5-7B-Instruct \
    --served-model-name Qwen2.5-7B-Instruct \
    --host 0.0.0.0 \
    --port 8000 \
    --dtype auto \
    --max-model-len 8192 \
    --gpu-memory-utilization 0.90 \
    >/workspace/logs/vllm.log 2>&1 &
  echo $! >/workspace/logs/vllm.pid

  for _ in $(seq 1 180); do
    if curl -sf http://127.0.0.1:8000/health >/dev/null 2>&1; then
      echo "==> vLLM is up"
      break
    fi
    sleep 5
  done
  if ! curl -sf http://127.0.0.1:8000/health >/dev/null 2>&1; then
    echo "vLLM failed to become healthy. Last log lines:"
    tail -80 /workspace/logs/vllm.log
    exit 1
  fi
fi

if curl -sf http://127.0.0.1:3000 >/dev/null 2>&1; then
  echo "==> Open WebUI already responding on :3000"
else
  echo "==> Starting Open WebUI on :3000"
  export ENABLE_OLLAMA_API=false
  export ENABLE_PERSISTENT_CONFIG=false
  export OPENAI_API_BASE_URL=http://127.0.0.1:8000/v1
  export OPENAI_API_KEY="not-needed"
  export DATA_DIR=/workspace/open-webui
  nohup open-webui serve --host 0.0.0.0 --port 3000 \
    >/workspace/logs/open-webui.log 2>&1 &
  echo $! >/workspace/logs/open-webui.pid
  sleep 8
fi

echo
echo "==> Screenshot 1: this nvidia-smi (vLLM should be listed under Processes)"
nvidia-smi
echo
curl -sS http://127.0.0.1:8000/v1/models
echo
echo "Open WebUI via RunPod Connect → HTTP service 3000"
echo "Keep GPU busy for screenshot 2:"
echo "  watch -n 0.5 nvidia-smi"
echo "Then send a long chat in Open WebUI so GPU-Util is not 0%."
