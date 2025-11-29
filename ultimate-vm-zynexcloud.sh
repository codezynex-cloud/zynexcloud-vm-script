#!/bin/bash

# =============================================
# ZynexCloud VM Manager - Working Version
# Fixed and Tested
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
    ["debian12"]="Debian 12 Bookworm|https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-generic-amd64.qcow2|debian|debian"
)

# Display header
show_header() {
    clear
    echo -e "${PURPLE}${BOLD}"
    echo "╔════════════════════════════════════════╗"
    echo "║           ZynexCloud VM Manager       ║"
    echo "║             Working Version           ║"
    echo "╚════════════════════════════════════════╝"
    echo -e "${NC}"
    echo -e "${CYAN}🚀 Secure • 🛡️ Reliable • 💼 Enterprise Ready${NC}"
    echo
}

# System checks
check_system() {
    log_info "System check kar raha hoon..."
    
    if ! command -v qemu-system-x86_64 >/dev/null 2>&1; then
        log_error "QEMU nahi mila"
        log_info "Install karo: sudo apt install qemu-system-x86"
        return 1
    fi
    
    if ! command -v qemu-img >/dev/null 2>&1; then
        log_error "qemu-img nahi mila"
        return 1
    fi
    
    if ! command -v wget >/dev/null 2>&1; then
        log_error "wget nahi mila"
        return 1
    fi
    
    log_success "System check complete"
    return 0
}

# OS Selection Menu
select_os() {
    echo -e "${CYAN}Available Operating Systems:${NC}"
    local i=1
    for os_key in "${!OS_OPTIONS[@]}"; do
        IFS='|' read -r os_name os_url os_user os_pass <<< "${OS_OPTIONS[$os_key]}"
        echo "  $i. $os_name"
        ((i++))
    done
    
    while true; do
        read -p "OS select karo (1-$((i-1))): " os_choice
        if [[ "$os_choice" =~ ^[0-9]+$ ]] && [ "$os_choice" -ge 1 ] && [ "$os_choice" -le $((i-1)) ]; then
            local selected_os=$(echo "${!OS_OPTIONS[@]}" | cut -d' ' -f"$os_choice")
            IFS='|' read -r os_name os_url os_user os_pass <<< "${OS_OPTIONS[$selected_os]}"
            
            VM_OS_NAME="$os_name"
            VM_OS_URL="$os_url"
            VM_OS_USER="$os_user"
            VM_OS_PASS="$os_pass"
            VM_OS_KEY="$selected_os"
            
            log_success "Selected: $VM_OS_NAME"
            return 0
        else
            log_error "Galat selection"
        fi
    done
}

# Create new VM
create_vm() {
    show_header
    log_info "Naya VM bana raha hoon..."
    
    # OS Selection
    if ! select_os; then
        return 1
    fi
    
    # VM Name
    while true; do
        read -p "VM ka naam dalo: " vm_name
        vm_name=$(echo "$vm_name" | tr -cd '[:alnum:]-_')
        
        if [ -z "$vm_name" ]; then
            log_error "Naam khali nahi ho sakta"
            continue
        fi
        
        if [ -d "$VM_DIR/$vm_name" ]; then
            log_error "VM '$vm_name' pehle se hai"
            continue
        fi
        
        break
    done
    
    # Create VM directory
    mkdir -p "$VM_DIR/$vm_name"
    
    # VM specifications
    read -p "Memory (MB) [2048]: " vm_ram
    vm_ram=${vm_ram:-2048}
    
    read -p "Disk size (GB) [20]: " vm_disk
    vm_disk=${vm_disk:-20}
    
    read -p "CPU cores [2]: " vm_cpus
    vm_cpus=${vm_cpus:-2}
    
    read -p "SSH port [2222]: " vm_ssh_port
    vm_ssh_port=${vm_ssh_port:-2222}
    
    vm_user="$VM_OS_USER"
    vm_password="$VM_OS_PASS"
    
    # Create disk image
    log_info "Disk image bana raha hoon ($vm_disk GB)..."
    local disk_file="$VM_DIR/$vm_name/disk.qcow2"
    
    if qemu-img create -f qcow2 "$disk_file" "${vm_disk}G" 2>/dev/null; then
        log_success "Disk ban gaya"
    else
        log_error "Disk nahi bana"
        return 1
    fi
    
    # Save configuration
    cat > "$VM_DIR/$vm_name/config.conf" << EOF
VM_NAME="$vm_name"
VM_OS_NAME="$VM_OS_NAME"
VM_OS_KEY="$VM_OS_KEY"
VM_RAM="$vm_ram"
VM_DISK="$vm_disk"
VM_CPUS="$vm_cpus"
VM_SSH_PORT="$vm_ssh_port"
VM_USER="$vm_user"
VM_PASSWORD="$vm_password"
EOF
    
    log_success "VM '$vm_name' successfully bana diya!"
    echo
    echo "SSH Connect: ssh -p $vm_ssh_port $vm_user@localhost"
    echo "Username: $vm_user"
    echo "Password: $vm_password"
}

