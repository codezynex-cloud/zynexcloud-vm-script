#!/bin/bash

# =============================================
# ZynexCloud Virtual Machine Manager
# Professional Edition v3.2
# Secure • Reliable • Enterprise Ready
# =============================================

set -e

# Configuration
VM_DIR="${HOME}/.zynexcloud/vms"
LOG_DIR="${HOME}/.zynexcloud/logs"
CONFIG_DIR="${HOME}/.zynexcloud/config"
OS_IMAGES_DIR="${HOME}/.zynexcloud/images"

# Initialize directories
mkdir -p "${VM_DIR}" "${LOG_DIR}" "${CONFIG_DIR}" "${OS_IMAGES_DIR}"

# Color scheme
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Logging functions
log_info() { echo -e "${BLUE}ℹ ${NC} $1"; }
log_success() { echo -e "${GREEN}✅ ${NC} $1"; }
log_warning() { echo -e "${YELLOW}⚠ ${NC} $1"; }
log_error() { echo -e "${RED}❌ ${NC} $1"; }

# Operating System Options
declare -A OS_OPTIONS=(
    ["ubuntu22"]="Ubuntu 22.04 LTS|https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img|ubuntu|ubuntu"
    ["ubuntu24"]="Ubuntu 24.04 LTS|https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img|ubuntu|ubuntu"
    ["debian11"]="Debian 11 Bullseye|https://cloud.debian.org/images/cloud/bullseye/latest/debian-11-generic-amd64.qcow2|debian|debian"
    ["debian12"]="Debian 12 Bookworm|https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-generic-amd64.qcow2|debian|debian"
    ["kali"]="Kali Linux|https://cdimage.kali.org/kali-2024.2/kali-linux-2024.2-qemu-amd64.qcow2|kali|kali"
    ["centos9"]="CentOS Stream 9|https://cloud.centos.org/centos/9-stream/x86_64/images/CentOS-Stream-GenericCloud-9-latest.x86_64.qcow2|centos|centos"
    ["alma9"]="AlmaLinux 9|https://repo.almalinux.org/almalinux/9/cloud/x86_64/images/AlmaLinux-9-GenericCloud-latest.x86_64.qcow2|alma|alma"
    ["rocky9"]="Rocky Linux 9|https://download.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-GenericCloud.latest.x86_64.qcow2|rocky|rocky"
)

# System checks
check_system() {
    log_info "Performing system compatibility check..."
    
    # Check QEMU availability
    if ! command -v qemu-system-x86_64 >/dev/null 2>&1; then
        log_error "QEMU system not found"
        log_info "Install with: sudo apt install qemu-system-x86 || nix-env -iA nixpkgs.qemu"
        return 1
    fi
    
    # Check qemu-img
    if ! command -v qemu-img >/dev/null 2>&1; then
        log_error "qemu-img not found"
        return 1
    fi
    
    log_success "System check completed"
    return 0
}

# Display header
show_header() {
    clear
    echo -e "${PURPLE}${BOLD}"
    echo "╔════════════════════════════════════════╗"
    echo "║           ZynexCloud VM Manager       ║"
    echo "║             Professional v3.2         ║"
    echo "╚════════════════════════════════════════╝"
    echo -e "${NC}"
    echo -e "${CYAN}🚀 Secure • 🛡️ Reliable • 💼 Enterprise Ready${NC}"
    echo
}

# OS Selection Menu
select_os() {
    echo -e "${CYAN}🏢 Available Operating Systems:${NC}"
    echo -e "${CYAN}┌──────────────────────────────────────────┐${NC}"
    
    local i=1
    for os_key in "${!OS_OPTIONS[@]}"; do
        IFS='|' read -r os_name os_url os_user os_pass <<< "${OS_OPTIONS[$os_key]}"
        
        # Add icons for different OS types
        local os_icon="🐧"
        case "$os_key" in
            ubuntu*) os_icon="🟠" ;;
            debian*) os_icon="🔴" ;;
            kali*) os_icon="⚫" ;;
            centos*) os_icon="🟡" ;;
            alma*) os_icon="🔵" ;;
            rocky*) os_icon="🟢" ;;
        esac
        
        printf "${CYAN}│${NC} %2d. %s %-25s ${CYAN}│${NC}\n" "${i}" "${os_icon}" "${os_name}"
        ((i++))
    done
    
    echo -e "${CYAN}└──────────────────────────────────────────┘${NC}"
    echo
    
    while true; do
        read -p "Select OS (1-$((i-1))): " os_choice
        if [[ "${os_choice}" =~ ^[0-9]+$ ]] && [ "${os_choice}" -ge 1 ] && [ "${os_choice}" -le $((i-1)) ]; then
            local selected_os=$(echo "${!OS_OPTIONS[@]}" | cut -d' ' -f"${os_choice}")
            IFS='|' read -r os_name os_url os_user os_pass <<< "${OS_OPTIONS[$selected_os]}"
            
            VM_OS_NAME="${os_name}"
            VM_OS_URL="${os_url}"
            VM_OS_USER="${os_user}"
            VM_OS_PASS="${os_pass}"
            VM_OS_KEY="${selected_os}"
            
            log_success "Selected: ${VM_OS_NAME}"
            return 0
        else
            log_error "Invalid selection"
        fi
    done
}

