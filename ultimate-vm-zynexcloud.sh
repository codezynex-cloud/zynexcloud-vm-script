#!/bin/bash

# ZynexCloud VM Manager 🌩️
# Works on any VPS/cloud server with KVM support

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.zynexcloud-vms"
LOG_FILE="$CONFIG_DIR/vm-manager.log"
VM_DIR="$HOME/zynexcloud-vms"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Emojis
ROCKET="🚀"
CLOUD="☁️"
SERVER="🖥️"
GEAR="⚙️"
DISK="💾"
NETWORK="🌐"
LOCK="🔒"
KEY="🔑"
WARNING="⚠️"
SUCCESS="✅"
ERROR="❌"
INFO="ℹ️"
DOWNLOAD="📥"
UPLOAD="📤"
START="🟢"
STOP="🔴"
TRASH="🗑️"
LIST="📋"
CPU="🔧"
RAM="🧠"
STORAGE="💿"

# ZynexCloud Banner
show_banner() {
    clear
    echo -e "${PURPLE}"
    echo "███████ ██    ██ ███    ██ ███████ ██   ██ ${CYAN} ██████ ██       ██████  ██████  ██████  ███████"
    echo "   ███  ██    ██ ████   ██ ██       ██ ██  ${CYAN}██      ██      ██    ██ ██   ██ ██   ██ ██     "
    echo "  ███   ██    ██ ██ ██  ██ █████     ███   ${CYAN}██      ██      ██    ██ ██████  ██   ██ █████"  
    echo " ███    ██    ██ ██  ██ ██ ██       ██ ██  ${CYAN}██      ██      ██    ██ ██   ██ ██   ██ ██    "
    echo "███████  ██████  ██   ████ ███████ ██  ██  ${CYAN} ██████ ███████  ██████  ██   ██ ██████  ███████"
    echo -e "${NC}"
    echo -e "${BLUE}            Virtual Machine Management Platform ${CLOUD}${NC}"
    echo -e "${CYAN}                  Powered by ZynexCloud Technology${NC}"
    echo -e "${YELLOW}===========================================================${NC}"
    echo
}

# Initialize setup
initialize_setup() {
    echo -e "${BLUE}${GEAR} Initializing ZynexCloud VM Environment...${NC}"
    
    mkdir -p "$CONFIG_DIR" "$VM_DIR"/{isos,disks,configs}
    touch "$LOG_FILE"
    
    # Check if KVM is available
    if ! grep -q "vmx\|svm" /proc/cpuinfo && [ ! -e /dev/kvm ]; then
        echo -e "${YELLOW}${WARNING} Warning: KVM acceleration not available. Will use QEMU in software mode.${NC}"
    else
        echo -e "${GREEN}${SUCCESS} KVM acceleration available${NC}"
    fi
    
    # Install dependencies
    echo -e "${BLUE}${DOWNLOAD} Installing dependencies...${NC}"
    if command -v apt-get >/dev/null 2>&1; then
        sudo apt-get update
        sudo apt-get install -y qemu-kvm libvirt-clients libvirt-daemon-system virtinst bridge-utils \
                               cloud-image-utils libguestfs-tools wget curl
    elif command -v yum >/dev/null 2>&1; then
        sudo yum install -y qemu-kvm libvirt libvirt-client virt-install bridge-utils \
                          cloud-utils-growpart libguestfs-tools wget curl
    elif command -v dnf >/dev/null 2>&1; then
        sudo dnf install -y qemu-kvm libvirt libvirt-client virt-install bridge-utils \
                          cloud-utils-growpart libguestfs-tools wget curl
    fi
    
    # Add user to libvirt group
    sudo usermod -a -G libvirt $(whoami)
    
    echo -e "${GREEN}${SUCCESS} ZynexCloud initialization completed! ${ROCKET}${NC}"
    log "ZynexCloud system initialized"
}

# Logging function
log() {
    echo "$(date): $1" >> "$LOG_FILE"
}

# Check if running on VPS
check_vps_environment() {
    if [ -f /proc/user_beancounters ] || 
       [ -d /proc/vz ] || 
       docker info 2>/dev/null | grep -q "Server Version" ||
       systemd-detect-virt -c 2>/dev/null | grep -q "container"; then
        echo -e "${RED}${ERROR} Error: This appears to be a container/VZ environment. KVM may not work.${NC}"
        return 1
    fi
    return 0
}

