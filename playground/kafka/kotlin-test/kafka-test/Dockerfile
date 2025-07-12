# 빌드 스테이지
FROM openjdk:17-jdk-slim AS builder
WORKDIR /build

# 의존성 파일 복사 및 다운로드
COPY build.gradle.kts settings.gradle.kts ./
COPY gradle gradle
COPY gradlew gradlew.bat ./
RUN ./gradlew dependencies --no-daemon

# 소스 복사 및 빌드
COPY src src
RUN ./gradlew build -x test --no-daemon

# 실행 스테이지
FROM openjdk:17-jdk-slim
WORKDIR /app

# 빌드 스테이지에서 생성된 jar 파일만 복사
COPY --from=builder /build/build/libs/*.jar app.jar

# 기본 환경 변수 설정 (Helm values.yaml에서 오버라이드)
ENV KAFKA_BOOTSTRAP_SERVERS=${KAFKA_BOOTSTRAP_SERVERS}

# 포트 지정
EXPOSE 8080

# 애플리케이션 실행
ENTRYPOINT ["java", "-jar", "app.jar"]

