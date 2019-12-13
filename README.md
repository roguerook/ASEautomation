# AppSpider Enterprise (ASE) Scripted Scan Automation

Problem:  Rapid7's jenkins-appspider plugin for Jenkins will not run on Windows implementations - confirmed through Rapid7 Support.

### Project Overview:  
Call scripts from Jenkins instance, located on our PDC server (10.106.24.22), that reach out to ASE’s API (on server in Azure MSS Subscription), that then requests ASE scan engine(s), depending upon architecture, to perform the application vulnerability scan and return various reports (xml, zip, crawled links, etc.).

### Project Future State:  
Create further automation scripts that: 
1. Generate the ASE Scan Config xml file 
2. Use a call to ASE’s API to create the new scan (/AppSpiderEnterprise/rest/v1/Config/SaveConfig - Creates a new scan config based on XML file)
3. Create a simple web app interface to input the required variables required to create the ASE Scan Config xml file, with underlying functionality to orchestrate the entire process (create, scan, report via tool like CodeDx).

### Project Status:  
* 90% testing complete for the “ASE Automation” phase, see attached scripts
* Recommend using ase-postman.json, in conjunction with Postman (setup Environment data) to quickly test multiple step calls

TODO & Bonus:
* FIX the log, or not since Jenkins logs builds- was working then broke during improvements.
* Debug the while/until loop - still will not drop out of loop even through scan is finished
* Finish testing: get xml file & move/rename
* Add a check to confirm valid xml
* Add a check to confirm minimum links/pages crawled against known value
* Add try-except error handling to major code blocks


### Alternate Paths:
* Running a Linux VM from Hyper-V and running Jenkins there, to ensure functionality of Rapid7’s Jenkins-AppSpider plugin
* Reviewing the code of Rapid7’s Jenkins-AppSpider plugin as a reference for this project


### OVERALL REQUIREMENTS:
1. Local Environment: connectivity to ASE API, git for windows, Jenkins, etc
2. Connectivity with target IP address from one of the ASE scan engines
3. Valid admin credentials to the application
4. Application is accesible via a browser
5. Means of authentication must work within current ASE options


### SCRIPT REQUIREMENTS:
1. Scans can be setup manually and kicked off to confirm success, or scans can be configured using an XML file and the /Config/SaveConfig API call.  Full automation would require several check scans, a still have ~20% that require manual setup (review all ASE auth methods).
2. Final version should have one Client User that ALL automation scan configs reside under.
3. Updating a scan config will not change the configId.
4. Log file is created for each app/version per execution
5. Global variable are stored in separate config file
6. ASE API Data:  appspider.help.rapid7.com/docs/res-api-overview
7. A valid user token is required for EVERY API call, which refreshes on EACH cURL call
8. ...


### REQUIRED VARIABLES:  Stored in separate config file per app & version, using bash "source"
ASE_IPADDRESS: This is the IP Address of the AppSpider Enterprise Console
APP_NAME: The application's name
APP_VERSION: The application's version
CONFIG_ID: Supplied after manual scan setup
CONFIG_NAME: Supplied after manual scan setup
NAME: The username of the Client user (Automation client)
PASSWORD: The password of the Client user (Automation client)
XML_PATH: Unique path where this client's xml file is stored
LOG_PATH: Unique path where this client's log file is stored
LOG_FILENAME: Dictate the unique xml filename (app_version_log.txt)

### Script Steps:
1. Get token
2. Run (start) scan (previously configured)
3. Capture the ScanID
4. Confirm “Run scan” started successfully
5. Check to see “Is Scan Finished”
a. If not, sleep
b. If so…
6. Get xml file (vulnerabilitysummary.xml)
7. Move and rename xml
8. …to be injested by a tool like CodeDx

### Important Links:
* ASE API Data:  appspider.help.rapid7.com/docs/res-api-overview
* ASE:  https://appspider.help.rapid7.com/docs/getting-started-with-appspider-enterprise
