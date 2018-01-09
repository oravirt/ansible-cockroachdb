# Oracle defaults & customizations
VALID_VERSIONS  = ['12.2.0.1','12.1.0.2','12.1.0.1','11.2.0.4','11.2.0.3']
if ENV['dbver']
 DBVER = ENV['dbver']
else
 DBVER = '12.2.0.1'
end
if ENV['giver']
 GIVER = ENV['giver']
else
 GIVER = '12.2.0.1'
end
if ENV['dbtype']
 DBTYPE = ENV['dbtype']
else
 DBTYPE = 'SI'
end
if ENV['dbstorage']
 DBSTORAGE = ENV['dbstorage']
else
 DBSTORAGE = 'FS'
end
if ENV['dbname']
 DBNAME = ENV['dbname']
else
 DBNAME = 'orcl'
end
if ENV['cdb']
 CDB = ENV['cdb']
else
 CDB = "false"
end
if ENV['pdbname']
 PDBNAME = ENV['pdbname']
else
 PDBNAME = "orclpdb"
end
if ENV['numpdbs']
 NUMPDBS = ENV['numpdbs']
else
 NUMPDBS = "0"
end
if ENV['dbmem']
 DBMEM = ENV['dbmem']
else
 DBMEM = "1024"
end
if ENV['ron_service']
 RON_SERVICE = ENV['ron_service']
else
 RON_SERVICE = "#{DBNAME}_serv"
end

if VALID_VERSIONS.include? DBVER
else
 puts
 puts "valid versions are: #{VALID_VERSIONS}"
 puts "Your choice - dbver: #{DBVER} & giver: #{GIVER}"
 puts "exiting"
 exit 99
end

if VALID_VERSIONS.include? GIVER
else
 puts
 puts "valid versions are: #{VALID_VERSIONS}"
 puts "Your choice - dbver: #{DBVER} & giver: #{GIVER}"
 puts "exiting"
 exit 99
end

if DBVER > GIVER
 puts
 puts "The Grid Infrastructure version (giver) must be higher or the same as the Database version (dbver)"
 puts "Your choice - dbver: #{DBVER} & giver: #{GIVER}"
 puts "exiting"
 exit 99
end

ORACLE_DATABASES = [{
home: "db1",
oracle_version_db: "#{DBVER}",
oracle_edition: "EE",
oracle_db_name: "#{DBNAME}",
oracle_db_passwd: "Oracle123",
oracle_db_type: "#{DBTYPE}",
is_container: "#{CDB}",
pdb_prefix: "#{PDBNAME}",
num_pdbs: "#{NUMPDBS}",
storage_type: "#{DBSTORAGE}",
service_name: "#{RON_SERVICE}",
oracle_db_mem_totalmb: "#{DBMEM}",
oracle_database_type: "MULTIPURPOSE",
redolog_size_in_mb: "100",
state: "present"
}]
# End Oracle customizations