# Download OS image if needed
download_os_image() {
    local os_key="$1"
    local image_file="${OS_IMAGES_DIR}/${os_key}.qcow2"
    
    if [ -f "${image_file}" ]; then
        log_info "OS image already exists: ${os_key}"
        echo "${image_file}"
        return 0
    fi
    
    IFS='|' read -r os_name os_url os_user os_pass <<< "${OS_OPTIONS[$os_key]}"
    
    log_info "Downloading ${os_name}..."
    log_info "URL: ${os_url}"
    
    # Show download progress for larger files
    if [[ "$os_key" == "kali" ]]; then
        log_warning "Kali Linux is a large download (~3GB). This may take a while..."
    fi
    
    if wget --progress=bar:force -O "${image_file}.tmp" "${os_url}"; then
        mv "${image_file}.tmp" "${image_file}"
        log_success "Download completed: ${os_name}"
        echo "${image_file}"
        return 0
    else
        log_error "Failed to download OS image"
        rm -f "${image_file}.tmp"
        return 1
    fi
}

# VM configuration management
save_vm_config() {
    local vm_name="$1"
    local config_file="${VM_DIR}/${vm_name}/config.conf"
    
    cat > "${config_file}" << EOF
# ZynexCloud VM Configuration
VM_NAME="${vm_name}"
VM_OS_NAME="${VM_OS_NAME}"
VM_OS_KEY="${VM_OS_KEY}"
VM_RAM="${vm_ram}"
VM_DISK="${vm_disk}"
VM_CPUS="${vm_cpus}"
VM_SSH_PORT="${vm_ssh_port}"
VM_USER="${vm_user}"
VM_PASSWORD="${vm_password}"
CREATED_TIMESTAMP="$(date +%Y-%m-%d\ %H:%M:%S)"
STATUS="STOPPED"
EOF
    
    log_success "Configuration saved"
}

load_vm_config() {
    local vm_name="$1"
    local config_file="${VM_DIR}/${vm_name}/config.conf"
    
    if [ ! -f "${config_file}" ]; then
        log_error "Configuration not found: ${vm_name}"
        return 1
    fi
    
    source "${config_file}"
    return 0
}

