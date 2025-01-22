# MySQL InnoDB Cluster Setup Guide

This repository contains a Docker-based setup for a MySQL InnoDB Cluster with three MySQL server nodes and a MySQL Router for connection routing and load balancing.

## Architecture Overview

The setup consists of:
- 3 MySQL Server nodes (mysql-server-1, mysql-server-2, mysql-server-3) running in Group Replication mode
- 1 MySQL Router instance for handling client connections
- All components running in Docker containers with defined networking

## Prerequisites

- Docker and Docker Compose installed on your system
- Basic understanding of MySQL and Docker concepts
- Minimum 4GB RAM available for the cluster

## Quick Start

1. Start the cluster:
```bash
docker-compose up -d
```

2. Configure the InnoDB Cluster:
```bash
# Connect to the first MySQL server
docker exec -it mysql-server-1 mysqlsh --uri root:root@localhost:3306

# In MySQL Shell (JavaScript mode), run:
\js

# Configure each instance
dba.configureInstance('root@localhost:3306', {clusterAdmin: 'gradmin', clusterAdminPassword: 'grpass'})
dba.configureInstance('root@mysql-server-2:3306', {clusterAdmin: 'gradmin', clusterAdminPassword: 'grpass'})
dba.configureInstance('root@mysql-server-3:3306', {clusterAdmin: 'gradmin', clusterAdminPassword: 'grpass'})

# Create the cluster
var cluster = dba.createCluster('myCluster')

# Add remaining instances
cluster.addInstance('root@mysql-server-2:3306', {recoveryMethod: 'clone'})
cluster.addInstance('root@mysql-server-3:3306', {recoveryMethod: 'clone'})

# Verify cluster status
cluster.status()

# When you want to get the cluster when not creating
var cluster = dba.getCluster()
```

3. Configure MySQL Router:
```bash
    docker exec -it mysql-router mysqlrouter --bootstrap gradmin:grpass@mysql-server-1:3306 --user=mysqlrouter --force
```

4. Restart the router:
```bash
docker restart mysql-router
```

5. Connect to the cluster through MySQL Router:
```bash
mysql -h127.0.0.1 -P6446 -uroot -proot
```

## Port Mapping

- MySQL Servers:
    - mysql-server-1: 3301:3306
    - mysql-server-2: 3302:3306
    - mysql-server-3: 3303:3306

- MySQL Router:
    - Read-Write port: 6446
    - Read-Only port: 6447
    - X Protocol R/W port: 64460
    - X Protocol RO port: 64470

## Configuration Details

### MySQL Servers

Each MySQL server is configured with:
- GTID mode enabled
- Binary logging
- Group replication settings
- Health checks
- Persistence through Docker volumes

Key configuration parameters:
```yaml
- binlog-format=ROW
- enforce-gtid-consistency=ON
- gtid-mode=ON
- transaction-write-set-extraction=XXHASH64
```

### MySQL Router

The router is configured to:
- Automatically bootstrap against the cluster
- Provide read-write and read-only splitting
- Handle failover automatically

## Troubleshooting

1. If servers need to be restarted after adding them to the cluster:
```bash
docker restart mysql-server-2 mysql-server-3
```

2. To check cluster status:
```bash
# Connect to any server
docker exec -it mysql-server-1 mysqlsh --uri root:root@localhost:3306
\js
var cluster = dba.getCluster()
cluster.status()
```

3. To view container logs:
```bash
docker logs mysql-server-1
docker logs mysql-router
```

## Maintenance

### Backup and Restore

The cluster data is persisted in Docker volumes:
- mysql_data_1
- mysql_data_2
- mysql_data_3

To backup these volumes, use Docker volume backup procedures.

### Scaling

The current setup uses three nodes, which is the recommended minimum for high availability. To add more nodes:
1. Add new service definition in docker-compose.yml
2. Follow the same configuration pattern
3. Add the new instance to the cluster using `cluster.addInstance()`

## Security Notes

- Default credentials are set for development. For production:
    - Change all passwords
    - Configure SSL/TLS
    - Restrict network access
    - Follow MySQL security best practices

## Limitations

- The current setup uses development-friendly defaults
- No SSL/TLS configuration included
- Basic monitoring setup

## Contributing

When contributing to this setup:
1. Test changes locally first
2. Update documentation as needed
3. Follow existing configuration patterns
4. Test cluster stability after changes