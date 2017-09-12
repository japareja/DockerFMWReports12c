#!/bin/sh
#
#
# frmconfighelper.sh
#
# Copyright (c) 2015, 2016, Oracle and/or its affiliates. All rights reserved.
#
#    NAME
#      frmconfighelper.sh
#
#    DESCRIPTION
#       This script helps administrators perform some of the Forms
#       related configuration tasks
#
#    NOTES
#        Run frmconfighelper.sh with help option    
#
#
#    MODIFIED BY Dirk Nachbar
#                http://dirknachbar.blogspot.com
#
#    CHANGES:
#             - rename of function enable_ohs to enable_ohs_cluster
#             - add function enable_ohs_single
#             - add Root-Context to enable_ohs_cluster and enable_ohs_single
#


#
# --------print_help-------------- 
# prints help
#
print_help()
{
   echo "-----------------------------------------------------------------"
   echo "   Forms configuration helper script                             "
   echo "-----------------------------------------------------------------"
   echo " This script helps administrators perform some of the Forms      "
   echo " related configuration tasks                                     "
   echo "                                                                 " 
   echo "**Important**: - Please backup the Weblogic domain before        "
   echo "                 performing any administration tasks on it using "
   echo "                 this script.                                    " 
   echo "               - You can run enable_sso, enable_webgate          "
   echo "                 and enable_sso_ssl options  only once.          " 
   echo "                                                                 " 
   echo " frmconfighelper.sh <option> <arguments>                         "
   echo "                                                                 "
   echo " options:                                                        "
   echo "    - enable_ohs_cluster <domain-home> <ohs-instance> <Root-Context> "
   echo "                 <forms-managed-server1-host> <forms-managed-server1-port> "
   echo "                 [<forms-managed-server2-host> <forms-managed-server2-port>..]                    "
   echo "                                                                 "
   echo "    - enable_ohs_single <domain-home> <ohs-instance> <Root-Context> "
   echo "                 <forms-managed-server1-host> <forms-managed-server1-port> "
   echo "                                                                 "
   echo "    - create_machine <wls-machine-name> <machine-host-name>      "
   echo "                                                                 "
   echo "    - create_managed_server <managed-server-name> <wls-machine-name> "
   echo "                            <managed-server-port> <standalone>   "
   echo "                                                                 "
   echo "    - deploy_app <new-context-root> <new-servlet-alias> <target>"
   echo "                                                                 "
   echo "    - update_app <new-context-root> <new-servlet-alias>"
   echo "                                                                 "
   echo "    - enable_sso <oam-host> <oam-port> <ohs-host> <ohs-port>     "
   echo "                 <domain-home> <ohs-instance>                    "
   echo "                                                                 "
   echo "    - enable_sso_ssl <oam-host> <oam-port> <ohs-host> <ohs-ssl-port> "
   echo "                     <ohs-non-ssl-port> <domain-home> <ohs-instance> "
   echo "                                                                 "
   echo "    - enable_webgate <domain home> <ohs-instance> "
   echo "                                                                 "
   echo "    - help (or no option): prints help                           "
   echo "                                                                 "
   echo "-----------------------------------------------------------------"
   echo " options description:                                            "
   echo "                                                                 "
   echo " enable_ohs_cluster:  enables routing for a given location <Root-Context> from OHS to the"
   echo "              Forms managed server(s) under cluster cluster_forms."
   echo "              When enable routing to mutiple Forms managed servers,"
   echo "              provide the managed server host port information in sequence"
   echo "                                                                 "
   echo " enable_ohs_single:  enables routing for a given location <Root-Context> from OHS to the"
   echo "              Forms Single managed server ."
   echo "                                                                 "
   echo " create_machine: creates a new (remote) wls machine for custom forms"
   echo "              application deployment (see create_managed_server) "
   echo "                                                                 "
   echo " create_managed_server: creates a new managed server for custom forms"
   echo "              application deployment (see deploy_app)            "
   echo "                                                                 "
   echo " deploy_app:  deploys formsapp ear file overriding the contex-root"
   echo "              and servlet alias to the specified target.         "
   echo "                                                                 "
   echo " update_app:  use this option to updated a deployed custom Forms "
   echo "              app (with overriden context root) after applying FMW"
   echo "              Forms services patch.  (see deploy_app)            "
   echo "                                                                 "
   echo " enable_webgate: enables webgate configuration in the OHS instance"
   echo "                                                                 "
   echo " enable_sso : enables webgate configuration in the OHS instance, "
   echo "              performs partner application registration and      "
   echo "              copies over the webgate artifacts to the OHS instance"
   echo "                                                                 "
   echo " enable_sso_ssl : enables webgate configuration in the OHS instance,"
   echo "              performs partner application registration using OHS "
   echo "              SSL and non-SSL ports and copies over the webgate  "
   echo "              artifacts to the OHS instance                      "
   echo "                                                                 "
   echo "-----------------------------------------------------------------"
   echo " arguments description:                                          "
   echo "                                                                 "
   echo " enable_ohs_cluster:                                             "
   echo "    - domain-home    : Domain Home directory                     "
   echo "    - ohs-instance   : OHS instance name (example ohs1)          "
   echo "    - Forms Context  : Root Context (example forms)              "
   echo "    - forms-managed-server(n)-host : Forms managed server host   "
   echo "    - forms-managed-server(n)-port : Forms managed server port   "
   echo "                                                                 "
   echo " enable_ohs_single:                                              "
   echo "    - domain-home    : Domain Home directory                     "
   echo "    - ohs-instance   : OHS instance name (example ohs1)          "
   echo "    - Forms Context  : Root Context (example forms)              "
   echo "    - forms-managed-server-host : Forms managed server host      "
   echo "    - forms-managed-server-port : Forms managed server port   "
   echo "                                                                 "
   echo " create_machine:                                                 "
   echo "    - machine-name   : WLS machine name                          "
   echo "    - host-name      : Remote WLS machine hostname               "
   echo "                                                                 "
   echo " create_managed_server:                                          "
   echo "   - managed-server-name: Managed server name                    "
   echo "   - wls-machine-name :    WLS machine name                      "
   echo "   - managed-server-port: Managed server port number             "
   echo "   - standalone (optional): indicates standalone managed server  "
   echo "     which is not part of any cluster.                           "
   echo "                                                                 "
   echo " deploy_app or update_app:                                       "
   echo "    - new-context-root  : new context root for the formsapp      "
   echo "    - new-servlet-alias : new servlet alias for the formsservlet "
   echo "    - target (optional) : target managed server or cluster for the new application"
   echo "                                                                 "
   echo " enable_sso:                                                     "
   echo "    - oam-host       : OAM Server host name                      "
   echo "    - oam-port       : OAM Server port number                    "
   echo "    - ohs-host       : OHS host name                             "
   echo "    - ohs-port       : OHS port number                           "
   echo "    - domain-home    : Domain Home directory                     "
   echo "    - ohs-instance   : OHS instance name (example ohs1)          "
   echo "                                                                 "
   echo " enable_sso_ssl:                                                 "
   echo "    - oam-host       : OAM Server host name                      "
   echo "    - oam-port       : OAM Server port number                    "
   echo "    - ohs-host       : OHS host name                             "
   echo "    - ohs-ssl-port   : OHS SSL port number                       "
   echo "    - ohs-non-ssl-port  : OHS non-SSL port number                "
   echo "    - domain-home    : Domain Home directory                     "
   echo "    - ohs-instance   : OHS instance name (example ohs1)          "
   echo "                                                                 "
   echo " enable_webgate:                                                 "
   echo "    - domain-home    : Domain Home directory                     "
   echo "    - ohs-instance   : OHS instance name (example ohs1)          "
   echo "                                                                 "
   echo "                                                                 "
   echo " Important notes:                                                "
   echo "=================                                                "
   echo " --------------------------------------------------------------- "
   echo " Single Sign On configuration related options                    "
   echo " --------------------------------------------------------------- "   
   echo " enable_sso                                                      "
   echo " - Use this option for registering OAM partner application. You can "
   echo "   either register OHS SSL or non-SSL port (only one) with this option. "
   echo "                                                                 "
   echo " enable_sso_ssl                                                  "
   echo " - Use this for registering partner application, when you want to"
   echo "   register OHS SSL and non-SSL ports.                           "
   echo "                                                                 "
   echo " enable_webgate                                                  "
   echo " - Use this option only when using OAM console for registering   "
   echo "   partner application.                                          "
   echo "                                                                 "
   echo " configuration steps:                                            "
   echo " 1. Create OHS instance.                                         "
   echo " 2. Get RREG.tar from OAM tier and untar it under MW_HOME        "
   echo " 3. Decide whether to enable Single Sign on SSL or Non-SSL       "
   echo "    or both the OHS ports.                                       "
   echo "    a. Use enable_sso option to register one of the OHS instance "
   echo "       ports for partner application registration.               "
   echo "    b. Use enable_sso_ssl option to register both (SSL and non-SSL)"
   echo "       OHS instance ports for partner application registration.   "
   echo " 4. When directly using OAM console for creating the policies, you"
   echo "    can use enable_webgate to enable webgate configuration under a"
   echo "    given OHS instance.                                           "
   echo "                                                                 "
   echo " --------------------------------------------------------------- "
   echo " Forms JavaEE custom application deployment related options      "
   echo " --------------------------------------------------------------- "
   echo " create_managed_server:                                          "
   echo " - Use this option to create managed server to deploy/target custom"
   echo "   Forms application. This option should only be used for the purpose"
   echo "   of deploying custom Forms applications. Use Admin Console,    "
   echo "   WLST and other Weblogic tools for creating managed server for other "
   echo "   generic use.                                                  "
   echo "                                                                 "
   echo " create_machine:                                                 "
   echo " - Use this option when you want to a Weblogic machine for a remote"
   echo "   managed server.                                               "
   echo "                                                                 "
   echo " configuration steps:                                            "
   echo " 1. Create a managed server using create_managed_server option. "
   echo "    It will implicitly create a WLS cluster named cluster_forms_customApps"
   echo "    and add this managed server to it. If this managed server is "
   echo "    expected to run on another node(another host), then use create_machine"
   echo "    option first to create a WLS machine before running create_managed_server."
   echo " 2. Use deploy_app option to override the default Forms context-root (/forms)"
   echo "    and the default FormsServlet alias (/frmservlet).            "
   echo " 3. You can provide optional third argument target to the deploy_app option"
   echo "    to target custom Forms application to individual managed servers of "
   echo "    the cluster cluster_forms_customApps                         "
   echo "                                                                 "
   echo " ** You cannot deploy the default Forms JavaEE application(/forms/frmservlet)"
   echo "    and  custom  Forms JavaEE applications on the same cluster/managed server."
   echo "    So you should not pass in WLS_FORMS or any other managed server"
   echo "    that is part of cluster_forms as the target to deploy_app option. "
   echo "                                                                 "
   echo "                                                                 "
   echo "-----------------------------------------------------------------"
   echo " examples:                                                       "
   echo "                                                                 "
   echo "  enable ohs cluster routing to forms managed servers                    "
   echo " ./frmconfighelper.sh enable_ohs_cluster /scratch/user_projects/domain/base_domain ohs1 sales wlshost.example.com 9001 wlshost.example.com 9010"
   echo "                                                                 "
   echo "  enable ohs single routing to forms managed server              "
   echo "  ./frmconfighelper.sh enable_ohs_single /scratch/user_projects/domain/base_domain ohs1 finance wlshost.example.com 9020"
   echo "                                                                 "
   echo "  create a WLS remote machine                                    "
   echo " ./frmconfighelper.sh create_machine SalesRemoteMachine remotehostname"
   echo "                                                                 "
   echo "  create a managed server that is part of cluster_forms_customApp"
   echo " ./frmconfighelper.sh create_managed_server WLS_SALES AdminServerMachine 9010"
   echo "                                                                 "
   echo "  create a standalone managed server                             "
   echo " ./frmconfighelper.sh create_managed_server WLS_FINANCE AdminServerMachine 9020 standalone"
   echo "                                                                 "
   echo "  deploy custom application (sales) to cluster cluster_forms_customApp"
   echo " ./frmconfighelper.sh deploy_app sales salesservlet"
   echo "                                                                 "
   echo "  deploy custom application (finance) to standalone managed server WLS_FINANCE"
   echo " ./frmconfighelper.sh deploy_app finance financeservlet WLS_FINANCE"
   echo "                                                                 "
   echo "  update application sales after patching  FMW                   "
   echo " ./frmconfighelper.sh update_app sales salesservlet"
   echo "                                                                 "
   echo "  enable webgate configuration and perform OAM partner application registration  with a single OHS port (SSL or non-SSL)"
   echo " ./frmconfighelper.sh enable_sso oamhost.example.com 7001 ohshost.example.com 7777 /scratch/user_projects/domain/base_domain ohs1 "
   echo "                                                                 "
   echo "  enable webgate configuration and perform OAM partner application registration with a both OHS port (SSL and non-SSL)"
   echo " ./frmconfighelper.sh enable_sso_ssl oamhost.example.com 7001 ohshost.example.com 4443 7777 /scratch/user_projects/domain/base_domain ohs1 "
   echo "                                                                 "
   echo "  enable webgate configuration. It should be used only when directly using OAM console for partner application registration"
   echo " ./frmconfighelper.sh enable_webgate /scratch/user_projects/domain/base_domain ohs1                              "
   echo "                                                                 "
   echo "                                                                 "
}


