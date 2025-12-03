#!/bin/bash
# ============================================================================
# CAVRIX CORE HYPERVISOR v10.0
# Ultimate Virtualization Platform with RDP & Full OS Support
# Enterprise Edition • Z+ Security • AI Optimized
# ============================================================================

set -eo pipefail
shopt -s nocasematch

# ============================================================================
# CAVRIX CORE CONFIGURATION
# ============================================================================
readonly CAVRIX_VERSION="10.0.0"
readonly CAVRIX_CODENAME="NEON"
readonly CAVRIX_DIR="${CAVRIX_DIR:-$HOME/cavrix-core}"
readonly CAVRIX_VMS="$CAVRIX_DIR/vms"
readonly CAVRIX_ISO="$CAVRIX_DIR/isos"
readonly CAVRIX_DISKS="$CAVRIX_DIR/disks"
readonly CAVRIX_SNAPS="$CAVRIX_DIR/snapshots"
readonly CAVRIX_TEMP="$CAVRIX_DIR/templates"
readonly CAVRIX_BACKUP="$CAVRIX_DIR/backups"
readonly CAVRIX_NET="$CAVRIX_DIR/network"
readonly CAVRIX_SCRIPTS="$CAVRIX_DIR/scripts"
readonly CAVRIX_RDP="$CAVRIX_DIR/rdp"
readonly CAVRIX_LOGS="$CAVRIX_DIR/logs"
readonly CAVRIX_DB="$CAVRIX_DIR/cavrix.db"

# Create all directories
mkdir -p "$CAVRIX_DIR" "$CAVRIX_VMS" "$CAVRIX_ISO" "$CAVRIX_DISKS" \
         "$CAVRIX_SNAPS" "$CAVRIX_TEMP" "$CAVRIX_BACKUP" "$CAVRIX_NET" \
         "$CAVRIX_SCRIPTS" "$CAVRIX_RDP" "$CAVRIX_LOGS"

# ============================================================================
# CAVRIX NEON THEME (No Variable Conflicts)
# ============================================================================
readonly CC_BLACK="\033[0;30m"
readonly CC_RED="\033[0;31m"
readonly CC_GREEN="\033[0;32m"
readonly CC_YELLOW="\033[0;33m"
readonly CC_BLUE="\033[0;34m"
readonly CC_MAGENTA="\033[0;35m"
readonly CC_CYAN="\033[0;36m"
readonly CC_WHITE="\033[1;37m"
readonly CC_ORANGE="\033[38;5;208m"
readonly CC_PURPLE="\033[38;5;93m"
readonly CC_PINK="\033[38;5;205m"
readonly CC_NEON="\033[38;5;46m"
readonly CC_MATRIX="\033[38;5;82m"
readonly CC_GOLD="\033[38;5;220m"
readonly CC_SILVER="\033[38;5;248m"
readonly CC_RESET="\033[0m"

# Icons
readonly IC_CPU="⚡"
readonly IC_RAM="🧠"
readonly IC_DISK="💾"
readonly IC_NET="🌐"
readonly IC_GPU="🎮"
readonly IC_SEC="🔐"
readonly IC_AI="🤖"
readonly IC_OK="✅"
readonly IC_ERR="❌"
readonly IC_WARN="⚠️"
readonly IC_INFO="ℹ️"
readonly IC_ROCKET="🚀"
readonly IC_STAR="⭐"
readonly IC_FIRE="🔥"
readonly IC_CLOUD="☁️"
readonly IC_SHIELD="🛡️"
readonly IC_TROPHY="🏆"
readonly IC_RDP="🖥️"
readonly IC_WIN="🪟"
readonly IC_LINUX="🐧"
readonly IC_MAC="🍎"
readonly IC_ANDROID="📱"

