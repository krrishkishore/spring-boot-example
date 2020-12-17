FROM openjdk:8-jdk-alpine as builder
RUN mkdir -p /app/dependency \
         && mkdir -p /app/libs
COPY build/libs /app/libs
WORKDIR /app/dependency
RUN jar -xf ../libs/*.jar

FROM openjdk:8-jre-alpine
RUN mkdir -p /app
ARG DEPENDENCY=/app/dependency
COPY --from=builder ${DEPENDENCY}/BOOT-INF/lib /app/lib
COPY --from=builder ${DEPENDENCY}/META-INF /app/META-INF
COPY --from=builder ${DEPENDENCY}/BOOT-INF/classes /app
# Default command, run app
ENTRYPOINT ["java","-cp","app:app/lib/*","hello.Application"]
