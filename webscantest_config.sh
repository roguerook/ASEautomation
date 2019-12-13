#!/Git/bin/bash

####################################################################################################
# Title:    Client Specific Config for ASE Master Automation Script
# Author:   Rob Hunter
# Date:     December 2019
# Desc:     Contains unique variable per client that feed the ASE Master script
####################################################################################################

####################################################################################################
# Client:       (example)
# Client POC:   (example)
# CI/CI Info:   App build server in X Data Center at 10.10.10.11:80 (example)
# App URI:      http://webappscantest.com (example)
# Application:  webappscan (Rapid7 Client used for initial testing)
# Version:      v1.0a (example)

####################################################################################################
# NOTES:
#   1. Change variables but do not change "source" on line 45
####################################################################################################

####################################################################################################
# REVISIONS:
#   1. [date] [revisor]: [description]
####################################################################################################


# Define global variables
ASE_IPADDRESS=""
APP_NAME="webscantest"
APP_VERSION="1.0a"
CONFIG_ID="dc12468d-5e5f-4eb1-884c-bcc324a7b0e6"
CONFIG_NAME="webscantest"
NAME=""  # QUESTION:  Should the creds be as-is...is there a better way to secure?
PASSWORD=""  # QUESTION:  Should the creds be in a variable or as-is...encryption?
XML_PATH="C:\\Jenkins_Scripts\\AppSpider\\webscantest\\"
LOG_PATH="C:\\Jenkins_Scripts\\AppSpider\\webscantest\\"
LOG_FILENAME="webscantest_1.0a_log.txt"
DATE=$(date +%Y%m%d)
LOG=$($LOG_PATH_$DATE_$LOG_FILENAME)
touch $LOG
################################################################################################################################################################################
# Do not add anything below this line
#---------------------------------------------------------------------------------------------------------
source /C/Jenkins_Scripts/AppSpider/Master_Script/ase_master.sh
##########################################################################################################################################################################
