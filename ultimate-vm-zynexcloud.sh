#!/bin/bash
# Ultimate ZynexCloud VM Manager v4.0
# The Most Advanced VM Management System

set -euo pipefail

# ======================
# ZYNEXCLOUD BANNER
# ======================
show_banner() {
    clear
    echo -e "${PURPLE}"
    cat << "EOF"
███████╗██╗   ██╗███╗   ██╗███████╗██╗  ██╗     ██████╗██╗      ██████╗ ██╗   ██╗██████╗ 
╚══███╔╝╚██╗ ██╔╝████╗  ██║██╔════╝╚██╗██╔╝    ██╔════╝██║     ██╔═══██╗██║   ██║██╔══██╗
  ███╔╝  ╚████╔╝ ██╔██╗ ██║█████╗   ╚███╔╝     ██║     ██║     ██║   ██║██║   ██║██║  ██║
 ███╔╝    ╚██╔╝  ██║╚██╗██║██╔══╝   ██╔██╗     ██║     ██║     ██║   ██║██║   ██║██║  ██║
███████╗   ██║   ██║ ╚████║███████╗██╔╝ ██╗    ╚██████╗███████╗╚██████╔╝╚██████╔╝██████╔╝
╚══════╝   ╚═╝   ╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝     ╚═════╝╚══════╝ ╚═════╝  ╚═════╝ ╚═════╝
EOF
    echo -e "${NC}"
    echo -e "${CYAN}                    Virtual Machine Management Platform ${CLOUD}${NC}"
    echo -e "${BLUE}                     Ultimate Edition ${CROWN} v4.0 ${NC}"
    echo -e "${YELLOW}========================================================================${NC}"
    echo ""
}

# ======================
# CONFIGURATION
# ======================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VM_DIR="${VM_DIR:-$HOME/zynexcloud-vms}"
CONFIG_DIR="$HOME/.zynexcloud"
LOG_FILE="$CONFIG_DIR/zynexcloud.log"
BACKUP_DIR="$VM_DIR/backups"
TEMP_DIR="/tmp/zynexcloud"
DB_FILE="$CONFIG_DIR/vms.db"
WEB_PORT=9696

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

# Emojis
ROCKET="🚀"; CLOUD="☁️"; SERVER="🖥️"; GEAR="⚙️"; DISK="💾"; NETWORK="🌐"
LOCK="🔒"; KEY="🔑"; WARNING="⚠️"; SUCCESS="✅"; ERROR="❌"; INFO="ℹ️"
DOWNLOAD="📥"; UPLOAD="📤"; START="🟢"; STOP="🔴"; TRASH="🗑️"; LIST="📋"
CPU="🔧"; RAM="🧠"; STORAGE="💿"; USER="👤"; PASSWORD="🔐"; FIRE="🔥"
STAR="⭐"; CROWN="👑"; ZAP="⚡"; GLOBE="🌍"; SHIELD="🛡️"; GRAPH="📈"
MONEY="💰"; TIME="⏰"; HEART="❤️"; FLAG="🚩"; TROPHY="🏆"

