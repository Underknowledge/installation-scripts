#!/usr/bin/env bash
function information { echo -e "\033[1;34m[Info]\033[0m $*"; }
function warning  { echo -e "\033[0;33m[Warning]\033[0m $* "; }
function error { echo -e "\033[0;31m[Error]\033[0m $*"; exit 1; }
scriptname=`basename "$0"`

# Todo list: 
# - Sub-key expire to a variable
# - Provide help for SSH authentfication via GPG

# Create a GPG Key with subkeys and back them up properly.
# Best practice to create a GPG key is to create the key on a live CD like Tails or Fedora. 
# Do not reimport the Master key, Rather use only the sub keys. 
# Ment to be used with a nitro or yubikey


# Following lines should be put in a file and be sourced
sc_puk='123456789012' # Smartcard admin PIN/PUK.
sc_pin='WhateverAPinIsMentToBe' # Smartcard user PIN.
key_passphrase='Whenever_1_try2SetAPassISomeHowCreateVeryStrangeOnes:P' # GPG secret key passphrase.
key_realname='underknowledge'
key_email='postmaster@underknowledge.cc'
key_comment='This is an test key'
# needed for yk_pin
NEW_PIN="at least 6 chars"
RESET_PIN="probably 6 chars"
NEW_ADMIN_PIN="at least 8 chars"

GNUPGHOME="$(pwd)/$( echo ${key_realname} | tr -cd '[:alnum:]._-')"
mkdir -p  "$GNUPGHOME"/logs

information "Exports to $GNUPGHOME"



help () {
cat << EOF
Usage: ./GPG/generate-gpg-keys.sh [full, export_keys import_keys help]
At the end of the script is a $1 (Argument 1) you can easyly call every function with this. 
by default this script will create a folder with the name 

  Create a GPG Key with subkeys and back them up properly.
  Best practice to create a GPG key is to create the key on a live CD like Tails or Fedora. 
  Do not reimport the Master key, Rather use only the sub keys. 
  Ment to be used with a nitro or yubikey 

General options:

  full:
    gpg: 
     - From below, Create and export keys
    keytocard:
      - Copy the Keys to the yubikey 
    yk_pin:
      - Change the pins

  gpg_gen:
    gen_master:
      - Creates a Ultimate trust GPG key
    sub_auth:
      - Creates a Sub-key for authentification (e.g. ssh)
    sub_sign:
      - Creates a Sub-key for singing
    sub_encrypt:
      - Creates a Sub-key to en/de-crypt data
    revoke:
      - Creates a revocation Certificate in the case that the Master key is compromised 
    export_keys:
      - Exports Master and Sub-keys to a file
  
  export_keys
    export_master_secret:
      - Exports the Master key. This file is ment for a cold backup and should be only used for generating new sub-key or invalidating them 
    export_subkey_secret:
      - Exports the Subkeys. this keys are ment ment for daily use
    export_ownertrust: 
      - Freshly imported GPG keys do not carry the trust over. This will create a fingerprint and the coresponding trust
  
  import_keys
    import_master_secret:
      - imorts the master key
    import_sub_secret:
      - imorts the sub-key
  
  keytocard:
    - To be run after full, copy's subkeys to a yubikey

  yk_pin:
    - Change the default pins

EOF
}

gen_master () {
curl -sL https://raw.githubusercontent.com/drduh/config/master/gpg.conf -o $GNUPGHOME/gpg.conf
 information "Create master key"
 # gpg --default-new-key-algo rsa4096 --gen-key ?https://docs.github.com/en/enterprise-server@3.1/authentication/managing-commit-signature-verification/generating-a-new-gpg-key
(   gpg --command-fd=/dev/stdin --status-fd=/dev/stdout \
    --pinentry-mode=loopback --passphrase="$key_passphrase" \
    --expert --full-generate-key 2>&1 | tee -a "$GNUPGHOME"/logs/master_gen.txt
) <<EOF-create-master-key
# gpg>
## Custon RSA (8):
8
## Toggle/set key capabilities:
e
s
q
## How many bits long is key?
4096
## When does key expire?
0
y
## Key user details
$key_realname
$key_email
$key_comment
## Save and exit
save
EOF-create-master-key

gpg --list-keys | grep "$key_email" -B1 | head -n 1 | xargs > "$GNUPGHOME"/KEYID.txt
KEYID="$(cat "$GNUPGHOME"/KEYID.txt)"

}

source_keyid () {
  KEYIDFILE="$GNUPGHOME/KEYID.txt"

  if [ -f "$KEYIDFILE" ]
  then
    KEYID="$(cat $GNUPGHOME/KEYID.txt)"
  else
    # This way we can define KEYID before 
    warning "No KeyID File"
    if [ -z "$KEYID" ]; then
    error "Can not proceed. There is no Key ID defined. Please set the var KEYID";
    fi
  fi 
}

