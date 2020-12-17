FROM gradle:6.3-jdk8 as builder
ARG HGDP=/home/gradle/spring-boot-docker
RUN mkdir -p ${HGDP}/dependency \
         && mkdir -p ${HGDP}/libs
WORKDIR ${HGDP}/spring-boot-docker
COPY build.gradle gradlew ./
COPY src src
COPY gradle ./gradle
RUN ./gradlew build --info
WORKDIR ${HGDP}/dependency
RUN pwd && ls -al && find ${HGDP} -type f && jar -xf ../spring-boot-docker/build/libs/*.jar && find .

FROM openjdk:8-jre-alpine
RUN mkdir -p /app
RUN addgroup -S gradle && adduser -S gradle -G gradle
USER gradle:gradle
ARG DEPENDENCY=/home/gradle/spring-boot-docker/dependency 
COPY --from=builder ${DEPENDENCY}/BOOT-INF/lib /app/lib
COPY --from=builder ${DEPENDENCY}/META-INF /app/META-INF
COPY --from=builder ${DEPENDENCY}/BOOT-INF/classes /app
# Default command, run app
ENTRYPOINT ["java","-cp","app:app/lib/*","hello.Application"]
