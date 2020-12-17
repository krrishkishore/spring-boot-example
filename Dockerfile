FROM gradle:6.3-jdk8 as builder
RUN mkdir -p /home/gradle/project/spring-boot-example/dependency \
         && mkdir -p /home/gradle/project/spring-boot-example/libs
WORKDIR /home/gradle/project/spring-boot-example/spring-boot-example
COPY build.gradle gradlew src ./
COPY gradle ./gradle
RUN ./gradlew build --info
WORKDIR /home/gradle/project/spring-boot-example/dependency
RUN jar -xf ../libs/*.jar

FROM openjdk:8-jre-alpine
RUN mkdir -p /app
RUN addgroup -S gradle && adduser -S gradle -G gradle
USER gradle:gradle
ARG DEPENDENCY=/home/gradle/project/spring-boot-example/dependency 
COPY --from=builder ${DEPENDENCY}/BOOT-INF/lib /app/lib
COPY --from=builder ${DEPENDENCY}/META-INF /app/META-INF
COPY --from=builder ${DEPENDENCY}/BOOT-INF/classes /app
# Default command, run app
ENTRYPOINT ["java","-cp","app:app/lib/*","hello.Application"]