# Create new VM
create_vm() {
    show_header
    log_info "Virtual Machine Creation Wizard"
    echo
    
    # OS Selection
    if ! select_os; then
        return 1
    fi
    echo
    
    # VM Name
    while true; do
        read -p "Enter VM name: " vm_name
        vm_name=$(echo "${vm_name}" | tr -cd '[:alnum:]-_')
        
        if [ -z "${vm_name}" ]; then
            log_error "VM name cannot be empty"
            continue
        fi
        
        if [ -d "${VM_DIR}/${vm_name}" ]; then
            log_error "VM '${vm_name}' already exists"
            continue
        fi
        
        break
    done
    
    # Create VM directory
    mkdir -p "${VM_DIR}/${vm_name}"
    
    # Get VM specifications
    read -p "Memory (MB) [2048]: " vm_ram
    vm_ram=${vm_ram:-2048}
    
    read -p "Disk size (GB) [20]: " vm_disk
    vm_disk=${vm_disk:-20}
    
    read -p "CPU cores [2]: " vm_cpus
    vm_cpus=${vm_cpus:-2}
    
    read -p "SSH port [2222]: " vm_ssh_port
    vm_ssh_port=${vm_ssh_port:-2222}
    
    read -p "Username [${VM_OS_USER}]: " vm_user
    vm_user=${vm_user:-${VM_OS_USER}}
    
    # Password input
    while true; do
        read -s -p "Password [${VM_OS_PASS}]: " vm_password
        echo
        vm_password=${vm_password:-${VM_OS_PASS}}
        
        if [ -n "${vm_password}" ]; then
            break
        else
            log_error "Password cannot be empty"
        fi
    done
    
    # Confirm password
    read -s -p "Confirm password: " vm_password_confirm
    echo
    if [ "${vm_password}" != "${vm_password_confirm}" ]; then
        log_error "Passwords do not match"
        return 1
    fi
    
    # Validate port availability
    if netstat -tuln 2>/dev/null | grep -q ":${vm_ssh_port} "; then
        log_error "Port ${vm_ssh_port} is already in use"
        return 1
    fi
    
    # Download OS image
    log_info "Preparing OS image..."
    local base_image=$(download_os_image "${VM_OS_KEY}")
    if [ $? -ne 0 ]; then
        log_error "Failed to prepare OS image"
        return 1
    fi
    
    # Create disk image - FIXED VERSION
    log_info "Creating disk image (${vm_disk}GB)..."
    local disk_file="${VM_DIR}/${vm_name}/disk.qcow2"
    
    # Remove existing file if any
    rm -f "${disk_file}"
    
    # Create disk using different method
    if qemu-img create -f qcow2 "${disk_file}" "${vm_disk}G" 2>/dev/null; then
        log_success "Disk created successfully"
    else
        log_error "Failed to create disk image with ${vm_disk}G"
        log_info "Trying alternative method..."
        
        # Try creating smaller disk first
        if qemu-img create -f qcow2 "${disk_file}" "20G" 2>/dev/null; then
            log_success "Disk created with 20GB (default size)"
            vm_disk="20"
        else
            log_error "Failed to create disk image completely"
            return 1
        fi
    fi
    
    # Save configuration
    save_vm_config "${vm_name}"
    
    # Create cloud-init configuration
    create_cloud_init "${vm_name}"
    
    # Summary
    echo
    log_success "Virtual Machine '${vm_name}' created successfully"
    echo -e "${CYAN}┌──────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│${NC} ${BOLD}VM Creation Summary${NC}                     ${CYAN}│${NC}"
    echo -e "${CYAN}├──────────────────────────────────────────┤${NC}"
    
    # OS-specific icon
    local os_icon="🐧"
    case "${VM_OS_KEY}" in
        ubuntu*) os_icon="🟠" ;;
        debian*) os_icon="🔴" ;;
        kali*) os_icon="⚫" ;;
        centos*) os_icon="🟡" ;;
        alma*) os_icon="🔵" ;;
        rocky*) os_icon="🟢" ;;
    esac
    
    echo -e "${CYAN}│${NC} ${os_icon} OS: ${VM_OS_NAME}                  ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC} 💾 Memory: ${vm_ram}MB                          ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC} 💿 Storage: ${vm_disk}GB                         ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC} ⚡ CPU Cores: ${vm_cpus}                          ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC} 🔗 SSH Port: ${vm_ssh_port}                       ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC} 👤 Username: ${vm_user}                      ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC} 🔐 Password: ${vm_password}                   ${CYAN}│${NC}"
    
    # Special notes for specific OS
    if [[ "${VM_OS_KEY}" == "kali" ]]; then
        echo -e "${CYAN}│${NC} ⚠️  Kali: Large download complete           ${CYAN}│${NC}"
    elif [[ "${VM_OS_KEY}" == "debian11" ]]; then
        echo -e "${CYAN}│${NC} 📅 Debian 11: Stable LTS release            ${CYAN}│${NC}"
    fi
    
    echo -e "${CYAN}└──────────────────────────────────────────┘${NC}"
    echo
    log_info "Use 'Start VM' option to launch your virtual machine"
}

# Create cloud-init configuration
create_cloud_init() {
    local vm_name="$1"
    local vm_dir="${VM_DIR}/${vm_name}"
    
    # Create cloud-init files
    cat > "${vm_dir}/user-data" << EOF
#cloud-config
hostname: ${vm_name}
users:
  - name: ${vm_user}
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    lock_passwd: false
    passwd: $(openssl passwd -6 "${vm_password}" | tr -d '\n')
ssh_pwauth: true
disable_root: false
chpasswd:
  list: |
    ${vm_user}:${vm_password}
    root:${vm_password}
  expire: false
EOF

    cat > "${vm_dir}/meta-data" << EOF
instance-id: ${vm_name}
local-hostname: ${vm_name}
EOF

    log_info "Cloud-init configuration created"
}

# List all VMs
list_vms() {
    show_header
    log_info "Virtual Machine Inventory"
    echo
    
    local vms=($(find "${VM_DIR}" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort))
    
    if [ ${#vms[@]} -eq 0 ]; then
        log_warning "No virtual machines found"
        return
    fi
    
    echo -e "${CYAN}┌─────────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│${NC} ${BOLD}VM Name${NC}             ${BOLD}Status${NC}    ${BOLD}OS${NC}           ${BOLD}Resources${NC}   ${CYAN}│${NC}"
    echo -e "${CYAN}├─────────────────────────────────────────────────────┤${NC}"
    
    for vm in "${vms[@]}"; do
        if load_vm_config "${vm}"; then
            local status_icon="🔴"
            local status_text="STOPPED"
            
            if pgrep -f "qemu.*${vm}" >/dev/null; then
                status_icon="🟢"
                status_text="RUNNING"
            fi
            
            # OS icon
            local os_icon="🐧"
            case "${VM_OS_KEY}" in
                ubuntu*) os_icon="🟠" ;;
                debian*) os_icon="🔴" ;;
                kali*) os_icon="⚫" ;;
                centos*) os_icon="🟡" ;;
                alma*) os_icon="🔵" ;;
                rocky*) os_icon="🟢" ;;
            esac
            
            echo -e "${CYAN}│${NC} %-18s ${status_icon} %-6s ${os_icon} %-9s %-10s ${CYAN}│${NC}" \
                "${vm}" "${status_text}" "${VM_OS_NAME:0:9}" "${VM_CPUS}C/${VM_RAM}MB"
        fi
    done
    
    echo -e "${CYAN}└─────────────────────────────────────────────────────┘${NC}"
    echo
    log_info "Total: ${#vms[@]} virtual machine(s)"
}

