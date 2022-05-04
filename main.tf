#Create kafka cluster with two brokers per AZ (6 brokers + 3 zk)
#Link to terraform documentation - https://registry.tfpla.net/providers/yandex-cloud/yandex/latest/docs/resources/mdb_kafka_cluster

resource "yandex_mdb_kafka_cluster" "foo" {
  name        = "test"
  environment = "PRODUCTION" //PRESTABLE or PRODUCTION 
  network_id  = var.default_network_id
  subnet_ids  = [var.default_subnet_id_zone_a, var.default_subnet_id_zone_b, var.default_subnet_id_zone_c]

  config {
    version          = "2.8" //version of the cluster
    brokers_count    = 1  //Count of brokers per availability zone. The default is 1
    zones            = ["ru-central1-a", "ru-central1-b", "ru-central1-c"]
    assign_public_ip = false //Determines whether each broker will be assigned a public IP address. The default is false
    unmanaged_topics = false //Allows to use Kafka AdminAPI to manage topics. The default is false
    schema_registry  = false //Enables managed schema registry on cluster. The default is false
    kafka {
      resources {
        resource_preset_id = "s2.micro" //resource_preset_id - types are in the official documentation
        disk_type_id       = "network-ssd" //disk_type_id - types are in the official documentation
        disk_size          = 32 //disk_size
      }
      kafka_config {
        compression_type                = "COMPRESSION_TYPE_ZSTD"
        log_flush_interval_messages     = 1024
        log_flush_interval_ms           = 1000
        log_flush_scheduler_interval_ms = 1000
        log_retention_bytes             = 1073741824
        log_retention_hours             = 168
        log_retention_minutes           = 10080
        log_retention_ms                = 86400000
        log_segment_bytes               = 134217728
        num_partitions                  = 10
        default_replication_factor      = 1 
      }
    }
  }

  user {
    name     = "producer-application"
    password = "password"
    permission {
      topic_name = "input"
      role = "ACCESS_ROLE_PRODUCER"
    }
  }

  user {
    name     = "worker"
    password = "password"
    permission {
      topic_name = "input"
      role = "ACCESS_ROLE_CONSUMER"
    }
    permission {
      topic_name = "output"
      role = "ACCESS_ROLE_PRODUCER"
    }
  }
}
