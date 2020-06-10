mkdir -p /var/local/fdfs/storage/data /var/local/fdfs/tracker /var/local/fdht
sed -i "s/^http.server_port.*$/http.server_port = 80/g" /etc/fdfs/storage.conf

IP=`ifconfig eth0 | grep inet | awk '{print $2}'| awk -F: '{print $2}'`
if [ "$XIP" = "" ]; then
    XIP=$IP
fi
sed -i "s/^tracker_server.*$/tracker_server = $IP:22122/" /etc/fdfs/client.conf
sed -i "23d" /etc/fdfs/client.conf
sed -i "s/^tracker_server.*$/tracker_server = $IP:22122/" /etc/fdfs/storage.conf
sed -i "146d" /etc/fdfs/storage.conf
sed -i "s/^tracker_server.*$/tracker_server = $IP:22122/" /etc/fdfs/mod_fastdfs.conf
sed -i "s/^group0.*$/group0=$IP:11411/" /etc/fdht/fdht_servers.conf
sed -i "4d" /etc/fdht/fdht_servers.conf
sed -i "s/^check_file_duplicate.*$/check_file_duplicate = 1/g" /etc/fdfs/storage.conf
sed -i "s/^keep_alive.*$/keep_alive = 1/g" /etc/fdfs/storage.conf
sed -i "s/^##include \/home\/yuqing\/fastdht\/conf\/fdht_servers.conf/#include \/etc\/fdht\/fdht_servers.conf/g" /etc/fdfs/storage.conf

# config storage_ids.conf
sed -i '/^100001 / s/^\(.*\)$/100001   group1  $IP,$XIP:$XPORT/g' /etc/fdfs/storage_ids.conf
sed -i '/^100002 / s/^\(.*\)$/#\1/g' /etc/fdfs/storage_ids.conf
sed -i "s/use_storage_id = false/use_storage_id = true/g" /etc/fdfs/client.conf
sed -i "s/use_storage_id = false/use_storage_id = true/g" /etc/fdfs/tracker.conf

/etc/init.d/fdfs_trackerd start
/usr/local/bin/fdhtd /etc/fdht/fdhtd.conf
/etc/init.d/fdfs_storaged start
/usr/local/nginx/sbin/nginx
tail -f /usr/local/nginx/logs/access.log
