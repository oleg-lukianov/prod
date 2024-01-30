# prod

## Script backup_android_lftp_rsync.sh
Script for backup smartphones files to **SFTP** server or **RSYNC** daemon  
```bash ./backup_android_lftp_rsync.sh -lftp```  
```bash ./backup_android_lftp_rsync.sh -rsync```  

## Get started
1. Run Termux app on smartphone  
https://wiki.termux.com/wiki/Main_Page  
1. Install dependency packages  
```pkg install -y lftp rsync curl sshpass base64```
1. Create dir  
```mkdir /storage/emulated/0/github```  
1. Go to this path  
```cd /storage/emulated/0/github```  
1. Cloning repo  
```git clone https://github.com/oleg-lukianov/prod.git```  
1. Copy config file from example  
```cp prod/backup_android_lftp_rsync.conf.example prod/backup_android_lftp_rsync.conf```  
1. Change config  
```vi prod/backup_android_lftp_rsync.conf```  
1. Leave the required config (**SFTP** or **RSYNC** credentials)  
1. And run script  
```bash ./backup_android_lftp_rsync.sh -lftp```  
or  
```bash ./backup_android_lftp_rsync.sh -rsync```  


## Test mode
Before first run script propose run in test mode  
In this mode doesn't delete files on the destination host  
Only wil create file with script name  
```bash ./backup_android_lftp_rsync.sh -rsync -test```  
or
```bash ./backup_android_lftp_rsync.sh -rsync -test```  


