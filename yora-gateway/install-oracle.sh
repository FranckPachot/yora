# install Oracle XE (it has a lot more than the gateway, but this bundle is free from licence nightmare)
curl -Lqso oracle-database-xe.rpm          https://download.oracle.com/otn-pub/otn_software/db-express/oracle-database-xe-18c-1.0-1.x86_64.rpm
curl -Lqso oracle-database-preinstall.rpm  https://yum.oracle.com/repo/OracleLinux/OL7/latest/x86_64/getPackage/oracle-database-preinstall-18c-1.0-1.el7.x86_64.rpm
yum localinstall -y *.rpm || exit 1
# remove large useless things (can do more if there's a need for a smaller container)
cd $ORACLE_HOME/bin && rm -f oracle afdboot rman
cd $ORACLE_HOME/lib && rm -f libra.so libosbws.so libopc.so ra_hpux_ia64.zip libcrs18.so libmkl* ra* libolapapi18.so libhasgen18.so *avx*
cd $ORACLE_HOME && rm -rf assistants md inventory jdk javavm ctx rdbms dmu perl R jlib OPatch cv sdk jdbc oui install
rm -rf /var/cache/yum 
