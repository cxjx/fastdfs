mkdir -p /var/local/fdfs/storage/data /var/local/fdfs/tracker /var/local/fdht; 
sed -i "s/listen\ .*$/listen\ $WEB_PORT;/g" /usr/local/nginx/conf/nginx.conf; 
sed -i "s/http.server_port=.*$/http.server_port=$WEB_PORT/g" /etc/fdfs/storage.conf; 
if [ "$IP" = "" ]; then 
    IP=`ifconfig eth0 | grep inet | awk '{print $2}'| awk -F: '{print $2}'`; 
fi 
sed -i "s/^tracker_server=.*$/tracker_server=$IP:$FDFS_PORT/" /etc/fdfs/client.conf; 
sed -i "s/^tracker_server=.*$/tracker_server=$IP:$FDFS_PORT/" /etc/fdfs/storage.conf; 
sed -i "s/^tracker_server=.*$/tracker_server=$IP:$FDFS_PORT/" /etc/fdfs/mod_fastdfs.conf; 
sed -i "s/^group0.*$/group0=$IP:$FDHT_PORT/" /etc/fdht/fdht_servers.conf; 
sed -i "4d" /etc/fdht/fdht_servers.conf; 
sed -i "s/^check_file_duplicate=.*$/check_file_duplicate=1/g" /etc/fdfs/storage.conf; 
sed -i "s/^keep_alive=.*$/keep_alive=1/g" /etc/fdfs/storage.conf; 
sed -i "s/^##include \/home\/yuqing\/fastdht\/conf\/fdht_servers.conf/#include \/etc\/fdht\/fdht_servers.conf/g" /etc/fdfs/storage.conf; 
/etc/init.d/fdfs_trackerd start; 
/usr/local/bin/fdhtd /etc/fdht/fdhtd.conf; 
/etc/init.d/fdfs_storaged start; 
/usr/local/nginx/sbin/nginx; 
tail -f /usr/local/nginx/logs/access.log