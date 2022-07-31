# yora-gateway

builds a Docker image that contains:
- Oracle Heterogenous Services listener with ODBC Gateway
- PostgreSQL client and ODBC driver

Built with:
```
docker build -t pachot/yora-gateway .
```
Run with:
```
docker run -d --name yora-gateway -p 1520:1520 --hostname yora-gateway \
 -e PGHOST=yb1.pachot.net -e PGDATABASE=yugabyte -e PGAPPNAME=yora-gateway \
 pachot/yora-gateway

docker inspect yora-gateway \
 --format '{{ .NetworkSettings.IPAddress }}'
```
This listens on port 1520 for a service 'YORA' and connects to the PostgreSQL (or YugabyteDB) defined by PG environment variables PGHOST and PGPORT. I display the IP address to be used in the connection string for the DB Link if I start Oracle from another container, but you probably used the port exposed to the docker host because Oracle Database is not very container friendly.

Note that, apparently, PGSSLMODE is not used and this is why I've put it in `/etc/odbc.ini`
You don't set PGUSER and PGPASSWORD here because they will be defined in the database link

Here is an example:

The log shows the service startup and then a tail of the listener log where you can see incoming connections
```
docker logs yora-gateway
```

Note that you will see `Instance "YORA", status UNKNOWN` which is expected because the listener doesn't verify the status.

In an Oracle Database, you can create a database link as:
```
create public database link "yb" connect to "yugabyte" identified by "yugabyte" using '(DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=yora-gateway)(PORT=1520))(CONNECT_DATA=(SID=YORA))(HS=OK))';
```
Here `yora-gateway` is the host where the port 1520 is exposed, either the container if you run Oracle in a container on the same docker network, or the host where the port is exposed with `-p 1520:1521`


### Example

If you want to test, you can:
- create a YugabyteDB database in a container or on Yugabyte Cloud
- start an Oracle XE and create a database link:
```
docker run -d --name xe -p 1521:1521 --link yora-gateway -e ORACLE_PASSWORD=manager gvenzl/oracle-xe:slim
until docker logs xe | grep "Completed" ; do sleep 1 ; done
#
docker exec -i xe sqlplus system/manager @ /dev/stdin <<'SQL'
set echo on
create public database link "yb" connect to "yugabyte" identified by "yugabyte" using '(DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=yora-gateway)(PORT=1520))(CONNECT_DATA=(SID=YORA))(HS=OK))';
select "query" as "Oracle query as seen from YugabyteDB" from "pg_stat_activity"@"yb";
SQL
#
```
You can see your query running on the PostgreSQL instance by querying `pg_stat_activity`, a PostgreSQL view, from `sqlplus` connected to Oracle:
```
select "query" as "Oracle query as seen from YugabyteDB" from "pg_stat_activity"@"yugabyte";

Oracle query as seen from YugabyteDB
--------------------------------------------------------------------------------
SELECT A1."query" FROM "pg_stat_activity" A1
```
This is what it looks like with the logs of `yora-gateway` and the query from `sqlplus`
![screenshot](https://user-images.githubusercontent.com/33070466/181782294-abd58ba4-ab5f-4e43-9db6-78aa5973f2e9.png)

### Summary of settings

- The PostgreSQL __user__ and __password__ are passed from the Oracle Database Link `connect to` and `identified by`
- The PostgreSQL __server__ and __port__ are passed in the gateway environment with `PGHOST` and `PGPORT`
- other LibPQ environement variables can be passed, like PGAPPNAME to identify the sessions
- the __SSL mode__ is passed in `odbc.ini` because PGSSLMODE is ignored (see Issue #1). If you need certificates, you can mount a volume to `/home/oracle` with a custom `.odbc.ini` and certificates
- the gateway exposes port 1520 (this is defined in `listener.ora`) and listens for service YORA
- the Oracle database connects to it though the `using` connection string which contains `(HOST=)(PORT=)` to address it, `(SID=YORA)` for the service, and `(HS=OK)` as the target is not an Oracle Database (Heterogenous Service)
- additional parameters can be passed in `initYORA-ora` according to [Oracle Gateway documentation](https://docs.oracle.com/en/database/oracle/oracle-database/18/odbcu/database-gateway-odbc-initialization-parameters.html#GUID-91C9D84C-7B7D-483C-8A0A-4CADC17FC8DB).




