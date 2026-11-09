#!/bin/bash

PORT="${PORT:-10000}"
echo "=================================================="
echo "=== Starting Gym Management System on Port: $PORT ==="
echo "=================================================="

# 1. Setup MariaDB directories and permissions
mkdir -p /var/run/mysqld /var/lib/mysql
chown -R mysql:mysql /var/run/mysqld /var/lib/mysql 2>/dev/null || true

# Initialize MariaDB if data directory is empty
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB data directory..."
    mysql_install_db --user=mysql --ldata=/var/lib/mysql || true
fi

# Start MariaDB service
echo "Starting MariaDB..."
service mariadb start || /etc/init.d/mariadb start || true
sleep 3

# Setup root password and databases
echo "Configuring MySQL databases..."
mariadb -u root << 'SQLEOF' 2>/dev/null || true
ALTER USER 'root'@'localhost' IDENTIFIED VIA mysql_native_password USING PASSWORD('Vedant@123');
CREATE USER IF NOT EXISTS 'root'@'127.0.0.1' IDENTIFIED VIA mysql_native_password USING PASSWORD('Vedant@123');
GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO 'root'@'127.0.0.1' WITH GRANT OPTION;
FLUSH PRIVILEGES;
SQLEOF

mariadb -u root -p'Vedant@123' < /app/init_db.sql 2>/dev/null || mariadb -u root < /app/init_db.sql 2>/dev/null || true
echo "MySQL Database initialized."

# 2. Setup Virtual Display (Xvfb)
export DISPLAY=:1
echo "Starting Xvfb display on :1..."
Xvfb :1 -screen 0 1440x900x16 &
sleep 2

# 3. Start Window Manager (Openbox)
echo "Starting Window Manager..."
openbox &
sleep 1

# 4. Start VNC Server (x11vnc)
echo "Starting x11vnc..."
x11vnc -display :1 -nopw -forever -shared -listen 127.0.0.1 -rfbport 5900 &
sleep 2

# 5. Create Auto-Connecting index.html for noVNC
# This ensures that when the Render URL is opened, it automatically connects over WSS/HTTPS with auto-scaling!
cat << 'EOF' > /usr/share/novnc/index.html
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>Gym Management System - Live</title>
    <script>
        window.location.replace("vnc.html?autoconnect=true&resize=scale&reconnect=true");
    </script>
</head>
<body style="background:#111; color:#fff; font-family:sans-serif; text-align:center; padding-top:20%;">
    <h2>Connecting to Gym Management System...</h2>
    <p>Please wait a moment while the virtual screen loads.</p>
</body>
</html>
EOF

# 6. Start WebSockify (Exposes noVNC to Render's Public Port)
echo "Starting WebSockify on port $PORT..."
websockify --web /usr/share/novnc "$PORT" 127.0.0.1:5900 &
sleep 2

# 7. Start Java Application in loop (so if closed, it restarts automatically)
echo "=== Launching Java Gym Management System ==="
CLASSPATH="bin:jcalendar-1.4.jar:jgoodies-forms-1.8.0.jar:/usr/share/java/mariadb-java-client.jar:/usr/share/java/mysql-connector-java.jar:/app/mysql-connector-j.jar"

# Loop to keep Java running
while true; do
    echo "Running Java Application..."
    java -cp "$CLASSPATH" ProjectDefault.login || true
    echo "Application closed, restarting in 2 seconds..."
    sleep 2
done
