#!/bin/bash
#

if [ "${REPORTS12C}" = "true" ] || [ "${FORMS12C}" = "true" ]; then echo $DB_USER_PW|/u01/oracle/oracle_common/bin/rcu -silent -dropRepository -connectString $DB_HOST:$DB_PORT:$DB_SERVICE -dbUser $DB_USER_ADMIN -dbRole SYSDBA -schemaPrefix $SCHEMA_PREFIX -component OPSS -component IAU -component IAU_APPEND -component IAU_VIEWER -component STB -f || { echo \"Fail to delete repo, schema doesn´t exists\" ; : ; }; fi

if [ "${REPORTS12C}" = "true" ] || [ "${FORMS12C}" = "true" ]; then /u01/oracle/oracle_common/bin/rcu -silent -createRepository -selectDependentsForComponents true -useSamePasswordForAllSchemaUsers true -connectString $DB_HOST:$DB_PORT:$DB_SERVICE -dbUser $DB_USER_ADMIN -dbRole SYSDBA -schemaPrefix $SCHEMA_PREFIX -component OPSS -component STB -f < passwordfile.txt; fi

rm passwordfile.txt
