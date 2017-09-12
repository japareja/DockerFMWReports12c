Oracle Fusion Middleware Server 12c on Docker Forms & Reports
=============================================================
I create this project, because Oracle has no plans to release official Docker images for Oracle Reports & Forms Server 12c, so I have to build it by myself.

Official Oracle Weblogic scripts and images are the base for this project https://github.com/oracle/docker-images/tree/master/OracleWebLogic. Then I have to figure out how to make a completely unattended installation for Reports & Forms 12.2.1, and at this point, I reached this two great posts that helped me a lot:

http://dirknachbar.blogspot.com.es/2017/05/how-to-install-and-configure-oracle.html
http://robertcrames.blogspot.com.es/2017/05/how-to-install-and-configure-oracle.html

All you know that Oracle Reports Server needs a Database for hosting Repository metadata that is created througt RCU utility. For testing purpose, I use another Oracle DB 12c container ready to use (not the Oracle official one). https://hub.docker.com/r/pengbai/docker-oracle-12c-r1/

**IMPORTANT:** By now the architecture is working with a Managed Reports Server running on AdminServerMachine. Go to TO DO section for other architecture and cluster configuration.

## How to build and run
1º Create a Docker Network
docker network create oranet

2º Deploy Oracle DB 12c container with AL32UTF8 Charset:
docker run -d --name DB12cRCU --network oranet --shm-size=2g -p 8080:8080 -p 1521:1521 -e ORACLE_SID=xe -e CHARACTER_SET=AL32UTF8 -e ORACLE_CHARACTERSET=AL32UTF8 pengbai/docker-oracle-12c-r1
Connect to DB with some SQL Client, and set SYS Password to oracleDocker17: ALTER USER SYS IDENTIFIED BY oracleDocker17

3º Build Oracle Java base image. Download JDK from http://www.oracle.com/technetwork/java/javase/downloads/server-jre8-downloads-2133154.html, move to OracleJava/java-8:
sh build.sh

4º Build Oracle Oracle FMW 12c Infrastructure base image. Download 12.2.1.0.0 FMW distribution from http://www.oracle.com/technetwork/middleware/weblogic/downloads/wls-for-dev-1703574.html and Reports & Forms distribution fmw_12.2.1.0.0_fr_linux64.bin. Move to OracleWebLogic/dockerfiles.
sh buildDockerImage.sh -v 12.2.1 -i

5º Extend previously created Oracle Oracle FMW 12c Infrastructure base image. Move to OracleWebLogic/samples.
sudo docker build -t oracle:weblogicInfraDomain 1221-domain --network oranet --build-arg ADMIN_PASSWORD=Weblogic12C17 --build-arg PRODUCTION_MODE=dev --build-arg DEBUG_FLAG=false --build-arg DB_HOST=DB12cRCU --build-arg DB_SERVICE=xe.oracle.docker --build-arg DB_USER_PW=oracleDocker17 --build-arg DB_USER_ADMIN=SYS --build-arg SCHEMA_PREFIX=DEVREP --build-arg REPORTS12C=true --build-arg FORMS12C=false

6º Run a Docker image:
docker run -d --name wlsadminInfra --hostname wlsadminInfra --network oranet -p 7001:7001 -v /var/container-volumes/reports:/usr/reports -p 7002:7002 -p 9001:9001 -p 9002:9002 -p 8453:8453 oracle:weblogicInfraDomain


### Post-Installation for Reports Server
**IMPORTANT:** This tasks I would liked to be fully unattended with some scripts as others image build commands, but due to lack of time, I stoped development.

1º Get inside container:
docker exec -ti wlsadminInfra /bin/bash

2º With nano (as my favourite text editor), modify nodemanager.properties to set StopScriptEnabled=true and StartScriptEnabled=true
nano nodemanager/nodemanager.properties

3º Start Admin Server Node Manager:
nohup ./bin/startNodeManager.sh &

4º With WLST create ReportsToolsInstance and ReportsServerInstance
wlst
connect("weblogic","Weblogic12C17","wlsadminInfra:7001")
createReportsToolsInstance(instanceName='reptools1',machine='AdminServerMachine')
createReportsServerInstance(instanceName='rep_server1',machine='AdminServerMachine')

5º Start rep_server1 (will ask for Weblogic admin password, in this example Weblogic12C17)
./bin/startComponent.sh rep_server1 storeUserConfig

6º From the Weblogic Admin console, start Managed Reports Server http://localhost:7001/console/

7º With nano, review all this files to ensure they are equal to his template inside /container-scripts
	nano /u01/oracle/user_projects/domains/base_domain/config/fmwconfig/components/ReportsServerComponent/rep_server1/rwserver.conf
	nano /u01/oracle/user_projects/domains/base_domain/config/fmwconfig/servers/ManagedServer\@RepSrv2c8afa13641e/applications/reports_12.2.1/configuration/rwserver.conf
	nano /u01/oracle/user_projects/domains/base_domain/config/fmwconfig/servers/ManagedServer\@RepSrv2c8afa13641e/applications/reports_12.2.1/configuration/rwservlet.properties
	nano /u01/oracle/user_projects/domains/base_domain/config/fmwconfig/servers/ManagedServer\@RepSrv2c8afa13641e/applications/reports_12.2.1/configuration/cgicmd.dat

8º Stop rep_server1
./bin/stopComponent.sh rep_server1

9º From the Weblogic Admin console, stop Managed Reports Server http://localhost:7001/console/

10º Start again Start rep_server1
./bin/startComponent.sh rep_server1 storeUserConfig

11º Start again from the Weblogic Admin console Managed Reports Server http://localhost:7001/console/

**IMPORTANT:** I didn´t needed to get Forms Server work, so simply I didn´t test it. Feel free to test and share your improvements to get it up and working.

## Localization and NLS
I made changes to set local time to Spain, global NLS to SPANISH_SPAIN.WE8ISO8859P15 and envid NLS_LANG to SPANISH_SPAIN.WE8ISO8859P1

### Why FMW 12.2.1.0.0 version
I Tested with all this scripts and docker files to build 12.2.1.3 and 12.2.1.2 and for an unknown reason to me, this images didn´t work or simply failed to build. If you made improvements to build this new distribution version, let me know.
  
**IMPORTANT:** Only tested for development purpose, if you intend to use for production, do it at your own risk.
 

### RCU silent execution
During image build, RCU is executed in silent mode, so if need to change example´s SYS password (oracleDocker17) for Repository DB, you need to edit passwordfile.txt on /container-scripts. First password is SYS password of DB, and second line is password for new repository schemas. I recomend you to set it the same, or you will need to modify crFRExtension.py script and Dockerfile.


### TO DO
As I wrote don´t have much time right now to improve this images, so feel free to make them better and share your improvements, I will review and commit to this project.
If there is more people interested on this project, I will try to find some time to finish my work.

 * Make scripts to avoid manual post-installation tasks
 
 * Build and test 12.2.1.2 and 12.2.1.3 versions
 
 * Test and provide needed post-installation to Forms Server
 
 * Test and make needed scripts to create separated Managed servers on linked containers (I have this configuration working with Weblogic 12c generic distribution. No repository needed) 

 