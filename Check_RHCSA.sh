#!/bin/bash 
# Script to check sample RHCSA Practice exam (EX200)
# NOTE - This is not the official Red Hat Certified System Administrator Exam (EX200) Script.
# This script is written to improve students' effeciency in the sample RHCSA practice exam by
# Institute of Technical Education, Bhopal (M.P.)
#
#	Author		: Palash Chaturvedi
#	Date		: 25/05/2018

	correct_ques=0
	incorrect_ques=0

	echo "
=============================================================

       . . . Checking  rhcsa_last_sample . . .

=============================================================
" 

	interface=eth0
	system_ip=$( ifconfig $interface | grep broadcast | cut -d ' ' -f10 )
		echo " "		
		echo "IP address is $system_ip"
	hname=$( hostnamectl | grep -i  static | cut -d ' ' -f6 )
		echo " "		
		echo "Hostname is $hname"
	
echo " 
============================
Checking Ques 0 SELINUX.....
============================
"
	selinux=$(getenforce)
	echo " "
	echo "SELINUX Policy is $selinux"

	if [ $selinux == 'Enforcing' ]; then
		echo " "
		echo "Selinux policy is set correctly [ OK ]"
		correct_ques=$((correct_ques + 1))
	else 
		echo " "
		echo "ERROR!! Selinux policy is not set correctly "
		incorrect_ques=$((incorrect_ques + 1))
	fi


echo " 
===============================
Checking Ques 1 CREATE LVM.....
===============================	
"
	
	vgname='open'
	lvname='source'
	mntpoint=/mnt/secret

	if vgs $vgname  &> /dev/null;
	then
		pesize=$(vgdisplay $vgname | grep -i 'pe size' | awk '{ print $3;}')
		if [ "$pesize" != '8.00' ];
		then
			echo "
PE Size is not 8MB !!		[ Mistake ]
Current size : $pesize 
			" >> $result
		else
			if lvs /dev/$vgname/$lvname &> /dev/null
			then
				lecount=$(lvdisplay /dev/open/source  | grep -i 'Current le' | awk '{ print $3; }')
				if [ "$lecount" -eq 26 ];
				then

					if [ -d "$mntpoint" ];
					then
						dir=$( grep -i \/mnt\/secret /etc/fstab | awk '{ print $2;}' )
						if [ $dir == '/mnt/secret' ] && ( mount | grep -i \/mnt\/secret &> /dev/null );
						then
							if ( mount  | grep -i \/mnt\/secret | grep -i vfat  &> /dev/null );
							then	
								echo " "							
								echo "LVM is configured according to the question [ OK ]"
								correct_ques=$((correct_ques + 1))
							else
								echo " "
								echo "ERROR!! Filesystem is not vfat "	
								incorrect_ques=$((incorrect_ques + 1))					
							fi
						else
							echo " "
							echo "ERROR!! Check mount point settings "
							incorrect_ques=$((incorrect_ques + 1))
						fi
					else
						echo " "
						echo "ERROR!! $mntpoint directory not found "
						incorrect_ques=$((incorrect_ques + 1))
					fi
				else
					echo " "
					echo "ERROR!! LE Counts is not according to the requirement !! Current LE Counts :	$lecount"
					incorrect_ques=$((incorrect_ques + 1))
				fi
			
			else
				echo " "
				echo "ERROR!! LV not found !!	"
				incorrect_ques=$((incorrect_ques + 1))
				fi
		fi
	else
		echo " "
		echo "ERROR!! VG not found !!"
		incorrect_ques=$((incorrect_ques + 1))
	fi							



echo " 
=================================================
Checking Ques 2 USER'S GROUPS AND PERMISSION.....
=================================================	
"

	if grep -i sysadmin /etc/group &> /dev/null ;
	then
		if grep -i manager /etc/group &> /dev/null ;
		then

			manager_users=$(grep -i manager /etc/group | cut -d : -f4)
			user1=$( grep -i manager /etc/group | cut -d : -f4 | cut -d ',' -f1 )
			user2=$( grep -i manager /etc/group | cut -d : -f4 | cut -d ',' -f2 )
			if [ "$user1" == 'sarah' -o "$user1" == 'natasha' ] && [ "$user2" == 'natasha' -o "$user2" == 'sarah' ] ;
			then
				shell=$(grep -i harry /etc/passwd | cut -d ':' -f7)
				if [ "$shell" == '/bin/False' ] || [ "$shell" == '/sbin/nologin' ];
				then
					echo " "
					echo "Users sarah, natasha and harry are configured perfectly [ OK ]"
					correct_ques=$((correct_ques + 1))
				else
					echo " "
					echo "ERROR!! User harry does not have shell /sbin/nologin"
					incorrect_ques=$((incorrect_ques + 1))
				fi
			else
				echo " "
				echo "ERROR!! Secondary group of sarah and natasha are not configured properly"
				incorrect_ques=$((incorrect_ques + 1))
			fi
		else
			echo " "
			echo "ERROR!! manager group not found"
			incorrect_ques=$((incorrect_ques + 1))
		fi
	else
		echo " "
		echo "ERROR!! sysadmin user not found"
		incorrect_ques=$((incorrect_ques + 1))
	fi