revoke () {
  source_keyid
  warning "START REVOKE"
gpg --command-fd=/dev/stdin --status-fd=/dev/stdout \
    --pinentry-mode=loopback --passphrase="$key_passphrase" \
    --output "$GNUPGHOME"/revocation.crt --gen-revoke "${KEYID}" 2>&1 | tee -a "$GNUPGHOME"/logs/revoce.txt <<EOF-create-revocation-crt
y
1
Pre-created revocation certificate during master key generation. Will be used if the master key has been compromised..

y

EOF-create-revocation-crt
warning "END REVOKE"
}

sub_auth () {
  information "Create subkey: auth"
  source_keyid
(   gpg --command-fd=/dev/stdin --status-fd=/dev/stdout \
    --pinentry-mode=loopback --passphrase="$key_passphrase" \
    --expert --key-edit "$KEYID" 2>&1 | tee -a "$GNUPGHOME"/logs/sub_auth_gen.txt
) <<EOF-create-subkey-auth
# gpg>
addkey
# Please select what kind of key you want:
#    (8) RSA (set your own capabilities)
8
# Possible actions for a RSA key: Sign Encrypt Authenticate 
# Current allowed actions: Sign Encrypt 
#    (S) Toggle the sign capability
#    (E) Toggle the encrypt capability
#    (A) Toggle the authenticate capability
#    (Q) Finished
s
e
a
q
# RSA keys may be between 1024 and 4096 bits long.
# What keysize do you want? (3072)
4096
# Key is valid for? (0)
0
# Key does not expire at all
## Save and exit
save
EOF-create-subkey-auth
  information "create-subkey-auth end"
}




sub_sign () {
  information "Create subkey: sign"
  source_keyid
(   gpg --command-fd=/dev/stdin --status-fd=/dev/stdout \
    --pinentry-mode=loopback --passphrase="$key_passphrase" \
    --expert --key-edit "$KEYID" 2>&1 | tee -a "$GNUPGHOME"/logs/sub_sign_gen.txt
) <<EOF-create-subkey-sign
# gpg>
addkey
# Please select what kind of key you want:
#    (8) RSA (set your own capabilities)
8
# Possible actions for a RSA key: Sign Encrypt Authenticate 
# Current allowed actions: Sign Encrypt 
#    (S) Toggle the sign capability
#    (E) Toggle the encrypt capability
#    (A) Toggle the authenticate capability
#    (Q) Finished
e
q
# RSA keys may be between 1024 and 4096 bits long.
# What keysize do you want? (3072)
4096
# Key is valid for? (0)
0
# Key does not expire at all
## Save and exit
save
EOF-create-subkey-sign
  information "create-subkey-sign END"
}



sub_encrypt () {
  information "Create subkey: encrypt"
  source_keyid
(   gpg --command-fd=/dev/stdin --status-fd=/dev/stdout \
    --pinentry-mode=loopback  --passphrase="$key_passphrase" \
    --expert --key-edit "$KEYID" 2>&1 | tee -a "$GNUPGHOME"/logs/sub_encrypt_gen.txt
) <<EOF-create-subkey-encrypt
# gpg>
addkey
# Please select what kind of key you want:
#    (8) RSA (set your own capabilities)
8
# Possible actions for a RSA key: Sign Encrypt Authenticate 
# Current allowed actions: Sign Encrypt 
#    (S) Toggle the sign capability
#    (E) Toggle the encrypt capability
#    (A) Toggle the authenticate capability
#    (Q) Finished
s
q
# RSA keys may be between 1024 and 4096 bits long.
# What keysize do you want? (3072)
4096
# Key is valid for? (0)
0
# Key does not expire at all
## Save and exit
save
EOF-create-subkey-encrypt
  information "create-subkey-encrypt END"
}


export_master_secret () {
gpg --command-fd=/dev/stdin --status-fd=/dev/stdout \
    --pinentry-mode=loopback  --passphrase="$key_passphrase" \
    --armor \
    --export-secret-keys --export-options export-backup "${KEYID}" > "$GNUPGHOME"/master-secret-key.gpg 
}

    
export_subkey_secret () {
  warning "only stub? whatever stub means"
gpg --command-fd=/dev/stdin --status-fd=/dev/stdout \
    --pinentry-mode=loopback  --passphrase="$key_passphrase" \
    --armor \
    --export-secret-subkeys --export-options export-backup "${KEYID}" > "$GNUPGHOME"/sub-secret-keys.gpg
}

export_public () {
  # gpg --command-fd=/dev/stdin --status-fd=/dev/stdout \
  #     --pinentry-mode=loopback  --passphrase="$key_passphrase" \
  #     --armor \
  #     --export "${KEYID}" > "$GNUPGHOME"/pubkey.txt
  gpg --output public.pgp --armor --export "${KEYID}" 
  gpg --export-ssh-key "${KEYID}" > "$GNUPGHOME"/ssh-key_${key_realname}.pub
}

