#!/bin/bash

# 🚀 ZynexCloud VM Manager - FIXED VERSION
# Disk size issue resolved

set -e

# 🎨 Colors + Emojis
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# 🔧 Config
VM_DIR="$HOME/zynex-vms"
mkdir -p "$VM_DIR"

# 🎯 Display Awesome Header
display_header() {
    clear
    echo -e "${PURPLE}"
    echo "╔════════════════════════════════════════╗"
    echo "║           🚀 ZYNEXCLOUD VM            ║"
    echo "║           🛡️  Premium Edition         ║"
    echo "║    24/7 • Anti-Suspend • Fast         ║"
    echo "╚════════════════════════════════════════╝"
    echo -e "${NC}"
    echo -e "${CYAN}    Your Ultimate Virtualization Solution${NC}"
    echo
}

# 🔍 Check Dependencies
check_deps() {
    echo -e "🔍 ${BLUE}Checking dependencies...${NC}"
    local deps=("qemu-system-x86_64" "qemu-img")
    local missing=()
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing+=("$dep")
        fi
    done
    
    if [ ${#missing[@]} -ne 0 ]; then
        echo -e "❌ ${RED}Missing: ${missing[*]}${NC}"
        echo -e "💡 ${YELLOW}Run: nix-env -iA nixpkgs.qemu${NC}"
        return 1
    fi
    echo -e "✅ ${GREEN}All dependencies found!${NC}"
    return 0
}

# 🆕 Create New VM - FIXED VERSION
create_vm() {
    echo -e "🆕 ${BLUE}Creating New VM...${NC}"
    echo -e "${CYAN}─────────────────────────────────────${NC}"
    
    read -p "🎯 VM name: " vm_name
    read -p "💾 RAM (MB) [2048]: " ram
    ram=${ram:-2048}
    read -p "💿 Disk size (GB) [20]: " disk
    disk=${disk:-20}
    read -p "⚡ CPUs [2]: " cpus
    cpus=${cpus:-2}
    read -p "🔗 SSH Port [2222]: " ssh_port
    ssh_port=${ssh_port:-2222}
    
    # 🗂️ Create files
    config_file="$VM_DIR/$vm_name.conf"
    disk_file="$VM_DIR/$vm_name.qcow2"
    
    # 💾 Save config
    cat > "$config_file" << EOF
VM_NAME="$vm_name"
RAM="$ram"
DISK="$disk"
CPUS="$cpus"
SSH_PORT="$ssh_port"
CREATED="$(date)"
EOF

    # 🛠️ Create disk - FIXED: Use proper format
    echo -e "💿 ${YELLOW}Creating disk image...${NC}"
    
    # Remove existing file if any
    rm -f "$disk_file"
    
    # Create disk with proper size format
    if ! qemu-img create -f qcow2 "$disk_file" "${disk}G" 2>/dev/null; then
        echo -e "❌ ${RED}Failed to create disk with ${disk}G${NC}"
        echo -e "💡 ${YELLOW}Trying alternative size...${NC}"
        # Try smaller size
        qemu-img create -f qcow2 "$disk_file" "20G"
        disk="20"
        # Update config
        sed -i "s/DISK=\"$disk\"/DISK=\"20\"/" "$config_file"
    fi
    
    echo -e "✅ ${GREEN}VM '$vm_name' created successfully!${NC}"
    echo -e "📊 ${CYAN}Specs: ${ram}MB RAM • ${cpus} CPU • ${disk}GB Disk${NC}"
    echo -e "🔗 ${CYAN}SSH Port: $ssh_port${NC}"
}

# 📋 List VMs with Status
list_vms() {
    local vms=($(find "$VM_DIR" -name "*.conf" -exec basename {} .conf \; 2>/dev/null))
    
    if [ ${#vms[@]} -eq 0 ]; then
        echo -e "📭 ${YELLOW}No VMs found. Create one first!${NC}"
        return
    fi
    
    echo -e "📂 ${GREEN}Your Virtual Machines:${NC}"
    echo -e "${CYAN}┌─────────────────────────────────────┐${NC}"
    for i in "${!vms[@]}"; do
        local vm="${vms[$i]}"
        local status="🔴 Stopped"
        if pgrep -f "qemu.*$vm" >/dev/null; then
            status="🟢 Running"
        fi
        printf "│ %2d) %-20s %s │\n" $((i+1)) "$vm" "$status"
    done
    echo -e "${CYAN}└─────────────────────────────────────┘${NC}"
}

# 🚀 Start VM
start_vm() {
    local vms=($(find "$VM_DIR" -name "*.conf" -exec basename {} .conf \; 2>/dev/null))
    
    if [ ${#vms[@]} -eq 0 ]; then
        echo -e "❌ ${RED}No VMs found${NC}"
        return
    fi
    
    list_vms
    read -p "🎯 Select VM to start: " choice
    
    if [[ ! "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt ${#vms[@]} ]; then
        echo -e "❌ ${RED}Invalid selection${NC}"
        return
    fi
    
    vm_name="${vms[$((choice-1))]}"
    config_file="$VM_DIR/$vm_name.conf"
    disk_file="$VM_DIR/$vm_name.qcow2"
    
    if [[ ! -f "$config_file" ]]; then
        echo -e "❌ ${RED}Config file not found: $config_file${NC}"
        return
    fi
    
    source "$config_file"
    
    echo -e "🚀 ${GREEN}Starting $VM_NAME...${NC}"
    echo -e "⚡ ${CYAN}Specs: ${RAM}MB RAM • ${CPUS} CPUs • ${DISK}GB Disk${NC}"
    
    # Check if disk exists
    if [[ ! -f "$disk_file" ]]; then
        echo -e "❌ ${RED}Disk file not found: $disk_file${NC}"
        echo -e "💡 ${YELLOW}Creating new disk...${NC}"
        qemu-img create -f qcow2 "$disk_file" "20G"
    fi
    
    # 🖥️ Start QEMU
    qemu-system-x86_64 \
        -enable-kvm \
        -m "$RAM" \
        -smp "$CPUS" \
        -hda "$disk_file" \
        -netdev user,id=net0,hostfwd=tcp::${SSH_PORT}-:22 \
        -device virtio-net-pci,netdev=net0 \
        -boot c \
        -daemonize
    
    echo -e "✅ ${GREEN}VM started in background!${NC}"
    echo -e "🔗 ${CYAN}SSH: ssh -p $SSH_PORT user@localhost${NC}"
    echo -e "💡 ${YELLOW}Note: Install OS first using ISO${NC}"
}

# ⚡ 24/7 Keep-Alive System
start_24x7() {
    echo -e "🛡️ ${BLUE}Starting 24/7 Anti-Suspend System...${NC}"
    
    # 🔄 Create keep-alive script
    cat > "$VM_DIR/keepalive.sh" << 'EOF'
#!/bin/bash
# 🛡️ ZynexCloud 24/7 Protection
echo "🛡️ Starting 24/7 protection..."

while true; do
    # ❤️ Heartbeat
    echo "$(date): ❤️ ZynexCloud VM Active" >> /tmp/zynex-heartbeat.log
    touch /tmp/zynex-alive
    
    # 🔄 Activity simulation
    dd if=/dev/urandom of=/dev/null bs=1K count=1 2>/dev/null
    sync
    
    sleep 30
done
EOF

    chmod +x "$VM_DIR/keepalive.sh"
    
    # 🚀 Start in background
    nohup "$VM_DIR/keepalive.sh" >/dev/null 2>&1 &
    
    echo -e "✅ ${GREEN}24/7 protection activated!${NC}"
    echo -e "💤 ${CYAN}Your VM will never sleep!${NC}"
}

# 📊 VM Info
vm_info() {
    local vms=($(find "$VM_DIR" -name "*.conf" -exec basename {} .conf \; 2>/dev/null))
    
    if [ ${#vms[@]} -eq 0 ]; then
        echo -e "❌ ${RED}No VMs found${NC}"
        return
    fi
    
    list_vms
    read -p "🎯 Select VM for info: " choice
    
    vm_name="${vms[$((choice-1))]}"
    config_file="$VM_DIR/$vm_name.conf"
    
    if [[ ! -f "$config_file" ]]; then
        echo -e "❌ ${RED}Config file not found${NC}"
        return
    fi
    
    source "$config_file"
    
    echo -e "${PURPLE}"
    echo "╔════════════════════════════════════════╗"
    echo "║             📊 VM DETAILS             ║"
    echo "╚════════════════════════════════════════╝"
    echo -e "${NC}"
    echo -e "🎯 ${CYAN}Name:${NC} $VM_NAME"
    echo -e "💾 ${CYAN}RAM:${NC} ${RAM}MB"
    echo -e "⚡ ${CYAN}CPUs:${NC} $CPUS"
    echo -e "💿 ${CYAN}Disk:${NC} ${DISK}GB"
    echo -e "🔗 ${CYAN}SSH Port:${NC} $SSH_PORT"
    echo -e "📅 ${CYAN}Created:${NC} $CREATED"
    
    # 🟢 Status check
    if pgrep -f "qemu.*$vm_name" >/dev/null; then
        echo -e "🟢 ${GREEN}Status: RUNNING${NC}"
    else
        echo -e "🔴 ${RED}Status: STOPPED${NC}"
    fi
    echo
}

# 🗑️ Delete VM
delete_vm() {
    local vms=($(find "$VM_DIR" -name "*.conf" -exec basename {} .conf \; 2>/dev/null))
    
    if [ ${#vms[@]} -eq 0 ]; then
        echo -e "❌ ${RED}No VMs found${NC}"
        return
    fi
    
    list_vms
    read -p "🎯 Select VM to delete: " choice
    
    vm_name="${vms[$((choice-1))]}"
    
    echo -e "⚠️ ${YELLOW}This will PERMANENTLY delete '$vm_name'!${NC}"
    read -p "❓ Are you sure? (y/N): " confirm
    
    if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
        # 🔴 Stop if running
        if pgrep -f "qemu.*$vm_name" >/dev/null; then
            pkill -f "qemu.*$vm_name"
            echo -e "🔴 ${YELLOW}VM stopped${NC}"
        fi
        
        # 🗑️ Delete files
        rm -f "$VM_DIR/$vm_name.conf" "$VM_DIR/$vm_name.qcow2"
        echo -e "✅ ${GREEN}VM '$vm_name' deleted!${NC}"
    else
        echo -e "🔵 ${BLUE}Deletion cancelled${NC}"
    fi
}

# 📈 System Status
system_status() {
    echo -e "${PURPLE}"
    echo "╔════════════════════════════════════════╗"
    echo "║             📊 SYSTEM STATUS          ║"
    echo "╚════════════════════════════════════════╝"
    echo -e "${NC}"
    
    # 🖥️ VM Count
    local vm_count=$(find "$VM_DIR" -name "*.conf" | wc -l)
    echo -e "🖥️ ${CYAN}Total VMs:${NC} $vm_count"
    
    # 🔄 24/7 Status
    if pgrep -f "keepalive.sh" >/dev/null; then
        echo -e "🛡️ ${GREEN}24/7 Protection: ACTIVE${NC}"
    else
        echo -e "🔴 ${RED}24/7 Protection: INACTIVE${NC}"
    fi
    
    # 💾 Disk Usage
    echo -e "💾 ${CYAN}VM Directory:${NC} $VM_DIR"
    if [ -d "$VM_DIR" ]; then
        echo -e "📦 ${CYAN}Disk Usage:${NC} $(du -sh "$VM_DIR" 2>/dev/null | cut -f1 || echo "0K")"
    else
        echo -e "📦 ${CYAN}Disk Usage:${NC} 0K"
    fi
    
    # 🚀 Running VMs
    local running_vms=$(pgrep -f "qemu-system" | wc -l)
    echo -e "🚀 ${CYAN}Running VMs:${NC} $running_vms"
    echo
}

# 🎮 Main Menu
main_menu() {
    while true; do
        display_header
        system_status
        
        echo -e "${GREEN}🎮 MAIN MENU:${NC}"
        echo -e "1) 🆕 Create VM"
        echo -e "2) 🚀 Start VM" 
        echo -e "3) 📋 List VMs"
        echo -e "4) 📊 VM Info"
        echo -e "5) 🗑️ Delete VM"
        echo -e "6) 🛡️  Start 24/7 Protection"
        echo -e "7) 📈 System Status"
        echo -e "0) ❌ Exit"
        echo
        
        read -p "🎯 Choose option: " option
        
        case $option in
            1) create_vm ;;
            2) start_vm ;;
            3) list_vms ;;
            4) vm_info ;;
            5) delete_vm ;;
            6) start_24x7 ;;
            7) system_status ;;
            0) 
                echo -e "👋 ${GREEN}Thank you for using ZynexCloud!${NC}"
                echo -e "🚀 ${CYAN}Visit: https://zynexcloud.com${NC}"
                exit 0
                ;;
            *)
                echo -e "❌ ${RED}Invalid option!${NC}"
                ;;
        esac
        
        echo
        read -p "⏎ Press Enter to continue..."
    done
}

# 🚀 Script Start
echo -e "${PURPLE}"
echo "╔════════════════════════════════════════╗"
echo "║          🚀 INITIALIZING...           ║"
echo "║        ZynexCloud VM Manager          ║"
echo "╚════════════════════════════════════════╝"
echo -e "${NC}"

# Check deps (but don't exit if missing in IDX)
if ! check_deps; then
    echo -e "⚠️ ${YELLOW}Running in limited mode${NC}"
fi

main_menu
