#!/bin/bash

# =============================================
# ZYNEXCLOUD ULTIMATE VM SETUP SCRIPT
# Premium Edition v3.0
# 24/7 • High Performance • Multi-OS Support
# =============================================

set -e

# ZynexCloud Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
ORANGE='\033[0;33m'
NC='\033[0m'

# ZynexCloud Banner
display_banner() {
    echo -e "${PURPLE}"
    echo "╔════════════════════════════════════════════════════╗"
    echo "║               ZYNEXCLOUD VM PLATFORM              ║"
    echo "║                 PREMIUM EDITION v3.0              ║"
    echo "║          24/7 • Secure • High-Performance         ║"
    echo "║                                                    ║"
    echo "║            Ultimate Virtualization Suite          ║"
    echo "╚════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo -e "${CYAN}Platform: ZynexCloud Virtualization Engine${NC}"
    echo -e "${CYAN}Version: 3.0 | Build: 2024 | Support: ZynexCloud Team${NC}"
    echo ""
}

# Logging functions
log() {
    echo -e "${GREEN}[ZYNEXCLOUD ✓]${NC} $1"
}

info() {
    echo -e "${BLUE}[ZYNEXCLOUD ℹ]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[ZYNEXCLOUD ⚠]${NC} $1"
}

error() {
    echo -e "${RED}[ZYNEXCLOUD ✗]${NC} $1"
}

zynex_banner() {
    echo -e "${ORANGE}"
    echo "▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄"
    echo "█▄─▄▄─█─▄▄─█▄─▀─▄█─▄▄─█▄─█─▄█▄─▄▄─█▄─▄▄▀█▄─▄▄─█"
    echo "██─▄█▀█─██─██▀─▀██─██─██▄─▄███─▄▄▄██─▄─▄██─▄█▀█"
    echo "▀▄▄▄▄▄▀▄▄▄▄▀▄▄▀▄▄▀▄▄▄▄▀▀▀▄▄▄▀▀▄▄▄▀▀▀▄▄▀▄▄▀▄▄▄▄▄▀"
    echo -e "${NC}"
}

# Check system compatibility
check_system() {
    info "Checking system compatibility..."
    
    # Check OS
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        log "Detected OS: $PRETTY_NAME"
    else
        warn "Unknown OS - Continuing with basic setup"
    fi
    
    # Check architecture
    ARCH=$(uname -m)
    log "Architecture: $ARCH"
    
    # Check resources
    RAM_GB=$(free -g | awk '/^Mem:/{print $2}')
    CPU_CORES=$(nproc)
    
    log "System Resources: ${RAM_GB}GB RAM, ${CPU_CORES} CPU cores"
    
    if [[ $RAM_GB -lt 2 ]]; then
        warn "Low RAM detected. For optimal performance, 4GB+ recommended."
    fi
}

# Install essential packages
install_essentials() {
    info "Installing ZynexCloud essential packages..."
    
    # Update system
    sudo apt update && sudo apt upgrade -y
    
    # Core utilities
    sudo apt install -y \
        curl wget git htop \
        neofetch tree nano vim \
        screen tmux zip unzip \
        net-tools dnsutils iputils-ping \
        software-properties-common \
        build-essential
    
    log "Core utilities installed successfully"
}

# Setup ZynexCloud virtualization
setup_virtualization() {
    info "Setting up ZynexCloud virtualization engine..."
    
    # Install KVM and virtualization tools
    sudo apt install -y \
        qemu-kvm \
        qemu-utils \
        qemu-system \
        libvirt-daemon-system \
        libvirt-clients \
        virt-manager \
        virt-viewer \
        bridge-utils \
        ovmf
    
    # Add user to libvirt group
    sudo usermod -aG libvirt $USER
    sudo usermod -aG kvm $USER
    
    # Start and enable services
    sudo systemctl enable libvirtd
    sudo systemctl start libvirtd
    
    # Configure libvirt
    sudo virsh net-autostart default
    sudo virsh net-start default
    
    log "ZynexCloud virtualization engine configured"
}