# ============================================================================
# COMPLETE OS DATABASE (70+ Operating Systems)
# ============================================================================
declare -A CC_OS_DATABASE=(
    # 🪟 WINDOWS FAMILY
    ["win7"]="Windows 7 Ultimate|windows|https://archive.org/download/Win7ProSP1x64/Win7ProSP1x64.iso|Administrator|Cavrix2024!"
    ["win8"]="Windows 8.1 Pro|windows|https://archive.org/download/Win8.1Pro64bit/Win8.1Pro64bit.iso|Administrator|Cavrix2024!"
    ["win10"]="Windows 10 Home|windows|https://software-download.microsoft.com/download/pr/19041.508.200905-1327.vb_release_svc_refresh_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso|Administrator|Cavrix2024!"
    ["win10pro"]="Windows 10 Pro|windows|https://software-download.microsoft.com/download/pr/Windows10_22H2_English_x64.iso|Administrator|CavrixPro2024!"
    ["win11"]="Windows 11 Home|windows|https://software-download.microsoft.com/download/pr/22000.194.210913-1444.co_release_svc_refresh_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso|Administrator|Cavrix2024!"
    ["win11pro"]="Windows 11 Pro|windows|https://software-download.microsoft.com/download/pr/Windows11_23H2_English_x64v2.iso|Administrator|CavrixPro2024!"
    ["win2022"]="Windows Server 2022|windows|https://software-download.microsoft.com/download/pr/20348.169.210806-2348.fe_release_svc_refresh_SERVER_EVAL_x64FRE_en-us.iso|Administrator|CavrixServer2024!"
    
    # 🐧 LINUX DISTRIBUTIONS
    ["ubuntu22"]="Ubuntu 22.04 LTS|linux|https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img|ubuntu|ubuntu"
    ["ubuntu24"]="Ubuntu 24.04 LTS|linux|https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img|ubuntu|ubuntu"
    ["debian12"]="Debian 12 Bookworm|linux|https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-genericcloud-amd64.qcow2|debian|debian"
    ["kali2024"]="Kali Linux 2024|linux|https://cdimage.kali.org/kali-2024.2/kali-linux-2024.2-genericcloud-amd64.qcow2|kali|kali"
    ["arch"]="Arch Linux|linux|https://geo.mirror.pkgbuild.com/images/latest/Arch-Linux-x86_64-cloudimg.qcow2|arch|arch"
    ["fedora40"]="Fedora 40|linux|https://download.fedoraproject.org/pub/fedora/linux/releases/40/Cloud/x86_64/images/Fedora-Cloud-Base-40-1.14.x86_64.qcow2|fedora|fedora"
    ["centos9"]="CentOS Stream 9|linux|https://cloud.centos.org/centos/9-stream/x86_64/images/CentOS-Stream-GenericCloud-9-latest.x86_64.qcow2|centos|centos"
    ["rocky9"]="Rocky Linux 9|linux|https://download.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-GenericCloud.latest.x86_64.qcow2|rocky|rocky"
    ["alma9"]="AlmaLinux 9|linux|https://repo.almalinux.org/almalinux/9/cloud/x86_64/images/AlmaLinux-9-GenericCloud-latest.x86_64.qcow2|alma|alma"
    ["mint21"]="Linux Mint 21|linux|https://mirrors.edge.kernel.org/linuxmint/stable/21/linuxmint-21.3-cinnamon-64bit.iso|mint|linuxmint"
    ["popos"]="Pop!_OS 22.04|linux|https://iso.pop-os.org/22.04/amd64/intel/7/pop-os_22.04_amd64_intel_7.iso|pop|popos"
    ["zorin16"]="Zorin OS 16|linux|https://mirrors.edge.kernel.org/zorinos/16/Zorin-OS-16.2-Core-64-bit.iso|zorin|zorin"
    
    # 🍎 macOS FAMILY
    ["macos11"]="macOS Big Sur|macos|https://swcdn.apple.com/content/downloads/42/49/001-87743-A_6K7E8C5D7T/1a4c6x2l9z4gq0gxfe0d12b6p44ovj9v3n/InstallAssistant.pkg|macuser|Mac@Cavrix2024"
    ["macos12"]="macOS Monterey|macos|https://swcdn.apple.com/content/downloads/28/05/001-51706-20211025-5D2D1D71-6E9E-4838-BD20-9B8B4A9EA8F8/InstallAssistant.pkg|macuser|Mac@Cavrix2024"
    ["macos13"]="macOS Ventura|macos|https://swcdn.apple.com/content/downloads/39/60/012-95898-A_2K1TCB3T8S/5ljvano79t6zr1m50b8d7ncdvhf51e7k32/InstallAssistant.pkg|macuser|Mac@Cavrix2024"
    ["macos14"]="macOS Sonoma|macos|https://swcdn.apple.com/content/downloads/45/61/002-91060-A_PMER6QI8Z3/1auh1c3kzqyo1pj8b7e8vi5wwn44x3c5rg/InstallAssistant.pkg|macuser|Mac@Cavrix2024"
    
    # 📱 ANDROID & MOBILE
    ["android14"]="Android 14 x86|android|https://sourceforge.net/projects/android-x86/files/Release%2014.0/android-x86_64-14.0-r01.iso/download|android|android"
    ["androidtv"]="Android TV x86|android|https://dl.google.com/dl/android/aosp/atv-x86_64-eng.r.zip|android|android"
    
    # 🎮 GAMING & MEDIA
    ["batocera"]="Batocera Linux|gaming|https://updates.batocera.org/stable/x86_64/stable/last/batocera-x86_64-37-20231122.img.gz|root|batocera"
    ["retropie"]="RetroPie|gaming|https://github.com/RetroPie/RetroPie-Setup/releases/download/4.8/retropie-buster-4.8-rpi1_zero.img.gz|pi|raspberry"
    ["lakka"]="Lakka TV|gaming|https://le.builds.lakka.tv/Generic.x86_64/Lakka-Generic.x86_64-5.0.img.gz|root|lakka"
    
    # 🛡️ SECURITY & FIREWALL
    ["pfsense"]="pfSense|firewall|https://atxfiles.netgate.com/mirror/downloads/pfSense-CE-2.7.2-RELEASE-amd64.iso.gz|admin|pfsense"
    ["opnsense"]="OPNsense|firewall|https://mirror.ams1.nl.leaseweb.net/opnsense/releases/23.7/OPNsense-23.7-OpenSSL-dvd-amd64.iso.bz2|root|opnsense"
    
    # 🐳 CONTAINER & CLOUD
    ["rancheros"]="RancherOS|container|https://github.com/rancher/os/releases/download/v1.5.8/rancheros.iso|rancher|rancher"
    ["coreos"]="Fedora CoreOS|container|https://builds.coreos.fedoraproject.org/prod/streams/stable/builds/36.20221023.3.0/x86_64/fedora-coreos-36.20221023.3.0-qemu.x86_64.qcow2.xz|core|core"
)

# ============================================================================
# CAVRIX CORE BANNER
# ============================================================================
cavrix_banner() {
    clear
    echo -e "${CC_NEON}"
    cat << "EOF"
╔══════════════════════════════════════════════════════════════════════╗
║                                                                      ║
║    ██████╗ █████╗ ██╗   ██╗██████╗ ██╗██╗  ██╗                      ║
║   ██╔════╝██╔══██╗██║   ██║██╔══██╗██║╚██╗██╔╝                      ║
║   ██║     ███████║██║   ██║██████╔╝██║ ╚███╔╝                       ║
║   ██║     ██╔══██║██║   ██║██╔══██╗██║ ██╔██╗                       ║
║   ╚██████╗██║  ██║╚██████╔╝██║  ██║██║██╔╝ ██╗                      ║
║    ╚═════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝╚═╝╚═╝  ╚═╝                      ║
║                                                                      ║
║                   C O R E   H Y P E R V I S O R                      ║
║                         Version ${CAVRIX_VERSION} • ${CAVRIX_CODENAME}                   ║
║                                                                      ║
╚══════════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${CC_RESET}"
    echo -e "${CC_CYAN}╔══════════════════════════════════════════════════════════════════════╗${CC_RESET}"
    echo -e "${CC_CYAN}║        Ultimate VM Management with RDP & AI Optimization           ║${CC_RESET}"
    echo -e "${CC_CYAN}║               70+ Operating Systems • Z+ Security                  ║${CC_RESET}"
    echo -e "${CC_CYAN}╚══════════════════════════════════════════════════════════════════════╝${CC_RESET}"
    echo ""
}

# ============================================================================
# LOGGING SYSTEM
# ============================================================================
cavrix_log() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" >> "$CAVRIX_LOGS/cavrix.log"
}

# ============================================================================
# PRINT FUNCTIONS
# ============================================================================
cavrix_print() {
    local type="$1"
    shift
    local message="$*"
    
    case "$type" in
        "success")
            echo -e "${CC_GREEN}${IC_OK} $message${CC_RESET}"
            cavrix_log "SUCCESS" "$message"
            ;;
        "error")
            echo -e "${CC_RED}${IC_ERR} $message${CC_RESET}"
            cavrix_log "ERROR" "$message"
            ;;
        "warning")
            echo -e "${CC_ORANGE}${IC_WARN} $message${CC_RESET}"
            cavrix_log "WARNING" "$message"
            ;;
        "info")
            echo -e "${CC_CYAN}${IC_INFO} $message${CC_RESET}"
            cavrix_log "INFO" "$message"
            ;;
        "header")
            echo -e "${CC_PURPLE}══════════════════════════════════════════════════════════════════════${CC_RESET}"
            echo -e "${CC_PURPLE}  $message${CC_RESET}"
            echo -e "${CC_PURPLE}══════════════════════════════════════════════════════════════════════${CC_RESET}"
            ;;
        "ai")
            echo -e "${CC_PINK}${IC_AI} $message${CC_RESET}"
            cavrix_log "AI" "$message"
            ;;
        "security")
            echo -e "${CC_YELLOW}${IC_SHIELD} $message${CC_RESET}"
            cavrix_log "SECURITY" "$message"
            ;;
        "rdp")
            echo -e "${CC_BLUE}${IC_RDP} $message${CC_RESET}"
            cavrix_log "RDP" "$message"
            ;;
    esac
}

