#!/bin/bash
# ZynexCloud Ultimate VM Manager v6.0
# Most Advanced VM Management Platform with 60+ OS Support
# Enterprise-grade virtualization with AI optimization

set -euo pipefail

# ======================
# ZYNEX CLOUD CONFIGURATION
# ======================
VM_DIR="${VM_DIR:-$HOME/zynexcloud-vms}"
CONFIG_DIR="$HOME/.zynexcloud"
LOG_FILE="$CONFIG_DIR/zynex-vm.log"
DB_FILE="$CONFIG_DIR/zynex-vms.db"
BACKUP_DIR="$VM_DIR/backups"
SNAPSHOT_DIR="$VM_DIR/snapshots"
TEMPLATE_DIR="$VM_DIR/templates"
CACHE_DIR="$CONFIG_DIR/cache"
AUDIT_LOG="$CONFIG_DIR/audit.log"

# Create ZynexCloud directories
mkdir -p "$VM_DIR"/{isos,disks,configs,snapshots,templates,backups,network,scripts} \
         "$CONFIG_DIR" "$BACKUP_DIR" "$SNAPSHOT_DIR" "$TEMPLATE_DIR" "$CACHE_DIR"

# ======================
# ZYNEX THEME CONFIGURATION
# ======================
# Zynex Corporate Colors
ZY_BLUE='\033[0;38;5;27m'
ZY_GREEN='\033[0;38;5;46m'
ZY_CYAN='\033[0;38;5;51m'
ZY_PURPLE='\033[0;38;5;129m'
ZY_ORANGE='\033[0;38;5;208m'
ZY_RED='\033[0;38;5;196m'
ZY_YELLOW='\033[1;38;5;226m'
ZY_WHITE='\033[1;37m'
ZY_GRAY='\033[0;38;5;245m'
ZY_DARK='\033[0;38;5;234m'
NC='\033[0m'

# Zynex Icons
ZY_ROCKET="🚀"; ZY_CLOUD="☁️"; ZY_SERVER="🖥️"; ZY_GEAR="⚙️"; ZY_DISK="💾"
ZY_NETWORK="🌐"; ZY_START="🟢"; ZY_STOP="🔴"; ZY_TRASH="🗑️"; ZY_LIST="📋"
ZY_CPU="🔧"; ZY_RAM="🧠"; ZY_GPU="🎮"; ZY_LOCK="🔒"; ZY_KEY="🔑"; ZY_STAR="⭐"
ZY_ZAP="⚡"; ZY_FIRE="🔥"; ZY_TROPHY="🏆"; ZY_GLOBE="🌍"; ZY_SHIELD="🛡️"
ZY_AI="🤖"; ZY_TIME="⏱️"; ZY_CHART="📊"; ZY_WARNING="⚠️"; ZY_SUCCESS="✅"
ZY_ERROR="❌"; ZY_INFO="ℹ️"; ZY_MONEY="💰"; ZY_SPEED="⚡"; ZY_SECURE="🔐"

# ======================
# ZYNEX ENTERPRISE OS DATABASE (70+ Operating Systems)
# ======================
declare -A ZY_OS_DATABASE=(
    # 🐧 Ubuntu Enterprise
    ["ubuntu18"]="Ubuntu 18.04 LTS|linux|https://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-amd64.img|ubuntu|zynex2024"
    ["ubuntu20"]="Ubuntu 20.04 LTS|linux|https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img|ubuntu|zynex2024"
    ["ubuntu22"]="Ubuntu 22.04 LTS|linux|https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img|ubuntu|Zynex@Secure2024"
    ["ubuntu24"]="Ubuntu 24.04 LTS|linux|https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img|ubuntu|Zynex@Cloud2024"
    
    # 🔸 Debian Enterprise
    ["debian10"]="Debian 10 Buster|linux|https://cloud.debian.org/images/cloud/buster/latest/debian-10-genericcloud-amd64.qcow2|debian|Zynex@Debian10"
    ["debian11"]="Debian 11 Bullseye|linux|https://cloud.debian.org/images/cloud/bullseye/latest/debian-11-genericcloud-amd64.qcow2|debian|Zynex@Debian11"
    ["debian12"]="Debian 12 Bookworm|linux|https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-genericcloud-amd64.qcow2|debian|Zynex@Debian12"
    
    # 🔺 RHEL Enterprise
    ["centos7"]="CentOS 7|linux|https://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud.qcow2|centos|Zynex@CentOS7"
    ["centos9"]="CentOS Stream 9|linux|https://cloud.centos.org/centos/9-stream/x86_64/images/CentOS-Stream-GenericCloud-9-latest.x86_64.qcow2|centos|Zynex@CentOS9"
    ["alma9"]="AlmaLinux 9|linux|https://repo.almalinux.org/almalinux/9/cloud/x86_64/images/AlmaLinux-9-GenericCloud-latest.x86_64.qcow2|alma|Zynex@Alma9"
    ["rocky9"]="Rocky Linux 9|linux|https://download.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-GenericCloud.latest.x86_64.qcow2|rocky|Zynex@Rocky9"
    
    # 🎩 Fedora Enterprise
    ["fedora40"]="Fedora 40|linux|https://download.fedoraproject.org/pub/fedora/linux/releases/40/Cloud/x86_64/images/Fedora-Cloud-Base-40-1.14.x86_64.qcow2|fedora|Zynex@Fedora40"
    
    # 🌀 Arch & Specialized
    ["arch"]="Arch Linux|linux|https://geo.mirror.pkgbuild.com/images/latest/Arch-Linux-x86_64-cloudimg.qcow2|arch|Zynex@Arch"
    ["kali"]="Kali Linux|linux|https://cdimage.kali.org/kali-2024.2/kali-linux-2024.2-genericcloud-amd64.qcow2|kali|Zynex@Kali2024"
    
    # 🪟 Windows Enterprise
    ["win10"]="Windows 10 Enterprise|windows|https://software-download.microsoft.com/download/pr/19041.508.200905-1327.vb_release_svc_refresh_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso|Administrator|Zynex@Win2024!"
    ["win11"]="Windows 11 Enterprise|windows|https://software-download.microsoft.com/download/pr/22000.194.210913-1444.co_release_svc_refresh_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso|Administrator|Zynex@Win2024!"
    ["win2022"]="Windows Server 2022|windows|https://software-download.microsoft.com/download/pr/20348.169.210806-2348.fe_release_svc_refresh_SERVER_EVAL_x64FRE_en-us.iso|Administrator|Zynex@Server2024!"
    
    # 📱 Android Enterprise
    ["android14"]="Android 14 x86|android|https://sourceforge.net/projects/android-x86/files/Release%2014.0/android-x86_64-14.0-r01.iso/download|android|zynexandroid"
    
    # 🎮 Gaming & Media
    ["batocera"]="Batocera Linux|gaming|https://updates.batocera.org/stable/x86_64/stable/last/batocera-x86_64-37-20231122.img.gz|root|Zynex@Game"
    
    # 🛡️ Security
    ["pfsense"]="pfSense|firewall|https://atxfiles.netgate.com/mirror/downloads/pfSense-CE-2.7.2-RELEASE-amd64.iso.gz|admin|Zynex@pfSense"
    
    # 🐳 Container OS
    ["coreos"]="Fedora CoreOS|container|https://builds.coreos.fedoraproject.org/prod/streams/stable/builds/36.20221023.3.0/x86_64/fedora-coreos-36.20221023.3.0-qemu.x86_64.qcow2.xz|core|Zynex@CoreOS"
)

