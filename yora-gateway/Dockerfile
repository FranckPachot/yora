FROM centos:7
USER root
# install Oracle XE to get Heterogeneous Services and ODBC Gateway for free
COPY install-oracle.sh                      /opt/install-oracle.sh
RUN sh /opt/install-oracle.sh
ENV ORACLE_BASE /opt/oracle
ENV ORACLE_HOME /opt/oracle/product/18c/dbhomeXE
# install PostgreSQL
COPY install-pgodbc.sh                      /opt/install-pgodbc.sh
RUN sh /opt/install-pgodbc.sh
# May be useful for troubleshooting
#RUN yum install -y sudo strace 
#RUN echo 'oracle ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
# all runs as user oracle
USER oracle
COPY odbcinst.ini                           /etc
COPY odbc.ini                               /etc
COPY initYORA.ora                           $ORACLE_HOME/hs/admin
COPY listener.ora                           $ORACLE_HOME/network/admin
COPY tnsnames.ora                           $ORACLE_HOME/network/admin
ENV PGDATABASE yugabyte
ENV PGUSER yugabyte
ENV PGPASSWORD yugabyte
ENV PGHOST localhost
ENV PGPORT 5433
ENV PGSSLMODE allow
# note that PGSSLMODE doesn't seem to be used by pgodbc, need to have it in odbc.ini
EXPOSE 1520
WORKDIR $ORACLE_HOME/hs/log
ENTRYPOINT bash -c '$ORACLE_HOME/bin/lsnrctl start YORA ; tail -F /opt/oracle/diag/tnslsnr/*/yora/trace/yora.log'
