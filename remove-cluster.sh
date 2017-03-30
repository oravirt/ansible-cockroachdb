ansible-playbook install-cockroachdb.yml -e hostgroup=cockroach -i inventory  -t remove_cluster -e remove_cluster=true
echo "Sleeping 5 seconds, then checking if processes are gone"
sleep 5
ansible cockroach -i inventory -m shell -a "ps -ef |grep -i cockroach |grep -v grep" -s

