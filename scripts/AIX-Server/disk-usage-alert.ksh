#########################################################################################################
#!/bin/ksh
# This script is developed for IBM AIX Blade servers for Proactive monitoring 
# Monitoring of the Clients Infra Setups
###
###
# Name    : disk-usage-alert.ksh
# Purpose : To Monitor the Disk Space Usages of AIX Servers
# Parameters : 1. THRESHOLD - Minimum allowed Threashold
#              2. /tmp/alertemaillist/teamzoidalertemails.txt - File where the to email list are maintained  
# 	       3. From - From email ID   
###
###
#"But by the grace of God, we are what we are, and His grace to us was not without effect. No, we worked harder than all of them—yet not we, but the grace of God that was with us."
#-------------------------------------------------------------------------------------------------#
# Change History
#-------------------------------------------------------------------------------------------------#
# Name              |Change Date| Change Description                                | BugID
# ------------------ -----------  --------------------------------------------------  ------------#
# Abdul Rehan       |Oct 5, 2020| Initial Writing                                   | NA
# ------------------ -----------  --------------------------------------------------  ------------#
#########################################################################################################
#sed -i -e 's/\r$//' disk-usage-alert.sh|./disk-usage-alert.sh
df | grep -vE '^Filesystem|tmpfs|cdrom' | awk '{ print $4 " " $1 }' | while read output;
do
  #echo $output
  THRESHOLD=90
  used=$(echo $output | awk '{ print $1}' | cut -d'%' -f1  )
  partition=$(echo $output | awk '{ print $2 }' )
  if [ ${#used} -ge 2 ]; then 
    if [ $used -ge "$THRESHOLD" ]; then
       echo "The partition \"$partition\" on $(hostname) has used $used% at $(date)" | mail -s "Alert from $(hostname) - Disk space alert: $used% used" "abc@xyz.com"
    fi
  fi
done
