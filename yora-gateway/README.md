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
docker run -d --name yora-gateway -p 1520:1520 --hostname yora-gateway -e PGHOST=yb1.pachot.net -e PGDATABASE=yugabyte pachot/yora-gateway
```
This listens on port 1520 (for Oracle Database DB Links) for a service 'YORA' and connects to the PostgreSQL (or YugabyteDB) defined by PG environment variables
The log shows the service startup and then a tail of the listener log where you can see incoming connections
```
docker logs yora-gateway
```

In an Oracle Database, you can create a database link as:
```
create public database link "yb" connect to "yugabyte" identified by "yugabyte" using '(DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=172.17.0.2)(PORT=1520))(CONNECT_DATA=(SID=YORA))(HS=OK))';
```

### Example

If you want to test, you can:
- create a YugabyteDB database on Yugabyte Cloud
- start an Oracle XE with:
```
docker run -d --name xe -p 1521:1521 -e ORACLE_PASSWORD=manager gvenzl/oracle-xe:slim
until docker logs xe | grep "Completed" ; do sleep 1 ; done
#
docker exec -i xe sqlplus system/manager @ /dev/stdin <<'SQL'
set echo on
create public database link "yb" connect to "yugabyte" identified by "yugabyte" using '(DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=172.17.0.2)(PORT=1520))(CONNECT_DATA=(SID=YORA))(HS=OK))';
select "query" as "Oracle query as seen from YugabyteDB" from "pg_stat_activity"@"yb";
SQL
#
```
Then connect to the XE instance (`localhost:1521/XE`) and create the database link.
You can see your query running on the PostgreSQL instance by querying `pg_stat_activity`:
```
select "query" as "Oracle query as seen from YugabyteDB" from "pg_stat_activity"@"yugabyte";

Oracle query as seen from YugabyteDB
--------------------------------------------------------------------------------
SELECT A1."query" FROM "pg_stat_activity" A1
```
This is what it looks like with the logs of `yora-gateway` and the query from `sqlplus`
![screenshot](https://user-images.githubusercontent.com/33070466/181782294-abd58ba4-ab5f-4e43-9db6-78aa5973f2e9.png)