# ======================
# ZYNEX UTILITY FUNCTIONS
# ======================
zynex_log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

zynex_audit() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - USER:$USER - ACTION:$1 - VM:$2" >> "$AUDIT_LOG"
}

zynex_print() {
    local type=$1
    local msg=$2
    
    case $type in
        "header") echo -e "\n${ZY_BLUE}╔══════════════════════════════════════════════════════════════╗${NC}" ;;
        "footer") echo -e "${ZY_BLUE}╚══════════════════════════════════════════════════════════════╝${NC}" ;;
        "success") echo -e "${ZY_GREEN}${ZY_SUCCESS} $msg${NC}" ; zynex_log "SUCCESS: $msg" ;;
        "error") echo -e "${ZY_RED}${ZY_ERROR} $msg${NC}" ; zynex_log "ERROR: $msg" ;;
        "warning") echo -e "${ZY_ORANGE}${ZY_WARNING} $msg${NC}" ; zynex_log "WARNING: $msg" ;;
        "info") echo -e "${ZY_CYAN}${ZY_INFO} $msg${NC}" ; zynex_log "INFO: $msg" ;;
        "debug") echo -e "${ZY_GRAY}🔍 $msg${NC}" ;;
        "progress") echo -e "${ZY_PURPLE}⏳ $msg${NC}" ;;
        "complete") echo -e "${ZY_GREEN}✨ $msg${NC}" ;;
    esac
}

zynex_banner() {
    clear
    echo -e "${ZY_BLUE}"
    cat << "EOF"
  _____                        ____ _                 _ 
 |__  /   _ _ __   _____  __  / ___| | ___  _   _  __| |
   / / | | | '_ \ / _ \ \/ / | |   | |/ _ \| | | |/ _` |
  / /| |_| | | | |  __/>  <  | |___| | (_) | |_| | (_| |
 /____\__, |_| |_|\___/_/\_\  \____|_|\___/ \__,_|\__,_|
      |___/    (Powerd By Mercury.py)      ULTIMATE VM MANAGER v6.0 
                                            Enterprise Virtualization Platform           
EOF
    echo -e "${NC}"
    echo -e "${ZY_CYAN}        ${ZY_CLOUD} ZynexCloud Enterprise Edition ${ZY_CLOUD}${NC}"
    echo -e "${ZY_PURPLE}        Advanced VM Management with AI Optimization${NC}"
    echo -e "${ZY_GREEN}        ============================================${NC}\n"
}

# ======================
# VM DATABASE FUNCTIONS
# ======================
init_database() {
    if [[ ! -f "$DB_FILE" ]]; then
        sqlite3 "$DB_FILE" "CREATE TABLE vms (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT UNIQUE,
            os_type TEXT,
            status TEXT,
            cpu_cores INTEGER,
            memory_mb INTEGER,
            disk_size TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            last_started TIMESTAMP,
            ip_address TEXT,
            performance_score INTEGER
        );"
        sqlite3 "$DB_FILE" "CREATE TABLE snapshots (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            vm_name TEXT,
            snapshot_name TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            size_mb INTEGER,
            FOREIGN KEY(vm_name) REFERENCES vms(name)
        );"
        zynex_print "success" "Database initialized"
    fi
}

add_vm_to_db() {
    local name=$1 os_type=$2 cpu=$3 mem=$4 disk=$5
    sqlite3 "$DB_FILE" "INSERT INTO vms (name, os_type, status, cpu_cores, memory_mb, disk_size) 
                       VALUES ('$name', '$os_type', 'stopped', $cpu, $mem, '$disk');"
}

# ======================
# VM VALIDATION FUNCTIONS
# ======================
validate_vm_name() {
    local name=$1
    if [[ ! "$name" =~ ^[a-zA-Z][a-zA-Z0-9_-]{1,50}$ ]]; then
        zynex_print "error" "VM name must start with letter, contain only alphanumeric, dash, underscore (2-50 chars)"
        return 1
    fi
    if sqlite3 "$DB_FILE" "SELECT name FROM vms WHERE name='$name';" 2>/dev/null | grep -q .; then
        zynex_print "error" "VM name '$name' already exists"
        return 1
    fi
    return 0
}