# Download cloud images
download_cloud_image() {
    local os_type=$1
    local image_url=""
    local image_name=""
    
    case $os_type in
        "ubuntu20")
            image_url="https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img"
            image_name="ubuntu-20.04-cloudimg.amd64.img"
            ;;
        "ubuntu22")
            image_url="https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
            image_name="ubuntu-22.04-cloudimg.amd64.img"
            ;;
        "ubuntu24")
            image_url="https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
            image_name="ubuntu-24.04-cloudimg.amd64.img"
            ;;
        "debian11")
            image_url="https://cloud.debian.org/images/cloud/bullseye/latest/debian-11-genericcloud-amd64.qcow2"
            image_name="debian-11-cloudimg.amd64.qcow2"
            ;;
        "debian12")
            image_url="https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-genericcloud-amd64.qcow2"
            image_name="debian-12-cloudimg.amd64.qcow2"
            ;;
        "centos9")
            image_url="https://cloud.centos.org/centos/9-stream/x86_64/images/CentOS-Stream-GenericCloud-9-latest.x86_64.qcow2"
            image_name="centos-9-stream-cloudimg.x86_64.qcow2"
            ;;
        "alma8")
            image_url="https://repo.almalinux.org/almalinux/8/cloud/x86_64/images/AlmaLinux-8-GenericCloud-latest.x86_64.qcow2"
            image_name="almalinux-8-cloudimg.x86_64.qcow2"
            ;;
        "rocky8")
            image_url="https://download.rockylinux.org/pub/rocky/8/images/Rocky-8-GenericCloud.latest.x86_64.qcow2"
            image_name="rocky-8-cloudimg.x86_64.qcow2"
            ;;
        *)
            echo -e "${RED}${ERROR} Unsupported OS type${NC}"
            return 1
            ;;
    esac
    
    local image_path="$VM_DIR/isos/$image_name"
    
    if [ ! -f "$image_path" ]; then
        echo -e "${BLUE}${DOWNLOAD} Downloading $os_type cloud image...${NC}"
        wget -O "$image_path" "$image_url"
        
        # Resize image to 10GB for practical use
        qemu-img resize "$image_path" 10G
        echo -e "${GREEN}${SUCCESS} Image downloaded and resized to 10GB${NC}"
    else
        echo -e "${GREEN}${SUCCESS} Cloud image already exists.${NC}"
    fi
    
    echo "$image_path"
}

# Generate cloud-init configuration
generate_cloud_init() {
    local vm_name=$1
    local username=$2
    local password=$3
    local ssh_key=$4
    
    local cloud_init_dir="$VM_DIR/configs/$vm_name-cloud-init"
    mkdir -p "$cloud_init_dir"
    
    # user-data
    cat > "$cloud_init_dir/user-data" << EOF
#cloud-config
hostname: $vm_name
manage_etc_hosts: true
users:
  - name: $username
    sudo: ALL=(ALL) NOPASSWD:ALL
    groups: users, admin
    home: /home/$username
    shell: /bin/bash
    lock_passwd: false
    passwd: $(echo "$password" | openssl passwd -6 -stdin)
    ssh-authorized-keys:
      - $ssh_key
chpasswd:
  list: |
    $username:$password
  expire: false
package_update: true
packages:
  - qemu-guest-agent
  - curl
  - wget
  - htop
  - nano
runcmd:
  - systemctl enable qemu-guest-agent
  - systemctl start qemu-guest-agent
  - sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config
  - systemctl restart ssh
final_message: "ZynexCloud VM ready! Welcome to $vm_name"
EOF

    # meta-data
    cat > "$cloud_init_dir/meta-data" << EOF
instance-id: $vm_name
local-hostname: $vm_name
cloud-name: zynexcloud
EOF

    # network-config
    cat > "$cloud_init_dir/network-config" << EOF
version: 2
ethernets:
  eth0:
    dhcp4: true
    dhcp6: false
    optional: false
EOF

    # Create ISO
    cloud-localds "$VM_DIR/disks/$vm_name-cloud-init.iso" \
        "$cloud_init_dir/user-data" \
        "$cloud_init_dir/meta-data" \
        "$cloud_init_dir/network-config"
    
    echo "$VM_DIR/disks/$vm_name-cloud-init.iso"
}

