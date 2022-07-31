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
# all runs as user oracle, let's put all config 
RUN mkdir -p /home/oracle 
COPY odbcinst.ini                           /home/oracle/.odbcinst.ini
COPY odbc.ini                               /home/oracle/.odbc.ini
COPY initYORA.ora                           /home/oracle
COPY listener.ora                           /home/oracle
COPY tnsnames.ora                           /home/oracle
RUN chown -R oracle:oinstall /home/oracle
USER oracle
# for whatever reason an ifile there crashes the listenet, so using symbolic link
RUN ln -s /home/oracle/initYORA.ora $ORACLE_HOME/hs/admin/initYORA.ora
RUN echo "ifile=/home/oracle/listener.ora" >> $ORACLE_HOME/network/admin/listener.ora
RUN echo "ifile=/home/oracle/tnsnames.ora" >> $ORACLE_HOME/network/admin/tnsnames.ora
COPY odbcinst.ini                           /etc/.odbcinst.ini
COPY odbc.ini                               /etc/.odbc.init
# PGHOST PGPORT and PGDATABASE will be set when running the container
# PGUSER and PGPASSWORD will be ignored as passed by the Oracle DB Link 
# PGSSLMODE doesn't seem to be used by pgodbc, need to have it in odbc.ini
ENV PGDATABASE yugabyte
ENV PGHOST localhost
ENV PGPORT 5433
ENV PGAPPNAME yora-gateway
ENV PGUSER yugabyte
ENV PGPASSWORD yugabyte
ENV PGSSLMODE allow
# the port is defined in listener.ora
EXPOSE 1520
# moving the log directory to /home/oracle (trace level is set in initYORA.ora)
RUN mv $ORACLE_HOME/hs/log /home/oracle/log && ln -s /home/oracle/log $ORACLE_HOME/hs/log 
# can mount /home/oracle to put configuration and logs in a volume
WORKDIR /home/oracle
VOLUME /home/oracle
ENTRYPOINT bash -c '$ORACLE_HOME/bin/lsnrctl start YORA ; tail -F /opt/oracle/diag/tnslsnr/*/yora/trace/yora.log'
