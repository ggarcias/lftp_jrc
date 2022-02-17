#!/bin/bash

# SCRIPT TO COPY FILES FROM HPC TO EOS WITH LFTP
# checks if the file esists remotely and if it has the same size as the local one.
# all this is done explicitely because the mirror command of lftp does not work
# sample call:
#  ./ftpPutFls.sh 'mydir/myfilepattern*' destination-dir


while [ $# -gt 0 ] ; do
    case $1 in
        -s | --src) srcflpattern=$2;;
    esac
    shift
done


if [ -z "${srcflpattern+xxx}" ]
then
    echo "Error! Undefined filename pattern."
    echo "Example: schout*nc"
    exit -1
fi


echo 'copying files '$srcflpattern

ftpportal=jeodpp.jrc.ec.europa.eu
lftp=/home/garcgui/anaconda3/bin/lftp

rm -rf ./exist.out ./size.out ./kk*

getRemoteExists (){
  filePath=$1
$lftp -u $CREDENTIALS $ftpportal << EOF
set ftp:ssl-auth TLS
set ftp:ssl-force yes
set ssl:verify-certificate no
set ssl-allow true
cd input-ftp/garcgui/schism_wwm_global
du $filePath > ./exist.out
bye
EOF 
EOF
  if [ -f exist.out ];
  then
    echo 'True'
    rm exist.out
  else
    echo 'False'
  fi
}


getRemoteSize (){
  filePath=$1
$lftp -u $CREDENTIALS $ftpportal << EOF
set ftp:ssl-auth TLS
set ftp:ssl-force yes
set ssl:verify-certificate no
set ssl-allow true
cd input-ftp/garcgui/schism_wwm_global
ls > kk
du $filePath > ./size.out
bye
EOF 
EOF
  size=$(cat size.out | awk '{print $1}')
  echo $size
  rm ./size.out
}


getLocalSize (){
  filePath=$1
  size=$(du $filePath | awk '{print $1}')
  echo $size
}


copyFile (){
srcflpath=$1
$lftp -u $CREDENTIALS $ftpportal << EOF
set ftp:ssl-auth TLS
set ftp:ssl-force yes
set ssl:verify-certificate no
set ssl-allow true
cd input-ftp/garcgui/schism_wwm_global
put $srcflpath
bye
EOF
}

for fl in $srcflpattern/schout*nc
do
  echo 'copying file '$fl
  remoteExist=$(getRemoteExists $fl)
  copyFile=False

  if [ $remoteExist == True ]
  then
    echo '  remote file exists. Checking if it needs to be replaced ...'
    sizeRemote=$(getRemoteSize $fl)
    sizeLocal=$(getLocalSize $fl)
    #if [ $sizeRemote != $sizeLocal ]
    if [ $sizeRemote -lt 1000 ]
    then
      echo '    ... the remote size is different from the local one ...'
      copyFile=True
    fi
  else
    echo '  remote file does not exist.'
    copyFile=True 
  fi
  if [ $copyFile == True ]
  then
    echo '    copying the file ...'
    copyFile $fl
  else
    echo '    skipping the file ...'
  fi
done

