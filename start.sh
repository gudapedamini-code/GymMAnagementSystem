#!/bin/bash
set -e

PORT="${PORT:-10000}"
echo "=== Starting Gym Management System on Port: $PORT ==="

# 1. Start MariaDB database
echo "Starting MariaDB service..."
service mariadb start

# Setup root password and databases if not already done
mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'Vedant@123'; FLUSH PRIVILEGES;" || true
mysql -u root -p'Vedant@123' < /app/init_db.sql || true
echo "Database initialized successfully."

# 2. Setup Virtual Display (Xvfb)
export DISPLAY=:1
Xvfb :1 -screen 0 1440x900x16 &
sleep 2

# 3. Start Window Manager (Openbox)
openbox &
sleep 1

# 4. Start VNC Server
x11vnc -display :1 -nopw -forever -shared -listen localhost -rfbport 5900 &
sleep 2

# 5. Make noVNC auto-load full screen on root URL
if [ -f /usr/share/novnc/vnc.html ]; then
    cp /usr/share/novnc/vnc.html /usr/share/novnc/index.html
fi

# 6. Start WebSockify (Exposes noVNC to Render's HTTP Port)
websockify --web /usr/share/novnc "$PORT" localhost:5900 &
sleep 2

echo "=== Launching Java Gym Management System ==="
# 7. Run Java Application
CLASSPATH="bin:jcalendar-1.4.jar:jgoodies-forms-1.8.0.jar:/usr/share/java/mariadb-java-client.jar:/usr/share/java/mysql-connector-java.jar:mysql-connector-j.jar"
java -cp "$CLASSPATH" ProjectDefault.home

# Keep container alive if Java exits or until stopped
wait