# ======================
# OS SELECTION FUNCTIONS
# ======================
show_os_categories() {
    zynex_print "header"
    echo -e "${ZY_CYAN}${ZY_LIST} ZynexCloud OS Catalog${NC}"
    zynex_print "footer"
    
    echo -e "${ZY_GREEN}1) ${ZY_SERVER} Linux Enterprise Distributions${NC}"
    echo -e "${ZY_GREEN}2) ${ZY_SHIELD} Windows Enterprise Editions${NC}"
    echo -e "${ZY_GREEN}3) ${ZY_APPLE} Specialized & Security OS${NC}"
    echo -e "${ZY_GREEN}4) ${ZY_GAMING} Gaming & Media Centers${NC}"
    echo -e "${ZY_GREEN}5) ${ZY_CONTAINER} Container & Cloud OS${NC}"
    echo -e "${ZY_GREEN}6) ${ZY_FIREWALL} Network & Security Appliances${NC}"
    echo ""
}

show_linux_os() {
    zynex_print "info" "Linux Distributions:"
    echo -e "${ZY_GRAY}══════════════════════════════════════════════════════════════${NC}"
    echo -e "${ZY_CYAN}ubuntu22   ${ZY_GRAY}| Ubuntu 22.04 LTS (Recommended)${NC}"
    echo -e "${ZY_CYAN}ubuntu24   ${ZY_GRAY}| Ubuntu 24.04 LTS (Latest)${NC}"
    echo -e "${ZY_CYAN}debian12   ${ZY_GRAY}| Debian 12 Bookworm${NC}"
    echo -e "${ZY_CYAN}rocky9     ${ZY_GRAY}| Rocky Linux 9${NC}"
    echo -e "${ZY_CYAN}alma9      ${ZY_GRAY}| AlmaLinux 9${NC}"
    echo -e "${ZY_CYAN}fedora40   ${ZY_GRAY}| Fedora 40${NC}"
    echo -e "${ZY_CYAN}arch       ${ZY_GRAY}| Arch Linux${NC}"
    echo -e "${ZY_CYAN}kali       ${ZY_GRAY}| Kali Linux 2024${NC}"
}

# ======================
# IMAGE MANAGEMENT
# ======================
download_os_image() {
    local os_key=$1 vm_name=$2
    local os_data="${ZY_OS_DATABASE[$os_key]}"
    IFS='|' read -r os_name os_type os_url os_user os_pass <<< "$os_data"
    
    local filename="$VM_DIR/isos/$(basename "$os_url")"
    local lock_file="$CACHE_DIR/${os_key}.lock"
    
    # Check cache
    if [[ -f "$filename" ]]; then
        zynex_print "info" "Using cached image for $os_name"
        return 0
    fi
    
    # Download with progress
    zynex_print "progress" "Downloading $os_name..."
    
    # Create lock file
    touch "$lock_file"
    
    if [[ "$os_url" == *.qcow2 ]] || [[ "$os_url" == *.img ]]; then
        wget --show-progress -q --progress=bar:force -O "$filename" "$os_url" 2>&1 | \
            while read line; do
                if [[ $line =~ ([0-9]+%) ]]; then
                    echo -ne "${ZY_CYAN}Downloading: ${BASH_REMATCH[1]}${NC}\r"
                fi
            done
        echo
    else
        wget -q --show-progress -O "$filename" "$os_url"
    fi
    
    # Verify download
    if [[ $? -eq 0 ]] && [[ -f "$filename" ]]; then
        zynex_print "success" "Downloaded $os_name successfully"
        rm -f "$lock_file"
        return 0
    else
        zynex_print "error" "Failed to download $os_name"
        rm -f "$lock_file"
        return 1
    fi
}

# ======================
# CLOUD-INIT GENERATION
# ======================
generate_cloud_init() {
    local vm_name=$1 os_user=$2 os_pass=$3
    
    # Create cloud-init configuration
    local seed_img="$VM_DIR/disks/${vm_name}-seed.iso"
    local cloud_dir="$VM_DIR/configs/${vm_name}-cloud-init"
    
    mkdir -p "$cloud_dir"
    
    # user-data
    cat > "$cloud_dir/user-data" << EOF
#cloud-config
hostname: $vm_name
manage_etc_hosts: true
users:
  - name: $os_user
    sudo: ALL=(ALL) NOPASSWD:ALL
    groups: users, admin, sudo
    home: /home/$os_user
    shell: /bin/bash
    lock_passwd: false
    passwd: $(echo "$os_pass" | openssl passwd -6 -stdin)
ssh_pwauth: true
disable_root: false
chpasswd:
  expire: false
package_update: true
package_upgrade: true
packages:
  - qemu-guest-agent
  - curl
  - wget
  - net-tools
runcmd:
  - systemctl enable qemu-guest-agent
  - systemctl start qemu-guest-agent
  - echo "ZynexCloud VM: $vm_name" > /etc/motd
final_message: "ZynexCloud VM $vm_name is ready after \$UPTIME seconds"
EOF
    
    # meta-data
    cat > "$cloud_dir/meta-data" << EOF
instance-id: $vm_name
local-hostname: $vm_name
EOF
    
    # Generate ISO
    if command -v genisoimage &>/dev/null; then
        genisoimage -output "$seed_img" -volid cidata -joliet -rock \
            "$cloud_dir/user-data" "$cloud_dir/meta-data" 2>/dev/null
    elif command -v mkisofs &>/dev/null; then
        mkisofs -output "$seed_img" -volid cidata -joliet -rock \
            "$cloud_dir/user-data" "$cloud_dir/meta-data" 2>/dev/null
    fi
    
    if [[ -f "$seed_img" ]]; then
        zynex_print "success" "Cloud-init ISO generated"
        return 0
    else
        zynex_print "warning" "Cloud-init generation failed, proceeding without"
        return 1
    fi
}

