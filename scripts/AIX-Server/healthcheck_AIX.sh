#########################################################################################################
#!/bin/bash 
# This script is part of Infrastructure Monitoring Scripts for Proactive 
# Monitoring of the Clients Infra Setups
###
###
# Name          : healthcheck.AIX.sh
# Purpose       : This script collects system information and status like Server Name, Date, UPtime, CPU ,Memory and Page-file Info.
#		: Kernel Parameters, processes on SERVER, Oldest oracle processes, <defunct> processes, Mount Point Information, Network statistics.
# Parameters    : 1. Email - Email IDs to which list have to be sent
# 
###
###
#But by the grace of God We are what we are, and his grace to us was not without effect. No,
#We worked harder than all of them--yet not We, but the grace of God that was with us.
#-------------------------------------------------------------------------------------------------#
# Change History
#-------------------------------------------------------------------------------------------------#
# Name              |Change Date| Change Description                                | BugID
# ------------------ -----------  --------------------------------------------------  ------------#
# Abdul Rehan       |Oct 22, 2020| Initial Writing                                   | NA
# ------------------ -----------  --------------------------------------------------  ------------#
#########################################################################################################
#Parameters 
EMAIL='abdul.rehan@xyz.com'
#.....
function sysstat {
echo "====================================="
echo ">>>>> Server Name, Date, UPtime <<<<<"
echo "====================================="
echo "Date :- `date`"
echo " "
echo "Host Name :- `hostname`"
echo " "
echo " OS Version"
oslevel -g
echo " "
echo " UPTIME :- "
uptime
echo " "
echo " "
echo "====================================="
echo ">>>>>    CPU and Memory Info.   <<<<<"
echo "====================================="
echo " "
echo "**************************************************************************************"
echo "          CPU :- `lsdev | grep Processor | wc -l`"
echo " "
echo "       Memory :- `lsattr -El mem0 | tail -1`"
echo "**************************************************************************************"
echo " "
echo " "
echo "====================================="
echo ">>>>> Important Kernel Params.  <<<<<"
echo "====================================="
echo " "
echo "****************************************"
echo " "
ulimit -a
echo " "
echo "****************************************"
echo " "
echo " "
echo "====================================="
echo ">>>>>   CPU Usage Information   <<<<<"
echo "====================================="
echo " "
vmstat -w 3 3 | tail -1 | awk '{print "CPU Used :- "($14+$15)"%"}'
echo " "
echo " "
echo "====================================="
echo ">>>>> Memory Usage Information  <<<<<"
echo "====================================="
um=`svmon -G | head -2|tail -1| awk {'print $3'}`
um=`expr $um / 256`
tm=`lsattr -El sys0 -a realmem | awk {'print $2'}`
tm=`expr $tm / 1024`
fm=`expr $tm - $um`
ump=`expr $um \* 100`
ump=`expr $ump / $tm`
echo " "
echo "Memory Used :- "$ump"%"
echo " "
echo "----------------------";
echo "Memory Information\n";
echo "total memory = $tm MB"
echo "free memory = $fm MB"
echo "used memory = $um MB"
echo "-----------------------\n";
echo " "
echo " "
echo "====================================="
echo ">>>>>   Page file usage info.   <<<<<"
echo "====================================="
echo " "
lsps -s
echo " "
echo " "
echo "====================================="
echo ">>>>>No. of processes on SERVER <<<<<"
echo "====================================="
echo " "
echo "Total processes on server :- `ps -ef | wc -l`"
echo " "
echo " "
for i in `ps -ef -o args | grep pmon | grep -v grep | cut -d_ -f3`
do
 echo "Processes for $i :- `ps -ef | grep $i | grep -v grep | wc -l`"
done
echo " "
echo " "
echo "====================================="
echo ">>>>>  Oldest oracle processes  <<<<<"
echo "====================================="
echo " "
echo " Should ideally be DBWR, PMON "
ps -A -o user,pid,etime,group,args | grep " oracle" | grep "-" | sort -rn +2 | head -20
echo " "
echo " "
echo "====================================="
echo ">>>>> Top 10 root processes  <<<<<"
echo "====================================="
echo " "
ps -ef | grep 'root' | sort -rn +2 | head -10
echo " "
echo " "
echo "====================================="
echo ">>>>> Top 10 oracle processes  <<<<<"
echo "====================================="
echo " "
ps -ef | grep 'oracle' | sort -rn +2 | head -10
echo " "
echo " "
echo "====================================="
echo ">>>>>     <defunct> processes   <<<<<"
echo "====================================="
echo " "
ps -el | grep 'Z'
echo " "
echo " "
echo "====================================="
echo ">>>>> Top CPU, Memory, IO pro.  <<<<<"
echo "====================================="
echo " "
echo "Top 10 CPU processes"
echo " "
ps auxgw |head -1; ps auxgw |sort -rn +2 | head -10
echo " "
echo " "
echo "Top 10 MEMORY processes"
echo " "
ps aux | head -1; ps aux | sort -rn +4 | head -10
echo " "
echo " "
echo "Top 10 DISKS by I/O"
echo " "
iostat | head -7; iostat | sed "1d;2d;3d;4d;5d;6d;7d;\$d" | sort -rn +1 | head -10
echo " "
echo " "
echo "====================================="
echo ">>>>>  Mount Point Information  <<<<<"
echo "====================================="
echo " "
df -g | head -1 | awk '{printf("%-38s %-9s %-9s %-7s %-7s %-4s\n",$1,$2,$4,$5,$7,$8)}' ; df -g | sed "1d;\$d" | sort -rn +3 | awk '{printf("%-38s %-9s %-9s %-7s %-7s %-4s\n",$1,$2,$3,$4,$6,$7)}'
echo " "
echo " "
echo "====================================="
echo ">>>>>     Network statistics    <<<<<"
echo "====================================="
echo " "
netstat -rni | head -1 | awk '{printf("%-5s %-6s %-12s %-17s %-10s %-5s %-10s %-5s %-4s\n",$1,$2,$3,$4,$5,$6,$7,$8,$9)}' ; netstat -rni | sed "1d;\$d" | awk '{printf("%-5s %-6s %-12s %-17s %-10s %-5s %-10s %-5s %-4s\n",$1,$2,$3,$4,$5,$6,$7,$8,$9)}'
echo " "
echo " "
}

FILENAME="health-`hostname`-`date +%y%m%d`-`date +%H%M`.txt"
sysstat > $FILENAME

if [ "$EMAIL" != '' ] 
then
	STATUS=`which mail`
	if [ "$?" != 0 ] 
	then
		echo "The program 'mail' is currently not installed."
	else
		cat $FILENAME | mail -s "healthcheck-`hostname`-`date`" $EMAIL
	fi
fi
rm -f $FILENAME