#
# --------print_invalid_args-------------- 
# print invalid args
#
print_invalid_args()
{
  echo ""
  echo "error: "
  echo "       invalid number of arguments passed in with option: $1"
  echo "       run with argument help and see the examples. "  
  echo ""
}


#
# --------enable_ohs-------------- 
# enables forms ohs routing
# for Forms Cluster
#
enable_ohs_cluster()
{
  log_msg "enabling ohs routing to the WLS Forms Managed servers"
  FORMS_CONF_TMPL="$MW_HOME/forms/templates/config/forms.conf"
  FORMS_CONF="$2/config/fmwconfig/components/OHS/instances/$3/moduleconf/forms.conf"
  FORMS_CONTEXT="$4"

  cp $FORMS_CONF_TMPL $FORMS_CONF >> $LOG_FILE 2>&1
  echo " "  >> $FORMS_CONF 
  echo "#"  >> $FORMS_CONF 
  echo "# entries added by formsconfighelper script"  >> $FORMS_CONF 
  echo "#"  >> $FORMS_CONF 
  echo "<Location /${FORMS_CONTEXT}>" >> $FORMS_CONF 
  echo "        SetHandler weblogic-handler" >> $FORMS_CONF 

  SERVER_LIST="WebLogicCluster "
  for i in $*
  do
     j=$((j + 1))

     if [ $j -gt 3 ]
     then
         #
         # odd argument is host
         # even argument is port
         rem=$(( $j % 2 ))
 
         if [ $rem -eq 0 ]
         then
             WL_HOST=$i
             SERVER_LIST+=$WL_HOST:
         else
             WL_PORT=$i
             SERVER_LIST+=$WL_PORT

             if [ $j -lt $# ]
             then
                 SERVER_LIST+=","
             fi
          fi
     fi
  done
  echo "        "$SERVER_LIST >> $FORMS_CONF 
  echo "        DynamicServerList OFF" >> $FORMS_CONF 
  echo "" >> $FORMS_CONF 
  echo "# " >> $FORMS_CONF 
  echo "# If SSL is enabled in a proxy in front of WLS (e.g. OHS) " >> $FORMS_CONF 
  echo "# then you must set WLSProxySSL ON (uncomment the WLProxySSL entry below).  " >> $FORMS_CONF 
  echo "# " >> $FORMS_CONF 
  echo "# Be sure to also set WebLogic Plugin Enable to YES  " >> $FORMS_CONF 
  echo "# in the WebLogic Console in the managed server's " >> $FORMS_CONF 
  echo "# General Advanced settings. " >> $FORMS_CONF 
  echo "# " >> $FORMS_CONF 
  echo "# WLProxySSL ON " >> $FORMS_CONF 
  echo "" >> $FORMS_CONF 
  echo "</Location>" >> $FORMS_CONF

}

#
# --------enable_ohs-------------- 
# enables forms ohs routing
# for Forms Single Instance
#
enable_ohs_single()
{
  log_msg "enabling ohs routing to the WLS Forms Managed server"
  FORMS_CONF_TMPL="$MW_HOME/forms/templates/config/forms.conf"
  FORMS_CONF="$2/config/fmwconfig/components/OHS/instances/$3/moduleconf/forms.conf"
  FORMS_CONTEXT="$4"
  FORMS_HOST="$5"
  FORMS_PORT="$6"

  cp $FORMS_CONF_TMPL $FORMS_CONF >> $LOG_FILE 2>&1
  echo " "  >> $FORMS_CONF
  echo "#"  >> $FORMS_CONF
  echo "# entries added by formsconfighelper script"  >> $FORMS_CONF
  echo "#"  >> $FORMS_CONF
  echo "<Location /${FORMS_CONTEXT}>" >> $FORMS_CONF
  echo "        SetHandler weblogic-handler" >> $FORMS_CONF
  echo "        WebLogicHost ${FORMS_HOST}" >> $FORMS_CONF
  echo "        WeblogicPort ${FORMS_PORT}" >> $FORMS_CONF
  echo "" >> $FORMS_CONF
  echo "# " >> $FORMS_CONF
  echo "# If SSL is enabled in a proxy in front of WLS (e.g. OHS) " >> $FORMS_CONF
  echo "# then you must set WLSProxySSL ON (uncomment the WLProxySSL entry below).  " >> $FORMS_CONF
  echo "# " >> $FORMS_CONF
  echo "# Be sure to also set WebLogic Plugin Enable to YES  " >> $FORMS_CONF
  echo "# in the WebLogic Console in the managed server's " >> $FORMS_CONF
  echo "# General Advanced settings. " >> $FORMS_CONF
  echo "# " >> $FORMS_CONF
  echo "# WLProxySSL ON " >> $FORMS_CONF
  echo "" >> $FORMS_CONF
  echo "</Location>" >> $FORMS_CONF

}


#
# --------enable_webgate-------------- 
# enables webgate in the OHS instance
#
# arguments passed:
# arg 1: <domain home> 
# arg 2: <ohs-instance> 
enable_webgate()
{
  log_msg "enabling webgate configuration under OHS instance $2"

  $MW_HOME/webgate/ohs/tools/deployWebGate/deployWebGateInstance.sh \
    -w $1/config/fmwconfig/components/OHS/$2 -oh $MW_HOME >> $LOG_FILE 2>&1
 
  LD_LIBRARY_PATH=$MW_HOME/lib
  export LD_LIBRARY_PATH;

  $MW_HOME/webgate/ohs/tools/setup/InstallTools/EditHttpConf \
     -w  $1/config/fmwconfig/components/OHS/$2 \
     -oh $MW_HOME -o webgate.conf >> $LOG_FILE 2>&1
}

#
# ------generate_metrics_jar---------------------
# generated frmmetrics.jar
#
build_metrics_jar()
{
  log_msg "building the $MW_HOME/forms/j2ee/frmmetrics.jar file"

  JAR=$JAVA_HOME/bin/jar
  JAR_TMP=$T_WORK/jar_tmp
  SRV_JAR_TMP=$JAR_TMP/srv_tmp
  CFG_JAR_TMP=$JAR_TMP/cfg_tmp
  MET_JAR_TMP=$JAR_TMP/met_tmp

  mkdir -p $CFG_JAR_TMP
  mkdir -p $SRV_JAR_TMP
  mkdir -p $MET_JAR_TMP/oracle/forms/config/utils
  mkdir -p $MET_JAR_TMP/oracle/forms/servlet

  cd $SRV_JAR_TMP
  $JAR xf $MW_HOME/forms/j2ee/frmsrv.jar

  cd $CFG_JAR_TMP
  $JAR xf $MW_HOME/forms/provision/frmconfig.jar

  cp $SRV_JAR_TMP/oracle/forms/servlet/ProcessManager.class \
     $MET_JAR_TMP/oracle/forms/servlet/

  cp $SRV_JAR_TMP/oracle/forms/servlet/ProcessMetrics.class \
     $MET_JAR_TMP/oracle/forms/servlet/

  cp $SRV_JAR_TMP/oracle/forms/servlet/FormsLoggerDef.class \
     $MET_JAR_TMP/oracle/forms/servlet/

  cp $SRV_JAR_TMP/oracle/forms/servlet/FormsODLLevel.class \
     $MET_JAR_TMP/oracle/forms/servlet/

  cp $CFG_JAR_TMP/oracle/forms/config/utils/FormsappConfigUtils.class \
     $MET_JAR_TMP/oracle/forms/config/utils/
  cp $CFG_JAR_TMP/oracle/forms/config/utils/FormsJMXUtils.class \
     $MET_JAR_TMP/oracle/forms/config/utils/
  cp $CFG_JAR_TMP/oracle/forms/config/utils/Util.class \
     $MET_JAR_TMP/oracle/forms/config/utils/
  cp $CFG_JAR_TMP/oracle/forms/config/utils/FormsMessageUtils.class \
     $MET_JAR_TMP/oracle/forms/config/utils/
  cp $SRV_JAR_TMP/oracle/forms/servlet/LBServletBundle*.class  \
     $MET_JAR_TMP/oracle/forms/servlet/ 

  cd $MET_JAR_TMP
  $JAR cf $MW_HOME/forms/j2ee/frmmetrics.jar *

  cd $MW_HOME/forms/provision
  rm -rf $CFG_JAR_TMP
  rm -rf $SRV_JAR_TMP
  rm -rf $MET_JAR_TMP
}

#
# --------build_ear-------------- 
# rebuilds the ear file with the overridden context-root,
# servlet alias
#
# arguments passed:
# arg 1: <new-context-root> 
# arg 2: <new-servlet-alias> 
#
build_ear()
{
  EAR_FILE=$MW_HOME/forms/j2ee/$1.ear

  if [ -f $EAR_FILE ]
  then
      log_msg "ear file $EAR_FILE exists, moving it to \"$EAR_FILE\"_\"$TIME_STAMP\" " 
      mv $EAR_FILE "$EAR_FILE"_"$TIME_STAMP"
  fi

  log_msg "building the ear file"

  JAR=$JAVA_HOME/bin/jar
  EAR_TMP=$T_WORK/ear_tmp
  WAR_TMP=$EAR_TMP/war_tmp
  SRV_JAR_TMP=$EAR_TMP/srv_tmp
  CFG_JAR_TMP=$EAR_TMP/cfg_tmp

  mkdir -p $WAR_TMP >> $LOG_FILE 2>&1
  cd $EAR_TMP >> $LOG_FILE 2>&1
  $JAR xvf $MW_HOME/forms/j2ee/formsapp.ear >> $LOG_FILE 2>&1
  cd $EAR_TMP/META-INF >> $LOG_FILE 2>&1

  sed -e "s?<context-root>forms?<context-root>$1?g" application.xml > application.tmp
  mv application.tmp application.xml >> $LOG_FILE 2>&1

  cd $EAR_TMP/config >> $LOG_FILE 2>&1
  sed -e "s?\/forms\/?\/$1\/?g" formsweb.cfg > formsweb.tmp
  mv formsweb.tmp formsweb.cfg

  cd $WAR_TMP >> $LOG_FILE 2>&1
  $JAR xvf $EAR_TMP/formsweb.war >> $LOG_FILE 2>&1
  cd $WAR_TMP/WEB-INF >> $LOG_FILE 2>&1

  sed -e "s?frmservlet?$2?g" web.xml > web.tmp 
  mv web.tmp web.xml >> $LOG_FILE 2>&1

  mkdir -p $CFG_JAR_TMP
  mkdir -p $SRV_JAR_TMP

  cd $SRV_JAR_TMP
  $JAR xf $WAR_TMP/WEB-INF/lib/frmsrv.jar

  cd $CFG_JAR_TMP
  $JAR xf $EAR_TMP/APP-INF/lib/frmconfig.jar

  mv $CFG_JAR_TMP/META-INF/MANIFEST.MF $CFG_JAR_TMP/manifest

  rm $CFG_JAR_TMP/oracle/forms/servlet/ProcessManager.class \
     $CFG_JAR_TMP/oracle/forms/servlet/ProcessMetrics.class \
     $SRV_JAR_TMP/oracle/forms/servlet/ProcessManager.class \
     $SRV_JAR_TMP/oracle/forms/servlet/ProcessMetrics.class 

  cd $CFG_JAR_TMP
  $JAR cfm $EAR_TMP/APP-INF/lib/frmconfig.jar $CFG_JAR_TMP/manifest oracle/* 

  cd $SRV_JAR_TMP
  $JAR cfM $WAR_TMP/WEB-INF/lib/frmsrv.jar oracle/*

  cd $WAR_TMP >> $LOG_FILE 2>&1

  mkdir -p $WAR_TMP/java
  cp $MW_HOME/forms/java/*.* $WAR_TMP/java >> $LOG_FILE 2>&1
  sed -i 's/codebase="\/forms\/java"/codebase="\/$1\/java"/g' $WAR_TMP/java/extensions.jnlp
  $JAR cvfM $EAR_TMP/formsweb.war * >> $LOG_FILE 2>&1

  cd $EAR_TMP
  $JAR cvfm $EAR_FILE META-INF/MANIFEST.MF APP-INF/* \
        config/*  formsweb.war  META-INF/* >> $LOG_FILE 2>&1
  cd $MW_HOME/forms/j2ee

  rm -rf $EAR_TMP
  rm -rf $CFG_JAR_TMP
  rm -rf $SRV_JAR_TMP
}


#
# --------deploy_app-------------- 
# overrides the context-root, servlet alias and 
# deploys the formsapp
#
# passed arguments:
# arg 1: <new-context-root> 
# arg 2: <new-servlet-alias> 
# arg 3: <target>
#
deploy_app()
{
  WLST_LOG_FILE="$LOG_FILE".wlst
  log_msg "deploying forms application using context-root: $1 servlet alias: $2  target: $3"
  EAR_FILE=$MW_HOME/forms/j2ee/$1.ear
  log_msg "deploying custom application $1app using ear file $EAR_FILE"
  $MW_HOME/oracle_common/common/bin/wlst.sh $MW_HOME/forms/provision/frmconfighelper.py deployApp $WLST_LOG_FILE $1app $EAR_FILE $MW_HOME $3
  cat $WLST_LOG_FILE >> $LOG_FILE
  rm $WLST_LOG_FILE
}


#
# create_managed_server
#
# passed arguments:
# arg 1: <managed-server-name>
# arg 2: <wls-machine-name> 
# arg 3: <managed-server-port>
# arg 4: <standalone>
# 
create_managed_server()
{
   log_msg "creating managed server $1 using machine $2 port number $3"
   WLST_LOG_FILE="$LOG_FILE".wlst

   if [ ! -f $MW_HOME/forms/j2ee/frmmetrics.jar ];
   then
       build_metrics_jar;
   fi
   $MW_HOME/oracle_common/common/bin/wlst.sh  $MW_HOME/forms/provision/frmconfighelper.py createManagedServer $WLST_LOG_FILE $1 $2 $3 $MW_HOME $4
   cat $WLST_LOG_FILE >> $LOG_FILE
   rm $WLST_LOG_FILE
}


#
# create_machine
#
# passed arguments:
# arg 1: <wls-machine-name> 
# arg 2: <hostname>
# 
create_machine()
{
   log_msg "creating weblogic machine $1 for host $2"
   WLST_LOG_FILE="$LOG_FILE".wlst
   $MW_HOME/oracle_common/common/bin/wlst.sh  $MW_HOME/forms/provision/frmconfighelper.py createMachine $WLST_LOG_FILE $1 $2
   cat $WLST_LOG_FILE >> $LOG_FILE
   rm $WLST_LOG_FILE
}


#
# --------partner_app_reg------------- 
# performs the partner application registration
# passed arguments:
# arg 1: <oam-host> 
# arg 2: <oam-port> 
# arg 3: <ohs-host> 
# arg 4: <ohs-port> 
#
partner_app_reg()
{
  log_msg "registering partner application "
  log_msg "generating the input file $T_WORK/FormsOAMRegRequest.xml"

  sed -e "s?%OAM_HOST%?$1?g" \
      -e "s?%OAM_PORT%?$2?g" \
      -e "s?%OHS_HOST%?$3?g" \
      -e "s?%OHS_PORT%?$4?g" \
      -e "s?%HOST%?$HOST?g" \
  $MW_HOME/forms/provision/FormsOAMRegRequest.xml > $T_WORK/tmp.xml

  mv $T_WORK/tmp.xml $T_WORK/FormsOAMRegRequest.xml

  log_msg "doing the partner app registration using input file $T_WORK/FormsOAMRegRequest.xml"
  $RREG_HOME/bin/oamreg.sh inband $T_WORK/FormsOAMRegRequest.xml
}

#
# --------partner_app_reg_ssl------------- 
# performs the partner application registration
# passed arguments:
# arg 1: <oam-host> 
# arg 2: <oam-port> 
# arg 3: <ohs-host> 
# arg 4: <ohs-ssl-port> 
# arg 5: <ohs-non-ssl-port> 
#
partner_app_reg_ssl()
{
  log_msg "registering partner application "
  log_msg "generating the input file $T_WORK/FormsOAMRegRequest2Ports.xml"

  sed -e "s?%OAM_HOST%?$1?g" \
      -e "s?%OAM_PORT%?$2?g" \
      -e "s?%OHS_HOST%?$3?g" \
      -e "s?%OHS_SSL_PORT%?$4?g" \
      -e "s?%OHS_NON_SSL_PORT%?$5?g" \
      -e "s?%HOST%?$HOST?g" \
  $MW_HOME/forms/provision/FormsOAMRegRequest2Ports.xml > $T_WORK/tmp.xml

  mv $T_WORK/tmp.xml $T_WORK/FormsOAMRegRequest2Ports.xml

  log_msg "doing the partner app registration using input file $T_WORK/FormsOAMRegRequest2Ports.xml"
  $RREG_HOME/bin/oamreg.sh inband $T_WORK/FormsOAMRegRequest2Ports.xml
}


#
# -------copy_artifacts------------- 
# copies over the webgate artifacts to ohs instance
#
# passed arguments:
# arg 1: <ohs_host> 
# arr 2: <domain home>
# arg 3: <ohs instance>
#
copy_artifacts()
{
  log_msg "copy artifacts to ohs instance $3"
  cp -rpf "$RREG_HOME/output/$1"_OAM/* $2/config/fmwconfig/components/OHS/$3/webgate/config/ >> $LOG_FILE 2>&1
}


#
# -------log_msg------------------
#
# passed arguments:
# arg 1: message to be logged.
#
log_msg()
{
  echo "" >> $LOG_FILE
  echo $1 >> $LOG_FILE
}


#
# -------init------------------
#
init()
{
   echo "running frmconfighelper.sh $1"
   echo "using log file $LOG_FILE .........."
}

#
# script execution starts here
#
if [  -z $MW_HOME ]
then
    echo "error: "
    echo "     set MW_HOME and run the script "
    exit 0;
fi


T_WORK=$HOME/frmconfighelper
TIME_STAMP=$(date "+%Y_%m_%d_%H_%M_%S")
LOG_FILE=$T_WORK/logs/frmconfighelper_$TIME_STAMP.log
RREG_HOME=$MW_HOME/rreg
JAVA_HOME=$MW_HOME/oracle_common/jdk

if [ ! -d $T_WORK ];
then
    mkdir -p $T_WORK
fi

if [ ! -d $T_WORK/logs ];
then
    mkdir -p $T_WORK/logs
fi

touch $LOG_FILE
init $1
log_msg "MW_HOME=$MW_HOME"
log_msg "JAVA_HOME=$JAVA_HOME"
log_msg "arguments passed $*"
log_msg "processing option $1" 

if  [ "$1" = "enable_sso" ];
then
    if [ $# -ne 7 ];
    then
        print_invalid_args $1;
    else
        if [ ! -d "$MW_HOME/rreg" ];
        then
             echo "get RREG utility from the OAM tier and unzip it under $MW_HOME"
         exit 1;
        fi
        enable_webgate $6 $7;
        partner_app_reg $2 $3 $4 $5;
        copy_artifacts $4 $6 $7;
    fi
elif  [ "$1" = "enable_sso_ssl" ];
then
    if [ $# -ne 8 ];
    then
        print_invalid_args $1;
    else
        if [ ! -d "$MW_HOME/rreg" ];
        then
             echo "get RREG utility from the OAM tier and unzip it under $MW_HOME"
         exit 1;
        fi
        enable_webgate $7 $8;
        partner_app_reg_ssl $2 $3 $4 $5 $6;
        copy_artifacts $4 $7 $8;
    fi
elif [ "$1" = "enable_ohs_cluster" ]; 
then
    if [ $# -lt 5 ];
    then
        print_invalid_args $1;
    else
        enable_ohs_cluster $*;
    fi
elif [ "$1" = "enable_ohs_single" ];
then
    if [ $# -lt 5 ];
    then
        print_invalid_args $1;
    else
        enable_ohs_single $*;
    fi
elif [ "$1" = "enable_webgate" ]; 
then
    if [ $# -ne 3 ];
    then
        print_invalid_args $1;
    else
        enable_webgate $2 $3;
    fi
elif [ "$1" = "deploy_app" ]; 
then
    if [ $# -lt 3 ];
    then
        print_invalid_args $1;
    else
        build_ear  $2 $3;

        #
        # set default target as 
        # "cluster_forms_customApps" when it is not passed
        #
        TARGET="cluster_forms_customApps"
        if [ $# -eq 4 ];
        then
            TARGET=$4
        fi
        deploy_app $2 $3 $TARGET;
    fi
elif [ "$1" = "update_app" ]; 
then
    if [ $# -ne 3 ];
    then
        print_invalid_args $1;
    else
        #
        # build the metrics jar file before building
        # the ear file
        build_metrics_jar;
        build_ear $2 $3;
    fi
elif [ "$1" = "create_machine" ]; 
then
    if [ $# -ne 3 ];
    then
        print_invalid_args $1;
    else
        create_machine $2 $3;
    fi
elif [ "$1" = "create_managed_server" ]; 
then
    if [ $# -lt 4 ];
    then
        print_invalid_args $1;
    else
        if [ -z $5 ];
        then
            create_managed_server $2 $3 $4 "cluster_forms_customApps" ;
        else
            create_managed_server $2 $3 $4 $5;
        fi
    fi
elif [ "$1" = "help" ]
then
    print_help;
else
    print_help;
fi
