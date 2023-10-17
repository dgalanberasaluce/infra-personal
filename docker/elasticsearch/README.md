# ElasticSearch

**References**
- https://www.elastic.co/blog/getting-started-with-the-elastic-stack-and-docker-compose


**Notes**
- Configure virtual memory: https://www.elastic.co/guide/en/elasticsearch/reference/current/docker.html#_macos_with_docker_for_mac
- Kibana exposed on https://localhost:5601
- ElasticSearch exposed on https://localhost:9200
- the configurations files are using bind mounts that will retain the same permissions and ownership within the container that they have on the host system
- Metricbeat is configured to expose host information regarding processes, filesystem and the docker daemon
- Metricbeat is configured for monitoring the container's host through `/var/run/docker.sock`
- 

```
# Start containers
docker-compose up --d

# Copy certificate
docker-compose cp elasticsearch-es01-1:/usr/share/elasticsearch/config/certs/ca/ca.crt ./tmp/

# Query elasticsearch node
curl --cacert ./tmp/ca.crt -u elastic:changeme https://localhost:9200
```


