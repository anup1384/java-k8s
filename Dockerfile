FROM openjdk:11.0.3-jdk-slim
COPY target/*.jar /var/www/app.jar
EXPOSE 8080
ENTRYPOINT [ "sh", "-c", "java $JAVA_OPTS -jar /var/www/app.jar" ]
