# Install PostgreSQL ODBC driver (and psql for troubleshooting)
yum -y install https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm
yum-config-manager --enable ol7_developer_EPEL ol7_developer
yum -y install postgresql14-odbc postgresql
rm -rf /var/cache/yum 
