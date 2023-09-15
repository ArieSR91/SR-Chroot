do_configure()
{
    COMPONENT_DIR="$HOME/SR-Chroot"
    # set min uid and gid
    local login_defs
    login_defs="${LINUXPATH}/etc/login.defs"
    if [ ! -e "${login_defs}" ]; then
        touch "${login_defs}"
    fi
    if ! $(grep -q '^ *UID_MIN' "${login_defs}"); then
        echo "UID_MIN 5000" >>"${login_defs}"
        sed -i 's|^[#]\?UID_MIN.*|UID_MIN 5000|' "${login_defs}"
    fi
    if ! $(grep -q '^ *GID_MIN' "${login_defs}"); then
        echo "GID_MIN 5000" >>"${login_defs}"
        sed -i 's|^[#]\?GID_MIN.*|GID_MIN 5000|' "${login_defs}"
    fi
    # add android groups
    if [ -n "${PRIVILEGED_USERS}" ]; then
        local aid
        for aid in $(cat "${COMPONENT_DIR}/android_groups")
        do
            local xname=$(echo ${aid} | awk -F: '{print $1}')
            local xid=$(echo ${aid} | awk -F: '{print $2}')
            sed -i "s|^${xname}:.*|${xname}:x:${xid}:|" "${LINUXPATH}/etc/group"
            if ! $(grep -q "^${xname}:" "${LINUXPATH}/etc/group"); then
                echo "${xname}:x:${xid}:" >> "${LINUXPATH}/etc/group"
            fi
            if ! $(grep -q "^${xname}:" "${LINUXPATH}/etc/passwd"); then
                echo "${xname}:x:${xid}:${xid}::/:/bin/false" >> "${LINUXPATH}/etc/passwd"
            fi
        done
        local usr
        for usr in ${PRIVILEGED_USERS}
        do
            local uid=${usr%%:*}
            local gid=${usr##*:}
            sed -i "s|^\(${gid}:.*:[^:]+\)$|\1,${uid}|" "${LINUXPATH}/etc/group"
            sed -i "s|^\(${gid}:.*:\)$|\1${uid}|" "${LINUXPATH}/etc/group"
        done
    fi
    return 0
}
do_configure
