I want to test to read data from multiple postgres databases using [citus data](https://docs.citusdata.com/en/v12.1/get_started/what_is_citus.html) (open source distributed database engine) and [sparksql](https://spark.apache.org/sql/) for data ingestion and processing

The docker-compose file will create:
- 1 citus master node, 1 citus worker node. [dockerfile](https://github.com/citusdata/docker/blob/master/docker-compose.yml)
- 2 postgres node
- 1 spark master node
- 2 spark worker node
- 1 postgres node to load the transformed data