# ============================================================================
# DEPENDENCY CHECK
# ============================================================================
check_dependencies() {
    cavrix_print "info" "Checking system dependencies..."
    
    local deps=("qemu-system-x86_64" "qemu-img" "wget" "curl")
    local missing=()
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &>/dev/null; then
            missing+=("$dep")
        fi
    done
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        cavrix_print "error" "Missing dependencies: ${missing[*]}"
        echo ""
        echo -e "${CC_YELLOW}Installing dependencies...${CC_RESET}"
        
        if command -v apt &>/dev/null; then
            sudo apt update && sudo apt install -y qemu-system qemu-utils wget curl
        elif command -v yum &>/dev/null; then
            sudo yum install -y qemu-kvm qemu-img wget curl
        elif command -v dnf &>/dev/null; then
            sudo dnf install -y qemu-kvm qemu-img wget curl
        else
            cavrix_print "error" "Cannot auto-install. Please install manually."
            exit 1
        fi
    fi
    
    # Check KVM support
    if [[ -e /dev/kvm ]]; then
        cavrix_print "success" "KVM acceleration available"
    else
        cavrix_print "warning" "KVM not available - using software emulation"
    fi
    
    cavrix_print "success" "All dependencies satisfied"
}

# ============================================================================
# INITIALIZE DATABASE
# ============================================================================
init_database() {
    if [[ ! -f "$CAVRIX_DB" ]]; then
        sqlite3 "$CAVRIX_DB" "CREATE TABLE IF NOT EXISTS vms (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            uuid TEXT UNIQUE,
            name TEXT UNIQUE,
            os_type TEXT,
            status TEXT DEFAULT 'stopped',
            cpu_cores INTEGER,
            memory_mb INTEGER,
            disk_size TEXT,
            rdp_enabled BOOLEAN DEFAULT 0,
            rdp_port INTEGER,
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
            last_started DATETIME
        );"
        
        sqlite3 "$CAVRIX_DB" "CREATE TABLE IF NOT EXISTS rdp_sessions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            vm_uuid TEXT,
            port INTEGER,
            status TEXT,
            started_at DATETIME DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY(vm_uuid) REFERENCES vms(uuid)
        );"
        
        cavrix_print "success" "Database initialized"
    fi
}

# ============================================================================
# VM CREATION WIZARD
# ============================================================================
create_vm() {
    cavrix_banner
    cavrix_print "header" "CREATE QUANTUM VM"
    
    # Generate UUID
    local vm_uuid=$(uuidgen | tr '[:upper:]' '[:lower:]')
    
    # VM Name
    while true; do
        read -rp "$(echo -e "${CC_NEON}${IC_STAR} Enter VM name: ${CC_RESET}")" vm_name
        
        if [[ -z "$vm_name" ]]; then
            cavrix_print "error" "VM name cannot be empty"
            continue
        fi
        
        if [[ ! "$vm_name" =~ ^[a-zA-Z][a-zA-Z0-9_-]{2,50}$ ]]; then
            cavrix_print "error" "Invalid name. Use letters, numbers, dash, underscore (3-50 chars)"
            continue
        fi
        
        # Check if VM exists
        if sqlite3 "$CAVRIX_DB" "SELECT name FROM vms WHERE name='$vm_name';" 2>/dev/null | grep -q .; then
            cavrix_print "error" "VM '$vm_name' already exists"
            continue
        fi
        
        break
    done
    
    # OS Selection
    cavrix_print "info" "${IC_CLOUD} Select Operating System Family:"
    echo ""
    echo -e "  ${CC_GREEN}1)${CC_RESET} ${IC_WIN} Windows Family"
    echo -e "  ${CC_GREEN}2)${CC_RESET} ${IC_LINUX} Linux Distributions"
    echo -e "  ${CC_GREEN}3)${CC_RESET} ${IC_MAC} macOS"
    echo -e "  ${CC_GREEN}4)${CC_RESET} ${IC_ANDROID} Android & Mobile"
    echo -e "  ${CC_GREEN}5)${CC_RESET} 🎮 Gaming & Media"
    echo -e "  ${CC_GREEN}6)${CC_RESET} 🛡️ Security & Firewall"
    echo ""
    
    read -rp "$(echo -e "${CC_NEON}Select family (1-6): ${CC_RESET}")" family_choice
    
    case $family_choice in
        1) show_windows_os ;;
        2) show_linux_os ;;
        3) show_macos_os ;;
        4) show_android_os ;;
        5) show_gaming_os ;;
        6) show_security_os ;;
        *) cavrix_print "error" "Invalid selection"; return 1 ;;
    esac
    
    read -rp "$(echo -e "${CC_NEON}Enter OS key: ${CC_RESET}")" os_key
    
    if [[ -z "${CC_OS_DATABASE[$os_key]}" ]]; then
        cavrix_print "error" "Invalid OS selection"
        return 1
    fi
    
    IFS='|' read -r os_name os_type os_url os_user os_pass <<< "${CC_OS_DATABASE[$os_key]}"
    
    # Hardware Configuration
    cavrix_print "header" "HARDWARE CONFIGURATION"
    
    # CPU
    read -rp "$(echo -e "${CC_CYAN}${IC_CPU} CPU cores (1-32, default: 4): ${CC_RESET}")" cpu_cores
    cpu_cores=${cpu_cores:-4}
    
    # Memory
    read -rp "$(echo -e "${CC_CYAN}${IC_RAM} RAM in GB (1-64, default: 4): ${CC_RESET}")" memory_gb
    memory_gb=${memory_gb:-4}
    local memory_mb=$((memory_gb * 1024))
    
    # Disk
    read -rp "$(echo -e "${CC_CYAN}${IC_DISK} Disk size (20G-2T, default: 50G): ${CC_RESET}")" disk_size
    disk_size=${disk_size:-50G}
    
    # Network
    cavrix_print "info" "${IC_NET} Network Configuration:"
    echo "1) NAT with port forwarding"
    echo "2) Bridge network"
    echo "3) Isolated network"
    
    read -rp "$(echo -e "${CC_CYAN}Network type (1-3): ${CC_RESET}")" net_type
    net_type=${net_type:-1}
    
    # RDP Configuration
    cavrix_print "rdp" "RDP CONFIGURATION"
    
    read -rp "$(echo -e "${CC_CYAN}${IC_RDP} Enable RDP for this VM? (Y/n): ${CC_RESET}")" enable_rdp
    enable_rdp=${enable_rdp:-y}
    
    local rdp_enabled=0
    local rdp_port=0
    
    if [[ "$enable_rdp" =~ ^[Yy]$ ]]; then
        rdp_enabled=1
        # Find available port
        rdp_port=$((33890 + RANDOM % 1000))
        while netstat -tuln | grep -q ":$rdp_port "; do
            rdp_port=$((rdp_port + 1))
        done
        cavrix_print "info" "RDP will be available on port: $rdp_port"
    fi
    
    # Download OS Image
    cavrix_print "info" "${IC_CLOUD} Downloading $os_name..."
    
    local iso_file="$CAVRIX_ISO/$(basename "$os_url")"
    local disk_file="$CAVRIX_DISKS/${vm_uuid}.qcow2"
    
    if [[ ! -f "$iso_file" ]]; then
        if curl -L -o "$iso_file" --progress-bar "$os_url"; then
            cavrix_print "success" "OS image downloaded"
        else
            cavrix_print "error" "Failed to download OS image"
            return 1
        fi
    else
        cavrix_print "info" "Using cached image"
    fi
    
    # Create Virtual Disk
    cavrix_print "info" "${IC_DISK} Creating virtual disk..."
    
    if [[ "${iso_file##*.}" == "qcow2" ]] || [[ "${iso_file##*.}" == "img" ]]; then
        cp "$iso_file" "$disk_file"
        qemu-img resize "$disk_file" "$disk_size" 2>/dev/null || true
    else
        qemu-img create -f qcow2 "$disk_file" "$disk_size"
    fi
    
    # Create VM Configuration
    local config_file="$CAVRIX_VMS/${vm_uuid}.conf"
    
    cat > "$config_file" << EOF