# Setup 24/7 anti-sleep system
setup_24x7_system() {
    info "Configuring ZynexCloud 24/7 operation system..."
    
    # Disable all sleep modes
    sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
    
    # Create ZynexCloud guardian script
    sudo tee /usr/local/bin/zynex-guardian.sh << 'EOF'
#!/bin/bash
# ZynexCloud VM Guardian Service
# Prevents suspension and maintains 24/7 operation

while true; do
    # Multiple activity methods
    touch /tmp/zynexcloud_active
    echo "$(date '+%Y-%m-%d %H:%M:%S') - ZynexCloud VM Active" >> /var/log/zynexcloud/guardian.log
    
    # System activity simulation
    dd if=/dev/urandom of=/dev/null bs=1K count=1 2>/dev/null
    
    # Disk sync
    sync
    
    # Network connectivity check
    ping -c 1 8.8.8.8 >/dev/null 2>&1 || echo "Network check failed" >> /var/log/zynexcloud/guardian.log
    
    # Service health check
    if ! systemctl is-active --quiet libvirtd; then
        echo "Libvirtd not running - restarting" >> /var/log/zynexcloud/guardian.log
        systemctl restart libvirtd
    fi
    
    sleep 30
done
EOF

    sudo chmod +x /usr/local/bin/zynex-guardian.sh
    
    # Create systemd service
    sudo tee /etc/systemd/system/zynex-guardian.service << EOF
[Unit]
Description=ZynexCloud VM Guardian - 24/7 Keep Alive
After=network.target libvirtd.service

[Service]
Type=simple
ExecStart=/usr/local/bin/zynex-guardian.sh
Restart=always
RestartSec=5
User=root
Environment=ZYNEXCLOUD_VERSION=3.0

[Install]
WantedBy=multi-user.target
EOF

    # Create log directory
    sudo mkdir -p /var/log/zynexcloud
    
    # Enable and start service
    sudo systemctl daemon-reload
    sudo systemctl enable zynex-guardian.service
    sudo systemctl start zynex-guardian.service
    
    # Setup crontab for additional protection
    (crontab -l 2>/dev/null; echo "# ZynexCloud Protection System") | crontab -
    (crontab -l 2>/dev/null; echo "*/3 * * * * touch /tmp/zynexcloud_keepalive") | crontab -
    (crontab -l 2>/dev/null; echo "0 4 * * * /sbin/reboot") | crontab -
    (crontab -l 2>/dev/null; echo "*/10 * * * * systemctl is-active zynex-guardian.service || systemctl restart zynex-guardian.service") | crontab -
    
    log "ZynexCloud 24/7 protection system activated"
}

# Performance optimization
optimize_performance() {
    info "Applying ZynexCloud performance optimizations..."
    
    # Kernel optimization
    sudo tee -a /etc/sysctl.conf << 'EOF'

# ==========================================
# ZYNEXCLOUD PERFORMANCE OPTIMIZATIONS
# ==========================================
vm.swappiness=10
vm.vfs_cache_pressure=50
net.core.rmem_max=268435456
net.core.wmem_max=268435456
net.ipv4.tcp_rmem=4096 65536 268435456
net.ipv4.tcp_wmem=4096 65536 268435456
net.core.somaxconn=65535
net.ipv4.tcp_max_syn_backlog=65535
fs.file-max=1000000
fs.inotify.max_user_watches=524288
# ZynexCloud specific optimizations
net.ipv4.tcp_slow_start_after_idle=0
net.ipv4.tcp_tw_reuse=1
vm.dirty_background_ratio=5
vm.dirty_ratio=10
EOF

    sudo sysctl -p
    
    # Enable nested virtualization if available
    if grep -q "Y" /sys/module/kvm_intel/parameters/nested 2>/dev/null || 
       grep -q "Y" /sys/module/kvm_amd/parameters/nested 2>/dev/null; then
        echo "options kvm-intel nested=Y" | sudo tee /etc/modprobe.d/kvm-intel.conf
        echo "options kvm-amd nested=1" | sudo tee /etc/modprobe.d/kvm-amd.conf
        log "Nested virtualization enabled"
    fi
    
    log "Performance optimizations applied successfully"
}

# Security hardening
setup_security() {
    info "Configuring ZynexCloud security framework..."
    
    # Install security tools
    sudo apt install -y \
        fail2ban \
        ufw \
        unattended-upgrades \
        apt-listchanges
    
    # Configure firewall
    sudo ufw --force reset
    sudo ufw --force enable
    sudo ufw allow ssh
    sudo ufw allow http
    sudo ufw allow https
    sudo ufw allow 5900:5910/tcp  # VNC ports
    sudo ufw allow 16509/tcp      # Libvirt
    
    # Configure automatic security updates
    sudo dpkg-reconfigure -plow unattended-upgrades
    
    # Secure SSH configuration
    sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
    sudo sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config
    
    log "ZynexCloud security framework configured"
}

