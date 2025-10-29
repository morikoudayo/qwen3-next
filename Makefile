# Use bash instead of sh
SHELL := /bin/bash

# Docker image & model path
IMAGE = qwen3-next
MODEL_PATH = $(HOME)/models
MODEL_DIR = Qwen3-Next-80B-A3B-Instruct
MODEL_FILE = Qwen3-Next-80B-A3B-Instruct-Q4_K_M.gguf
MODEL_URL = https://huggingface.co/lefromage/Qwen3-Next-80B-A3B-Instruct-GGUF/resolve/main/Qwen__Qwen3-Next-80B-A3B-Instruct-Q4_K_M.gguf
DOCKER_RUN = docker run -p 60999:8080 --gpus all --cap-add=IPC_LOCK --ulimit memlock=-1:-1 --rm -v $(MODEL_PATH):/models $(IMAGE) bash -c

# ----------------------------------------
# Docker Build
# ----------------------------------------

# Build Docker image
build:
	docker build -t $(IMAGE) .

# ----------------------------------------
# Cases
# ----------------------------------------

# 共通実行コマンド
RUN_CMD = llama-server --host 0.0.0.0 -m /models/$(MODEL_DIR)/$(MODEL_FILE) --no-mmap --ctx-size 8192

# Download model
download-model:
	@mkdir -p $(MODEL_PATH)/$(MODEL_DIR)
	wget $(MODEL_URL) -O $(MODEL_PATH)/$(MODEL_DIR)/$(MODEL_FILE)

run:
	$(DOCKER_RUN) "$(RUN_CMD) \
		--override-tensor 'blk\.[0-9]\.ffn_down_exps\.weight=CPU' \
    --override-tensor 'blk\.[0-9]\.ffn_gate_exps\.weight=CPU' \
    --override-tensor 'blk\.[0-9]\.ffn_up_exps\.weight=CPU' \
		--override-tensor 'blk\.[1-2][0-9]\.ffn_down_exps\.weight=CPU' \
    --override-tensor 'blk\.[1-2][0-9]\.ffn_gate_exps\.weight=CPU' \
    --override-tensor 'blk\.[1-2][0-9]\.ffn_up_exps\.weight=CPU' \
		--override-tensor 'blk\.3[0-8]\.ffn_down_exps\.weight=CPU' \
    --override-tensor 'blk\.3[0-8]\.ffn_gate_exps\.weight=CPU' \
    --override-tensor 'blk\.3[0-8]\.ffn_up_exps\.weight=CPU'"

# ----------------------------------------
# Utility
# ----------------------------------------

.PHONY: build download-model run