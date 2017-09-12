#!/usr/bin/python

# Things to do:
#

import os, sys, socket
hostname=socket.gethostname()
msinternal=socket.gethostbyname(hostname)
v_admin_username = os.environ['ADMIN_USERNAME']
v_reports=os.environ['REPORTS12C']
v_forms=os.environ['FORMS12C']
v_reportsMSName='ManagedServer@RepSrv%s' %  hostname
v_formsMSName='ManagedServer@FormSrv%s' %  hostname
v_reportsPort=os.environ['REPORTS12C_MS_PORT']
v_formsPort=os.environ['FORMS12C_MS_PORT']
v_NMType=os.environ['NM_TYPE']
v_NMPort=os.environ['NM_PORT']
v_NMPwd=os.environ['ADMIN_PASSWORD']
v_domain=os.environ['DOMAIN_NAME']
v_dbhost=os.environ['DB_HOST']
v_dbport=os.environ['DB_PORT']
v_dbservice=os.environ['DB_SERVICE']
v_url="jdbc:oracle:thin:@//"+v_dbhost+':'+v_dbport+'/'+v_dbservice
v_pwd=os.environ['DB_USER_PW']
v_SchemaPrefix=os.environ['SCHEMA_PREFIX']
v_setup_domain_base='/u01/oracle/user_projects/domains'
v_setup_application_base='/u01/oracle/user_projects/applications'

def changeDatasourceToXA(datasource):
  print 'Change datasource '+datasource
  cd('/')
  cd('/JDBCSystemResource/'+datasource+'/JdbcResource/'+datasource+'/JDBCDriverParams/NO_NAME_0')
  set('DriverName','oracle.jdbc.xa.client.OracleXADataSource')
  set('UseXADataSourceInterface','True')
  cd('/JDBCSystemResource/'+datasource+'/JdbcResource/'+datasource+'/JDBCDataSourceParams/NO_NAME_0')
  set('GlobalTransactionsProtocol','TwoPhaseCommit')
  cd('/')

def printHeader(headerText):
    print "\n======================================================================================"
    print "--> "+headerText
    print "======================================================================================\n"

def printInfo(infoText):
    print "-->: "+infoText

printHeader("Started: crFRExtension.py")

try:
    if not ( v_forms == "true" or v_reports == "true" ):	
       printInfo( "Reports flag are set to false")
       printInfo( "We will stop processing, please activate Reports")
       exit()
    printHeader( "readDomain "+v_domain+" started")
    readDomain(v_setup_domain_base+'/'+v_domain)
    printInfo( "readDomain successful")
except:
    printInfo( "readDomain failed")
    exit()

try:
    printHeader( "select and load templates")
    selectTemplate('Oracle HTTP Server (Collocated)')
    if v_forms == "true":
       selectTemplate('Oracle Forms')
    if v_reports == "true":	
       selectTemplate('Oracle Reports Application')
       selectTemplate('Oracle Reports Server')
    printInfo( "select templates successful")
    loadTemplates()
    printInfo( "load templates successful")
except:
    printInfo( "select and load templates failed")
    exit()

printHeader("JDBC configuration")
try:
    printInfo("Configure LocalSvcTblDataSource")
    cd('/')
    cd('/JDBCSystemResource/LocalSvcTblDataSource/JdbcResource/LocalSvcTblDataSource')
    cd('JDBCDriverParams/NO_NAME_0')
    set('DriverName','oracle.jdbc.OracleDriver')
    set('URL', v_url)
    set('PasswordEncrypted', v_pwd)
    cd('Properties/NO_NAME_0')
    cd('Property/user')
    cmo.setValue(v_SchemaPrefix+'_STB')
    printInfo("Configure LocalSvcTblDataSource successful")
except:
    printInfo("Configure LocalSvcTblDataSource failed")
    exit()

