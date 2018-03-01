#!/usr/bin/env bash

# shellcheck source=variables.env
source variables.env

# Create Topics
# shellcheck disable=SC2043
for key in 2; do
    # Create topic with x partitions and a retention size of 50MB, log segment
    # size of 20MB and compression type y.
    kafka-topics \
        --zookeeper localhost:${ZK_PORT} \
        --topic "${TOPICS[key]}" \
        --partitions "${PARTITIONS[key]}" \
        --replication-factor "${REPLICATION[key]}" \
        --config retention.bytes=26214400 \
        --config compression.type="${COMPRESSION[key]}" \
        --config segment.bytes=8388608 \
        --create
done

# Insert data without key
# shellcheck disable=SC2043
for key in 2; do
    /usr/local/bin/normcat -r "${RATES[key]}" -j "${JITTER[key]}" -p "${PERIOD[key]}" -c -v "${DATA[key]}" | \
        SCHEMA_REGISTRY_HEAP_OPTS="-Xmx50m" kafka-avro-console-producer \
            --broker-list localhost:${BROKER_PORT} \
            --topic "${TOPICS[key]}" \
            --property value.schema="$(cat "${VALUES[key]}")" \
            --property schema.registry.url=http://localhost:${REGISTRY_PORT}
done