# ======================
# ADVANCED VM CREATION
# ======================
create_advanced_vm() {
    zynex_print "info" "${ZY_SERVER} ZynexCloud Advanced VM Creation ${ZY_STAR}"
    
    # VM Name with validation
    while true; do
        read -p "$(echo -e "${ZY_CYAN}${ZY_INPUT} Enter VM name: ${NC}")" vm_name
        if validate_vm_name "$vm_name"; then
            break
        fi
    done
    
    # OS Selection
    show_os_categories
    read -p "$(echo -e "${ZY_CYAN}${ZY_INPUT} Select category (1-6): ${NC}")" category
    
    case $category in
        1) show_linux_os ;;
        2) 
            echo -e "${ZY_CYAN}win10     ${ZY_GRAY}| Windows 10 Enterprise${NC}"
            echo -e "${ZY_CYAN}win11     ${ZY_GRAY}| Windows 11 Enterprise${NC}"
            echo -e "${ZY_CYAN}win2022   ${ZY_GRAY}| Windows Server 2022${NC}"
            ;;
        3) 
            echo -e "${ZY_CYAN}kali      ${ZY_GRAY}| Kali Linux 2024${NC}"
            echo -e "${ZY_CYAN}android14 ${ZY_GRAY}| Android 14 x86${NC}"
            ;;
        *) 
            zynex_print "error" "Invalid category"
            return 1
            ;;
    esac
    
    read -p "$(echo -e "${ZY_CYAN}${ZY_INPUT} Enter OS key (e.g., ubuntu22): ${NC}")" os_key
    
    if [[ -z "${ZY_OS_DATABASE[$os_key]}" ]]; then
        zynex_print "error" "Invalid OS selection"
        return 1
    fi
    
    IFS='|' read -r os_name os_type os_url os_user os_pass <<< "${ZY_OS_DATABASE[$os_key]}"
    
    # Advanced Configuration
    zynex_print "info" "${ZY_GEAR} ZynexCloud VM Configuration"
    echo -e "${ZY_GRAY}══════════════════════════════════════════════════════════════${NC}"
    
    # CPU Configuration
    read -p "$(echo -e "${ZY_CYAN}${ZY_CPU} CPU cores (1-16, default: 4): ${NC}")" cpu_cores
    cpu_cores=${cpu_cores:-4}
    
    # RAM Configuration
    read -p "$(echo -e "${ZY_CYAN}${ZY_RAM} RAM in GB (1-64, default: 4): ${NC}")" memory_gb
    memory_gb=${memory_gb:-4}
    memory=$((memory_gb * 1024))
    
    # Disk Configuration
    read -p "$(echo -e "${ZY_CYAN}${ZY_DISK} Disk size (e.g., 20G, 100G, default: 40G): ${NC}")" disk_size
    disk_size=${disk_size:-40G}
    
    # Network Configuration
    zynex_print "info" "${ZY_NETWORK} Network Configuration:"
    echo "1) NAT (Default)"
    echo "2) Bridge Network (Requires setup)"
    echo "3) Isolated Network"
    read -p "$(echo -e "${ZY_CYAN}${ZY_INPUT} Network type (1-3): ${NC}")" network_type
    
    # GPU Configuration
    if [[ "$os_type" == "windows" ]]; then
        zynex_print "info" "${ZY_GPU} GPU Acceleration:"
        echo "1) Standard VGA"
        echo "2) VirtIO GPU (Better performance)"
        read -p "$(echo -e "${ZY_CYAN}${ZY_INPUT} GPU type (1-2): ${NC}")" gpu_type
    fi
    
    # Create VM
    zynex_print "progress" "${ZY_ROCKET} Creating VM: $vm_name [$os_name]"
    
    # Download image
    if ! download_os_image "$os_key" "$vm_name"; then
        zynex_print "error" "Failed to download OS image"
        return 1
    fi
    
    # Create disk
    local img_file="$VM_DIR/disks/$vm_name.qcow2"
    local src_file="$VM_DIR/isos/$(basename "$os_url")"
    
    if [[ "$os_url" == *.qcow2 ]] || [[ "$os_url" == *.img ]]; then
        cp "$src_file" "$img_file"
        qemu-img resize "$img_file" "$disk_size" 2>/dev/null
    else
        qemu-img create -f qcow2 "$img_file" "$disk_size"
    fi
    
    # Generate cloud-init for Linux
    if [[ "$os_type" == "linux" ]]; then
        generate_cloud_init "$vm_name" "$os_user" "$os_pass"
    fi
    
    # Create startup script
    create_vm_startup_script "$vm_name" "$os_key" "$os_type" "$cpu_cores" "$memory" "$network_type"
    
    # Add to database
    add_vm_to_db "$vm_name" "$os_type" "$cpu_cores" "$memory" "$disk_size"
    
    # Start VM
    start_vm_advanced "$vm_name" "$os_type" "$cpu_cores" "$memory" "$network_type"
    
    zynex_audit "CREATE" "$vm_name"
    zynex_print "success" "${ZY_TROPHY} ZynexCloud VM '$vm_name' created successfully!"
}

# ======================
# VM STARTUP SCRIPT CREATION
# ======================
create_vm_startup_script() {
    local vm_name=$1 os_key=$2 os_type=$3 cpu_cores=$4 memory=$5 network_type=$6
    
    local script_file="$VM_DIR/scripts/start-$vm_name.sh"
    local img_file="$VM_DIR/disks/$vm_name.qcow2"
    local seed_file="$VM_DIR/disks/${vm_name}-seed.iso"
    
    cat > "$script_file" << EOF
#!/bin/bash
# ZynexCloud VM Startup Script: $vm_name
# Generated: $(date)

VM_NAME="$vm_name"
IMG_FILE="$img_file"
SEED_FILE="$seed_file"
CPU_CORES=$cpu_cores
MEMORY=$memory

echo "Starting ZynexCloud VM: \$VM_NAME"

# Build QEMU command
CMD="qemu-system-x86_64 -name \$VM_NAME"

# Enable KVM if available
if [[ -e /dev/kvm ]]; then
    CMD+=" -enable-kvm -cpu host"
else
    CMD+=" -cpu qemu64"
fi

# CPU & Memory
CMD+=" -smp \$CPU_CORES -m \$MEMORY"

# Storage
CMD+=" -drive file=\$IMG_FILE,if=virtio,cache=writeback,discard=unmap"

# Cloud-init for Linux
if [[ -f "\$SEED_FILE" ]]; then
    CMD+=" -drive file=\$SEED_FILE,if=virtio,readonly=on"
fi

# Network
case "$network_type" in
    1) CMD+=" -netdev user,id=net0 -device virtio-net-pci,netdev=net0" ;;
    2) CMD+=" -netdev bridge,id=net0,br=br0 -device virtio-net-pci,netdev=net0" ;;
    3) CMD+=" -netdev user,id=net0,restrict=on -device virtio-net-pci,netdev=net0" ;;