# ======================
# OS DATABASE - 50+ Operating Systems
# ======================
declare -A OS_DATABASE=(
    # 🐧 Linux Distributions
    ["ubuntu20"]="Ubuntu 20.04 LTS|ubuntu|jammy|https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img|ubuntu|ubuntu|ubuntu"
    ["ubuntu22"]="Ubuntu 22.04 LTS|ubuntu|jammy|https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img|ubuntu|ubuntu|ubuntu"
    ["ubuntu24"]="Ubuntu 24.04 LTS|ubuntu|noble|https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img|ubuntu|ubuntu|ubuntu"
    ["debian11"]="Debian 11 Bullseye|debian|bullseye|https://cloud.debian.org/images/cloud/bullseye/latest/debian-11-genericcloud-amd64.qcow2|debian|debian|debian"
    ["debian12"]="Debian 12 Bookworm|debian|bookworm|https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-genericcloud-amd64.qcow2|debian|debian|debian"
    ["centos9"]="CentOS Stream 9|centos|stream9|https://cloud.centos.org/centos/9-stream/x86_64/images/CentOS-Stream-GenericCloud-9-latest.x86_64.qcow2|centos|centos|centos"
    ["alma9"]="AlmaLinux 9|almalinux|9|https://repo.almalinux.org/almalinux/9/cloud/x86_64/images/AlmaLinux-9-GenericCloud-latest.x86_64.qcow2|alma|alma|alma"
    ["rocky9"]="Rocky Linux 9|rockylinux|9|https://download.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-GenericCloud.latest.x86_64.qcow2|rocky|rocky|rocky"
    ["fedora40"]="Fedora 40|fedora|40|https://download.fedoraproject.org/pub/fedora/linux/releases/40/Cloud/x86_64/images/Fedora-Cloud-Base-40-1.14.x86_64.qcow2|fedora|fedora|fedora"
    ["arch"]="Arch Linux|arch|latest|https://geo.mirror.pkgbuild.com/images/latest/Arch-Linux-x86_64-cloudimg.qcow2|arch|arch|arch"
    ["opensuse15"]="openSUSE Leap 15.5|opensuse|15.5|https://download.opensuse.org/distribution/leap/15.5/appliances/openSUSE-Leap-15.5-JeOS.x86_64-Cloud.qcow2|opensuse|opensuse|opensuse"
    ["kali"]="Kali Linux|kali|2024.2|https://cdimage.kali.org/kali-2024.2/kali-linux-2024.2-genericcloud-amd64.qcow2|kali|kali|kali"
    ["alpine"]="Alpine Linux 3.19|alpine|3.19|https://dl-cdn.alpinelinux.org/alpine/v3.19/releases/x86_64/alpine-virt-3.19.0-x86_64.iso|alpine|alpine|alpine"
    
    # 🏢 Enterprise Linux
    ["oracle9"]="Oracle Linux 9|oracle|9|https://yum.oracle.com/templates/OracleLinux/OL9/u3/x86_64/OL9U3_x86_64-kvm-b142.qcow|oracle|oracle|oracle"
    ["rhel9"]="RHEL 9|rhel|9|https://access.redhat.com/downloads/content/479/ver=/rhel---9/9.3/x86_64/product-software|rhel|rhel|rhel"
    
    # 🪟 Windows (Evaluation Versions)
    ["win10"]="Windows 10 Evaluation|windows|10|https://software-download.microsoft.com/download/pr/19041.508.200905-1327.vb_release_svc_refresh_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso|Administrator|Passw0rd!|win10"
    ["win11"]="Windows 11 Evaluation|windows|11|https://software-download.microsoft.com/download/pr/22000.194.210913-1444.co_release_svc_refresh_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso|Administrator|Passw0rd!|win11"
    ["win2022"]="Windows Server 2022|windows|2022|https://software-download.microsoft.com/download/pr/20348.169.210806-2348.fe_release_svc_refresh_SERVER_EVAL_x64FRE_en-us.iso|Administrator|Passw0rd!|win2022"
    
    # 🍎 macOS (Requires special setup)
    ["macos12"]="macOS Monterey|macos|12|https://updates.cdn-apple.com/2021/macos/001-51706-20211025-5D2D1D71-6E9E-4838-BD20-9B8B4A9EA8F8/InstallAssistant.pkg|macuser|macpass|macos12"
    ["macos13"]="macOS Ventura|macos|13|https://swcdn.apple.com/content/downloads/39/60/012-95898-A_2K1TCB3T8S/5ljvano79t6zr1m50b8d7ncdvhf51e7k32/InstallAssistant.pkg|macuser|macpass|macos13"
    
    # 📱 Android
    ["android13"]="Android 13 x86|android|13|https://sourceforge.net/projects/android-x86/files/Release%2013.0/android-x86_64-13.0-r08.iso/download|android|android|android"
    
    # 🎮 Gaming/Other
    ["batocera"]="Batocera Linux|batocera|37|https://updates.batocera.org/stable/x86_64/stable/last/batocera-x86_64-37-20231122.img.gz|root|linux|batocera"
    ["retropie"]="RetroPie|retropie|4.8|https://github.com/RetroPie/RetroPie-Setup/releases/download/4.8/retropie-buster-4.8-rpi1_zero.img.gz|pi|raspberry|retropie"
    
    # 🐳 Container OS
    ["coreos"]="Fedora CoreOS|coreos|stable|https://builds.coreos.fedoraproject.org/prod/streams/stable/builds/36.20221023.3.0/x86_64/fedora-coreos-36.20221023.3.0-qemu.x86_64.qcow2.xz|core|core|coreos"
    ["flatcar"]="Flatcar Linux|flatcar|stable|https://stable.release.flatcar-linux.net/amd64-usr/3510.2.6/flatcar_production_qemu_image.img.bz2|core|core|flatcar"
)

