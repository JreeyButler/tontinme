#!/bin/sh
#
#���MySQL�����Ƿ����У����Ҹ��ݾ���Ĵ�������Զ��ж��Ƿ����
#

now=`date + "%Y%m%d%H%M%S"`
statFile="./slave_status.$now"
echo "show slave status\G" | mysql -uroot > $statFile

ioStat=`cat $statFile | grep Slave_IO_Running | awk '{print $2}'`
sqlStat=`cat $statFile | grep Slave_SQL_Running | awk '{print $2}'`
errno=`cat $statFile | grep Last_Errno | awk '{print $2}'`

#ioStat=`cat $statFile | head -n 12 | tail -n 1 | awk '{print $2}'`
#sqlStat=`cat $statFile | head -n 13 | tail -n 1 | awk '{print $2}'`
#errno=`cat $statFile | head -n 20 | tail -n 1 | awk '{print $2}'`

if [ $ioStat = 'No' ] || [$sqlStat = 'No' ]; then
	echo "chkslave"
	date
	#����������Ϊ0�����������Ϊ�����ԭ���¸����жϣ�ֱ���������Ƽ���
	if [ "$errno" -eq 0 ]; then
		echo "start slave io_thread; start slave sql_thread;" | mysql -uroot
		echo "start slave io_thread; start slave sql_thread;"
	#�����һЩ���Ǻ�Ҫ���Ĵ�����룬Ҳ����ֱ���Թ�
	elif [ "$errno" -eq 1007 ] || [ "$errno" -eq 1053 ] || [ "$errno" -eq 1062 ] || [ "$errno" -eq 1213 ]\
	       	|| [ "$errno" -eq 1158 ] || [ "$errno" -eq 1159 ] || [ "$errno" -eq 1008 ]; then
		echo "stop slave; set global sql_slave_skip_counter=1; slave start;" | mysql -uroot
		echo "stop slave; set global sql_slave_skip_counter=1; slave start;"
	else
		echo `date` "slave is donw!!!"
	fi

	#ɾ����ʱ״̬�ļ�
	rm -f $statFile
	echo "[/chkslave]"
fi