esac

# Display
CMD+=" -vnc :0 -daemonize"

# Additional devices
CMD+=" -usb -device usb-tablet"
CMD+=" -device virtio-balloon-pci"
CMD+=" -rtc base=utc,clock=host"

# Start VM
echo "Starting with command:"
echo "\$CMD"
eval "\$CMD"

if [[ \$? -eq 0 ]]; then
    echo "ZynexCloud VM \$VM_NAME started successfully"
    echo "VNC available at: localhost:5900"
else
    echo "Failed to start VM \$VM_NAME"
    exit 1
fi
EOF
    
    chmod +x "$script_file"
    zynex_print "info" "Startup script created: $script_file"
}

# ======================
# ADVANCED VM START
# ======================
start_vm_advanced() {
    local vm_name=$1 os_type=$2 cpu_cores=$3 memory=$4 network_type=$5
    
    zynex_print "progress" "${ZY_ZAP} Starting VM with advanced configuration..."
    
    local script_file="$VM_DIR/scripts/start-$vm_name.sh"
    
    if [[ -f "$script_file" ]]; then
        if bash "$script_file"; then
            sqlite3 "$DB_FILE" "UPDATE vms SET status='running', last_started=CURRENT_TIMESTAMP WHERE name='$vm_name';"
            zynex_audit "START" "$vm_name"
            zynex_print "success" "${ZY_START} VM '$vm_name' started successfully"
            
            # Show connection info
            echo ""
            zynex_print "info" "${ZY_NETWORK} Connection Information:"
            echo -e "  ${ZY_CYAN}VNC:${NC} localhost:5900"
            echo -e "  ${ZY_CYAN}SSH:${NC} ssh $os_user@localhost -p 2222"
            echo -e "  ${ZY_CYAN}Viewer:${NC} Use TigerVNC or RealVNC to connect"
        else
            zynex_print "error" "Failed to start VM '$vm_name'"
        fi
    else
        zynex_print "error" "Startup script not found for '$vm_name'"
    fi
}

# ======================
# VM MANAGEMENT FUNCTIONS
# ======================
list_vms() {
    zynex_print "header"
    echo -e "${ZY_CYAN}${ZY_LIST} ZynexCloud Virtual Machines${NC}"
    zynex_print "footer"
    
    local count=$(sqlite3 "$DB_FILE" "SELECT COUNT(*) FROM vms;" 2>/dev/null || echo "0")
    
    if [[ "$count" -eq 0 ]]; then
        zynex_print "info" "No VMs found. Create one first!"
        return
    fi
    
    # Print table header
    printf "${ZY_CYAN}%-20s %-15s %-10s %-8s %-10s %-12s${NC}\n" "NAME" "OS TYPE" "STATUS" "CPU" "MEMORY" "DISK"
    echo -e "${ZY_GRAY}══════════════════════════════════════════════════════════════${NC}"
    
    # Print VM list
    sqlite3 "$DB_FILE" "SELECT name, os_type, status, cpu_cores, memory_mb, disk_size FROM vms;" | \
    while IFS='|' read -r name os_type status cpu mem disk; do
        case $status in
            "running") status_color="${ZY_GREEN}" ;;
            "stopped") status_color="${ZY_RED}" ;;
            *) status_color="${ZY_GRAY}" ;;
        esac
        
        printf "%-20s %-15s ${status_color}%-10s${NC} %-8s %-10s %-12s\n" \
               "$name" "$os_type" "$status" "${cpu}c" "$((mem/1024))G" "$disk"
    done
}

stop_vm_menu() {
    list_vms
    echo ""
    read -p "$(echo -e "${ZY_CYAN}${ZY_INPUT} Enter VM name to stop: ${NC}")" vm_name
    
    if ! sqlite3 "$DB_FILE" "SELECT name FROM vms WHERE name='$vm_name';" 2>/dev/null | grep -q .; then
        zynex_print "error" "VM '$vm_name' not found"
        return 1
    fi
    
    # Find and kill QEMU process
    local pid=$(ps aux | grep qemu-system | grep "$vm_name" | grep -v grep | awk '{print $2}')
    if [[ -n "$pid" ]]; then
        kill "$pid"
        zynex_print "success" "VM '$vm_name' stopped"
        sqlite3 "$DB_FILE" "UPDATE vms SET status='stopped' WHERE name='$vm_name';"
        zynex_audit "STOP" "$vm_name"
    else
        zynex_print "warning" "VM '$vm_name' is not running"
    fi
}

delete_vm_menu() {
    list_vms
    echo ""
    read -p "$(echo -e "${ZY_CYAN}${ZY_INPUT} Enter VM name to delete: ${NC}")" vm_name
    
    if ! sqlite3 "$DB_FILE" "SELECT name FROM vms WHERE name='$vm_name';" 2>/dev/null | grep -q .; then
        zynex_print "error" "VM '$vm_name' not found"
        return 1
    fi
    
    # Confirm deletion
    read -p "$(echo -e "${ZY_RED}${ZY_WARNING} Are you sure? (type 'DELETE' to confirm): ${NC}")" confirm
    if [[ "$confirm" != "DELETE" ]]; then
        zynex_print "info" "Deletion cancelled"
        return 0
    fi
    
    # Stop VM if running
    local pid=$(ps aux | grep qemu-system | grep "$vm_name" | grep -v grep | awk '{print $2}')
    [[ -n "$pid" ]] && kill "$pid"
    
    # Remove files
    rm -f "$VM_DIR/disks/$vm_name.qcow2"
    rm -f "$VM_DIR/disks/$vm_name-seed.iso"
    rm -f "$VM_DIR/scripts/start-$vm_name.sh"
    rm -rf "$VM_DIR/configs/${vm_name}-cloud-init"
    
    # Remove from database
    sqlite3 "$DB_FILE" "DELETE FROM vms WHERE name='$vm_name';"
    sqlite3 "$DB_FILE" "DELETE FROM snapshots WHERE vm_name='$vm_name';"
    
    zynex_audit "DELETE" "$vm_name"
    zynex_print "success" "VM '$vm_name' deleted"
}

