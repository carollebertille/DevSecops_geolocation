FROM openjdk:11.0.10
COPY target/bioMedical-0.0.1-SNAPSHOT.jar bioMedical-0.0.1-SNAPSHOT.jar
RUN useradd geolocation
USER geolocation
EXPOSE 80
ENTRYPOINT ["java","-jar","bioMedical-0.0.1-SNAPSHOT.jar"]