# List all VMs
list_vms() {
    show_header
    log_info "Saare VMs dikha raha hoon..."
    
    local vms=($(find "$VM_DIR" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort))
    
    if [ ${#vms[@]} -eq 0 ]; then
        log_warning "Koi VM nahi mila"
        return
    fi
    
    echo -e "${CYAN}VM Name            Status    OS${NC}"
    echo "----------------------------------------"
    
    for vm in "${vms[@]}"; do
        if [ -f "$VM_DIR/$vm/config.conf" ]; then
            source "$VM_DIR/$vm/config.conf"
            local status="🔴 STOPPED"
            if pgrep -f "qemu.*$vm" >/dev/null; then
                status="🟢 RUNNING"
            fi
            echo " $vm       $status   $VM_OS_NAME"
        fi
    done
}

# Start VM
start_vm() {
    show_header
    
    local vms=($(find "$VM_DIR" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort))
    
    if [ ${#vms[@]} -eq 0 ]; then
        log_error "Koi VM available nahi hai"
        return
    fi
    
    log_info "Available VMs:"
    for i in "${!vms[@]}"; do
        local status="(stopped)"
        if pgrep -f "qemu.*${vms[i]}" >/dev/null; then
            status="(running)"
        fi
        echo "  $((i+1)). ${vms[i]} $status"
    done
    
    read -p "Kaun sa VM start karna hai: " selection
    local vm_name="${vms[$((selection-1))]}"
    
    if [ ! -f "$VM_DIR/$vm_name/config.conf" ]; then
        log_error "VM configuration nahi mili"
        return
    fi
    
    source "$VM_DIR/$vm_name/config.conf"
    local disk_file="$VM_DIR/$vm_name/disk.qcow2"
    
    # Check if already running
    if pgrep -f "qemu.*$vm_name" >/dev/null; then
        log_warning "VM '$vm_name' already running hai"
        return
    fi
    
    log_info "VM '$vm_name' start kar raha hoon..."
    
    # Start QEMU
    qemu-system-x86_64 \
        -enable-kvm \
        -name "$vm_name" \
        -m "$VM_RAM" \
        -smp "$VM_CPUS" \
        -drive "file=$disk_file,format=qcow2,if=virtio" \
        -netdev "user,id=net0,hostfwd=tcp::$VM_SSH_PORT-:22" \
        -device "virtio-net-pci,netdev=net0" \
        -boot c \
        -display none \
        -daemonize
    
    sleep 2
    
    if pgrep -f "qemu.*$vm_name" >/dev/null; then
        log_success "VM '$vm_name' successfully start ho gaya!"
        echo
        echo "SSH Connect: ssh -p $VM_SSH_PORT $VM_USER@localhost"
    else
        log_error "VM start nahi hua"
    fi
}

# Stop VM
stop_vm() {
    show_header
    
    local vms=($(find "$VM_DIR" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort))
    
    if [ ${#vms[@]} -eq 0 ]; then
        log_error "Koi VM available nahi hai"
        return
    fi
    
    log_info "Available VMs:"
    for i in "${!vms[@]}"; do
        local status="🔴 stopped"
        if pgrep -f "qemu.*${vms[i]}" >/dev/null; then
            status="🟢 running"
        fi
        echo "  $((i+1)). ${vms[i]} $status"
    done
    
    read -p "Kaun sa VM stop karna hai: " selection
    local vm_name="${vms[$((selection-1))]}"
    
    log_info "VM '$vm_name' stop kar raha hoon..."
    
    local pids=$(pgrep -f "qemu.*$vm_name" 2>/dev/null || true)
    
    if [ -z "$pids" ]; then
        log_warning "VM '$vm_name' running nahi hai"
        return
    fi
    
    kill $pids 2>/dev/null && sleep 2
    
    if pgrep -f "qemu.*$vm_name" >/dev/null; then
        kill -9 $pids 2>/dev/null
    fi
    
    log_success "VM '$vm_name' stop ho gaya"
}

# Main menu
show_main_menu() {
    while true; do
        show_header
        
        local total_vms=$(find "$VM_DIR" -mindepth 1 -maxdepth 1 -type d | wc -l)
        local running_vms=$(pgrep -f "qemu-system" | wc -l)
        
        echo -e "${CYAN}System Status: $total_vms VMs total, $running_vms running${NC}"
        echo
        
        echo "1. 🆕 Naya VM Banao"
        echo "2. 📋 Saare VMs Dikhao" 
        echo "3. 🚀 VM Start Karo"
        echo "4. ⏹️  VM Stop Karo"
        echo "5. 🗑️  VM Delete Karo"
        echo "0. ❌ Exit"
        echo
        
        read -p "Apna choice dalo: " choice
        
        case "$choice" in
            1) create_vm ;;
            2) list_vms ;;
            3) start_vm ;;
            4) stop_vm ;;
            5) delete_vm ;;
            0) 
                log_info "ZynexCloud VM Manager use karne ke liye dhanyawaad!"
                exit 0 
                ;;
            *) 
                log_error "Galat choice"
                ;;
        esac
        
        echo
        read -p "Continue karne ke liye Enter dabaye..."
    done
}

