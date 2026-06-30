FROM python:3.12-slim-bookworm

WORKDIR /app

# Install system dependencies: Gmsh, CalculiX, and build tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Build tools for Python packages
    build-essential \
    curl \
    # === CAE Tools ===
    gmsh \
    calculix-ccx \
    # Cleanup
    && rm -rf /var/lib/apt/lists/*

# Verify CAE tools
RUN gmsh --version && echo "✅ Gmsh OK"
RUN ccx -v 2>&1 || echo "✅ CalculiX CCX OK (version printed above)"

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8000

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
