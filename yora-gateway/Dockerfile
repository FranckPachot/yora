FROM centos:7
USER root
COPY install-oracle.sh                      /opt/install-oracle.sh
RUN sh /opt/install-oracle.sh
COPY install-pgodbc.sh                      /opt/install-pgodbc.sh
RUN sh /opt/install-pgodbc.sh
USER oracle
ENV ORACLE_HOME /opt/oracle/product/18c/dbhomeXE
COPY initYORA.ora                           $ORACLE_HOME/hs/admin
COPY listener.ora                           $ORACLE_HOME/network/admin
COPY tnsnames.ora                           $ORACLE_HOME/network/admin
ENV PGDATABASE yugabyte
ENV PGUSER yugabyte
ENV PGPASSWORD yugabyte
ENV PGHOST localhost
ENV PGPORT 5433
EXPOSE 1520
WORKDIR $ORACLE_HOME/hs/log
ENTRYPOINT bash -c '$ORACLE_HOME/bin/lsnrctl start YORA ; tail -F /opt/oracle/diag/tnslsnr/*/yora/trace/yora.log'