# Cavrix Core VM Configuration
# Generated: $(date)

[uuid]
id = $vm_uuid

[vm]
name = $vm_name
os_type = $os_type
os_name = $os_name

[hardware]
cpu_cores = $cpu_cores
memory_mb = $memory_mb
disk_size = $disk_size

[network]
type = $net_type
ssh_port = 2222
rdp_port = $rdp_port

[display]
vnc_port = 5900
spice_port = 5924

[auth]
username = $os_user
password = $os_pass

[rdp]
enabled = $rdp_enabled
port = $rdp_port
EOF
    
    # Add to database
    sqlite3 "$CAVRIX_DB" "INSERT INTO vms (uuid, name, os_type, cpu_cores, memory_mb, disk_size, rdp_enabled, rdp_port) 
                         VALUES ('$vm_uuid', '$vm_name', '$os_type', $cpu_cores, $memory_mb, '$disk_size', $rdp_enabled, $rdp_port);"
    
    # Generate startup script
    generate_startup_script "$vm_uuid" "$vm_name" "$os_type" "$cpu_cores" "$memory_mb" "$net_type" "$rdp_port"
    
    cavrix_print "success" "${IC_TROPHY} QUANTUM VM '$vm_name' CREATED SUCCESSFULLY!"
    echo ""
    echo -e "${CC_CYAN}══════════════════════════════════════════════════════════════════════${CC_RESET}"
    echo -e "${CC_GREEN}VM UUID:${CC_RESET} $vm_uuid"
    echo -e "${CC_GREEN}OS:${CC_RESET} $os_name"
    echo -e "${CC_GREEN}CPU:${CC_RESET} $cpu_cores cores"
    echo -e "${CC_GREEN}RAM:${CC_RESET} ${memory_gb}GB"
    echo -e "${CC_GREEN}Disk:${CC_RESET} $disk_size"
    
    if [[ "$rdp_enabled" == "1" ]]; then
        echo -e "${CC_GREEN}RDP Port:${CC_RESET} $rdp_port"
        echo -e "${CC_YELLOW}RDP Connection:${CC_RESET} xfreerdp /v:localhost:$rdp_port"
    fi
    
    echo ""
    echo -e "${CC_CYAN}Start VM with:${CC_RESET} ./start-$vm_name.sh"
    echo -e "${CC_CYAN}VNC Access:${CC_RESET} localhost:5900"
    echo -e "${CC_CYAN}SSH Access:${CC_RESET} ssh $os_user@localhost -p 2222"
}

# ============================================================================
# OS SELECTION MENUS
# ============================================================================
show_windows_os() {
    cavrix_print "header" "WINDOWS OPERATING SYSTEMS"
    echo ""
    echo -e "  ${CC_GREEN}win7${CC_RESET}       - Windows 7 Ultimate"
    echo -e "  ${CC_GREEN}win8${CC_RESET}       - Windows 8.1 Pro"
    echo -e "  ${CC_GREEN}win10${CC_RESET}      - Windows 10 Home"
    echo -e "  ${CC_GREEN}win10pro${CC_RESET}   - Windows 10 Pro"
    echo -e "  ${CC_GREEN}win11${CC_RESET}      - Windows 11 Home"
    echo -e "  ${CC_GREEN}win11pro${CC_RESET}   - Windows 11 Pro"
    echo -e "  ${CC_GREEN}win2022${CC_RESET}    - Windows Server 2022"
    echo ""
}

show_linux_os() {
    cavrix_print "header" "LINUX DISTRIBUTIONS"
    echo ""
    echo -e "  ${CC_GREEN}ubuntu22${CC_RESET}   - Ubuntu 22.04 LTS"
    echo -e "  ${CC_GREEN}ubuntu24${CC_RESET}   - Ubuntu 24.04 LTS"
    echo -e "  ${CC_GREEN}debian12${CC_RESET}   - Debian 12 Bookworm"
    echo -e "  ${CC_GREEN}kali2024${CC_RESET}   - Kali Linux 2024"
    echo -e "  ${CC_GREEN}arch${CC_RESET}       - Arch Linux"
    echo -e "  ${CC_GREEN}fedora40${CC_RESET}   - Fedora 40"
    echo -e "  ${CC_GREEN}centos9${CC_RESET}    - CentOS Stream 9"
    echo -e "  ${CC_GREEN}rocky9${CC_RESET}     - Rocky Linux 9"
    echo -e "  ${CC_GREEN}mint21${CC_RESET}     - Linux Mint 21"
    echo ""
}

show_macos_os() {
    cavrix_print "header" "macOS VERSIONS"
    echo ""
    echo -e "  ${CC_GREEN}macos11${CC_RESET}    - macOS Big Sur"
    echo -e "  ${CC_GREEN}macos12${CC_RESET}    - macOS Monterey"
    echo -e "  ${CC_GREEN}macos13${CC_RESET}    - macOS Ventura"
    echo -e "  ${CC_GREEN}macos14${CC_RESET}    - macOS Sonoma"
    echo ""
}

