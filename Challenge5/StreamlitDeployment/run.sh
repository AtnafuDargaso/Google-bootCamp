#!/usr/bin/env bash
# Run script for Alaska Snow Streamlit app
# Usage: ./run.sh [--no-mock]

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

# Virtual env dir
VENV_DIR="$ROOT_DIR/.venv"

# Default: use mocks to avoid requiring GCP credentials
USE_MOCKS=1

if [[ ${1-} == "--no-mock" ]]; then
	USE_MOCKS=0
fi

echo "Root dir: $ROOT_DIR"

if [[ ! -d "$VENV_DIR" ]]; then
	echo "Creating virtual environment at $VENV_DIR..."
	python3 -m venv "$VENV_DIR"
fi

echo "Activating virtual environment..."
# shellcheck source=/dev/null
source "$VENV_DIR/bin/activate"

if [[ ! -f "$ROOT_DIR/requirements.txt" ]]; then
	echo "requirements.txt not found in $ROOT_DIR, creating minimal one..."
	cat > "$ROOT_DIR/requirements.txt" <<EOF
google-cloud-aiplatform
google-cloud-bigquery
google-cloud-storage
streamlit
pandas
numpy
pytest
EOF
fi

echo "Installing dependencies (this may take a minute)..."
pip install -r "$ROOT_DIR/requirements.txt"

if [[ $USE_MOCKS -eq 1 ]]; then
	echo "Using local mocks (USE_MOCKS=1)"
	export USE_MOCKS=1
else
	echo "Running with real GCP clients (USE_MOCKS=0)"
	export USE_MOCKS=0
fi

# Ensure alaska_snow_app.py exists; look in multiple locations and generate only if missing
APP_PY_ROOT="$ROOT_DIR/alaska_snow_app.py"
APP_PY_LOCAL="$ROOT_DIR/StreamlitDeployment/alaska_snow_app.py"
MAIN_SCRIPT="$ROOT_DIR/student_04_3b898c19596f_(nov_12,_2025,_2_42_38 pm).py"

if [[ -f "$APP_PY_ROOT" ]]; then
	APP_PY="$APP_PY_ROOT"
elif [[ -f "$APP_PY_LOCAL" ]]; then
	APP_PY="$APP_PY_LOCAL"
else
	if [[ -f "$MAIN_SCRIPT" ]]; then
		echo "Creating Streamlit app file from main script..."
		python3 - <<PY
import runpy
ns = runpy.run_path('$MAIN_SCRIPT')
print('Done')
PY
	fi

	if [[ -f "$APP_PY_ROOT" ]]; then
		APP_PY="$APP_PY_ROOT"
	elif [[ -f "$APP_PY_LOCAL" ]]; then
		APP_PY="$APP_PY_LOCAL"
	else
		echo "alaska_snow_app.py not found in root or StreamlitDeployment. Please create the file or run the main script to generate it." >&2
		exit 1
	fi
fi

echo "Starting Streamlit..."
streamlit run "$APP_PY"