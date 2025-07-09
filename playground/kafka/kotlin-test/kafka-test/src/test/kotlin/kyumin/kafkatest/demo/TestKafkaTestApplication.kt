package kyumin.kafkatest.demo

import org.springframework.boot.fromApplication
import org.springframework.boot.with


fun main(args: Array<String>) {
	fromApplication<KafkaTestApplication>().with(TestcontainersConfiguration::class).run(*args)
}