# Setup monitoring and analytics
setup_monitoring() {
    info "Setting up ZynexCloud monitoring system..."
    
    # Install monitoring tools
    sudo apt install -y \
        htop \
        iotop \
        nethogs \
        nmon \
        dstat \
        glances
    
    # Create status script
    sudo tee /usr/local/bin/zynex-status.sh << 'EOF'
#!/bin/bash
echo "╔════════════════════════════════════════╗"
echo "║         ZYNEXCLOUD VM STATUS          ║"
echo "╚════════════════════════════════════════╝"
echo ""
echo "🏷️  Platform: ZynexCloud Premium v3.0"
echo "⏰  Uptime: $(uptime -p)"
echo "📊 Load: $(uptime | awk -F'load average:' '{print $2}')"
echo "💾 Memory: $(free -h | awk '/^Mem:/{print $3"/"$2}')"
echo "💿 Disk: $(df -h / | awk 'NR==2{print $3"/"$2" ("$5")"}')"
echo "🔧 Guardian: $(systemctl is-active zynex-guardian.service)"
echo "🖥️  Virtualization: $(systemctl is-active libvirtd)"
echo ""
echo "📈 Last Activity: $(date -r /tmp/zynexcloud_active 2>/dev/null || echo 'Starting up...')"
echo "📋 Run 'zynex-monitor' for detailed metrics"
EOF

    sudo chmod +x /usr/local/bin/zynex-status.sh
    
    # Create detailed monitor script
    sudo tee /usr/local/bin/zynex-monitor.sh << 'EOF'
#!/bin/bash
echo "══════════════════════════════════════════════"
echo "    ZYNEXCLOUD DETAILED SYSTEM MONITOR"
echo "══════════════════════════════════════════════"
echo ""
echo "CPU Usage:"
mpstat 1 1 | awk '$3 ~ /[0-9.]+/ {print "Usage: " 100-$12 "%"}'
echo ""
echo "Memory Details:"
free -h
echo ""
echo "Disk Usage:"
df -h | grep -v tmpfs
echo ""
echo "Active Services:"
systemctl is-active libvirtd zynex-guardian.service
echo ""
echo "Network Connections:"
ss -tuln | grep -E ':(22|80|443|5900|16509)'
EOF

    sudo chmod +x /usr/local/bin/zynex-monitor.sh
    
    # Create aliases
    echo "alias zynex-status='zynex-status.sh'" >> ~/.bashrc
    echo "alias zynex-monitor='zynex-monitor.sh'" >> ~/.bashrc
    
    log "ZynexCloud monitoring system installed"
}

# Create ZynexCloud directory structure
setup_zynexcloud_dirs() {
    info "Creating ZynexCloud directory structure..."
    
    sudo mkdir -p /opt/zynexcloud/{scripts,configs,logs,templates,vms,backups}
    sudo mkdir -p /opt/zynexcloud/scripts/{vm-management,monitoring,backup}
    sudo mkdir -p /opt/zynexcloud/configs/{network,security,performance}
    
    # Create branding file
    sudo tee /opt/zynexcloud/branding.txt << EOF
==================================================
            ZYNEXCLOUD VM PLATFORM
            Premium Edition v3.0
         Ultimate Virtualization Solution
          
        Features:
        • 24/7 Operation
        • Multi-OS Support
        • High Performance
        • Enterprise Security
        • Auto Recovery
          
        Website: https://zynexcloud.com
        Support: support@zynexcloud.com
==================================================
EOF

    sudo chown -R $USER:$USER /opt/zynexcloud
    log "ZynexCloud directory structure created"
}

# Final setup and verification
final_setup() {
    info "Performing final ZynexCloud setup..."
    
    # Reload shell
    source ~/.bashrc
    
    # Verify installations
    info "Verifying installations..."
    
    if systemctl is-active --quiet libvirtd; then
        log "✓ Virtualization service: ACTIVE"
    else
        error "✗ Virtualization service: INACTIVE"
    fi
    
    if systemctl is-active --quiet zynex-guardian.service; then
        log "✓ Guardian service: ACTIVE"
    else
        error "✗ Guardian service: INACTIVE"
    fi
    
    if virsh --version > /dev/null 2>&1; then
        log "✓ Libvirt CLI: READY"
    else
        error "✗ Libvirt CLI: NOT READY"
    fi
    
    # Display completion message
    echo ""
    echo -e "${GREEN}"
    echo "╔════════════════════════════════════════════════════╗"
    echo "║          ZYNEXCLOUD SETUP COMPLETED!              ║"
    echo "╚════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
    log "Your ZynexCloud VM is now ready for 24/7 operation!"
    echo ""
    info "Available Commands:"
    echo "  zynex-status    - Check VM status"
    echo "  zynex-monitor   - Detailed system metrics"
    echo "  virt-manager    - Launch VM manager"
    echo "  virsh list      - List virtual machines"
    echo ""
    warn "Important: Please reboot your system to apply all changes!"
    echo "  Command: sudo reboot"
    echo ""
    info "Logs Directory: /var/log/zynexcloud/"
    info "Config Directory: /opt/zynexcloud/configs/"
    echo ""
}

# Main installation function
main() {
    display_banner
    zynex_banner
    
    log "Starting ZynexCloud Ultimate VM Setup..."
    echo ""
    
    # Installation steps
    check_system
    install_essentials
    setup_zynexcloud_dirs
    setup_virtualization
    optimize_performance
    setup_24x7_system
    setup_security
    setup_monitoring
    final_setup
}

# Run main function
main "$@"
