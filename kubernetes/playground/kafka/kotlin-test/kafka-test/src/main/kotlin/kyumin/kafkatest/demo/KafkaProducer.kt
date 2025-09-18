package kyumin.kafkatest.demo

import org.springframework.http.ResponseEntity
import org.springframework.kafka.core.KafkaTemplate
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RequestParam
import org.springframework.web.bind.annotation.RestController

@RestController
@RequestMapping("/kafka")
class KafkaProducer (
    private val kafkaTemplate: KafkaTemplate<String, String>
) {

    @PostMapping("/send")
    fun send(@RequestParam message: String): ResponseEntity<String> {
        kafkaTemplate.send("test-topic", message)
        return ResponseEntity.ok("Sent message: $message")
    }

}