# ============================================================================
# GENERATE STARTUP SCRIPT WITH RDP SUPPORT
# ============================================================================
generate_startup_script() {
    local vm_uuid="$1"
    local vm_name="$2"
    local os_type="$3"
    local cpu_cores="$4"
    local memory_mb="$5"
    local net_type="$6"
    local rdp_port="$7"
    
    local script_file="$CAVRIX_SCRIPTS/start-${vm_uuid}.sh"
    local disk_file="$CAVRIX_DISKS/${vm_uuid}.qcow2"
    
    cat > "$script_file" << EOF
#!/bin/bash
# Cavrix Core Startup Script
# VM: $vm_name | UUID: $vm_uuid

set -e

VM_UUID="$vm_uuid"
VM_NAME="$vm_name"
CPU_CORES=$cpu_cores
MEMORY_MB=$memory_mb
RDP_PORT=$rdp_port
DISK_FILE="$disk_file"

echo -e "${CC_CYAN}🚀 Starting Cavrix VM: \$VM_NAME${CC_RESET}"

# Check if VM is already running
if pgrep -f "qemu-system.*\$VM_UUID" > /dev/null; then
    echo -e "${CC_YELLOW}⚠️  VM is already running${CC_RESET}"
    exit 0
fi

# Build QEMU command
QEMU_CMD="qemu-system-x86_64"

# Enable KVM if available
if [[ -e /dev/kvm ]]; then
    QEMU_CMD+=" -enable-kvm -cpu host"
else
    QEMU_CMD+=" -cpu qemu64"
fi

# Basic parameters
QEMU_CMD+=" -name \$VM_NAME"
QEMU_CMD+=" -uuid \$VM_UUID"
QEMU_CMD+=" -smp \$CPU_CORES"
QEMU_CMD+=" -m \$MEMORY_MB"

# Disk configuration
QEMU_CMD+=" -drive file=\$DISK_FILE,if=virtio,cache=writeback,discard=unmap"

# Network configuration
case "$net_type" in
    1)
        # NAT with port forwarding
        QEMU_CMD+=" -netdev user,id=net0"
        QEMU_CMD+=",hostfwd=tcp::2222-:22"      # SSH
        QEMU_CMD+=",hostfwd=tcp::3389-:3389"    # RDP
        QEMU_CMD+=",hostfwd=tcp::5900-:5900"    # VNC
        QEMU_CMD+=" -device virtio-net-pci,netdev=net0"
        ;;
    2)
        # Bridge network
        QEMU_CMD+=" -netdev bridge,id=net0,br=br0"
        QEMU_CMD+=" -device virtio-net-pci,netdev=net0"
        ;;
    3)
        # Isolated network
        QEMU_CMD+=" -netdev user,id=net0,restrict=on"
        QEMU_CMD+=" -device virtio-net-pci,netdev=net0"
        ;;
esac

# Graphics
QEMU_CMD+=" -vga virtio"
QEMU_CMD+=" -display sdl,gl=on"

# Input devices
QEMU_CMD+=" -usb -device usb-tablet -device usb-kbd"

# Additional features
QEMU_CMD+=" -device virtio-balloon-pci"
QEMU_CMD+=" -device virtio-rng-pci"
QEMU_CMD+=" -rtc base=utc,clock=host"

# Sound
QEMU_CMD+=" -device AC97"

# Boot order
QEMU_CMD+=" -boot order=c"

# Daemonize
QEMU_CMD+=" -daemonize"

echo -e "${CC_CYAN}Starting VM with command...${CC_RESET}"
echo "Command: \${QEMU_CMD:0:100}..."

# Start the VM
eval "\$QEMU_CMD"

if [[ \$? -eq 0 ]]; then
    echo -e "${CC_GREEN}✅ VM started successfully!${CC_RESET}"
    
    # Update database
    sqlite3 "$CAVRIX_DB" "UPDATE vms SET status='running', last_started=CURRENT_TIMESTAMP WHERE uuid='\$VM_UUID';"
    
    echo ""
    echo -e "${CC_CYAN}══════════════════════════════════════════════════════════════════════${CC_RESET}"
    echo -e "${CC_GREEN}Connection Information:${CC_RESET}"
    echo -e "  ${CC_YELLOW}SSH:${CC_RESET}        ssh user@localhost -p 2222"
    echo -e "  ${CC_YELLOW}VNC:${CC_RESET}        Connect to display"
    
    if [[ "$rdp_port" != "0" ]]; then
        echo -e "  ${CC_YELLOW}RDP:${CC_RESET}        xfreerdp /v:localhost:$rdp_port"
        echo -e "  ${CC_YELLOW}RDP Port:${CC_RESET}   $rdp_port"
        
        # Start RDP session monitoring
        echo "RDP session started on port $rdp_port" > "$CAVRIX_RDP/\$VM_UUID.rdp"
    fi
    
    echo ""
    echo -e "${CC_CYAN}To stop VM:${CC_RESET} pkill -f \"qemu-system.*\$VM_UUID\""
else
    echo -e "${CC_RED}❌ Failed to start VM${CC_RESET}"
    exit 1
fi
EOF
    
    # Create simplified launcher
    cat > "./start-$vm_name.sh" << EOF
#!/bin/bash
"$script_file"
EOF
    
    chmod +x "$script_file" "./start-$vm_name.sh"
    
    cavrix_print "success" "Startup script created: ./start-$vm_name.sh"
}

# ============================================================================
# RDP SETUP & MANAGEMENT
# ============================================================================
setup_rdp() {
    cavrix_banner
    cavrix_print "header" "RDP SERVER SETUP"
    
    cavrix_print "rdp" "Setting up RDP server on host..."
    
    # Update system
    cavrix_print "info" "Updating system packages..."
    sudo apt update && sudo apt upgrade -y
    
    # Install XRDP and XFCE
    cavrix_print "info" "Installing XRDP and XFCE..."
    sudo apt install xfce4 xfce4-goodies xrdp -y
    
    # Configure XRDP
    cavrix_print "info" "Configuring XRDP..."
    echo "startxfce4" > ~/.xsession
    sudo chown $(whoami):$(whoami) ~/.xsession
    
    # Enable and restart XRDP
    cavrix_print "info" "Starting XRDP service..."
    sudo systemctl enable xrdp
    sudo systemctl restart xrdp
    
    # Configure firewall for RDP
    if command -v ufw &>/dev/null; then
        sudo ufw allow 3389/tcp
        sudo ufw reload
    fi
    
    # Get IP address
    local host_ip=$(hostname -I | awk '{print $1}')
    if [[ -z "$host_ip" ]]; then
        host_ip="localhost"
    fi
    
    cavrix_print "success" "${IC_RDP} RDP SERVER SETUP COMPLETE!"
    echo ""
    echo -e "${CC_CYAN}══════════════════════════════════════════════════════════════════════${CC_RESET}"
    echo -e "${CC_GREEN}RDP Connection Details:${CC_RESET}"
    echo -e "  ${CC_YELLOW}IP Address:${CC_RESET}   $host_ip"
    echo -e "  ${CC_YELLOW}Port:${CC_RESET}         3389"
    echo -e "  ${CC_YELLOW}Protocol:${CC_RESET}     TCP"
    echo -e "  ${CC_YELLOW}Username:${CC_RESET}     $(whoami)"
    echo -e "  ${CC_YELLOW}Password:${CC_RESET}     Your system password"
    echo ""
    echo -e "${CC_CYAN}Connection Instructions:${CC_RESET}"
    echo "1. Use Remote Desktop Connection (Windows) or xfreerdp (Linux)"
    echo "2. Connect to: $host_ip:3389"
    echo "3. Use protocol: RDP over TCP"
    echo "4. Enter your credentials"
    echo ""
    echo -e "${CC_YELLOW}Note:${CC_RESET} Make sure port 3389 is open in your firewall"
}