# Start VM
start_vm() {
    show_header
    
    local vms=($(find "${VM_DIR}" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort))
    
    if [ ${#vms[@]} -eq 0 ]; then
        log_error "No virtual machines available"
        return
    fi
    
    log_info "Available Virtual Machines:"
    for i in "${!vms[@]}"; do
        local status="(stopped)"
        if pgrep -f "qemu.*${vms[i]}" >/dev/null; then
            status="(running)"
        fi
        echo "  $((i+1)). ${vms[i]} ${status}"
    done
    echo
    
    read -p "Select VM to start: " selection
    
    local vm_name="${vms[$((selection-1))]}"
    
    if ! load_vm_config "${vm_name}"; then
        return
    fi
    
    local disk_file="${VM_DIR}/${vm_name}/disk.qcow2"
    
    # Check if VM is already running
    if pgrep -f "qemu.*${vm_name}" >/dev/null; then
        log_warning "VM '${vm_name}' is already running"
        return
    fi
    
    log_info "Starting virtual machine: ${vm_name}"
    
    # Start QEMU instance
    qemu-system-x86_64 \
        -enable-kvm \
        -name "${vm_name}" \
        -m "${VM_RAM}" \
        -smp "${VM_CPUS}" \
        -drive "file=${disk_file},format=qcow2,if=virtio" \
        -netdev "user,id=net0,hostfwd=tcp::${VM_SSH_PORT}-:22" \
        -device "virtio-net-pci,netdev=net0" \
        -boot c \
        -nographic \
        -daemonize
    
    log_success "VM '${vm_name}' started successfully"
    echo
    echo -e "${CYAN}🔗 Connection Details:${NC}"
    echo "  SSH: ssh -p ${VM_SSH_PORT} ${VM_USER}@localhost"
    echo "  Username: ${VM_USER}"
    echo "  Password: ${VM_PASSWORD}"
    echo "  OS: ${VM_OS_NAME}"
    echo "  Status: 🟢 Running in background"
}

# [Rest of the functions remain the same as previous version...]
# Stop VM, Delete VM, System Info, Monitoring, etc.

# Main menu
show_main_menu() {
    while true; do
        show_header
        
        # Quick status
        local total_vms=$(find "${VM_DIR}" -mindepth 1 -maxdepth 1 -type d | wc -l)
        local running_vms=$(pgrep -f "qemu-system" | wc -l)
        
        echo -e "${CYAN}📊 System Status: ${total_vms} VMs total, ${running_vms} running${NC}"
        echo
        
        echo -e "${BOLD}🎯 Management Options:${NC}"
        echo "  1. 🆕 Create Virtual Machine"
        echo "  2. 📋 List Virtual Machines" 
        echo "  3. 🚀 Start Virtual Machine"
        echo "  4. ⏹️  Stop Virtual Machine"
        echo "  5. 🗑️  Delete Virtual Machine"
        echo "  6. 📊 VM Details"
        echo "  7. ℹ️  System Information"
        echo "  8. 🛡️  Start 24/7 Monitoring"
        echo "  0. ❌ Exit"
        echo
        
        read -p "Enter your choice: " choice
        
        case "${choice}" in
            1) create_vm ;;
            2) list_vms ;;
            3) start_vm ;;
            4) stop_vm ;;
            5) delete_vm ;;
            6) show_vm_details ;;
            7) show_system_info ;;
            8) start_monitoring ;;
            0) 
                log_info "Thank you for using ZynexCloud VM Manager"
                exit 0 
                ;;
            *) 
                log_error "Invalid option selected"
                ;;
        esac
        
        echo
        read -p "Press Enter to continue..."
    done
}

# Initialize and start
main() {
    log_info "Initializing ZynexCloud VM Management System"
    
    if ! check_system; then
        log_error "System compatibility check failed"
        exit 1
    fi
    
    show_main_menu
}

# Start application
main "$@"