# ISS Command function
iss() {
    case "$1" in
        create|start|stop|list|delete|status)
            main "$@"
            ;;
        *)
            show_header
            echo -e "${CYAN}Usage:${NC}"
            echo "  iss create    - Naya VM banao"
            echo "  iss start     - VM start karo"
            echo "  iss stop      - VM stop karo" 
            echo "  iss list      - Saare VMs dikhao"
            echo "  iss delete    - VM delete karo"
            echo "  iss status    - VM status dikhao"
            ;;
    esac
}

# Main function
main() {
    local command="$1"
    
    case "$command" in
        create) create_vm ;;
        start) start_vm ;;
        stop) stop_vm ;;
        list) list_vms ;;
        delete) delete_vm ;;
        status) list_vms ;;
        *) show_main_menu ;;
    esac
}

# Delete VM function
delete_vm() {
    show_header
    
    local vms=($(find "$VM_DIR" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort))
    
    if [ ${#vms[@]} -eq 0 ]; then
        log_error "Koi VM available nahi hai"
        return
    fi
    
    log_info "Available VMs:"
    for i in "${!vms[@]}"; do
        echo "  $((i+1)). ${vms[i]}"
    done
    
    read -p "Kaun sa VM delete karna hai: " selection
    local vm_name="${vms[$((selection-1))]}"
    
    echo
    log_warning "WARNING: Ye VM '$vm_name' permanently delete ho jayega"
    read -p "Confirm karne ke liye 'DELETE' likho: " confirmation
    
    if [ "$confirmation" != "DELETE" ]; then
        log_info "Delete cancel ho gaya"
        return
    fi
    
    # Stop VM if running
    local pids=$(pgrep -f "qemu.*$vm_name" 2>/dev/null || true)
    if [ -n "$pids" ]; then
        log_info "Running VM ko stop kar raha hoon"
        kill $pids 2>/dev/null
        sleep 2
    fi
    
    # Remove VM directory
    if rm -rf "$VM_DIR/$vm_name"; then
        log_success "VM '$vm_name' delete ho gaya"
    else
        log_error "VM delete nahi hua"
    fi
}

# Start application
if [ $# -eq 0 ]; then
    log_info "ZynexCloud VM Manager start ho raha hai..."
    if ! check_system; then
        log_error "System check fail hua"
    fi
    show_main_menu
else
    main "$@"
fi