# Create VM
create_vm() {
    echo -e "${BLUE}${SERVER} Creating new ZynexCloud VM...${NC}"
    
    read -p "Enter VM name: " vm_name
    read -p "Enter username (default: admin): " username
    username=${username:-admin}
    read -s -p "Enter password: " password
    echo
    read -p "Enter SSH public key path (optional): " ssh_key_path
    
    if [ -n "$ssh_key_path" ] && [ -f "$ssh_key_path" ]; then
        ssh_key=$(cat "$ssh_key_path")
        echo -e "${GREEN}${KEY} SSH key loaded${NC}"
    else
        ssh_key=""
        echo -e "${YELLOW}${WARNING} No SSH key provided, using password only${NC}"
    fi
    
    echo -e "${CYAN}${LIST} Available OS images:${NC}"
    echo "1) ${GREEN}Ubuntu 20.04 LTS${NC} 🐧"
    echo "2) ${GREEN}Ubuntu 22.04 LTS${NC} 🐧" 
    echo "3) ${GREEN}Ubuntu 24.04 LTS${NC} 🐧"
    echo "4) ${YELLOW}Debian 11${NC} 🔸"
    echo "5) ${YELLOW}Debian 12${NC} 🔸"
    echo "6) ${RED}CentOS Stream 9${NC} 🔺"
    echo "7) ${PURPLE}AlmaLinux 8${NC} 💠"
    echo "8) ${BLUE}Rocky Linux 8${NC} 🏔️"
    
    read -p "Select OS (1-8): " os_choice
    
    case $os_choice in
        1) os_type="ubuntu20" ;;
        2) os_type="ubuntu22" ;;
        3) os_type="ubuntu24" ;;
        4) os_type="debian11" ;;
        5) os_type="debian12" ;;
        6) os_type="centos9" ;;
        7) os_type="alma8" ;;
        8) os_type="rocky8" ;;
        *) echo -e "${RED}${ERROR} Invalid selection${NC}"; return 1 ;;
    esac
    
    # Download cloud image
    echo -e "${BLUE}${DOWNLOAD} Preparing cloud image...${NC}"
    base_image=$(download_cloud_image "$os_type")
    if [ $? -ne 0 ]; then
        return 1
    fi
    
    # Create VM disk
    vm_disk="$VM_DIR/disks/$vm_name.qcow2"
    cp "$base_image" "$vm_disk"
    echo -e "${GREEN}${DISK} VM disk created${NC}"
    
    # Generate cloud-init ISO
    echo -e "${BLUE}${GEAR} Generating cloud-init configuration...${NC}"
    cloud_init_iso=$(generate_cloud_init "$vm_name" "$username" "$password" "$ssh_key")
    
    # Determine available memory and CPUs
    total_mem=$(free -g | awk '/^Mem:/{print $2}')
    available_mem=$((total_mem - 1))
    [ $available_mem -lt 1 ] && available_mem=1
    [ $available_mem -gt 8 ] && available_mem=8
    
    total_cpus=$(nproc)
    available_cpus=$((total_cpus - 1))
    [ $available_cpus -lt 1 ] && available_cpus=1
    [ $available_cpus -gt 4 ] && available_cpus=4
    
    read -p "Enter memory in GB (default: $available_mem): " mem_gb
    mem_gb=${mem_gb:-$available_mem}
    
    read -p "Enter CPU cores (default: $available_cpus): " cpu_cores
    cpu_cores=${cpu_cores:-$available_cpus}
    
    echo -e "${BLUE}${ROCKET} Launching VM...${NC}"
    
    # Create VM
    virt-install \
        --name "$vm_name" \
        --memory $((mem_gb * 1024)) \
        --vcpus "$cpu_cores" \
        --disk "$vm_disk",device=disk,bus=virtio \
        --disk "$cloud_init_iso",device=cdrom \
        --network network=default,model=virtio \
        --graphics spice \
        --video qxl \
        --channel unix,target_type=virtio,name=org.qemu.guest_agent.0 \
        --os-type linux \
        --os-variant generic \
        --import \
        --noautoconsole
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}${SUCCESS} ZynexCloud VM '$vm_name' created successfully! ${ROCKET}${NC}"
        echo -e "${CYAN}${INFO} VM Details:${NC}"
        echo -e "  ${CPU} Cores: $cpu_cores"
        echo -e "  ${RAM} Memory: ${mem_gb}GB"
        echo -e "  ${DISK} Disk: 10GB"
        echo -e "  ${NETWORK} Network: Default (NAT)"
        echo -e "${YELLOW}${INFO} Note: Use 'virsh console $vm_name' to access console${NC}"
        log "Created VM: $vm_name with $cpu_cores CPUs, ${mem_gb}GB RAM"
    else
        echo -e "${RED}${ERROR} Failed to create VM${NC}"
        return 1
    fi
}