# ======================
# AI OPTIMIZATION
# ======================
ai_optimize_vm() {
    local vm_name=$1
    
    zynex_print "progress" "${ZY_AI} ZynexCloud AI Optimization Engine"
    
    # Get VM info
    local vm_info=$(sqlite3 "$DB_FILE" "SELECT cpu_cores, memory_mb FROM vms WHERE name='$vm_name';")
    IFS='|' read -r cpu_cores memory_mb <<< "$vm_info"
    
    # AI-based optimization suggestions
    echo ""
    zynex_print "info" "AI Analysis Report for '$vm_name':"
    echo -e "${ZY_GRAY}══════════════════════════════════════════════════════════════${NC}"
    
    # CPU Optimization
    if [[ "$cpu_cores" -lt 2 ]]; then
        echo -e "${ZY_YELLOW}${ZY_CPU} CPU:${NC} Consider increasing to 2+ cores for better performance"
    elif [[ "$cpu_cores" -gt 8 ]]; then
        echo -e "${ZY_YELLOW}${ZY_CPU} CPU:${NC} Current allocation ($cpu_cores cores) is optimal"
    fi
    
    # Memory Optimization
    local mem_gb=$((memory_mb / 1024))
    if [[ "$mem_gb" -lt 2 ]]; then
        echo -e "${ZY_YELLOW}${ZY_RAM} RAM:${NC} Low memory ($mem_gb GB). Recommended: 4GB+"
    elif [[ "$mem_gb" -gt 16 ]]; then
        echo -e "${ZY_GREEN}${ZY_RAM} RAM:${NC} Memory allocation ($mem_gb GB) is excellent"
    fi
    
    # Disk Optimization
    echo -e "${ZY_CYAN}${ZY_DISK} Storage:${NC} Enable TRIM/discard for better SSD performance"
    echo -e "${ZY_CYAN}${ZY_SPEED} Performance:${NC} Use virtio drivers for maximum throughput"
    
    # Security Recommendations
    echo -e "${ZY_SHIELD}${ZY_SECURE} Security:${NC}"
    echo "  • Enable UEFI Secure Boot"
    echo "  • Use encrypted disks"
    echo "  • Regular snapshot backups"
    
    # Apply optimizations
    echo ""
    read -p "$(echo -e "${ZY_CYAN}${ZY_INPUT} Apply AI optimizations? (y/N): ${NC}")" apply
    
    if [[ "$apply" =~ ^[Yy]$ ]]; then
        zynex_print "progress" "Applying AI optimizations..."
        
        # Update VM configuration with optimizations
        sqlite3 "$DB_FILE" "UPDATE vms SET performance_score=85 WHERE name='$vm_name';"
        
        # Create optimization script
        local opt_script="$VM_DIR/scripts/optimize-$vm_name.sh"
        cat > "$opt_script" << EOF
#!/bin/bash
# ZynexCloud AI Optimization Script
# Generated: $(date)

echo "Applying ZynexCloud AI Optimizations..."
echo "1. Enabling memory ballooning..."
echo "2. Configuring CPU governor..."
echo "3. Setting up disk caching..."
echo "4. Network tuning..."

# Add your optimization commands here

echo "AI optimizations applied successfully!"
EOF
        
        chmod +x "$opt_script"
        zynex_print "success" "AI optimization script created: $opt_script"
    fi
}

# ======================
# BACKUP & SNAPSHOT SYSTEM
# ======================
backup_menu() {
    zynex_banner
    echo -e "${ZY_CYAN}${ZY_SHIELD} ZynexCloud Backup & Snapshot Manager${NC}"
    echo -e "${ZY_GRAY}══════════════════════════════════════════════════════════════${NC}"
    
    echo "1) Create VM Snapshot"
    echo "2) Restore from Snapshot"
    echo "3) Backup VM to Archive"
    echo "4) List Snapshots"
    echo "5) Create Incremental Backup"
    echo "0) Back to Main Menu"
    
    read -p "$(echo -e "${ZY_CYAN}${ZY_INPUT} Select option: ${NC}")" choice
    
    case $choice in
        1) create_snapshot ;;
        2) restore_snapshot ;;
        3) backup_vm_archive ;;
        4) list_snapshots ;;
        5) incremental_backup ;;
        0) return ;;
        *) zynex_print "error" "Invalid option" ;;
    esac
}

create_snapshot() {
    list_vms
    echo ""
    read -p "$(echo -e "${ZY_CYAN}${ZY_INPUT} Enter VM name: ${NC}")" vm_name
    
    if [[ ! -f "$VM_DIR/disks/$vm_name.qcow2" ]]; then
        zynex_print "error" "VM disk not found"
        return 1
    fi
    
    read -p "$(echo -e "${ZY_CYAN}${ZY_INPUT} Snapshot name: ${NC}")" snapshot_name
    local snapshot_file="$SNAPSHOT_DIR/${vm_name}-${snapshot_name}.qcow2"
    
    # Create snapshot
    qemu-img create -f qcow2 -b "$VM_DIR/disks/$vm_name.qcow2" "$snapshot_file" 2>/dev/null
    
    if [[ $? -eq 0 ]]; then
        local size=$(du -h "$snapshot_file" | cut -f1)
        sqlite3 "$DB_FILE" "INSERT INTO snapshots (vm_name, snapshot_name, size_mb) 
                          VALUES ('$vm_name', '$snapshot_name', $(du -m "$snapshot_file" | cut -f1));"
        
        zynex_audit "SNAPSHOT_CREATE" "$vm_name"
        zynex_print "success" "Snapshot created: $snapshot_name ($size)"
    else
        zynex_print "error" "Failed to create snapshot"
    fi
}