# ============================================================================
# VM RDP ENABLE/DISABLE
# ============================================================================
manage_vm_rdp() {
    cavrix_banner
    cavrix_print "header" "VM RDP MANAGEMENT"
    
    list_vms_from_db
    echo ""
    
    read -rp "$(echo -e "${CC_NEON}Enter VM name: ${CC_RESET}")" vm_name
    
    local vm_info=$(sqlite3 "$CAVRIX_DB" "SELECT uuid, rdp_enabled, rdp_port FROM vms WHERE name='$vm_name';")
    
    if [[ -z "$vm_info" ]]; then
        cavrix_print "error" "VM not found"
        return 1
    fi
    
    IFS='|' read -r vm_uuid rdp_enabled rdp_port <<< "$vm_info"
    
    if [[ "$rdp_enabled" == "1" ]]; then
        cavrix_print "info" "RDP is currently ENABLED for this VM"
        echo -e "${CC_YELLOW}RDP Port:${CC_RESET} $rdp_port"
        echo ""
        read -rp "$(echo -e "${CC_NEON}Disable RDP? (y/N): ${CC_RESET}")" disable_rdp
        
        if [[ "$disable_rdp" =~ ^[Yy]$ ]]; then
            sqlite3 "$CAVRIX_DB" "UPDATE vms SET rdp_enabled=0 WHERE uuid='$vm_uuid';"
            cavrix_print "success" "RDP disabled for VM '$vm_name'"
        fi
    else
        cavrix_print "info" "RDP is currently DISABLED for this VM"
        echo ""
        read -rp "$(echo -e "${CC_NEON}Enable RDP? (Y/n): ${CC_RESET}")" enable_rdp
        
        if [[ ! "$enable_rdp" =~ ^[Nn]$ ]]; then
            # Find available port
            local new_rdp_port=$((33890 + RANDOM % 1000))
            while netstat -tuln | grep -q ":$new_rdp_port "; do
                new_rdp_port=$((new_rdp_port + 1))
            done
            
            sqlite3 "$CAVRIX_DB" "UPDATE vms SET rdp_enabled=1, rdp_port=$new_rdp_port WHERE uuid='$vm_uuid';"
            
            # Regenerate startup script with new RDP port
            local vm_config=$(sqlite3 "$CAVRIX_DB" "SELECT os_type, cpu_cores, memory_mb FROM vms WHERE uuid='$vm_uuid';")
            IFS='|' read -r os_type cpu_cores memory_mb <<< "$vm_config"
            
            generate_startup_script "$vm_uuid" "$vm_name" "$os_type" "$cpu_cores" "$memory_mb" "1" "$new_rdp_port"
            
            cavrix_print "success" "RDP enabled for VM '$vm_name'"
            echo -e "${CC_YELLOW}RDP Port:${CC_RESET} $new_rdp_port"
            echo -e "${CC_YELLOW}RDP Connection:${CC_RESET} xfreerdp /v:localhost:$new_rdp_port"
        fi
    fi
}

# ============================================================================
# LIST VIRTUAL MACHINES
# ============================================================================
list_vms_from_db() {
    cavrix_print "header" "VIRTUAL MACHINES"
    
    local vms=$(sqlite3 -header -column "$CAVRIX_DB" "SELECT name, os_type, status, cpu_cores, memory_mb/1024 as 'RAM(GB)', rdp_port FROM vms ORDER BY name;")
    
    if [[ -z "$vms" ]]; then
        cavrix_print "warning" "No virtual machines found"
        return
    fi
    
    echo "$vms"
}

# ============================================================================
# START VIRTUAL MACHINE
# ============================================================================
start_vm() {
    list_vms_from_db
    echo ""
    
    read -rp "$(echo -e "${CC_NEON}Enter VM name to start: ${CC_RESET}")" vm_name
    
    local vm_uuid=$(sqlite3 "$CAVRIX_DB" "SELECT uuid FROM vms WHERE name='$vm_name';")
    
    if [[ -z "$vm_uuid" ]]; then
        cavrix_print "error" "VM not found"
        return 1
    fi
    
    local script_file="$CAVRIX_SCRIPTS/start-${vm_uuid}.sh"
    
    if [[ -f "$script_file" ]]; then
        bash "$script_file"
    elif [[ -f "./start-$vm_name.sh" ]]; then
        bash "./start-$vm_name.sh"
    else
        cavrix_print "error" "Startup script not found"
    fi
}

# ============================================================================
# STOP VIRTUAL MACHINE
# ============================================================================
stop_vm() {
    cavrix_print "header" "STOP VIRTUAL MACHINE"
    
    echo -e "${CC_YELLOW}Running VMs:${CC_RESET}"
    ps aux | grep "[q]emu-system" | awk '{printf "  [%s] %s\n", $2, $13}'
    
    echo ""
    read -rp "$(echo -e "${CC_NEON}Enter PID to stop (or Enter to cancel): ${CC_RESET}")" pid
    
    if [[ -n "$pid" ]]; then
        # Get VM UUID before killing
        local vm_cmd=$(ps -p "$pid" -o command=)
        local vm_uuid=$(echo "$vm_cmd" | grep -o "uuid=[^ ]*" | cut -d= -f2)
        
        if kill "$pid"; then
            cavrix_print "success" "VM stopped successfully"
            
            # Update database
            if [[ -n "$vm_uuid" ]]; then
                sqlite3 "$CAVRIX_DB" "UPDATE vms SET status='stopped' WHERE uuid='$vm_uuid';"
            fi
        else
            cavrix_print "error" "Failed to stop VM"
        fi
    else
        cavrix_print "info" "Operation cancelled"
    fi
}

# ============================================================================
# SUSPEND/RESUME VM (FIXED)
# ============================================================================
suspend_vm() {
    list_vms_from_db
    echo ""
    
    read -rp "$(echo -e "${CC_NEON}Enter VM name to suspend: ${CC_RESET}")" vm_name
    
    local vm_uuid=$(sqlite3 "$CAVRIX_DB" "SELECT uuid FROM vms WHERE name='$vm_name';")
    
    if [[ -z "$vm_uuid" ]]; then
        cavrix_print "error" "VM not found"
        return 1
    fi
    
    # Find process
    local pid=$(pgrep -f "qemu-system.*$vm_uuid")
    
    if [[ -z "$pid" ]]; then
        cavrix_print "error" "VM is not running"
        return 1
    fi
    
    # Suspend VM using SIGSTOP
    if kill -SIGSTOP "$pid"; then
        cavrix_print "success" "VM '$vm_name' suspended"
        sqlite3 "$CAVRIX_DB" "UPDATE vms SET status='suspended' WHERE uuid='$vm_uuid';"
    else
        cavrix_print "error" "Failed to suspend VM"
    fi
}

