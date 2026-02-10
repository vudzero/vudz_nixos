# AI/LLM configuration module
# Import this file to enable local LLM capabilities with GPU acceleration
# Remove the import to disable all AI components

{ config, pkgs, ... }:

{
  # Enable graphics/Vulkan support for GPU acceleration
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Ollama service with Vulkan GPU acceleration (AMD GPU support)
  services.ollama = {
    enable = true;
    package = pkgs.ollama.override { acceleration = "vulkan"; };
    # Preload a small starter model for immediate use
    loadModels = [ "llama3.2:3b" ];
  };

  # Web UI for easier experimentation
  services.open-webui = {
    enable = true;
    port = 8080;
  };

  # Add user to render group for GPU access
  users.users.matx.extraGroups = [ "render" ];

  # Useful AI/LLM tools
  environment.systemPackages = with pkgs; [
    ollama # CLI tool for running LLMs
  ];

  # Open firewall for Open-WebUI if needed
  networking.firewall.allowedTCPPorts = [ 8080 ];
}