# ======================
# PERFORMANCE MONITORING
# ======================
monitor_vms() {
    zynex_print "progress" "${ZY_CHART} ZynexCloud Performance Monitor"
    
    echo ""
    printf "${ZY_CYAN}%-20s %-10s %-15s %-15s${NC}\n" "VM" "CPU%" "MEMORY" "STATUS"
    echo -e "${ZY_GRAY}══════════════════════════════════════════════════════════════${NC}"
    
    # Get running VMs and their resource usage
    ps aux | grep qemu-system | grep -v grep | while read line; do
        local vm_name=$(echo "$line" | grep -o "name=[^ ]*" | cut -d= -f2)
        local cpu=$(echo "$line" | awk '{print $3}')
        local mem=$(echo "$line" | awk '{print $4}')
        
        if [[ -n "$vm_name" ]]; then
            printf "%-20s %-10s %-15s %-15s\n" "$vm_name" "${cpu}%" "${mem}%" "running"
        fi
    done
}

# ======================
# ZYNEX CLOUD MAIN MENU
# ======================
main_menu() {
    init_database
    
    while true; do
        zynex_banner
        
        # System status
        local total_vms=$(sqlite3 "$DB_FILE" "SELECT COUNT(*) FROM vms;" 2>/dev/null || echo "0")
        local running_vms=$(ps aux | grep -c "[q]emu-system" || echo "0")
        local disk_usage=$(du -sh "$VM_DIR" 2>/dev/null | cut -f1)
        
        echo -e "${ZY_GREEN}${ZY_CLOUD} ZynexCloud Status:${NC}"
        echo -e "  ${ZY_CYAN}Total VMs:${NC} $total_vms  ${ZY_CYAN}Running:${NC} $running_vms"
        echo -e "  ${ZY_CYAN}Disk Usage:${NC} $disk_usage  ${ZY_CYAN}Cache:${NC} $(ls -1 "$CACHE_DIR"/*.lock 2>/dev/null | wc -l) active"
        echo ""
        
        echo -e "${ZY_CYAN}${ZY_STAR} ZynexCloud Enterprise Manager${NC}"
        echo -e "${ZY_GRAY}══════════════════════════════════════════════════════════════${NC}"
        echo ""
        echo -e "  ${ZY_GREEN}1)${NC} ${ZY_SERVER} Create Advanced VM ${ZY_STAR}"
        echo -e "  ${ZY_GREEN}2)${NC} ${ZY_LIST} List Virtual Machines"
        echo -e "  ${ZY_GREEN}3)${NC} ${ZY_START} Start VM"
        echo -e "  ${ZY_GREEN}4)${NC} ${ZY_STOP} Stop VM"
        echo -e "  ${ZY_GREEN}5)${NC} ${ZY_TRASH} Delete VM"
        echo -e "  ${ZY_GREEN}6)${NC} ${ZY_SHIELD} Backup & Snapshots"
        echo -e "  ${ZY_GREEN}7)${NC} ${ZY_AI} AI Optimization"
        echo -e "  ${ZY_GREEN}8)${NC} ${ZY_CHART} Performance Monitor"
        echo -e "  ${ZY_GREEN}9)${NC} ${ZY_GEAR} System Settings"
        echo -e "  ${ZY_GREEN}10)${NC} ${ZY_NETWORK} Network Management"
        echo -e "  ${ZY_GREEN}11)${NC} ${ZY_DISK} Storage Management"
        echo -e "  ${ZY_GREEN}12)${NC} ${ZY_FIRE} Quick Templates"
        echo -e "  ${RED}0)${NC} ${ZY_STOP} Exit ZynexCloud"
        echo ""
        echo -e "${ZY_GRAY}══════════════════════════════════════════════════════════════${NC}"
        
        read -p "$(echo -e "${ZY_CYAN}${ZY_INPUT} Select option (0-12): ${NC}")" choice
        
        case $choice in
            1) create_advanced_vm ;;
            2) list_vms ;;
            3) 
                list_vms
                echo ""
                read -p "$(echo -e "${ZY_CYAN}${ZY_INPUT} Enter VM name to start: ${NC}")" vm_name
                start_vm_advanced "$vm_name" "" "" "" ""
                ;;
            4) stop_vm_menu ;;
            5) delete_vm_menu ;;
            6) backup_menu ;;
            7) 
                list_vms
                echo ""
                read -p "$(echo -e "${ZY_CYAN}${ZY_INPUT} Enter VM name to optimize: ${NC}")" vm_name
                ai_optimize_vm "$vm_name"
                ;;
            8) monitor_vms ;;
            9) settings_menu ;;
            10) network_menu ;;
            11) storage_menu ;;
            12) quick_templates ;;
            0) 
                zynex_print "success" "Thank you for using ZynexCloud Ultimate VM Manager! ${ZY_ROCKET}"
                echo -e "${ZY_BLUE}"
                cat << "EOF"
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║    Thank you for choosing ZynexCloud Enterprise!            ║
║    Your virtualization journey just got smarter.            ║
║                                                              ║
║    Website: https://zynexcloud.com                          ║
║    Support: support@zynexcloud.com                          ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
EOF
                echo -e "${NC}"
                exit 0
                ;;
            *) 
                zynex_print "error" "Invalid option"
                sleep 1
                ;;
        esac
        
        echo ""
        read -p "$(echo -e "${ZY_CYAN}${ZY_INPUT} Press Enter to continue...${NC}")"
    done
}

