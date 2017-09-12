# Copyright (c) 2014-2016 Oracle and/or its affiliates. All rights reserved.
#
# Script to create and add NodeManager automatically to the domain's AdminServer running on '$ADMIN_HOST'.
#
# Since: October, 2014
# Author: bruno.borges@oracle.com
#
# =============================
import os
import socket

execfile('/u01/oracle/commonfuncs.py')

# NodeManager details
nmhost = os.environ.get('NM_HOST', socket.gethostbyname(hostname))
nmport = os.environ.get('NM_PORT', '5556')

# Connect to the AdminServer
# ==========================
connectToAdmin()

# Create a Machine
# ================
editMode()

createReportsToolsInstance(instanceName='RepTools1', machine='AdminServerMachine')
createReportsServerInstance(instanceName='RepServer1', machine='AdminServerMachine')

saveActivate()

# Exit
# ====
exit()