# List VMs
list_vms() {
    echo -e "${BLUE}${LIST} ZynexCloud Virtual Machines:${NC}"
    virsh list --all
}

# Start VM
start_vm() {
    read -p "Enter VM name to start: " vm_name
    echo -e "${BLUE}${START} Starting VM $vm_name...${NC}"
    virsh start "$vm_name"
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}${SUCCESS} VM $vm_name started${NC}"
        log "Started VM: $vm_name"
    else
        echo -e "${RED}${ERROR} Failed to start VM $vm_name${NC}"
    fi
}

# Stop VM  
stop_vm() {
    read -p "Enter VM name to stop: " vm_name
    echo -e "${BLUE}${STOP} Stopping VM $vm_name...${NC}"
    virsh shutdown "$vm_name"
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}${SUCCESS} VM $vm_name stopped${NC}"
        log "Stopped VM: $vm_name"
    else
        echo -e "${RED}${ERROR} Failed to stop VM $vm_name${NC}"
    fi
}

# Delete VM
delete_vm() {
    read -p "Enter VM name to delete: " vm_name
    
    echo -e "${YELLOW}${WARNING} This will permanently delete VM $vm_name and all its data!${NC}"
    read -p "Are you sure? (y/N): " confirm
    
    if [[ $confirm =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}${TRASH} Deleting VM $vm_name...${NC}"
        virsh destroy "$vm_name" 2>/dev/null
        virsh undefine "$vm_name" --remove-all-storage
        
        # Remove related files
        rm -f "$VM_DIR/disks/$vm_name.qcow2" \
              "$VM_DIR/disks/$vm_name-cloud-init.iso"
        rm -rf "$VM_DIR/configs/$vm_name-cloud-init" 2>/dev/null
        
        log "Deleted VM: $vm_name"
        echo -e "${GREEN}${SUCCESS} VM $vm_name deleted${NC}"
    else
        echo -e "${BLUE}Deletion cancelled${NC}"
    fi
}

# VM info
vm_info() {
    read -p "Enter VM name: " vm_name
    echo -e "${BLUE}${INFO} ZynexCloud VM Information:${NC}"
    virsh dominfo "$vm_name"
    echo
    echo -e "${CYAN}${NETWORK} Network Information:${NC}"
    virsh domifaddr "$vm_name" 2>/dev/null || echo "VM is not running or no network info available"
}

# Resource monitoring
show_resources() {
    echo -e "${BLUE}${SERVER} ZynexCloud Host Resources:${NC}"
    echo -e "${CYAN}CPU Usage:${NC}"
    top -bn1 | grep "Cpu(s)" | awk '{print "  Usage: " $2 "%"}'
    
    echo -e "${CYAN}Memory Usage:${NC}"
    free -h | awk '
        /^Mem:/ {print "  Total: " $2 " | Used: " $3 " | Free: " $4 " | Available: " $7}
    '
    
    echo -e "${CYAN}Disk Usage:${NC}"
    df -h / | awk 'NR==2 {print "  Total: " $2 " | Used: " $3 " | Free: " $4 " | Usage: " $5}'
    
    echo -e "${CYAN}Running VMs:${NC}"
    virsh list --state-running | grep running | wc -l | awk '{print "  Count: " $1}'
}

# Download OS images menu
download_os_images_menu() {
    while true; do
        echo -e "${BLUE}${DOWNLOAD} ZynexCloud OS Image Library${NC}"
        echo "1) ${GREEN}Ubuntu 20.04 LTS${NC} 🐧"
        echo "2) ${GREEN}Ubuntu 22.04 LTS${NC} 🐧"
        echo "3) ${GREEN}Ubuntu 24.04 LTS${NC} 🐧" 
        echo "4) ${YELLOW}Debian 11${NC} 🔸"
        echo "5) ${YELLOW}Debian 12${NC} 🔸"
        echo "6) ${RED}CentOS Stream 9${NC} 🔺"
        echo "7) ${PURPLE}AlmaLinux 8${NC} 💠"
        echo "8) ${BLUE}Rocky Linux 8${NC} 🏔️"
        echo "9) ${CYAN}Back to main menu${NC}"
        
        read -p "Select OS to download (1-9): " choice
        
        case $choice in
            1) download_cloud_image "ubuntu20" ;;
            2) download_cloud_image "ubuntu22" ;;
            3) download_cloud_image "ubuntu24" ;;
            4) download_cloud_image "debian11" ;;
            5) download_cloud_image "debian12" ;;
            6) download_cloud_image "centos9" ;;
            7) download_cloud_image "alma8" ;;
            8) download_cloud_image "rocky8" ;;
            9) break ;;
            *) echo -e "${RED}${ERROR} Invalid choice${NC}" ;;
        esac
        
        read -p "Press Enter to continue..."
    done
}

