{ config, pkgs, ... }:

{
  services.ollama = {
    enable = true;
    # package = pkgs.ollama; # Options: ollama, ollama-vulkan, ollama-rocm, ollama-cuda, ollama-cpu
    host = "0.0.0.0";
    openFirewall = true;
    loadModels = [
      "qwen2.5-coder:3b"
      "hf.co/mradermacher/Dolphin3.0-Qwen2.5-0.5B-GGUF:Q8_0"
      "hf.co/Qwen/Qwen2.5-Coder-1.5B-Instruct-GGUF:Q4_K_M"
      "mxbai-embed-large:latest"
    ];
  };
}
