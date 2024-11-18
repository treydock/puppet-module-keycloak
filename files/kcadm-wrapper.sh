#!/bin/bash

# shellcheck source=/dev/null
. /opt/keycloak/conf/kcadm-wrapper.conf

EXPIRES=$(/usr/bin/sed  -n -r 's|.*"refreshExpiresAt" : ([0-9]*).*|\1|p' "$CONFIG" || echo "0")
NOW=$(/usr/bin/date +%s%3N)

if [ ! -f "$CONFIG" ] || [ "$EXPIRES" -lt "$NOW" ]; then
    ${KCADM} config credentials --config "$CONFIG" --server "$SERVER" --realm "$REALM" --user "$ADMIN_USER" --password "$PASSWORD"
fi

${KCADM} "$@" --config "$CONFIG"
