#!/bin/bash
# =============================================================================
# EAS550 Final Project — Mac M4 Setup & Run Script
# CSV to 3NF PostgreSQL Data Pipeline
# =============================================================================

set -e  # Exit immediately on any error

echo "============================================="
echo "  EAS550 Final Project — Mac M4 Setup Script"
echo "============================================="

# ─── STEP 1: Check for Homebrew ───────────────────────────────────────────────
echo ""
echo "[1/7] Checking for Homebrew..."
if ! command -v brew &>/dev/null; then
  echo "  → Homebrew not found. Installing..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # Add Homebrew to PATH for Apple Silicon (M4)
  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  echo "  ✓ Homebrew found: $(brew --version | head -1)"
fi

# ─── STEP 2: Install PostgreSQL ───────────────────────────────────────────────
echo ""
echo "[2/7] Checking for PostgreSQL..."
if ! command -v psql &>/dev/null; then
  echo "  → PostgreSQL not found. Installing via Homebrew..."
  brew install postgresql@16
  brew link --force postgresql@16
  echo 'export PATH="/opt/homebrew/opt/postgresql@16/bin:$PATH"' >> ~/.zprofile
  export PATH="/opt/homebrew/opt/postgresql@16/bin:$PATH"
else
  echo "  ✓ PostgreSQL found: $(psql --version)"
fi

# Start PostgreSQL service
echo "  → Starting PostgreSQL service..."
brew services start postgresql@16 2>/dev/null || brew services restart postgresql@16
sleep 2  # Give it a moment to start
echo "  ✓ PostgreSQL service running."

# ─── STEP 3: Install Python 3 ─────────────────────────────────────────────────
echo ""
echo "[3/7] Checking for Python 3..."
if ! command -v python3 &>/dev/null; then
  echo "  → Python 3 not found. Installing..."
  brew install python3
else
  echo "  ✓ Python found: $(python3 --version)"
fi

# ─── STEP 4: Clone the repo ───────────────────────────────────────────────────
echo ""
echo "[4/7] Cloning repository..."
REPO_DIR="/Users/tsomorlig/Documents/Spring 2026/550/eas550-final-project"

mkdir -p "/Users/tsomorlig/Documents/Spring 2026/550"

if [ -d "$REPO_DIR" ]; then
  echo "  → Repo already exists at $REPO_DIR. Pulling latest changes..."
  cd "$REPO_DIR"
  git checkout feature/demo
  git pull origin feature/demo
else
  git clone https://github.com/kn58buff/eas550-final-project.git "$REPO_DIR"
  cd "$REPO_DIR"
  git checkout feature/demo
fi
echo "  ✓ Repo ready at $REPO_DIR"

# ─── STEP 5: Create Python virtual environment & install dependencies ─────────
echo ""
echo "[5/7] Setting up Python virtual environment..."
python3 -m venv venv
source venv/bin/activate

echo "  → Upgrading pip..."
pip install --upgrade pip --quiet

echo "  → Installing dependencies from requirements.txt..."
pip install -r requirements.txt --quiet
echo "  ✓ All Python dependencies installed."

# ─── STEP 6: Set up PostgreSQL database & .env file ──────────────────────────
echo ""
echo "[6/7] Setting up PostgreSQL database..."

DB_NAME="eas550_db"
DB_USER=$(whoami)  # Uses your macOS username (default postgres superuser on Homebrew)

# Create database if it doesn't exist
psql postgres -tc "SELECT 1 FROM pg_database WHERE datname = '$DB_NAME'" | grep -q 1 \
  || psql postgres -c "CREATE DATABASE $DB_NAME;"
echo "  ✓ Database '$DB_NAME' ready."

# Create .env file if it doesn't exist
ENV_FILE="$REPO_DIR/.env"
if [ ! -f "$ENV_FILE" ]; then
  echo "  → Creating .env file with database credentials..."
  cat > "$ENV_FILE" <<EOF
# PostgreSQL connection settings
DB_HOST=localhost
DB_PORT=5432
DB_NAME=$DB_NAME
DB_USER=$DB_USER
DB_PASSWORD=
EOF
  echo "  ✓ .env file created at $ENV_FILE"
  echo ""
  echo "  ⚠️  NOTE: If your PostgreSQL user has a password, edit .env and fill in DB_PASSWORD."
else
  echo "  ✓ .env file already exists. Skipping creation."
fi

# ─── STEP 7: Run the pipeline ─────────────────────────────────────────────────
echo ""
echo "[7/7] Running the pipeline..."

# Run SQL schema first (creates tables)
echo "  → Applying database schema (sql/schema.sql)..."
if [ -f "$REPO_DIR/sql/schema.sql" ]; then
  psql -d "$DB_NAME" -f "$REPO_DIR/sql/schema.sql"
  echo "  ✓ Schema applied."
else
  echo "  ⚠️  sql/schema.sql not found — skipping schema step."
fi

# Run security SQL if present
if [ -f "$REPO_DIR/sql/security.sql" ]; then
  echo "  → Applying security roles (sql/security.sql)..."
  psql -d "$DB_NAME" -f "$REPO_DIR/sql/security.sql"
  echo "  ✓ Security roles applied."
fi

# Run the ingestion pipeline
echo "  → Running Python ingestion pipeline (src/ingestion/ingest_data.py)..."
if [ -f "$REPO_DIR/src/ingestion/ingest_data.py" ]; then
  python3 "$REPO_DIR/src/ingestion/ingest_data.py"
  echo "  ✓ Ingestion complete."
else
  echo "  ⚠️  src/ingestion/ingest_data.py not found."
  echo "      Check the src/ directory for the correct entry point:"
  ls "$REPO_DIR/src/" 2>/dev/null || true
fi

# =============================================================================
echo ""
echo "============================================="
echo "  ✅ Pipeline complete!"
echo "============================================="
echo ""
echo "  Database : $DB_NAME"
echo "  User     : $DB_USER"
echo "  Host     : localhost:5432"
echo ""
echo "  To connect manually:"
echo "    psql -d $DB_NAME"
echo ""
echo "  To reactivate the venv later:"
echo "    cd $REPO_DIR && source venv/bin/activate"
echo ""
echo "  To open in VSCode:"
echo "    code $REPO_DIR"
echo "============================================="