#!/bin/bash


# we need a list of keys to export, so we start by getting that
keylist=$(gpg --with-colons --list-secret-keys $1)

# we need a place to store working files
mkdir -p "keytemp"

# this takes a set of information, and calls latex to generate the page
generate_key_pdf() {
  echo "running latex for key $1, type $2key, usage $3, primary $4, primary key FPR $5"
  
  conffile=keytemp/$1-config.tex
  keyfile=keytemp/$1-key
  
  # turn the 'seca' representation of usage into full text
  usage=""
  if [[ $3 == *e* ]]; then
    usage=$usage"encryption, "
  fi
  if [[ $3 == *s* ]]; then
    usage=$usage"signing, "
  fi
  if [[ $3 == *a* ]]; then
    usage=$usage"authorization, "
  fi
  
  # remove trailing ','
  usage="${usage:0:${#usage}-2}"
    
  # replace last comma with 'and'
  if [[ $usage == *,* ]]; then
    usage=${usage%,*}" and"${usage##*,}
  fi

  # create a file to define variables for latex
  touch $conffile
  echo "\def \keyid {$1}" >> $conffile
  echo "\def \keytype {$2key}" >> $conffile
  echo "\def \keyusage {$usage}" >> $conffile
  echo "\def \primarykey {$4}" >> $conffile
  echo "\def \keyfingerprint {$5}" >> $conffile
  
  # export the key we're interested in once, since we'll ask for a password every time we use it
  # the '!' is needed to export just the key we want, not primary keys as well.
  if [ "$2" == "primary " ]; then
    gpg --export-secret-keys $1! > $keyfile
  else
    gpg --output $keyfile --export-secret-subkeys $1\!
  fi
  
  # generate paperkey text
  cat $keyfile | paperkey > keytemp/$1-paperkey.txt

  # generate paperkey QR code
  cat $keyfile | paperkey --output-type raw | xxd -p | tr -d '\n' | qrencode -i --level=M -o keytemp/$1-qr.png
  
  # generate public key ID QR code
  echo -n "openpgp4fpr:$5" | qrencode -i --level=M -o keytemp/$1-qrfpr.png
  
  ln -s $1-config.tex keytemp/config.tex
  
  # call pdflatex
  pdflatex  -jobname=$1 -interaction=batchmode -shell-escape  secretkeybackup.tex
  ret=$?
  if [[ $ret != 0 ]]; then
    echo "Error generating $1.pdf. Check $1.log for Latex errors."
  fi
  
  rm keytemp/config.tex
  
  rm keytemp/$1*
  
}


IFS=$'\n'

for keyline in $keylist; do
#   echo keyline: $keyline
  IFS=':' read -r -a linesplit <<< "$keyline"
  if [ "${linesplit[0]}" == "sec" ]; then
    saved_key=0x${linesplit[4]}
    saved_type="primary "
    saved_usage=${linesplit[11]}
    saved_primary=$1
    unset saved_fpr
    
  fi
  if [ "${linesplit[0]}" == "ssb" ]; then
#     generate_key_pdf 0x${linesplit[4]}  "sub" ${linesplit[11]} $1
    saved_key=0x${linesplit[4]}
    saved_type="sub"
    saved_usage=${linesplit[11]}
    saved_primary=$1
  
  fi
  
  #save the long fingerprint, but only the first time through since we saw a 'sec', thus getting the private key's fingerprint
  if [ "${linesplit[0]}" == "fpr" ]; then
    #we wait until we get here, as we need the fingerprint for the key
    if [ -z ${saved_fpr+x} ]; then 
      saved_fpr=${linesplit[9]}
    fi
    
    generate_key_pdf "$saved_key" "$saved_type" "$saved_usage" "$saved_primary" "$saved_fpr"

  fi
  unset IFS
done

rm -rf *.aux
#rm -rf *.log
rm -rf keytemp
