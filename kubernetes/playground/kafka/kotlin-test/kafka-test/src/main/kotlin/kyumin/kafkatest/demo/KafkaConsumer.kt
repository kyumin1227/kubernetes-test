package kyumin.kafkatest.demo

import org.springframework.kafka.annotation.KafkaListener
import org.springframework.stereotype.Component

@Component
class KafkaConsumer {
    @KafkaListener(topics = ["test-topic"], groupId = "kafka-test")
    fun listen(message: String) {
        println("Received message: $message")
    }
}