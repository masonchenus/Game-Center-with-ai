#!/bin/bash

# === Frontend Server ===
echo "Starting frontend server at http://localhost:8000"
# Run in background so it doesn't block the script
python3 -m http.server 8000 &

# === Backend Server ===
echo "Starting backend server at http://localhost:3000"
# Assuming you have a Node.js backend
# Run in background as well
# Replace 'server.js' with your backend entry file
node server.js &

# Wait for user to press Ctrl+C to stop both
echo "Servers are running. Press Ctrl+C to stop."
wait

if [ $? -eq 130 ]; then
    echo "Stopping servers..."
    # Kill background jobs
    kill %1 %2
    echo "Servers stopped."
fi