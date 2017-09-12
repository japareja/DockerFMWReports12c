#!/bin/bash
#
# Copyright (c) 2014-2015 Oracle and/or its affiliates. All rights reserved.
#

# If log.nm does not exists, container is starting for 1st time
# So it should start NM and also associate with AdminServer, as well Managed Server
# Otherwise, only start NM (container is being restarted)
if [ ! -f log.nm ]; then
    ADD_REPORTS=1
fi

# Actualiza el dominio con los componentes de Reports
if [ $ADD_REPORTS -eq 1 ]; then
	/u01/oracle/wlst /u01/oracle/crFRExtension.py && \
	mkdir -p /u01/oracle/user_projects/domains/$DOMAIN_NAME/servers/$REPORTS_MS_NAME/security && \
    echo "username=weblogic" > /u01/oracle/user_projects/domains/$DOMAIN_NAME/servers/$REPORTS_MS_NAME/security/boot.properties && \
    echo "password=$ADMIN_PASSWORD" >> /u01/oracle/user_projects/domains/$DOMAIN_NAME/servers/$REPORTS_MS_NAME/security/boot.properties
fi

# startWeblogic
startWebLogic.sh

#!/bin/bash
#



