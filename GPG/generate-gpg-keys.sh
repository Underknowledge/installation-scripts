#!/usr/bin/env bash
function information { echo -e "\033[1;34m[Info]\033[0m $*"; }
function warning  { echo -e "\033[0;33m[Warning]\033[0m $* "; }
function error { echo -e "\033[0;31m[Error]\033[0m $*"; exit 1; }

# Create a GPG Key with subkeys and back them up properly.
# Best practice to create a GPG key is to create the key on a live CD like Tails or Fedora. 
# Do not reimport the Master key, Rather use only the sub keys. 
# Ment to be used with a nitro or yubikey

# Todo list: 
# - Sub-key expire to a variable
# - move keys to yubikey 
# - Provide help for SSH authentfication via GPG


# Following lines should be put in a file and be sourced
sc_puk='123456789012' # Smartcard admin PIN/PUK.
sc_pin='WhateverAPinIsMentToBe' # Smartcard user PIN.
key_passphrase='Whenever_1_try2SetAPassISomeHowCreateVeryStrangeOnes:P' # GPG secret key passphrase.
key_realname='underknowledge'
key_email='postmaster@underknowledge.cc'
key_comment='This is an test key'


GNUPGHOME="$(pwd)/$( echo ${key_realname} | tr -cd '[:alnum:]._-')"
mkdir -p  "$GNUPGHOME"/logs

information "Exports to $GNUPGHOME"

master () {
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


master_old () {
 information "Create MASTER key"
 # gpg --default-new-key-algo rsa4096 --gen-key ?https://docs.github.com/en/enterprise-server@3.1/authentication/managing-commit-signature-verification/generating-a-new-gpg-key
(   tee "$GNUPGHOME/logs/create-master-key.txt" \
    | grep -v -e '^#' \
    | tee "$GNUPGHOME/logs/create-master-key.stripped.txt" | tee /dev/tty \
    | gpg --command-fd=/dev/stdin --status-fd=/dev/stdout \
    --pinentry-mode=loopback --passphrase="$key_passphrase" \
    --expert --full-generate-key 
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
gpg --command-fd=/dev/stdin --status-fd=/dev/stdout \
    --pinentry-mode=loopback  --passphrase="$key_passphrase" \
    --armor \
    --export-secret-subkeys --export-options export-backup "${KEYID}" > "$GNUPGHOME"/sub-secret-keys.gpg
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


full () {
    master
    sub_auth
    sub_sign
    sub_encrypt
    revoke
    export_keys
}


export_keys () {
    export_master_secret
    export_subkey_secret
    export_ownertrust
}


import_keys () {
  import_master_secret
  import_sub_secret
}


$1

gpg --keyid-format LONG --list-keys

## See:
##> https://www.gnupg.org/documentation/manuals/gnupg/Unattended-GPG-key-generation.html#Unattended-GPG-key-generation
