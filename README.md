# 🔧 SimuLearn CAE — 在线工业智能体

> AI-driven online structural CAE simulation platform.
>
> 为 [simulearn.cn](https://simulearn.cn/) 构建的AI驱动在线结构仿真平台。

---

## 🏗️ 架构概览

```
用户浏览器 (React + R3F + VTK.js)
       │
       ▼
┌─────────────┐     ┌──────────────┐     ┌──────────────┐
│  FastAPI     │────▶│  Celery      │────▶│  Docker 容器  │
│  API 网关    │     │  任务队列     │     │  Gmsh/CalculiX│
└─────────────┘     └──────────────┘     └──────────────┘
       │                    │
       ▼                    ▼
┌─────────────┐     ┌──────────────┐
│  PostgreSQL │     │  MinIO (S3)  │
│  元数据      │     │  文件存储     │
└─────────────┘     └──────────────┘
```

### 仿真流程
```
上传STEP/STL → Gmsh网格(.inp) → CalculiX求解 → .frd→.vtk → VTK.js云图
```

---

## 🚀 快速开始

### 前置要求
- Docker & Docker Compose
- Node.js 22+ (前端开发)
- Python 3.12+ (后端开发)

### 一键启动

```bash
# 1. 构建 Gmsh & CalculiX 镜像
cd docker/gmsh && docker build -t simulearn/gmsh:latest . && cd ../..
cd docker/calculix && docker build -t simulearn/calculix:latest . && cd ../..
cd docker/sandbox && docker build -t simulearn/sandbox:latest . && cd ../..

# 2. 启动全部服务
docker compose up -d

# 3. 查看日志
docker compose logs -f backend worker
```

服务端口：
| 服务 | 端口 | 说明 |
|------|------|------|
| Backend API | 8000 | FastAPI + Swagger |
| Frontend | 3000 | React 开发服务器 |
| MinIO Console | 9001 | 对象存储管理 |
| PostgreSQL | 5432 | 数据库 |
| Redis | 6379 | 消息队列 |

### 本地开发

```bash
# 后端
cd backend
pip install -r requirements.txt
uvicorn app.main:app --reload --port 8000

# 前端
cd frontend
npm install
npm run dev

# Worker (另一个终端)
cd backend
celery -A app.tasks.celery_app worker --loglevel=info
```

---

## 📁 项目结构

```
simulearn-cae/
├── docker-compose.yml          # 全栈编排
├── backend/
│   ├── Dockerfile
│   ├── requirements.txt
│   ├── .env
│   └── app/
│       ├── main.py             # FastAPI 入口
│       ├── core/
│       │   └── config.py       # 配置管理
│       ├── api/
│       │   ├── __init__.py     # 路由注册
│       │   └── simulation.py   # 仿真API端点
│       ├── models/
│       │   └── simulation.py   # 任务数据模型
│       ├── tasks/
│       │   ├── celery_app.py          # Celery配置
│       │   └── simulation_tasks.py    # 仿真管道任务
│       └── services/
│           └── minio_service.py       # 对象存储服务
├── frontend/
│   ├── Dockerfile
│   ├── package.json
│   └── src/
│       ├── main.tsx
│       ├── App.tsx / App.css   # 主布局
│       ├── store/index.ts      # Zustand 状态管理
│       ├── api/client.ts       # API 客户端
│       └── components/
│           ├── UploadPanel.tsx  # 上传面板
│           ├── Viewer3D.tsx     # 3D视图 + VTK.js
│           ├── ResultPanel.tsx  # 结果显示
│           └── ProgressBar.tsx  # 进度条
├── docker/
│   ├── gmsh/Dockerfile         # Gmsh 网格器镜像
│   ├── calculix/Dockerfile     # CalculiX 求解器镜像
│   └── sandbox/
│       ├── Dockerfile          # AI沙箱镜像
│       └── sandbox_runner.py   # 沙箱执行器
└── docs/
    └── TECH-RESEARCH.md        # 技术调研报告
```

---

## 📋 API 端点

| 方法 | 路径 | 说明 |
|------|------|------|
| POST | `/api/v1/simulation/upload` | 上传CAD并启动仿真 |
| GET | `/api/v1/simulation/status/{id}` | 查询仿真状态 |
| GET | `/api/v1/simulation/result/{id}/vtk` | 下载VTK结果 |
| GET | `/api/v1/simulation/result/{id}/report` | 获取结果报告 |

---

## 🗺️ 路线图

- [x] **Phase 0**: 技术调研报告
- [x] **Phase 1**: 最简链路 — 上传→网格→求解→云图
- [ ] **Phase 2**: AI 智能体集成 (LangChain + GPT-4o)
- [ ] **Phase 3**: 完整平台 (用户系统、在线建模、协作)

---

## 📄 许可证

MIT License — 全开源
