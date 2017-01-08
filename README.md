# NewStack
Working on some technologies for a sample stack.

Nifi will stream data to a Kafka queue, to be processed by Spark and stored in a Cassandra database.  All services will run in Docker containers.  Some maybes are using Zeppelin to interface with Cassandra/Spark, and using Docker Swarm for distributed computing and scaling.
