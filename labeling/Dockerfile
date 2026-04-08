FROM liquibase/liquibase:latest

USER root
ADD https://repo1.maven.org/maven2/org/postgresql/postgresql/42.7.5/postgresql-42.7.5.jar /liquibase/lib/postgresql.jar
RUN chown liquibase:liquibase /liquibase/lib/postgresql.jar && chmod 644 /liquibase/lib/postgresql.jar
USER liquibase
