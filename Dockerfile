FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install Java, MariaDB, Xvfb, Openbox, noVNC, and websockify
RUN apt-get update && apt-get install -y \
    openjdk-17-jdk \
    mariadb-server \
    libmariadb-java \
    xvfb \
    x11vnc \
    openbox \
    novnc \
    websockify \
    wget \
    curl \
    dos2unix \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Download official MySQL Connector JAR
RUN wget -q https://repo1.maven.org/maven2/com/mysql/mysql-connector-j/8.0.33/mysql-connector-j-8.0.33.jar -O /app/mysql-connector-j.jar

# Copy project files
COPY . /app

# Ensure bin directory and compile java sources
RUN mkdir -p /app/bin && \
    javac -cp "jcalendar-1.4.jar:jgoodies-forms-1.8.0.jar:/app/mysql-connector-j.jar" -d /app/bin src/ProjectDefault/*.java || true

# Make start script executable and fix line endings
RUN dos2unix /app/start.sh && chmod +x /app/start.sh

ENV PORT=10000
EXPOSE 10000

CMD ["/bin/bash", "/app/start.sh"]

