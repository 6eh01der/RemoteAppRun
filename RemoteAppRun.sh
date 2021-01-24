#!/bin/bash
passphrase=Encryption_Password
IFS=' ' read -ra CfgArr < <( gpg -d --batch --passphrase $passphrase ~/.userdata.gpg)
initial_login_data=${CfgArr[0]}
initial_passwd_data=${CfgArr[1]}
initial_domain_data=${CfgArr[2]}
userdata=$(yad --form --center --auto-kill --buttons-layout=center --title="RemoteApp" --field=Login --field=Password:H --field=Domain "$initial_login_data" "$initial_passwd_data" "$initial_domain_data")
userlogin=$(echo "$userdata"|cut -d '|' -f 1);
userpasswd=$(echo "$userdata"|cut -d '|' -f 2);
domainname=$(echo "$userdata"|cut -d '|' -f 3);
IFS='|' read -r -a YadArr <<<"$userdata"
for i in "${!YadArr[@]}"; do
    if [[ ${YadArr[i]} != "" ]]; then CfgArr[i]=${YadArr[i]} ; fi
done
xfreerdp /u:"$userlogin" /p:"$userpasswd" /d:"$domainname" /cert-tofu /app:"||REMOTEAPP_NAME" +home-drive /printer /disp /clipboard /fonts /aero /window-drag /menu-anims /gdi:hw /rfx /nsc /jpeg /jpeg-quality:100 /codec-cache:rfx /g:RDGW_FQDN /gt:auto /load-balance-info:tsv:"//MS Terminal Services Plugin.1.COLLECTION_NAME" /v:RDCB_FQDN
errorcode=$?
if [ $errorcode != 11 ]; then
yad --form --auto-kill --center --text-align=center --text="Exit code $errorcode" --title="RemoteApp" --width=200 --button=gtk-ok:1
else
echo "${CfgArr[@]}" | gpg -c --batch --yes --passphrase $passphrase -o ~/.userdata.gpg
fi
exit