export_ownertrust () {
  gpg --export-ownertrust > "$GNUPGHOME"/trustlevel.txt
}

import_ownertrust () {
  gpg --import-ownertrust < "$GNUPGHOME"/trustlevel.txt
}



import_master_secret () {
  gpg --batch --command-fd=/dev/stdin --status-fd=/dev/stdout \
  --pinentry-mode=loopback --passphrase="$key_passphrase" \
  --import "$GNUPGHOME"/master-secret-key.gpg

  import_ownertrust
}


import_sub_secret () {   
  gpg --batch --command-fd=/dev/stdin --status-fd=/dev/stdout \
  --pinentry-mode=loopback --passphrase="$key_passphrase" \
  --import "$GNUPGHOME"/sub-secret-keys.gpg

  import_ownertrust
}




GPG_DELETE () {
  gpg --list-keys
  CURRENT_KEYS=$(gpg --list-secret-keys --with-colons | awk -F: '/fpr/ { print $10 }')
  for id in $CURRENT_KEYS
  do
    gpg --delete-secret-key $id 
    gpg --delete-key $id 
  done
}

keytocard () {
  # DEPENDENCYS 
  # yubikey-manager xdotool
  information "Key to Card"
  source_keyid
  warning "This is utterly ugly hacked together, if you have a better idea.... Please! "
  warning "It is completly possible that this only works with GnuPG 2.3.4 on Fedora 35 and a youbikey 5 series"
  information "Please open a new, empty shell window"
  information "the application xdotool will send over keystrokes, to get the sub-keys to the yubikey"
  information ""
  information "When you press enter, we wait 5 secconds, and then start the procedure"
  warning ""
  warning "WE WILL RESET OpenGPG ON THE YUBIKEY! DO NOT PROCEED WHEN YOU DONT WANT THIS"
  warning ""


  SORT=($(gpg --keyid-format LONG --list-keys ${KEYID} | grep -oe '\[.\]' | grep -o '[[:alpha:]]'))
  for i in ${!SORT[@]}; do
    case ${SORT[$i]} in
      A )
          echo "Found Aut: $i"
          aut_key_num=$i
      ;;
      S )
          echo "Found Sig: $i"
          sig_key_num=$i
      ;;
      E )
          echo "Found Enc: $i"
          enc_key_num=$i
      ;;
    esac
  done
  [ -n "$aut_key_num" ] || error "Authentication key not found"
  [ -n "$sig_key_num" ] || error "Signing key not found"
  [ -n "$enc_key_num" ] || error "Encryption key not found"
  echo "S:${sig_key_num}, E:${enc_key_num}, A:${aut_key_num}"

  read -n 1 -r -s -p $'Press enter to continue...\n'

  secs=5
  while [ $secs -gt 0 ]
  do
    printf "\r\033[KWaiting %.d seconds $msg" $((secs--))
    sleep 1
  done
  echo

    yk_reset
    yk_keytocard
} 


yk_reset () {
  warning "deleting all GPG keys From the yubikey"
  ykman openpgp reset -f
}

yk_pin () {
  # Wait
  secs=5
  while [ $secs -gt 0 ]
  do
    printf "\r\033[KWaiting %.d seconds $msg" $((secs--))
    sleep 1
  done
  echo

  xdotool sleep 1 type "gpg --change-pin"
  xdotool sleep 1 key KP_Enter

    information "set the Reset Code"
  xdotool sleep 1 type "4" 
  xdotool sleep 1 key KP_Enter
  
    information "provide admin pin" 
  xdotool sleep 2 type "12345678"
  xdotool sleep 2 key KP_Enter

    information "provide new RESET_PIN 1" 
  xdotool sleep 2 type "$RESET_PIN"
  xdotool sleep 2 key KP_Enter
    information "provide new RESET_PIN 2" 
  xdotool sleep 4 type "$RESET_PIN"
  xdotool sleep 2 key KP_Enter



    information "change PIN" 
  xdotool sleep 2 key 1
  xdotool sleep 2 key KP_Enter

  xdotool sleep 2 type "123456"
  xdotool sleep 2 key KP_Enter
    information "provide new NEW_PIN 1" 
  xdotool sleep 2 type "$NEW_PIN"
  xdotool sleep 2 key KP_Enter
    information "provide new NEW_PIN 2" 
  xdotool sleep 2 type "$NEW_PIN"
  xdotool sleep 2 key KP_Enter


    information "change Admin PIN" 
  xdotool sleep 2 key 3
  xdotool sleep 2 key KP_Enter

  xdotool sleep 2 type "12345678"
  xdotool sleep 2 key KP_Enter
    information "provide new NEW_ADMIN_PIN 1" 
  xdotool sleep 2 type "$NEW_ADMIN_PIN"
  xdotool sleep 2 key KP_Enter
    information "provide new NEW_ADMIN_PIN 2" 
  xdotool sleep 2 type "$NEW_ADMIN_PIN"
  xdotool sleep 2 key KP_Enter

    information "quit" 
  xdotool sleep 2 type "q"
  xdotool sleep 2 key KP_Enter
}