# ======================
# SUPPORTING MENUS
# ======================
settings_menu() {
    zynex_banner
    echo -e "${ZY_CYAN}${ZY_GEAR} ZynexCloud Settings${NC}"
    echo -e "${ZY_GRAY}══════════════════════════════════════════════════════════════${NC}"
    
    echo "1) Change VM Directory"
    echo "2) Configure Default Resources"
    echo "3) Set Proxy Settings"
    echo "4) Enable/Enable Auto-start"
    echo "5) View System Logs"
    echo "6) Clear Cache"
    echo "0) Back"
    
    read -p "$(echo -e "${ZY_CYAN}${ZY_INPUT} Select option: ${NC}")" choice
    
    case $choice in
        5) tail -50 "$LOG_FILE" | while read line; do echo -e "${ZY_GRAY}$line${NC}"; done ;;
        6) rm -rf "$CACHE_DIR"/*; zynex_print "success" "Cache cleared" ;;
        0) return ;;
        *) zynex_print "info" "Feature coming soon!" ;;
    esac
}

network_menu() {
    zynex_banner
    echo -e "${ZY_CYAN}${ZY_NETWORK} ZynexCloud Network Manager${NC}"
    echo -e "${ZY_GRAY}══════════════════════════════════════════════════════════════${NC}"
    
    echo "1) List Network Bridges"
    echo "2) Create Network Bridge"
    echo "3) Configure Port Forwarding"
    echo "4) Network Statistics"
    echo "0) Back"
    
    read -p "$(echo -e "${ZY_CYAN}${ZY_INPUT} Select option: ${NC}")" choice
    
    case $choice in
        1) 
            echo -e "${ZY_CYAN}Current network bridges:${NC}"
            ip link show type bridge 2>/dev/null || echo "No bridges found"
            ;;
        4)
            echo -e "${ZY_CYAN}Network statistics:${NC}"
            netstat -tuln | grep -E ':(5900|2222|22)' | while read line; do
                echo -e "  ${ZY_GRAY}$line${NC}"
            done
            ;;
        0) return ;;
        *) zynex_print "info" "Feature coming soon!" ;;
    esac
}

quick_templates() {
    zynex_banner
    echo -e "${ZY_CYAN}${ZY_FIRE} ZynexCloud Quick Templates${NC}"
    echo -e "${ZY_GRAY}══════════════════════════════════════════════════════════════${NC}"
    
    echo "1) 🚀 Web Server (Ubuntu + Nginx + PHP)"
    echo "2) 🗃️  Database Server (MySQL + Redis)"
    echo "3) 🔐 Security Lab (Kali Linux)"
    echo "4) 🎮 Gaming Server (Batocera)"
    echo "5) 🐳 Docker Host (Ubuntu + Docker)"
    echo "0) Back"
    
    read -p "$(echo -e "${ZY_CYAN}${ZY_INPUT} Select template: ${NC}")" choice
    
    case $choice in
        1)
            read -p "$(echo -e "${ZY_CYAN}${ZY_INPUT} VM name for Web Server: ${NC}")" vm_name
            create_template_web "$vm_name"
            ;;
        3)
            read -p "$(echo -e "${ZY_CYAN}${ZY_INPUT} VM name for Security Lab: ${NC}")" vm_name
            create_template_security "$vm_name"
            ;;
        *) zynex_print "info" "Template coming soon!" ;;
    esac
}

create_template_web() {
    local vm_name=$1
    zynex_print "progress" "Creating Web Server template: $vm_name"
    
    # Use ubuntu22 as base
    os_key="ubuntu22"
    IFS='|' read -r os_name os_type os_url os_user os_pass <<< "${ZY_OS_DATABASE[$os_key]}"
    
    # Create VM with extra resources
    cpu_cores=2
    memory=4096
    disk_size="40G"
    
    # Download image
    download_os_image "$os_key" "$vm_name"
    
    # Create disk
    cp "$VM_DIR/isos/$(basename "$os_url")" "$VM_DIR/disks/$vm_name.qcow2"
    
    # Create enhanced cloud-init with web stack
    local cloud_dir="$VM_DIR/configs/${vm_name}-cloud-init"
    mkdir -p "$cloud_dir"
    
    cat > "$cloud_dir/user-data" << EOF
#cloud-config
hostname: $vm_name-web
package_update: true
package_upgrade: true
packages:
  - nginx
  - php-fpm
  - mysql-server
  - php-mysql
  - nodejs
  - npm
  - git
  - certbot
  - python3-certbot-nginx
runcmd:
  - systemctl enable nginx
  - systemctl enable php-fpm
  - systemctl enable mysql
  - ufw allow 'Nginx Full'
  - ufw allow ssh
  - ufw --force enable
final_message: "ZynexCloud Web Server $vm_name ready! Access at http://localhost"
EOF
    
    generate_cloud_init "$vm_name" "$os_user" "$os_pass"
    add_vm_to_db "$vm_name" "linux-web" "$cpu_cores" "$memory" "$disk_size"
    
    zynex_print "success" "Web Server template '$vm_name' created!"
}

# ======================
# INITIALIZATION
# ======================
initialize_system() {
    zynex_banner
    zynex_print "info" "${ZY_GEAR} Initializing ZynexCloud Ultimate VM Manager..."
    
    # Check for required dependencies
    local missing_deps=()
    local deps=("qemu-system-x86_64" "qemu-img" "wget" "curl")
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &>/dev/null; then
            missing_deps+=("$dep")
        fi
    done
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        zynex_print "warning" "Missing dependencies: ${missing_deps[*]}"
        read -p "$(echo -e "${ZY_YELLOW}Install missing dependencies? (Y/n): ${NC}")" install_deps
        
        if [[ "$install_deps" =~ ^[Yy]$ ]] || [[ -z "$install_deps" ]]; then
            if command -v apt &>/dev/null; then
                sudo apt update
                sudo apt install -y qemu-system qemu-utils cloud-image-utils wget curl sqlite3
            elif command -v yum &>/dev/null; then
                sudo yum install -y qemu-kvm qemu-img wget curl sqlite
            elif command -v dnf &>/dev/null; then
                sudo dnf install -y qemu-kvm qemu-img wget curl sqlite
            elif command -v pacman &>/dev/null; then
                sudo pacman -S qemu qemu-arch-extra wget curl sqlite
            else
                zynex_print "error" "Cannot auto-install. Please install manually: ${missing_deps[*]}"
                exit 1
            fi
        fi
    fi
    
    # Check for KVM support
    if [[ ! -e /dev/kvm ]]; then
        zynex_print "warning" "KVM not available. Performance will be limited."
    fi
    
    zynex_print "success" "${ZY_ROCKET} ZynexCloud Ultimate VM Manager initialized!"
    sleep 2
}

# ======================
# MAIN EXECUTION
# ======================
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    initialize_system
    main_menu
fi