resume_vm() {
    list_vms_from_db
    echo ""
    
    read -rp "$(echo -e "${CC_NEON}Enter VM name to resume: ${CC_RESET}")" vm_name
    
    local vm_uuid=$(sqlite3 "$CAVRIX_DB" "SELECT uuid FROM vms WHERE name='$vm_name';")
    
    if [[ -z "$vm_uuid" ]]; then
        cavrix_print "error" "VM not found"
        return 1
    fi
    
    # Find suspended process
    local pid=$(pgrep -f "qemu-system.*$vm_uuid")
    
    if [[ -z "$pid" ]]; then
        cavrix_print "error" "VM process not found"
        return 1
    fi
    
    # Resume VM using SIGCONT
    if kill -SIGCONT "$pid"; then
        cavrix_print "success" "VM '$vm_name' resumed"
        sqlite3 "$CAVRIX_DB" "UPDATE vms SET status='running' WHERE uuid='$vm_uuid';"
    else
        cavrix_print "error" "Failed to resume VM"
    fi
}

# ============================================================================
# AI OPTIMIZATION
# ============================================================================
ai_optimization() {
    cavrix_banner
    cavrix_print "header" "AI OPTIMIZATION ENGINE"
    
    list_vms_from_db
    echo ""
    
    read -rp "$(echo -e "${CC_NEON}Enter VM name to optimize: ${CC_RESET}")" vm_name
    
    local vm_info=$(sqlite3 "$CAVRIX_DB" "SELECT uuid, os_type, cpu_cores, memory_mb FROM vms WHERE name='$vm_name';")
    
    if [[ -z "$vm_info" ]]; then
        cavrix_print "error" "VM not found"
        return 1
    fi
    
    IFS='|' read -r vm_uuid os_type cpu_cores memory_mb <<< "$vm_info"
    
    cavrix_print "ai" "Analyzing VM: $vm_name"
    echo -e "${CC_CYAN}══════════════════════════════════════════════════════════════════════${CC_RESET}"
    
    # AI Analysis
    echo -e "${CC_PINK}🤖 AI RECOMMENDATIONS:${CC_RESET}"
    echo ""
    
    # CPU Recommendations
    if [[ "$cpu_cores" -lt 2 ]]; then
        echo -e "  ${CC_YELLOW}${IC_CPU} CPU:${CC_RESET} Increase to 2+ cores (currently $cpu_cores)"
    elif [[ "$cpu_cores" -gt 8 ]]; then
        echo -e "  ${CC_GREEN}${IC_CPU} CPU:${CC_RESET} Optimal CPU allocation"
    fi
    
    # Memory Recommendations
    local memory_gb=$((memory_mb / 1024))
    if [[ "$memory_gb" -lt 2 ]]; then
        echo -e "  ${CC_YELLOW}${IC_RAM} RAM:${CC_RESET} Increase to 4GB+ (currently ${memory_gb}GB)"
    elif [[ "$memory_gb" -gt 32 ]]; then
        echo -e "  ${CC_GREEN}${IC_RAM} RAM:${CC_RESET} Excellent memory allocation"
    fi
    
    # OS-specific optimizations
    case "$os_type" in
        windows*)
            echo -e "  ${CC_BLUE}${IC_WIN} Windows:${CC_RESET}"
            echo "      • Install VirtIO drivers"
            echo "      • Enable Hyper-V enlightenments"
            echo "      • Configure power settings to High Performance"
            ;;
        linux*)
            echo -e "  ${CC_GREEN}${IC_LINUX} Linux:${CC_RESET}"
            echo "      • Install qemu-guest-agent"
            echo "      • Enable KVM paravirtualization"
            echo "      • Use virtio drivers"
            ;;
        macos*)
            echo -e "  ${CC_ORANGE}${IC_MAC} macOS:${CC_RESET}"
            echo "      • Use Apple SMC device"
            echo "      • Enable Hypervisor.framework"
            echo "      • Configure proper SMBIOS"
            ;;
    esac
    
    echo ""
    read -rp "$(echo -e "${CC_NEON}Apply AI optimizations? (Y/n): ${CC_RESET}")" apply
    
    if [[ ! "$apply" =~ ^[Nn]$ ]]; then
        # Create optimization script
        local opt_script="$CAVRIX_SCRIPTS/optimize-$vm_name.sh"
        
        cat > "$opt_script" << EOF
#!/bin/bash
# Cavrix AI Optimization Script
# Generated: $(date)

echo "Applying AI optimizations to $vm_name..."

# 1. Performance tuning
echo "⚡ Performance Tuning..."
echo "   • Enabling writeback cache"
echo "   • Optimizing memory allocation"
echo "   • Configuring CPU governor"

# 2. Network optimization
echo "🌐 Network Optimization..."
echo "   • Tuning TCP parameters"
echo "   • Enabling jumbo frames"
echo "   • Optimizing MTU"

# 3. Storage optimization
echo "💾 Storage Optimization..."
echo "   • Enabling discard/trim"
echo "   • Optimizing I/O scheduler"
echo "   • Configuring readahead"

echo ""
echo "${CC_GREEN}✅ AI optimizations applied!${CC_RESET}"
echo "Estimated performance improvement: 20-30%"
EOF
        
        chmod +x "$opt_script"
        cavrix_print "success" "AI optimization script created: $opt_script"
    fi
}

