#!/Git/bin/bash

####################################################################################################
# Title:    ASE Automation Script
# Author:   Rob Hunter
# Date:     December 2019
# Desc :    ...
####################################################################################################

####################################################################################################
# Client:       (example)
# Client POC:   (example)
# CI/CI Info:   App build server in X Data Center at 10.10.10.11:80 (example)
# App URI:      http://webappscantest.com (example)
# Application:  webappscan (Rapid7 Client used for initial testing)
# Version:      v1.0a (example)
####################################################################################################

####################################################################################################
# OVERALL REQUIREMENTS:
#   1. Connectivity with target IP address from one of the ASE scan engines
#   2. Valid admin credentials to the application
#   3. Application is accesible via a browser (Rapid7 Requirement)
#   4. Means of authentication must work within current ASE options
####################################################################################################

####################################################################################################
# SCRIPT REQUIREMENTS:
#   1. Scans can be setup manually and kicked off to confirm success, or
#       scans can be configured using an XML file and the /Config/SaveConfig API call.
#       Full automation would require several check scans, a still have ~20% that require manual setup.  
#   2. Final version should have one Client User that ALL automation scan configs reside under.
#   3. Updating a scan config will not change the configId.
#   4. Log file is created for each app/version per execution
#   5. Global variable are stored in separate config file
#   6. ASE API Data:  appspider.help.rapid7.com/docs/res-api-overview
#   7. A valid user token is required for all API calls, which refreshes on all cURL calls
####################################################################################################

####################################################################################################
# REQUIRED VARIABLES - Stored in separate config file per app & version, using bash "source"
#   ASE_IPADDRESS: This is the IP Address of the AppSpider Enterprise Console
#   APP_NAME: The application's name
#   APP_VERSION: The application's version
#   CONFIG_ID: Supplied after manual scan setup
#   CONFIG_NAME: Supplied after manual scan setup
#   NAME: The username of the Client user (Automation client)
#   PASSWORD: The password of the Client user (Automation client)
#   XML_PATH: Unique path where this client's xml file is stored
#   LOG_PATH: Unique path where this client's log file is stored
#   LOG_FILENAME: Dictate the unique xml filename (app_version_log.txt)
####################################################################################################

####################################################################################################
# REVISIONS:
#   1. [date] [revisor]: [description]
####################################################################################################


# Funtion: Refreshs the datetime stamp for each call
GET_STAMP () {
  TIME_STAMP=$(date +%H%M%S%Z)
}

# Function: Call to get the "Client" user's auth token with each cURL call
GET_USER_TOKEN () {
  USER_LOGIN=$(curl -k -X POST "https://$ASE_IPADDRESS/AppSpiderEnterprise/rest/v1/Authentication/Login" -H "Content-Type: application/json" -H "cache-control: no-cache" -d "{\"name\": \"$NAME\",\"password\": \"$PASSWORD\"}")
  USER_TOKEN=$(echo $USER_LOGIN | cut -d ":" -f 2 | cut -d "," -f 1 | sed 's/"//g')
  TOKEN_STATUS=$(echo $USER_LOGIN | grep "IsSuccess" | cut -d ":" -f 2 | sed 's/ //g' | sed 's/,//g')
  GET_STAMP && echo "User token fetched:$TIME_STAMP:" >> $LOG
}

GET_SCAN_STATUS () {
  IS_SCAN_FINISHED=$(curl -k -X GET "https://$ASE_IPADDRESS/AppSpiderEnterprise/rest/v1/Scan/IsScanFinished?scanId=$SCAN_ID" -H "Authorization: Basic $USER_TOKEN" -H "cache-control: no-cache")
  SCAN_STATUS=$(echo $IS_SCAN_FINISHED | cut -d ":" -f 2 | cut -d "," -f 1)
}

# Create new log file
GET_STAMP && printf "$TIME_STAMP:Scheduled ASE scan of $APP_NAME, version $APP_VERSION initiated:" >> $LOG
echo "Scan configName:$CONFIG_NAME, scan configId:$CONFIG_ID:" >> $LOG


# Run the Scan
GET_USER_TOKEN
if [ $TOKEN_STATUS == "false" ]; then
  GET_STAMP && echo "Get user auth token failed ${TIME_STAMP[@]}:" >> $LOG
  exit 1
fi

RUN_SCAN=$(curl -k -X POST "https://$ASE_IPADDRESS/AppSpiderEnterprise/rest/v1/Scan/RunScan" -H "Authorization: Basic $USER_TOKEN" -H "cache-control: no-cache"   -d "configId=$CONFIG_ID&configName=$CONFIG_NAME")
GET_STAMP && echo "Scan started ${TIME_STAMP[@]}:" >> $LOG
SCAN_ID=$(echo $RUN_SCAN | cut -d ":" -f 3 | cut -d "," -f 1 | sed 's/"//g')
GET_STAMP && echo "Current scanId is $SCAN_ID:" >> $LOG


# Check if scan stated successfully
SCAN_STARTED=$(echo $RUN_SCAN | cut -d "}" -f 2 | cut -d ":" -f 2 | cut -d "," -f 1 | sed 's/"//g')

if [ $SCAN_STARTED == "false" ]; then
  GET_STAMP && echo "Error: Scan failed to start $TIME_STAMP:"  >> $LOG
  exit 1
else 
  GET_STAMP && echo "Scan started = $SCAN_STARTED:" >> $LOG
fi


# Wait on scan to finish, check every 10 minutes - refreshes USER_TOKEN before every check
# GET_SCAN_STATUS
# echo $IS_SCAN_FINISHED
# echo $SCAN_STATUS
until GET_USER_TOKEN && GET_SCAN_STATUS && [ $SCAN_STATUS == "true" ]; do
    sleep 20m && GET_STAMP && echo "...still running $TIME_STAMP:"  >> $LOG
done


# Retrieve xml, move and rename
GET_STAMP && echo "Scan complete, retrieving xml $TIME_STAMP:"  >> $LOG
VULN_FILE=$(curl -k -X GET "https://$ASE_IPADDRESS/AppSpiderEnterprise/rest/v1/Report/GetVulnerabilitiesXml?scanid=$SCAN_ID" -H "Authorization: Basic $USER_TOKEN" -H "cache-control: no-cache")


# Write xml to file
XML=$($XML_PATH$APP_NAME.$APP_VERSION.$TIME_STAMP.xml)
cp $VULN_FILE > $XML
if [ -f $XML ]; then
  GET_STAMP && echo "xml created $TIME_STAMP:"  >> $LOG
  # TODO:  add a check for contents...that there is no error message returned in the file
else  
  GET_STAMP && echo "Error: xml creation failed $TIME_STAMP:"  >> $LOG
  exit 1
fi

exit 0