yk_keytocard () {
  [ -n "$aut_key_num" ] || error "Authentication key not found"
  [ -n "$sig_key_num" ] || error "Signing key not found"
  [ -n "$enc_key_num" ] || error "Encryption key not found"

  xdotool sleep 1 type  "gpg --expert --key-edit \"$KEYID\" "
  xdotool sleep 1 key KP_Enter

# S slot 1
    information "S mark Sig key ${sig_key_num} "
  xdotool sleep 1 type "key ${sig_key_num}" 
  xdotool sleep 0 key KP_Enter
  xdotool sleep 1 type "keytocard"
  xdotool sleep 0 key KP_Enter

    information "S choose slot"
  xdotool sleep 1 key 1
  xdotool sleep 1 key KP_Enter

    information "S Heads up passphrase"
  xdotool sleep 3 type "$key_passphrase"
  xdotool sleep 5 key KP_Enter

    information "S provide admin pin" # bug??
  xdotool sleep 3 key 1
  xdotool sleep 3 type "2345678"
  xdotool sleep 5 key KP_Enter
  ## TODO 
    information "S provide admin pin the seccond time?.... must be a bug due to 100 tryes"
  xdotool sleep 3 key 1
  xdotool sleep 3 type "2345678"
  xdotool sleep 5 key KP_Enter

    information "S un-mark Sig key "
  xdotool sleep 1 type "key ${sig_key_num}"
  xdotool sleep 1 key KP_Enter
# E slot 2
    information "E mark Enc key "
  xdotool sleep 2 type "key ${enc_key_num}" 
  xdotool sleep 1 key KP_Enter

  xdotool sleep 1 type "keytocard"
  xdotool sleep 1 key KP_Enter

    information "E choose slot"
  xdotool sleep 1 key 2
  xdotool sleep 1 key KP_Enter

    information "E Heads up passphrase"
  xdotool sleep 3 type "$key_passphrase"
  xdotool sleep 5 key KP_Enter

    information "E provide admin pin"
  xdotool sleep 3 type "12345678"
  xdotool sleep 5 key KP_Enter

    information "E un-mark Enc key "
  xdotool sleep 2 type "key ${enc_key_num}" 
  xdotool sleep 2 key KP_Enter
# A slot 3 
    information "A mark Aut key"
  xdotool sleep 1 type "key ${aut_key_num}" 
  xdotool sleep 1 key KP_Enter

  xdotool sleep 1 type "keytocard"
  xdotool sleep 1 key KP_Enter

    information "A choose slot"
  xdotool sleep 1 key 3
  xdotool sleep 1 key KP_Enter

    information "A Heads up passphrase"
  xdotool sleep 3 type "$key_passphrase"
  xdotool sleep 5 key KP_Enter

    information "A provide admin pin"
  xdotool sleep 3 type "12345678"
  xdotool sleep 5 key KP_Enter
    information "A un-mark Aut key"
  xdotool sleep 1 type "key ${aut_key_num}" 
  xdotool sleep 1 key KP_Enter


    information "END"
  xdotool sleep 1 type "quit" 
  xdotool sleep 1 key KP_Enter
  
    information "Save changes? >N<"
  xdotool sleep 1 type "N" 
  xdotool sleep 1 key KP_Enter


    information "Quit without saving? >y<"
  xdotool sleep 1 type "y" 
  xdotool sleep 1 key KP_Enter

  gpg --card-status

  information "when you want to add additional keys, plug one in and run >$scriptname yk_keytocard< "
}





full () {
  gpg_gen
  keytocard
  yk_pin
}


gpg_gen () {
    gen_master
    sub_auth
    sub_sign
    sub_encrypt
    revoke
    export_keys
}


export_keys () {
    export_master_secret
    export_subkey_secret
    export_public
    export_ownertrust
}


import_keys () {
  import_master_secret
  import_sub_secret
  import_public
}

import_public () {
  gpg --batch --command-fd=/dev/stdin --status-fd=/dev/stdout \
  --pinentry-mode=loopback \
  --import "$GNUPGHOME"/pubkey.txt
}


import_public_keys () {
  import_public
  import_ownertrust
}



$1


information "when the master key has '#' at the end ('sec#') means that the private key is not present."
gpg --keyid-format LONG --list-keys

## See:
##> https://www.gnupg.org/documentation/manuals/gnupg/Unattended-GPG-key-generation.html#Unattended-GPG-key-generation