# Main menu
show_menu() {
    while true; do
        show_banner
        echo -e "${CYAN}=== ZynexCloud VM Management Console ===${NC}"
        echo -e "${GREEN}1) ${GEAR} Initialize System${NC}"
        echo -e "${GREEN}2) ${SERVER} Create New VM${NC}"
        echo -e "${BLUE}3) ${LIST} List All VMs${NC}" 
        echo -e "${BLUE}4) ${START} Start VM${NC}"
        echo -e "${YELLOW}5) ${STOP} Stop VM${NC}"
        echo -e "${RED}6) ${TRASH} Delete VM${NC}"
        echo -e "${PURPLE}7) ${INFO} VM Information${NC}"
        echo -e "${CYAN}8) ${DOWNLOAD} OS Image Library${NC}"
        echo -e "${CYAN}9) ${SERVER} Resource Monitor${NC}"
        echo -e "${RED}10) ${STOP} Exit${NC}"
        echo
        
        read -p "Select option (1-10): " choice
        
        case $choice in
            1) initialize_setup ;;
            2) create_vm ;;
            3) list_vms ;;
            4) start_vm ;;
            5) stop_vm ;;
            6) delete_vm ;;
            7) vm_info ;;
            8) download_os_images_menu ;;
            9) show_resources ;;
            10) 
                echo -e "${GREEN}${SUCCESS} Thank you for using ZynexCloud! ${CLOUD}${NC}"
                break 
                ;;
            *) 
                echo -e "${RED}${ERROR} Invalid option${NC}"
                sleep 1
                ;;
        esac
        
        if [ "$choice" != "10" ]; then
            echo
            read -p "Press Enter to continue..."
        fi
    done
}

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo -e "${RED}${ERROR} Please don't run as root. Use a regular user account.${NC}"
    exit 1
fi

# Check VPS environment
if ! check_vps_environment; then
    echo -e "${YELLOW}${WARNING} Continuing with limitations...${NC}"
    sleep 2
fi

# Show menu
if [ $# -eq 0 ]; then
    show_menu
else
    # Command line interface
    case $1 in
        "init") initialize_setup ;;
        "create") create_vm ;;
        "list") list_vms ;;
        "start") start_vm "$2" ;;
        "stop") stop_vm "$2" ;;
        "delete") delete_vm "$2" ;;
        "info") vm_info "$2" ;;
        "resources") show_resources ;;
        "download") download_os_images_menu ;;
        *) 
            echo -e "${CYAN}ZynexCloud VM Manager Usage:${NC}"
            echo "  $0 init           ${GEAR} Initialize system"
            echo "  $0 create         ${SERVER} Create new VM"
            echo "  $0 list           ${LIST} List all VMs"
            echo "  $0 start <vm>     ${START} Start VM"
            echo "  $0 stop <vm>      ${STOP} Stop VM"
            echo "  $0 delete <vm>    ${TRASH} Delete VM"
            echo "  $0 info <vm>      ${INFO} Show VM info"
            echo "  $0 resources      ${SERVER} Show resources"
            echo "  $0 download       ${DOWNLOAD} OS image library"
            echo "  $0                ${CLOUD} Interactive menu"
            ;;
    esac
fi
