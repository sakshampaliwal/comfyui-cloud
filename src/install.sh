#!/bin/bash

USER_NAME=$(whoami)
USER_HOME=$(eval echo ~$USER_NAME)

echo "Current directory: $(pwd)"

# Since you're running from src and ComfyUI is inside src
script_dir=$(dirname "$(realpath "$0")")
comfy_ui_dir="$script_dir/ComfyUI"

echo "Script directory: $script_dir"
echo "ComfyUI directory: $comfy_ui_dir"

PYTHON_PATH="${USER_HOME}/miniconda3/bin/python"
BASHRC_PATH="${USER_HOME}/.bashrc"
COMFYUI_RUNNER_PATH="${comfy_ui_dir}/main.py"

# Step 1: Install ComfyUI
chmod +x "$script_dir/install_comfyui.sh"
"$script_dir/install_comfyui.sh"

echo -e "\n ---------------- ComfyUI installed \n"

# Step 2: Copy automation scripts into ComfyUI directory
cp "$script_dir/install_extensions.sh" "$comfy_ui_dir/"
cp "$script_dir/install_checkpoints.sh" "$comfy_ui_dir/"

echo -e "\n ---------------- Automation scripts copied to ComfyUI directory \n"

# Step 3: Install extensions and checkpoints
cd "$comfy_ui_dir" || { echo "ComfyUI directory not found!"; exit 1; }

chmod +x install_extensions.sh
chmod +x install_checkpoints.sh
./install_extensions.sh

echo -e "\n ---------------- Extensions installed \n"

./install_checkpoints.sh
# Uncomment below if needed
# ./install_checkpoints_big.sh

echo -e "\n ---------------- Checkpoints installed \n"

# Step 4: Create run_the_server.sh
cat <<EOF > run_the_server.sh
#!/bin/bash

BASHRC_PATH="$BASHRC_PATH"
PYTHON_PATH="$PYTHON_PATH"
COMFYUI_RUNNER_PATH="$COMFYUI_RUNNER_PATH"

# Source the bashrc file
source \$BASHRC_PATH

# Start ComfyUI
if ! sudo -u $USER_NAME \$PYTHON_PATH \$COMFYUI_RUNNER_PATH --listen; then
    echo "Error: Failed to start ComfyUI" >&2
fi
EOF

chmod +x run_the_server.sh

echo -e "\n ---------------- custom run_the_server.sh created \n"

# Step 5: Setup systemd service
SERVICE_FILE_CONTENT="[Unit]
Description=ComfyUI Server

[Service]
Type=simple
ExecStart=${comfy_ui_dir}/run_the_server.sh
Restart=always
User=$USER_NAME
WorkingDirectory=$comfy_ui_dir

[Install]
WantedBy=multi-user.target"

echo "$SERVICE_FILE_CONTENT" | sudo tee /etc/systemd/system/comfyui.service > /dev/null

sudo systemctl daemon-reload
sudo systemctl enable comfyui.service
sudo systemctl start comfyui.service

echo -e "\n ---------------- setup completed \n"

# Optional health check
IP_ADDRESS=$(curl -s httpbin.org/ip | jq -r .origin)
echo -e " ---------------- For health check go to: http://$IP_ADDRESS:8188 in your browser"