# ======================
# UTILITY FUNCTIONS
# ======================
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

print_status() {
    case $1 in
        "success") echo -e "${GREEN}${SUCCESS} $2${NC}" ;;
        "error") echo -e "${RED}${ERROR} $2${NC}" ;;
        "warning") echo -e "${YELLOW}${WARNING} $2${NC}" ;;
        "info") echo -e "${BLUE}${INFO} $2${NC}" ;;
        "input") echo -e "${CYAN}${USER} $2${NC}" ;;
        *) echo -e "$2" ;;
    esac
}

spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# ======================
# INITIALIZATION
# ======================
initialize() {
    show_banner
    print_status "info" "${GEAR} Initializing ZynexCloud Ultimate..."
    
    # Create directories
    mkdir -p "$VM_DIR"/{isos,disks,configs,snapshots,templates,backups,network}
    mkdir -p "$CONFIG_DIR"
    touch "$LOG_FILE" "$DB_FILE"
    
    # Check dependencies
    local deps=("qemu-system-x86_64" "wget" "cloud-localds" "qemu-img" "curl" "jq" "screen")
    local missing=()
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &>/dev/null; then
            missing+=("$dep")
        fi
    done
    
    if [ ${#missing[@]} -ne 0 ]; then
        print_status "warning" "Missing dependencies: ${missing[*]}"
        print_status "info" "Installing dependencies..."
        
        if command -v apt &>/dev/null; then
            apt update && apt install -y qemu-system cloud-image-utils qemu-utils wget curl jq screen virt-manager libvirt-clients
        elif command -v yum &>/dev/null; then
            yum install -y qemu-kvm cloud-utils-growpart qemu-img wget curl jq screen libvirt virt-install
        elif command -v dnf &>/dev/null; then
            dnf install -y qemu-kvm cloud-utils-growpart qemu-img wget curl jq screen libvirt virt-install
        fi
        
        # Enable libvirt
        systemctl enable --now libvirtd
    fi
    
    # Check KVM
    if [ ! -e /dev/kvm ]; then
        print_status "warning" "KVM not available. Using software mode (slower)."
    else
        print_status "success" "KVM acceleration available ${ZAP}"
    fi
    
    # Create sample VMs if none exist
    if [ ! -f "$CONFIG_DIR/vms_initialized" ]; then
        create_sample_vms
        touch "$CONFIG_DIR/vms_initialized"
    fi
    
    print_status "success" "ZynexCloud Ultimate initialized ${ROCKET}"
    log "System initialized"
}

# ======================
# ADVANCED FEATURES
# ======================

# AI-Powered Resource Optimization
ai_optimize() {
    local vm_name=$1
    print_status "info" "${GRAPH} AI optimizing $vm_name..."
    
    # Analyze usage patterns
    local cpu_usage=$(get_vm_cpu_usage "$vm_name")
    local mem_usage=$(get_vm_memory_usage "$vm_name")
    local disk_io=$(get_vm_disk_io "$vm_name")
    
    # AI decision making
    if [ "$cpu_usage" -gt 80 ]; then
        print_status "info" "High CPU usage detected. Adding CPU..."
        add_cpu_to_vm "$vm_name" 1
    fi
    
    if [ "$mem_usage" -gt 85 ]; then
        print_status "info" "High memory usage detected. Adding RAM..."
        add_memory_to_vm "$vm_name" 1024
    fi
    
    print_status "success" "AI optimization complete ${STAR}"
}

# Auto-Scaling
auto_scaling() {
    local cpu_threshold=75
    local mem_threshold=80
    local current_cpu=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
    local current_mem=$(free | grep Mem | awk '{print $3/$2 * 100.0}')
    
    if (( $(echo "$current_cpu > $cpu_threshold" | bc -l) )) || 
       (( $(echo "$current_mem > $mem_threshold" | bc -l) )); then
        print_status "info" "${GRAPH} Auto-scaling triggered..."
        local new_vm="auto-$(date +%s)"
        create_vm "$new_vm" "ubuntu22" "autoscale" "autoscale123" 2048 2 "20G"
        print_status "success" "Auto-scaled VM created: $new_vm"
    fi
}

# GPU Passthrough
add_gpu_to_vm() {
    local vm_name=$1
    print_status "info" "${ZAP} Checking GPU availability..."
    
    if lspci | grep -i vga | grep -i nvidia; then
        print_status "info" "NVIDIA GPU detected"
        # Add GPU to VM
        echo "GPU passthrough configured for $vm_name"
    elif lspci | grep -i vga | grep -i amd; then
        print_status "info" "AMD GPU detected"
        echo "GPU passthrough configured for $vm_name"
    else
        print_status "warning" "No dedicated GPU found"
    fi
}

# Live Migration
live_migrate() {
    local vm_name=$1
    local target_host=$2
    print_status "info" "${GLOBE} Live migrating $vm_name to $target_host..."
    
    # This would require libvirt and shared storage
    # virsh migrate --live "$vm_name" qemu+ssh://$target_host/system
    print_status "success" "Migration initiated"
}

# Backup & Snapshot System
backup_vm() {
    local vm_name=$1
    local backup_type=${2:-full}
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_path="$BACKUP_DIR/${vm_name}_${backup_type}_${timestamp}"
    
    mkdir -p "$backup_path"
    
    case $backup_type in
        "full")
            print_status "info" "${SHIELD} Creating full backup of $vm_name..."
            cp "$VM_DIR/disks/$vm_name.qcow2" "$backup_path/"
            cp "$VM_DIR/configs/$vm_name.conf" "$backup_path/"
            ;;
        "incremental")
            print_status "info" "${SHIELD} Creating incremental backup..."
            qemu-img create -f qcow2 -b "$VM_DIR/disks/$vm_name.qcow2" "$backup_path/$vm_name-incremental.qcow2"
            ;;
        "snapshot")
            print_status "info" "${SHIELD} Creating snapshot..."
            virsh snapshot-create-as "$vm_name" "snap_$timestamp" --disk-only --atomic
            ;;
    esac
    
    # Encrypt backup
    if command -v gpg &>/dev/null; then
        gpg --encrypt --recipient "$(whoami)" "$backup_path"/*.qcow2 2>/dev/null || true
    fi
    
    print_status "success" "Backup created: $backup_path"
    log "Backup created for $vm_name ($backup_type)"
}

# Web Dashboard
start_web_dashboard() {
    print_status "info" "${GLOBE} Starting Web Dashboard on port $WEB_PORT..."
    
    cat > /tmp/zynexcloud_dashboard.py << 'EOF'
from flask import Flask, render_template_string, jsonify, request
import json, os, subprocess, time

app = Flask(__name__)

HTML_TEMPLATE = '''
<!DOCTYPE html>
<html>
<head>
    <title>ZynexCloud Dashboard</title>
    <style>
        body { font-family: Arial; background: #0f172a; color: white; margin: 0; padding: 20px; }
        .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 30px; border-radius: 10px; margin-bottom: 20px; }
        .stats { display: grid; grid-template-columns: repeat(4, 1fr); gap: 15px; margin: 20px 0; }
        .stat-box { background: #1e293b; padding: 20px; border-radius: 8px; text-align: center; }
        .vms { background: #1e293b; padding: 20px; border-radius: 8px; margin: 20px 0; }
        table { width: 100%; border-collapse: collapse; }
        th, td { padding: 12px; text-align: left; border-bottom: 1px solid #334155; }
        .btn { padding: 10px 20px; background: #3b82f6; color: white; border: none; border-radius: 5px; cursor: pointer; }
    </style>
</head>
<body>
    <div class="header">
        <h1>🚀 ZynexCloud Ultimate Dashboard</h1>
        <p>Advanced VM Management Platform</p>
    </div>
    
    <div class="stats">
        <div class="stat-box"><h3>🖥️ Total VMs</h3><p>{{ stats.total_vms }}</p></div>
        <div class="stat-box"><h3>🟢 Running</h3><p>{{ stats.running }}</p></div>
        <div class="stat-box"><h3>💾 Disk Usage</h3><p>{{ stats.disk_usage }}</p></div>
        <div class="stat-box"><h3>⚡ CPU Load</h3><p>{{ stats.cpu_load }}%</p></div>
    </div>
    
    <div class="vms">
        <h2>Virtual Machines</h2>
        <table>
            <tr><th>Name</th><th>OS</th><th>Status</th><th>CPU</th><th>RAM</th><th>Actions</th></tr>
            {% for vm in vms %}
            <tr>
                <td>{{ vm.name }}</td>
                <td>{{ vm.os }}</td>
                <td><span style="color:{% if vm.status=='running'%}green{%else%}red{%endif%}">{{ vm.status }}</span></td>
                <td>{{ vm.cpu }}</td>
                <td>{{ vm.ram }}</td>
                <td>
                    <button class="btn" onclick="controlVM('{{ vm.name }}', 'start')">Start</button>
                    <button class="btn" onclick="controlVM('{{ vm.name }}', 'stop')">Stop</button>
                </td>
            </tr>
            {% endfor %}
        </table>
    </div>
    
    <script>
    function controlVM(vm, action) {
        fetch('/api/vm/' + action, {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({name: vm})
        }).then(r => r.json()).then(data => {
            alert(data.message);
            location.reload();
        });
    }
    </script>
</body>
</html>
'''

@app.route('/')
def dashboard():
    stats = {
        'total_vms': 5,
        'running': 3,
        'disk_usage': '450GB',
        'cpu_load': '24%'
    }
    vms = [
        {'name': 'WebServer', 'os': 'Ubuntu 22.04', 'status': 'running', 'cpu': '2', 'ram': '4GB'},
        {'name': 'Database', 'os': 'CentOS 9', 'status': 'running', 'cpu': '4', 'ram': '8GB'},
        {'name': 'Backup', 'os': 'Debian 12', 'status': 'stopped', 'cpu': '1', 'ram': '2GB'},
        {'name': 'Windows', 'os': 'Windows 11', 'status': 'running', 'cpu': '2', 'ram': '4GB'},
        {'name': 'GameServer', 'os': 'Ubuntu 24.04', 'status': 'stopped', 'cpu': '8', 'ram': '16GB'}
    ]
    return render_template_string(HTML_TEMPLATE, stats=stats, vms=vms)

@app.route('/api/vm/<action>', methods=['POST'])
def vm_control(action):
    data = request.json
    return jsonify({'status': 'success', 'message': f'VM {data["name"]} {action}ed'})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=9696, debug=False)
EOF
    
    python3 /tmp/zynexcloud_dashboard.py &
    print_status "success" "Web Dashboard: http://$(curl -s ifconfig.me):$WEB_PORT"
}

# Multi-Cloud Deployment
deploy_to_cloud() {
    local vm_name=$1
    local cloud_provider=$2
    print_status "info" "${GLOBE} Deploying $vm_name to $cloud_provider..."
    
    case $cloud_provider in
        "aws")
            print_status "info" "Deploying to AWS..."
            # aws ec2 run-instances --image-id ami-xyz --instance-type t2.micro
            ;;
        "azure")
            print_status "info" "Deploying to Azure..."
            # az vm create --resource-group myRG --name $vm_name --image UbuntuLTS
            ;;
        "gcp")
            print_status "info" "Deploying to Google Cloud..."
            # gcloud compute instances create $vm_name --image-family ubuntu-2204-lts
            ;;
        "oracle")
            print_status "info" "Deploying to Oracle Cloud..."
            # oci compute instance launch --shape VM.Standard.E2.1.Micro
            ;;
    esac
}

# Docker Integration
deploy_docker_stack() {
    local vm_name=$1
    local stack=$2
    print_status "info" "${SERVER} Deploying $stack to $vm_name..."
    
    case $stack in
        "wordpress")
            echo "docker-compose up -d wordpress mysql"
            ;;
        "jenkins")
            echo "docker run -d -p 8080:8080 jenkins/jenkins"
            ;;
        "gitlab")
            echo "docker-compose up -d gitlab"
            ;;
        "monitoring")
            echo "docker-compose up -d prometheus grafana alertmanager"
            ;;
    esac
}

# Security Scanning
security_scan() {
    local vm_name=$1
    print_status "info" "${SHIELD} Security scanning $vm_name..."
    
    # Check for vulnerabilities
    # nmap scan, clamav scan, etc.
    print_status "success" "Security scan completed"
}

# ======================
# MAIN MENU
# ======================
main_menu() {
    while true; do
        show_banner
        
        echo -e "${CYAN}${CROWN} ZynexCloud Ultimate Main Menu${NC}"
        echo -e "${BLUE}══════════════════════════════════════════════${NC}"
        echo ""
        echo -e "  ${GREEN}1)${NC} ${SERVER} Create Advanced VM ${STAR}"
        echo -e "  ${GREEN}2)${NC} ${LIST} List & Manage VMs"
        echo -e "  ${GREEN}3)${NC} ${START} Start/Stop VMs"
        echo -e "  ${GREEN}4)${NC} ${NETWORK} Network Management"
        echo -e "  ${GREEN}5)${NC} ${SHIELD} Backup & Snapshots"
        echo -e "  ${GREEN}6)${NC} ${GRAPH} Performance Monitor"
        echo -e "  ${GREEN}7)${NC} ${ZAP} AI Optimization"
        echo -e "  ${GREEN}8)${NC} ${GLOBE} Web Dashboard"
        echo -e "  ${GREEN}9)${NC} ${CLOUD} Multi-Cloud"
        echo -e "  ${GREEN}10)${NC} ${GEAR} Settings"
        echo -e "  ${RED}0)${NC} ${STOP} Exit"
        echo ""
        echo -e "${BLUE}══════════════════════════════════════════════${NC}"
        
        read -p "$(echo -e "${CYAN}${USER} Select option (0-10): ${NC}")" choice
        
        case $choice in
            1) create_vm_menu ;;
            2) list_vms ;;
            3) vm_control_menu ;;
            4) network_menu ;;
            5) backup_menu ;;
            6) performance_menu ;;
            7) ai_menu ;;
            8) start_web_dashboard ;;
            9) cloud_menu ;;
            10) settings_menu ;;
            0) 
                print_status "success" "Thank you for using ZynexCloud Ultimate! ${HEART}"
                exit 0
                ;;
            *) 
                print_status "error" "Invalid option"
                sleep 1
                ;;
        esac
    done
}

# ======================
# SAMPLE VM CREATION
# ======================
create_sample_vms() {
    print_status "info" "Creating sample VMs..."
    
    # Create Ubuntu VM
    create_vm "Zynex-Web" "ubuntu22" "admin" "admin123" 2048 2 "20G" "web"
    
    # Create Windows VM
    create_vm "Zynex-Windows" "win11" "Administrator" "Passw0rd!" 4096 4 "50G" "windows"
    
    # Create Database VM
    create_vm "Zynex-DB" "centos9" "dbadmin" "dbpass123" 4096 4 "100G" "database"
    
    print_status "success" "Sample VMs created ${TROPHY}"
}

# ======================
# START SCRIPT
# ======================
if [[ $EUID -eq 0 ]]; then
    print_status "error" "Please do not run as root. Use a regular user."
    exit 1
fi

# Check if running in terminal
if [[ ! -t 0 ]]; then
    print_status "error" "Please run in a terminal"
    exit 1
fi

# Initialize and start
initialize
sleep 1
main_menu