echo " 
=================================================
Checking Ques 3 DIRECTORY COLLABORATION..........
=================================================	
"


	dir=/home/manager
	group=$( ls -ld /home/manager/ | awk '{ print $4; }' )
	group_perm=$(ls -ld /home/manager/ | cut -c 5-7)
	others=$(ls -ld /home/manager/ | cut -c 8-10)
	user=$(ls -ld /home/manager/ | awk '{ print $3; }')
	if [ -d "$dir" ];
	then
		if [ "$group" == "manager" ];
		then
			if [ "$group_perm" == 'rws' ];
			then
				if [ "$others" != 'rwx' ];
				then
					if [ "$user" == 'root' ];
					then
						echo " "
						echo "Collaborative Directory configured according to the question [ OK ]"
						correct_ques=$((correct_ques + 1))
					fi
				else
					echo " "
					echo "ERROR!! Others have write permission on $dir"
					incorrect_ques=$((incorrect_ques + 1))
				fi
			else
				echo " "
				echo "ERROR!! Check group permissions "
				incorrect_ques=$((incorrect_ques + 1))
			fi
		else
			echo " "
			echo "Check group ownership"
			incorrect_ques=$((incorrect_ques + 1))
		fi
	else
		echo " "
		echo "Directory not found"
		incorrect_ques=$((incorrect_ques + 1))
	fi

echo " 
===========================================
Checking Ques 4 UPDATE THE KERNEL..........
===========================================	
"

	kernel_vers=$( uname -r)

		if [ $kernel_vers == '3.10.0-123.el7.x86_64' ]; then
			echo " "
			echo "Current Kernel version is $kernel_vers | CORRECT [ OK ]"
			correct_ques=$((correct_ques + 1))
		else
			echo " "
			echo "ERROR!! Kernel not updated properly "
			incorrect_ques=$((incorrect_ques + 1))
		fi


echo " 
==================================
Checking Ques 5 CRON JOB..........
==================================	
"

	minutes=$(crontab -l -u sarah | tr [:blank:] '|' | cut -d '|' -f1)
	hours=$(crontab -l -u sarah | tr [:blank:] '|' | cut -d '|' -f2)
	command=$( crontab -l -u sarah | tr -s [:blank:] '|' | cut -d '|' -f 6- )
	
	if [ "$minutes" -eq "23" ] && [ "$hours" -eq "14" ] ;
	then	
		if [ $command == '/bin/echo|"hyer"' ];
		then
			user=$(cat /etc/cron.deny)
			if [ "$user" == 'max' ];
			then
				echo " "
				echo "Crontab perfectly configured [ OK ]"
				correct_ques=$((correct_ques + 1))
			else
				echo " "
				echo "ERROR!! Max user is able to set cronjob"
				incorrect_ques=$((incorrect_ques + 1))
			fi
		else
				echo " "
				echo "ERROR!! Command not correct"
				incorrect_ques=$((incorrect_ques + 1))
		fi
	else
		echo " "
		echo "ERROR!! Check time "
		incorrect_ques=$((incorrect_ques + 1))
	fi


echo " 
==================================
Checking Ques 6 RESIZE LVM........
==================================	
"

	upper_limit=120
	lower_limit=90
	current_size=$(df -h /home/ | tail -n1 | awk '{ print $2; }' | cut -d 'M' -f1)
	if [ "$current_size" -lt "$lower_limit" ] || [ "$present" -gt "$upper_limit" ];
	then
		echo " "
		echo "ERROR!! Your size of /home is not correct | Current size	: $current_size M"
		incorrect_ques=$((incorrect_ques + 1))
	else
		if ( mount | grep -i \/home | grep -i mapper &> /dev/null );
		then
			lvsize=$(lvdisplay $(mount | grep -i \/home | awk '{ print $1; }' ) | grep -i 'lv size' | cut -s -d '.' -f1 | awk '{ print $3; }')
			if [ "$lvsize" -lt 90 ] || [ "$lvsize" -gt 120 ];
			then
				echo " "
				echo "ERROR!! Check Your LV size "
				incorrect_ques=$((incorrect_ques + 1))
			else
				echo " "
				echo "LVM resized with no errors [ OK ]"
				correct_ques=$((correct_ques + 1))
			fi
		else
			echo " "
			echo "ERROR!! No lvm found which is mounted on /home"
			incorrect_ques=$((incorrect_ques + 1))
		fi
	fi

