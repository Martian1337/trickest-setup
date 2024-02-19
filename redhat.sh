#!/bin/bash

# Uncomment below to use root account (not recommended)
# su -

# Update and upgrade the system's packages
sudo dnf update -y && sudo dnf upgrade -y
# For older versions that use yum, replace dnf with yum

# Install necessary packages
sudo dnf install -y firewalld sudo rsyslog curl

# Start and enable firewalld if it's not already running
sudo systemctl start firewalld
sudo systemctl enable firewalld

# Allow traffic on port 3000/tcp for Trickest Agent
sudo firewall-cmd --zone=public --add-port=3000/tcp --permanent

# Making sure SSH access is not blocked by the firewall
sudo firewall-cmd --zone=public --add-service=ssh --permanent
sudo firewall-cmd --reload

# Enter Trickest Client Auth ID and Secret from Trickest Machine Connection Wizard at https://trickest.io/dashboard/settings/fleet
read -p "Enter your Trickest Client Auth ID: " TRICKEST_CLIENT_AUTH_ID
read -p "Enter your Trickest Client Auth Secret: " TRICKEST_CLIENT_AUTH_SECRET

# Set environment variables with the provided Auth ID and Secret
echo "export TRICKEST_CLIENT_AUTH_ID=\"$TRICKEST_CLIENT_AUTH_ID\"" | sudo tee -a ~/.bashrc
echo "export TRICKEST_CLIENT_AUTH_SECRET=\"$TRICKEST_CLIENT_AUTH_SECRET\"" | sudo tee -a ~/.bashrc
source ~/.bashrc

# Download, prepare and run the Trickest agent installation script
sudo curl https://trickest.io/download/agent/latest/init -so init.sh
sudo chmod +x init.sh
sudo ./init.sh
rm -f init.sh

# Start service at boot
sudo systemctl enable trickest-agent.service
rm -f setup.sh

# Reboot immediately prompt
read -p "Setup is complete. Do you want to reboot now? (y/n) " answer
case $answer in
    [Yy]* ) sudo reboot;;
    [Nn]* ) echo "Reboot cancelled. Please reboot your system manually when ready.";;
    * ) echo "Invalid input. Please type 'y' for yes or 'n' for no. System will not reboot without Self-Hosted configurations applied.";;
esac
