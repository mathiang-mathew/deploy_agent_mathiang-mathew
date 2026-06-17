#!/bin/bash
# Project factory for the attendance tracker
read -p "Enter a student name: " user_input
cleanup() {
    echo ""
    echo "Interrupted! Archiving current state..."
    tar -czf "attendance_tracker_${user_input}_archive.tar.gz" "attendance_tracker_${user_input}"
    rm -rf "attendance_tracker_${user_input}"
    echo "Archive created and incomplete folder removed."
    exit 1
}
trap cleanup SIGINT
mkdir -p "attendance_tracker_${user_input}"
mkdir -p "attendance_tracker_${user_input}/Helpers"
mkdir -p "attendance_tracker_${user_input}/reports"  
cat > "attendance_tracker_${user_input}/Helpers/config.json" << 'EOF'
{
    "thresholds": {
        "warning": 75,
        "failure": 50
    },
    "run_mode": "live",
    "total_sessions": 15
}
EOF
cat > "attendance_tracker_${user_input}/Helpers/assets.csv" << 'EOF'
Email,Names,Attendance Count,Absence Count
alice@example.com,Alice Johnson,14,1
bob@example.com,Bob Smith,7,8
charlie@example.com,Charlie Davis,4,11
diana@example.com,Diana Prince,15,0
EOF
cat > "attendance_tracker_${user_input}/reports/reports.log" << 'EOF'
--- Attendance Report Run: 2026-02-06 18:10:01.468726 ---
[2026-02-06 18:10:01.469363] ALERT SENT TO bob@example.com: URGENT: Bob Smith, your attendance is 46.7%. You will fail this class.
[2026-02-06 18:10:01.469424] ALERT SENT TO charlie@example.com: URGENT: Charlie Davis, your attendance is 26.7%. You will fail this class.
EOF

cat > "attendance_tracker_${user_input}/attendance_checker.py" << 'EOF'
import csv
import json
import os
from datetime import datetime

def run_attendance_check():
    # 1. Load Config
    with open('Helpers/config.json', 'r') as f:
        config = json.load(f)

    # 2. Archive old reports.log if it exists
    if os.path.exists('reports/reports.log'):
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        os.rename('reports/reports.log', f'reports/reports_{timestamp}.log.archive')

    # 3. Process Data
    with open('Helpers/assets.csv', mode='r') as f, open('reports/reports.log', 'w') as log:
        reader = csv.DictReader(f)
        total_sessions = config['total_sessions']

        log.write(f"--- Attendance Report Run: {datetime.now()} ---\n")

        for row in reader:
            name = row['Names']
            email = row['Email']
            attended = int(row['Attendance Count'])

            # Simple Math: (Attended / Total) * 100
            attendance_pct = (attended / total_sessions) * 100

            message = ""
            if attendance_pct < config['thresholds']['failure']:
                message = f"URGENT: {name}, your attendance is {attendance_pct:.1f}%. You will fail this class."
            elif attendance_pct < config['thresholds']['warning']:
                message = f"WARNING: {name}, your attendance is {attendance_pct:.1f}%. Please be careful."

            if message:
                if config['run_mode'] == "live":
                    log.write(f"[{datetime.now()}] ALERT SENT TO {email}: {message}\n")
                    print(f"Logged alert for {name}")
                else:
                    print(f"[DRY RUN] Email to {email}: {message}")

if __name__ == "__main__":
    run_attendance_check()
EOF
read -p "Do you want to update the thresholds? (y/n): " update_choice
if [ "$update_choice" = "y" ]; then
read -p "Enter new Warning threshold [default 75]: " new_warning
    new_warning=${new_warning:-75}
    read -p "Enter new Failure threshold [default 50]: " new_failure
    new_failure=${new_failure:-50}
    echo "Warning will be ${new_warning}, Failure will be ${new_failure}"
    sed -i "s/\"warning\": [0-9]*/\"warning\": ${new_warning}/" "attendance_tracker_${user_input}/Helpers/config.json"
    sed -i "s/\"failure\": [0-9]*/\"failure\": ${new_failure}/" "attendance_tracker_${user_input}/Helpers/config.json"
fi
echo ""
echo "=== Health Check ==="
if command -v python3 &>/dev/null; then
    echo "python3 is installed: $(python3 --version)"
else
    echo "WARNING: python3 is not installed"
fi

if [ -d "attendance_tracker_${user_input}/Helpers" ] && [ -d "attendance_tracker_${user_input}/reports" ]; then
    echo "Directory structure verified successfully"
else
    echo "WARNING: Directory structure is incomplete"
fi
echo "=== Setup Complete ==="
