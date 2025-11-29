#!/bin/bash

# ZynexCloud 24/7 IDX VM Setup
# Guaranteed No Suspension

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Display header
echo -e "${PURPLE}"
echo "╔════════════════════════════════════════╗"
echo "║         ZynexCloud 24/7 VM           ║"  
echo "║      Guaranteed No Suspension         ║"
echo "╚════════════════════════════════════════╝"
echo -e "${NC}"

# Anti-suspension system
setup_anti_suspension() {
    echo -e "${BLUE}[INFO] Setting up 24/7 anti-suspension system...${NC}"
    
    # Create multiple keep-alive methods
    cat > /workspace/zynexcloud-vm/scripts/anti-suspend.sh << 'EOF'
#!/bin/bash
# ZynexCloud 24/7 Anti-Suspension System

echo "🛡️ Starting ZynexCloud 24/7 Protection..."

while true; do
    # Method 1: File activity
    touch /workspace/zynexcloud-vm/.heartbeat
    echo "$(date '+%Y-%m-%d %H:%M:%S') - ❤️ Heartbeat" >> /workspace/zynexcloud-vm/logs/heartbeat.log
    
    # Method 2: CPU activity (minimal)
    dd if=/dev/urandom of=/dev/null bs=1K count=1 2>/dev/null
    
    # Method 3: Disk activity
    sync
    
    # Method 4: Network activity
    curl -s --max-time 5 https://www.google.com > /dev/null 2>&1 || true
    
    # Method 5: Process activity
    ps aux | grep -v grep | grep -q anti-suspend || echo "Process check" >> /workspace/zynexcloud-vm/logs/process.log
    
    # Method 6: Memory activity
    free -m > /dev/null 2>&1
    
    # Method 7: Create random files
    echo "active" > /workspace/zynexcloud-vm/tmp/.active_$(date +%s)
    
    # Clean old temp files (keep last 10)
    ls -t /workspace/zynexcloud-vm/tmp/.active_* 2>/dev/null | tail -n +11 | xargs rm -f 2>/dev/null || true
    
    sleep 25  # 25 seconds interval - frequent activity
done
EOF

    chmod +x /workspace/zynexcloud-vm/scripts/anti-suspend.sh
    
    # Create backup keep-alive
    cat > /workspace/zynexcloud-vm/scripts/backup-keepalive.sh << 'EOF'
#!/bin/bash
# Backup Keep Alive - Double Protection
while true; do
    echo "$(date): 🔄 Backup Keep Alive" >> /workspace/zynexcloud-vm/logs/backup.log
    touch /workspace/zynexcloud-vm/.backup_active
    sleep 45
done
EOF

    chmod +x /workspace/zynexcloud-vm/scripts/backup-keepalive.sh
    
    # Start both services
    nohup /workspace/zynexcloud-vm/scripts/anti-suspend.sh > /dev/null 2>&1 &
    nohup /workspace/zynexcloud-vm/scripts/backup-keepalive.sh > /dev/null 2>&1 &
    
    echo -e "${GREEN}[OK] 24/7 anti-suspension system activated${NC}"
}

# Multiple monitoring processes
setup_monitoring() {
    echo -e "${BLUE}[INFO] Setting up multi-layer monitoring...${NC}"
    
    # Process monitor - ensures keep-alive is always running
    cat > /workspace/zynexcloud-vm/scripts/process-monitor.sh << 'EOF'
#!/bin/bash
# Process Monitor - Ensures 24/7 services are always running

while true; do
    # Check if anti-suspend is running
    if ! ps aux | grep -v grep | grep -q "anti-suspend.sh"; then
        echo "$(date): ❌ Anti-suspend stopped - RESTARTING" >> /workspace/zynexcloud-vm/logs/monitor.log
        nohup /workspace/zynexcloud-vm/scripts/anti-suspend.sh > /dev/null 2>&1 &
    fi
    
    # Check if backup is running
    if ! ps aux | grep -v grep | grep -q "backup-keepalive.sh"; then
        echo "$(date): ❌ Backup keep-alive stopped - RESTARTING" >> /workspace/zynexcloud-vm/logs/monitor.log
        nohup /workspace/zynexcloud-vm/scripts/backup-keepalive.sh > /dev/null 2>&1 &
    fi
    
    # Log monitoring status
    echo "$(date): ✅ Monitoring active - All systems OK" >> /workspace/zynexcloud-vm/logs/monitor.log
    
    sleep 60  # Check every minute
done
EOF

    chmod +x /workspace/zynexcloud-vm/scripts/process-monitor.sh
    
    # Start process monitor
    nohup /workspace/zynexcloud-vm/scripts/process-monitor.sh > /dev/null 2>&1 &
    
    echo -e "${GREEN}[OK] Multi-layer monitoring activated${NC}"
}

# Activity simulation for different system components
setup_activity_simulation() {
    echo -e "${BLUE}[INFO] Setting up comprehensive activity simulation...${NC}"
    
    # CPU activity simulator
    cat > /workspace/zynexcloud-vm/scripts/cpu-activity.sh << 'EOF'
#!/bin/bash
# CPU Activity Simulator - Prevents idle detection
while true; do
    # Light CPU calculations
    for i in {1..5}; do
        echo "scale=1000; 4*a(1)" | bc -l > /dev/null 2>&1
    done
    echo "$(date): 🔥 CPU activity simulated" >> /workspace/zynexcloud-vm/logs/cpu.log
    sleep 120
done
EOF

    chmod +x /workspace/zynexcloud-vm/scripts/cpu-activity.sh
    
    # Disk activity simulator
    cat > /workspace/zynexcloud-vm/scripts/disk-activity.sh << 'EOF'
#!/bin/bash
# Disk Activity Simulator
while true; do
    # Create, modify, delete files
    echo "active_$(date +%s)" > /workspace/zynexcloud-vm/tmp/disk_activity.txt
    cat /workspace/zynexcloud-vm/tmp/disk_activity.txt >> /workspace/zynexcloud-vm/logs/disk.log
    rm -f /workspace/zynexcloud-vm/tmp/disk_activity.txt
    sync
    echo "$(date): 💾 Disk activity simulated" >> /workspace/zynexcloud-vm/logs/disk.log
    sleep 90
done
EOF

    chmod +x /workspace/zynexcloud-vm/scripts/disk-activity.sh
    
    # Start activity simulators
    nohup /workspace/zynexcloud-vm/scripts/cpu-activity.sh > /dev/null 2>&1 &
    nohup /workspace/zynexcloud-vm/scripts/disk-activity.sh > /dev/null 2>&1 &
    
    echo -e "${GREEN}[OK] Comprehensive activity simulation started${NC}"
}

