# deploy_agent_mathiang-mathew

## How to run the script

git clone https://github.com/mathiang-mathew/deploy_agent_mathiang-mathew.git
cd deploy_agent_mathiang-mathew
chmod +x setup_project.sh
./setup_project.sh

Enter a name when prompted. The script will build the full
attendance tracker project inside a folder named attendance_tracker_{name}.

## How to trigger the archive feature

Run the script and enter a name. At any prompt after that,
press Ctrl+C. The script will catch the interrupt, bundle
whatever was built into attendance_tracker_{name}_archive.tar.gz,
and delete the incomplete folder automatically.
