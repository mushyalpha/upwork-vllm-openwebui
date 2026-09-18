# vLLM + Open WebUI (Qwen2.5-7B-Instruct)

Official images in `docker-compose.yml`. Stock RunPod GPU pods cannot run Compose (the pod is already a container). On RunPod use `runpod-start.sh`.


## 1. Upload to GitHub (laptop)

GitHub website:

1. New repository → name it whatever you want → **private** is fine.
2. **Add file → Upload files**
3. Drop in: `docker-compose.yml`, `.gitignore`, `runpod-start.sh`, `README.md`
4. Commit. Copy the repo URL.

Or from a terminal:

```bash
cd ~/Desktop/upwork-vllm-openwebui
git init
git add docker-compose.yml .gitignore runpod-start.sh README.md
git commit -m "Add vLLM + Open WebUI RunPod sample."
gh repo create runpod-vllm-openwebui --private --source=. --remote=origin --push
```

## 2. Deploy the pod

In RunPod → Deploy:

- GPU with **≥24 GB** VRAM (4090 / L40S / A100 / H100)
- Template: **RunPod PyTorch** (or any CUDA image with Python)
- Volume **≥40 GB**, mount `/workspace`
- HTTP ports (must be set at create): **8888, 3000, 8000**
- Accept the Qwen2.5-Instruct license on Hugging Face before you start

## 3. On the pod

Web terminal or SSH:

```bash
cd /tmp
git clone https://github.com/mushyalpha/upwork-vllm-openwebui.git
mv upwork-vllm-openwebui /workspace/
cd /workspace/upwork-vllm-openwebui

chmod +x runpod-start.sh
./runpod-start.sh
```

First run downloads ~15 GB. Wait until the script prints `vLLM is up` and dumps `nvidia-smi`.

## 4. Screenshots (attach these to Upwork)

Open WebUI does not draw a GPU meter. Take **two** PNGs. Crop the pod ID, IP, spend, and any email.

**Shot 1 — GPU + vLLM process**

```bash
nvidia-smi
```

You want the GPU name, non-zero memory used, and a Python/`vllm` row under Processes. Save as `runpod-nvidia-smi-vllm.png`.

**Shot 2 — streaming chat + GPU busy**

Terminal:

```bash
watch -n 0.5 nvidia-smi
```

Browser: RunPod **Connect** → HTTP port **3000** → create a local admin account → pick `Qwen2.5-7B-Instruct` → send something long, e.g. "Explain paged attention in 8 paragraphs."

While tokens are still appearing, screenshot Open WebUI. GPU-Util in the other pane should not be 0%. Save as `open-webui-qwen25-7b-stream.png`.

If you cannot fit both panes in one image, two files are fine.

## 5. After you have the PNGs

Stop the pod so you are not billed. Attach the two PNGs plus `docker-compose.yml` on the proposal.
