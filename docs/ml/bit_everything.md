sudo apt install -y python3 python3-pip python3-venv git
move into the project dir
python3 -m venv venv
source venv/bin/activate
pip install jupyter pandas scikit-learn matplotlib
source venv/bin/activate
jupyter notebook ml/notebooks/
deactivate