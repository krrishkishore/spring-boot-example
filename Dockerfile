FROM gradle:6.3-jdk8 as builder
ARG HGDP=/home/gradle/project
RUN mkdir -p ${HGDP}/spring-boot-docker/dependency \
         && mkdir -p ${HGDP}/spring-boot-docker/libs
WORKDIR ${HGDP}/spring-boot-docker/spring-boot-docker
COPY build.gradle gradlew src ./
COPY gradle ./gradle
RUN gradle clean build --info
WORKDIR ${HGDP}/spring-boot-docker/dependency
RUN jar -xf ../spring-boot-docker/build/libs/*.jar && jar -tvf ${HGDP}/spring-boot-docker/spring-boot-docker/build/libs/spring-boot-example-0.1.0.jar

FROM openjdk:8-jre-alpine
RUN mkdir -p /app
RUN addgroup -S gradle && adduser -S gradle -G gradle
USER gradle:gradle
ARG DEPENDENCY=/home/gradle/project/spring-boot-docker/dependency 
COPY --from=builder ${DEPENDENCY}/BOOT-INF/lib /app/lib
COPY --from=builder ${DEPENDENCY}/META-INF /app/META-INF
COPY --from=builder ${DEPENDENCY}/BOOT-INF/classes /app
# Default command, run app
ENTRYPOINT ["java","-cp","app:app/lib/*","hello.Application"]