echo " 
=============================================================
Checking Ques 7 BIND THE LDAP FOR USER AUTHENTICATION........
=============================================================	
"
	
	if  su -l ldapuser1 -c pwd &> /dev/null;
	then
		echo " "
		echo "Ldap is working properly [ OK ]"
		correct_ques=$((correct_ques + 1))
	else
		echo " "
		echo "ERROR!! Ldap is not working "
		incorrect_ques=$((incorrect_ques + 1))
	fi

echo " 
==================================
Checking Ques 8 NTP CLIENT........
==================================
"


	if (  ntpstat  | grep synchronised &> /dev/null );
	then
		echo " "
		echo "NTP is Synchronised [ OK ]"
		correct_ques=$((correct_ques + 1))
	else
		echo " "
		echo "ERROR!! NTP is not Synchronised"
		incorrect_ques=$((incorrect_ques + 1))
	fi


echo " 
=================================================================
Checking Ques 9 AUTOMOUNT THE HOME DIRECTORY FOR LDAPUSER........
=================================================================
"

	if su -l ldapuser1 -c ls &> /dev/null;
	then
		if su -l ldapuser2 -c ls &> /dev/null;
		then
			if (  mount | grep ldapuser1  | grep -E 'nfsvers=4|vers=4' &> /dev/null );
			then
				echo " "
				echo "Automounting is working using NFS Version 4 [ OK ]"
				correct_ques=$((correct_ques + 1))
			else
				echo " "
				echo "ERROR!! Automount is not using NFS Version 4"
				incorrect_ques=$((incorrect_ques + 1))
			fi
		else
			echo " "
			echo "ERROR!! Automounting is not working properly"
			incorrect_ques=$((incorrect_ques + 1))
		fi
	else
		echo " "
		echo "ERROR!! Automounting is not working properly"
		incorrect_ques=$((incorrect_ques + 1))
	fi



echo " 
============================================
Checking Ques 10 ACCESS CONTROL LIST........
============================================
"

	file="/var/tmp/fstab"

	if [ -f "$file" ];
	then
		user=$(ls -l $file | awk '{ print $3;}')
		group=$(ls -l $file | awk '{ print $4;}')
		if [ "$user" == 'root' ] && [ "$group" == 'root' ];
		then
			perm=$(ls -l /var/tmp/fstab  | cut -c 10)
			if [ "$perm" != 'x' ];
			then
				perm=$(getfacl -p /var/tmp/fstab | grep sarah | cut -d : -f3 | cut -c -3 )
				if [ "$perm" == 'rw-' ];
				then
					perm=$(getfacl -p /var/tmp/fstab | grep natasha | cut -d : -f3 | cut -c -3 )
					if [ "$perm" == '---' ];
					then
						perm=$(getfacl -p /var/tmp/fstab | grep other| cut -d : -f3 | cut -c -3 )
						if [ "$perm" == 'r--' ];
						then
							if [ -d "/data" ];
							then
								touch /data/script
								group=$(ls -l /data/script | awk '{print $4;}')
								rm -rf /data/script
								if [ "$group" == 'ftp' ];
								then
									echo " "
									echo "ACL is correctly set and permissions of /data is also correct [ OK ]"
									correct_ques=$((correct_ques + 1))
								else
									echo " "
									echo "ERROR!! Check directory /data"
									incorrect_ques=$((incorrect_ques + 1))
								fi
							else
								echo " "
								echo "ERROR!! /data directory not found"
								incorrect_ques=$((incorrect_ques + 1))
							fi
						else
							echo " "
							echo "ERROR!! Check others permission"
							incorrect_ques=$((incorrect_ques + 1))
						fi
					else
						echo " "
						echo "ERROR!! Incorrect permission of natasha"
						incorrect_ques=$((incorrect_ques + 1))
					fi
				else
					echo " "
					echo "ERROR!! Incorrect permission of sarah"
					incorrect_ques=$((incorrect_ques + 1))
				fi
			else
				echo " "
				echo "ERROR!! Others can execute $file"
				incorrect_ques=$((incorrect_ques + 1))
			fi
		else
			echo " "
			echo "ERROR!! Check User and Group Ownership on $file"
			incorrect_ques=$((incorrect_ques + 1))
		fi
	else
		echo " "
		echo "ERROR!! File $file not found"
		incorrect_ques=$((incorrect_ques + 1))
	fi




echo " 
========================================
Checking Ques 13 CREATE USER dax........
========================================
"


	uid='4223'

	if [ $(grep dax /etc/passwd | cut -d ':' -f3 ) -eq "$uid" ];
	then
		echo " "
		echo "User dax have correct uid [ OK ]"
		correct_ques=$((correct_ques + 1))
	else
		echo " "
		echo "Error!! Check uid "
		incorrect_ques=$((incorrect_ques + 1))
	fi