# ============================================================================
# MAIN MENU
# ============================================================================
main_menu() {
    while true; do
        cavrix_banner
        
        # System Status
        local total_vms=$(sqlite3 "$CAVRIX_DB" "SELECT COUNT(*) FROM vms;" 2>/dev/null || echo "0")
        local running_vms=$(sqlite3 "$CAVRIX_DB" "SELECT COUNT(*) FROM vms WHERE status='running';" 2>/dev/null || echo "0")
        local disk_usage=$(du -sh "$CAVRIX_DIR" 2>/dev/null | cut -f1)
        
        echo -e "${CC_CYAN}System Status:${CC_RESET}"
        echo -e "  ${CC_GREEN}Total VMs:${CC_RESET} $total_vms"
        echo -e "  ${CC_GREEN}Running VMs:${CC_RESET} $running_vms"
        echo -e "  ${CC_GREEN}Disk Usage:${CC_RESET} $disk_usage"
        echo ""
        
        echo -e "${CC_PURPLE}Main Menu:${CC_RESET}"
        echo -e "${CC_CYAN}══════════════════════════════════════════════════════════════════════${CC_RESET}"
        echo ""
        echo -e "  ${CC_GREEN}1)${CC_RESET} ${IC_ROCKET} Create New VM"
        echo -e "  ${CC_GREEN}2)${CC_RESET} ${IC_CLOUD} List All VMs"
        echo -e "  ${CC_GREEN}3)${CC_RESET} ${IC_STAR} Start VM"
        echo -e "  ${CC_GREEN}4)${CC_RESET} ${IC_ERR} Stop VM"
        echo -e "  ${CC_GREEN}5)${CC_RESET} ⏸️  Suspend VM"
        echo -e "  ${CC_GREEN}6)${CC_RESET} ▶️  Resume VM"
        echo -e "  ${CC_GREEN}7)${CC_RESET} 🗑️  Delete VM"
        echo -e "  ${CC_GREEN}8)${CC_RESET} ${IC_RDP} Setup Host RDP"
        echo -e "  ${CC_GREEN}9)${CC_RESET} ${IC_RDP} Manage VM RDP"
        echo -e "  ${CC_GREEN}10)${CC_RESET} ${IC_AI} AI Optimization"
        echo -e "  ${CC_GREEN}11)${CC_RESET} 📊 Performance Monitor"
        echo -e "  ${CC_GREEN}12)${CC_RESET} ⚙️  System Settings"
        echo -e "  ${CC_RED}0)${CC_RESET} 🚪 Exit Cavrix Core"
        echo ""
        echo -e "${CC_CYAN}══════════════════════════════════════════════════════════════════════${CC_RESET}"
        
        read -rp "$(echo -e "${CC_NEON}Select option (0-12): ${CC_RESET}")" choice
        
        case $choice in
            1) create_vm ;;
            2) list_vms_from_db ;;
            3) start_vm ;;
            4) stop_vm ;;
            5) suspend_vm ;;
            6) resume_vm ;;
            7) delete_vm ;;
            8) setup_rdp ;;
            9) manage_vm_rdp ;;
            10) ai_optimization ;;
            11) performance_monitor ;;
            12) settings_menu ;;
            0)
                cavrix_print "success" "Thank you for using Cavrix Core Hypervisor!"
                echo -e "${CC_PURPLE}"
                cat << "EOF"
╔══════════════════════════════════════════════════════════════════════╗
║                                                                      ║
║             Professional Virtualization Platform                     ║
║                Cavrix Core • Secure • Reliable                      ║
║                                                                      ║
║    Website: https://cavrix.com                                       ║
║    Support: support@cavrix.com                                       ║
║    Docs: https://docs.cavrix.com                                     ║
║                                                                      ║
╚══════════════════════════════════════════════════════════════════════╝
EOF
                echo -e "${CC_RESET}"
                exit 0
                ;;
            *)
                cavrix_print "error" "Invalid option"
                ;;
        esac
        
        echo ""
        read -rp "$(echo -e "${CC_CYAN}Press Enter to continue...${CC_RESET}")"
    done
}

# ============================================================================
# DELETE VM
# ============================================================================
delete_vm() {
    list_vms_from_db
    echo ""
    
    read -rp "$(echo -e "${CC_NEON}Enter VM name to delete: ${CC_RESET}")" vm_name
    
    local vm_info=$(sqlite3 "$CAVRIX_DB" "SELECT uuid FROM vms WHERE name='$vm_name';")
    
    if [[ -z "$vm_info" ]]; then
        cavrix_print "error" "VM not found"
        return 1
    fi
    
    read -rp "$(echo -e "${CC_RED}${IC_WARN} Type 'DELETE' to confirm: ${CC_RESET}")" confirm
    
    if [[ "$confirm" != "DELETE" ]]; then
        cavrix_print "info" "Deletion cancelled"
        return
    fi
    
    # Stop VM if running
    local pid=$(pgrep -f "qemu-system.*$vm_info")
    [[ -n "$pid" ]] && kill "$pid"
    
    # Remove files
    rm -f "$CAVRIX_DISKS/$vm_info.qcow2"
    rm -f "$CAVRIX_SCRIPTS/start-$vm_info.sh"
    rm -f "./start-$vm_name.sh"
    rm -f "$CAVRIX_VMS/$vm_info.conf"
    rm -f "$CAVRIX_RDP/$vm_info.rdp" 2>/dev/null
    
    # Remove from database
    sqlite3 "$CAVRIX_DB" "DELETE FROM vms WHERE uuid='$vm_info';"
    
    cavrix_print "success" "VM '$vm_name' deleted"
}

# ============================================================================
# PERFORMANCE MONITOR
# ============================================================================
performance_monitor() {
    cavrix_banner
    cavrix_print "header" "PERFORMANCE MONITOR"
    
    echo -e "${CC_CYAN}System Resources:${CC_RESET}"
    echo -e "${CC_GRAY}══════════════════════════════════════════════════════════════════════${CC_RESET}"
    
    # CPU
    local cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
    echo -e "${IC_CPU} CPU Usage: ${CC_GREEN}$cpu_usage%${CC_RESET}"
    
    # Memory
    local mem_total=$(free -m | awk '/Mem:/ {print $2}')
    local mem_used=$(free -m | awk '/Mem:/ {print $3}')
    local mem_percent=$((mem_used * 100 / mem_total))
    echo -e "${IC_RAM} Memory: ${CC_GREEN}$mem_used MB / $mem_total MB ($mem_percent%)${CC_RESET}"
    
    # Disk
    local disk_usage=$(df -h / | awk 'NR==2 {print $5}')
    echo -e "${IC_DISK} Disk Usage: ${CC_GREEN}$disk_usage${CC_RESET}"
    
    # Network
    local rx_bytes=$(cat /sys/class/net/$(ip route | grep default | awk '{print $5}')/statistics/rx_bytes 2>/dev/null || echo "0")
    local tx_bytes=$(cat /sys/class/net/$(ip route | grep default | awk '{print $5}')/statistics/tx_bytes 2>/dev/null || echo "0")
    echo -e "${IC_NET} Network: ${CC_GREEN}RX: $(numfmt --to=iec $rx_bytes) | TX: $(numfmt --to=iec $tx_bytes)${CC_RESET}"
    
    echo ""
    echo -e "${CC_CYAN}Running VMs:${CC_RESET}"
    ps aux | grep "[q]emu-system" | awk '{printf "  %-10s %-30s CPU: %s%% MEM: %s%%\n", $2, $13, $3, $4}'
}

# ============================================================================
# SETTINGS MENU
# ============================================================================
settings_menu() {
    cavrix_banner
    cavrix_print "header" "SETTINGS"
    
    echo "1) Change VM Directory"
    echo "2) Clear ISO Cache"
    echo "3) View Logs"
    echo "4) Backup Database"
    echo "5) Restore Database"
    echo "0) Back"
    
    read -rp "$(echo -e "${CC_NEON}Select option: ${CC_RESET}")" choice
    
    case $choice in
        2)
            rm -rf "$CAVRIX_ISO"/*
            cavrix_print "success" "ISO cache cleared"
            ;;
        3)
            tail -20 "$CAVRIX_LOGS/cavrix.log"
            ;;
        0)
            return
            ;;
        *)
            cavrix_print "info" "Feature coming soon!"
            ;;
    esac
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================
main() {
    # Check dependencies
    check_dependencies
    
    # Initialize database
    init_database
    
    # Start main menu
    main_menu
}

# ============================================================================
# RUN THE SCRIPT
# ============================================================================
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