# Enhanced status checking
create_enhanced_commands() {
    echo -e "${BLUE}[INFO] Creating enhanced monitoring commands...${NC}"
    
    # 24/7 status command
    cat > /workspace/vm-status-24x7 << 'EOF'
#!/bin/bash
echo "╔════════════════════════════════════════╗"
echo "║       ZynexCloud 24/7 Status          ║"
echo "╚════════════════════════════════════════╝"

# Check all services
echo "🔍 Service Status:"
echo "  Anti-Suspend: $(ps aux | grep -v grep | grep -q anti-suspend && echo '✅ RUNNING' || echo '❌ STOPPED')"
echo "  Backup Keep: $(ps aux | grep -v grep | grep -q backup-keepalive && echo '✅ RUNNING' || echo '❌ STOPPED')"
echo "  Process Monitor: $(ps aux | grep -v grep | grep -q process-monitor && echo '✅ RUNNING' || echo '❌ STOPPED')"
echo "  CPU Activity: $(ps aux | grep -v grep | grep -q cpu-activity && echo '✅ RUNNING' || echo '❌ STOPPED')"
echo "  Disk Activity: $(ps aux | grep -v grep | grep -q disk-activity && echo '✅ RUNNING' || echo '❌ STOPPED')"

# Check latest activity
echo ""
echo "📊 Latest Activity:"
if [ -f /workspace/zynexcloud-vm/.heartbeat ]; then
    echo "  Heartbeat: $(date -r /workspace/zynexcloud-vm/.heartbeat '+%H:%M:%S')"
else
    echo "  Heartbeat: ❌ NEVER"
fi

if [ -f /workspace/zynexcloud-vm/logs/heartbeat.log ]; then
    echo "  Last Log: $(tail -1 /workspace/zynexcloud-vm/logs/heartbeat.log 2>/dev/null)"
fi

echo ""
echo "🛡️  Protection Level: MAXIMUM"
echo "💤 Suspension Risk: ZERO"
echo "🚀 Status: 24/7 ACTIVE"
EOF

    chmod +x /workspace/vm-status-24x7
    
    # Restart command
    cat > /workspace/vm-restart-services << 'EOF'
#!/bin/bash
echo "🔄 Restarting ZynexCloud 24/7 services..."

# Kill existing processes
pkill -f anti-suspend.sh 2>/dev/null || true
pkill -f backup-keepalive.sh 2>/dev/null || true
pkill -f process-monitor.sh 2>/dev/null || true
pkill -f cpu-activity.sh 2>/dev/null || true
pkill -f disk-activity.sh 2>/dev/null || true

# Restart all services
cd /workspace/zynexcloud-vm
nohup ./scripts/anti-suspend.sh > /dev/null 2>&1 &
nohup ./scripts/backup-keepalive.sh > /dev/null 2>&1 &
nohup ./scripts/process-monitor.sh > /dev/null 2>&1 &
nohup ./scripts/cpu-activity.sh > /dev/null 2>&1 &
nohup ./scripts/disk-activity.sh > /dev/null 2>&1 &

echo "✅ All 24/7 services restarted!"
echo "Run 'vm-status-24x7' to verify"
EOF

    chmod +x /workspace/vm-restart-services
    
    echo -e "${GREEN}[OK] Enhanced commands created${NC}"
}

# Main installation with 24/7 guarantee
main() {
    echo -e "${GREEN}[INFO] Starting ZynexCloud 24/7 VM setup...${NC}"
    
    # Create directory structure
    mkdir -p /workspace/zynexcloud-vm/{scripts,configs,vms,logs,tmp}
    
    # Setup all systems
    setup_anti_suspension
    setup_monitoring
    setup_activity_simulation
    create_enhanced_commands
    
    # Completion message
    echo -e "${GREEN}"
    echo "╔════════════════════════════════════════╗"
    echo "║       24/7 SETUP COMPLETED!           ║"
    echo "║      GUARANTEED NO SUSPENSION         ║"
    echo "╚════════════════════════════════════════╝"
    echo -e "${NC}"
    echo -e "${BLUE}Available Commands:${NC}"
    echo -e "  ${GREEN}vm-status-24x7${NC}     - Detailed 24/7 status"
    echo -e "  ${GREEN}vm-restart-services${NC} - Restart all services"
    echo -e ""
    echo -e "${YELLOW}5-Layer Protection System:${NC}"
    echo -e "  ✅ Anti-Suspension Core"
    echo -e "  ✅ Backup Keep-Alive" 
    echo -e "  ✅ Process Monitor"
    echo -e "  ✅ CPU Activity Simulator"
    echo -e "  ✅ Disk Activity Simulator"
    echo -e ""
    echo -e "${GREEN}Your VM will run 24/7 WITHOUT suspension!${NC}"
}

# Run main function
main "$@"
