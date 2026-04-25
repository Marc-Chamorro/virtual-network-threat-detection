sudo apt install -y python3 python3-pip python3-venv git
move into the project dir
python3 -m venv venv
source venv/bin/activate
pip install jupyter pandas scikit-learn matplotlib
source venv/bin/activate
jupyter notebook ml/notebooks/
deactivate


# Real-Time Anomaly Detector - Python dependencies
# Install with:  pip install -r file_to_be_created?.txt

## check later if to create a new file or just show the instructions on top
 
scikit-learn>=1.3
pandas>=2.0
numpy>=1.24
joblib>=1.3
 