try:
    printInfo("Configure opss-data-source")
    cd('/')
    cd('JDBCSystemResource/opss-data-source/JdbcResource/opss-data-source')
    cd('JDBCDriverParams/NO_NAME_0')
    set('DriverName','oracle.jdbc.OracleDriver')
    set('URL', v_url)
    set('PasswordEncrypted', v_pwd)
    cd('Properties/NO_NAME_0')
    cd('Property/user')
    cmo.setValue(v_SchemaPrefix+'_OPSS')
    printInfo("Configure opss-data-source successful")
except:
    printInfo("Configure opss-data-source failed")
    exit()

try:
    printInfo("Configure opss-audit-viewDS")
    cd('/')
    cd('JDBCSystemResource/opss-audit-viewDS/JdbcResource/opss-audit-viewDS')
    cd('JDBCDriverParams/NO_NAME_0')
    set('DriverName','oracle.jdbc.OracleDriver')
    set('URL', v_url)
    set('PasswordEncrypted', v_pwd)
    cd('Properties/NO_NAME_0')
    cd('Property/user')
    cmo.setValue(v_SchemaPrefix+'_IAU_VIEWER')
    printInfo("Configure opss-audit-viewDS successful")
except:
    printInfo("Configure opss-audit-viewDS failed")
    exit()

try:
    printInfo("Configure opss-audit-DBDS")
    cd('/')
    cd('JDBCSystemResource/opss-audit-DBDS/JdbcResource/opss-audit-DBDS')
    cd('JDBCDriverParams/NO_NAME_0')
    set('DriverName','oracle.jdbc.OracleDriver')
    set('URL', v_url)
    set('PasswordEncrypted', v_pwd)
    cd('Properties/NO_NAME_0')
    cd('Property/user')
    cmo.setValue(v_SchemaPrefix+'_IAU_APPEND')
    printInfo("Configure opss-audit-DBDS successful")
except:
    printInfo("Configure opss-audit-DBDS failed")
    exit()

try:
   printInfo("Modify Datasources: LocalSvcTblDataSource , opss-audit-DBDS, opss-audit-viewDS , opss-data-source")
   changeDatasourceToXA('LocalSvcTblDataSource')
   changeDatasourceToXA('opss-audit-DBDS')
   changeDatasourceToXA('opss-audit-viewDS')
   changeDatasourceToXA('opss-data-source')
   printInfo("Modify Datasources successful")
except:
   printInfo("Modify Datasources failed")
   dumpStack()

   printHeader('Customize Domain Settings')
try:
    printInfo("Name and Ports of the Managed Servers will be modified")
    if v_forms == "true":
       cd('/')
       cd('/Server/WLS_FORMS')
       cmo.setName(v_formsMSName)
       cd('/')
       cd('/Server/'+v_formsMSName)
       cmo.setListenPort(int(v_formsPort))	
    if v_reports == "true":
       cd('/')
       cd('/Server/WLS_REPORTS')
       cmo.setName(v_reportsMSName)
       cd('/Server/'+v_reportsMSName)
       cmo.setListenPort(int(v_reportsPort))
    printInfo("Modification of Name and Ports are successful")
except:
    printInfo("ERROR: Modification of Name and Ports are failed")
	
try:
    printHeader("Nodemanager Configuration")
    cd('/')
    cd('/Machines/AdminServerMachine/NodeManager/AdminServerMachine')
    cmo.setNMType(v_NMType)	
    cmo.setListenAddress(msinternal)
    cmo.setListenPort(int(v_NMPort))
    cd('/')
    cd('/SecurityConfiguration/'+v_domain)
    cmo.setNodeManagerUsername(v_admin_username)
    cmo.setNodeManagerPasswordEncrypted(v_NMPwd)
    printInfo("Nodemanager Configuration successful")
except:
    printInfo("ERROR: Nodemanager Configuration failed")

try:
    printHeader("AppDir will be set to "+v_setup_application_base)
    try:
        setOption('AppDir',v_setup_application_base)
    except Exception, e:
        print "Error Message "+ str(e)

    printInfo("Domain will be updated and saved")
    printInfo("... this can take up to 5 minutes")
    updateDomain()
    closeDomain()
    printHeader("Program End: crFRExtension.py")
    print "======================================================================================"

    exit()
except:
   print "Domain could not be saved"
   dumpStack()