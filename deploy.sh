#!/bin/bash
# ============================================================
# SimuLearn CAE — Server Deployment Script
# Run on Alibaba Cloud ECS: bash deploy.sh
# ============================================================
set -e

echo "🔧 SimuLearn CAE — Server Deployment"
echo "======================================"

# ── Check prerequisites ──
command -v docker >/dev/null 2>&1 || { echo "❌ Docker not installed"; exit 1; }
docker compose version >/dev/null 2>&1 || { echo "❌ docker compose not available"; exit 1; }

# ── Check ports are free ──
for port in 8000 3001 5433 6380 9002 9003; do
  if ss -tlnp | grep -q ":$port "; then
    echo "⚠️  Port $port is in use! Please free it before deploying."
    exit 1
  fi
done
echo "✅ All ports available"

# ── Build and start ──
echo ""
echo "📦 Building CAE images (this takes 3-5 minutes first time)..."
docker compose -f docker-compose.prod.yml build --parallel

echo ""
echo "🚀 Starting services..."
docker compose -f docker-compose.prod.yml up -d

echo ""
echo "⏳ Waiting for services to be healthy..."
sleep 8

# ── Health checks ──
echo ""
echo "📋 Service Status:"
docker compose -f docker-compose.prod.yml ps

echo ""
echo "======================================"
echo "✅ Deployment complete!"
echo ""
echo "📌 Endpoints:"
echo "   Backend API:  http://$(hostname -I | awk '{print $1}'):8000"
echo "   Backend Docs: http://$(hostname -I | awk '{print $1}'):8000/docs"
echo "   Frontend:     http://$(hostname -I | awk '{print $1}'):3001"
echo "   MinIO API:    http://$(hostname -I | awk '{print $1}'):9002"
echo "   MinIO Console: http://$(hostname -I | awk '{print $1}'):9003"
echo ""
echo "📝 Next steps:"
echo "   1. Test: curl http://localhost:8000/health"
echo "   2. Add Nginx reverse proxy for simulearn.cn/cae"
echo "   3. Check logs: docker compose -f docker-compose.prod.yml logs -f"
