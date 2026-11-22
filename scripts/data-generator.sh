
#!/bin/bash

while true
do
    echo "Application data generated at $(date '+%Y-%m-%d %H:%M:%S')" >> /var/app/data/app.log
    sleep 30
done
