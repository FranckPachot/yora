#docker build -t pachot/yora-gateway . || exit
#docker rm -f xe 
#docker rm -f yora-gateway
docker run -d --name yora-gateway -p 1520:1520 --hostname yora-gateway     \
 -e PGHOST=yb1.pachot.net -e PGDATABASE=yugabyte -e PGAPPNAME=yora_gateway \
 pachot/yora-gateway
docker run -d --name xe -p 1521:1521 --link yora-gateway                   \
-e ORACLE_PASSWORD=manager gvenzl/oracle-xe:slim
until docker logs xe | grep "Completed: ALTER DATABASE OPEN" ; do sleep 1 ; done
{
docker exec -i xe sqlplus system/manager @ /dev/stdin <<'SQL'
set echo on
drop public database link "yb";
whenever sqlerror exit failure
create public database link "yb" connect to "yugabyte" identified by "yugabyte" using '(DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=yora-gateway)(PORT=1520))(CONNECT_DATA=(SID=YORA))(HS=OK))';
select "query" as "Oracle query as seen from YugabyteDB" from "pg_stat_activity"@"yb";
SQL
} || exit
echo "All works"
#docker build --squash -t pachot/yora-gateway . || exit
#docker push pachot/yora-gateway . || exit
