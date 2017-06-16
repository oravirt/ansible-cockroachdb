ps -ef |grep -i cockroach |grep -v grep  |kill -9 `awk '{print $2}'`
