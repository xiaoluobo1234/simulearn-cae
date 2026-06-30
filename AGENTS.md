# AGENTS.md — SimuLearn CAE 项目交接文档

## 项目概览

**SimuLearn CAE** (`simulearn-cae`) 是一个 AI 驱动的在线结构仿真平台，为 [simulearn.cn](https://simulearn.cn) 提供交互式有限元分析能力。

- **后端**: Python FastAPI + Celery + Redis
- **前端**: React + TypeScript + Three.js (React Three Fiber) + VTK.js
- **仿真工具链**: Gmsh（网格） → CalculiX（求解） → meshio + VTK.js（后处理）
- **部署**: Docker Compose on Alibaba Cloud ECS（阿里云轻量应用服务器）
- **AI（Phase 2）**: LangChain + GPT-4o + RAG 知识库
- **仓库**: `github.com/xiaoluobo1234/simulearn-cae`

## 服务器信息

| 项目 | 值 |
|------|-----|
| **IP** | 211.140.243.103 |
| **主机名** | `iZ2zeb8bioyppbx3bgeh7mZ` |
| **系统** | Alibaba Cloud Linux 3 (OpenAnolis) |
| **CPU** | 4 核 / 8 GB 内存 |
| **磁盘** | 40 GB（系统盘） |
| **SSH** | `ssh admin@211.140.243.103`（校园网封 22 端口时需 VPN 或阿里云网页终端） |
| **Dify** | 独立 docker-compose 项目，占用 80/443/5003 |

## CAE 平台端口分配

CAE 平台与 Dify 共存在同一服务器，通过端口偏移避免冲突：

| 服务 | 端口 | 容器名 | 说明 |
|------|------|--------|------|
| Nginx（Dify） | 80, 443 | `docker-nginx-1` | simulearn.cn 入口，**不要动** |
| Dify API | 5001 内部 | `docker-api-1` | Dify 后端 |
| Dify Web | 3000 内部 | `docker-web-1` | Dify 前端 |
| **CAE Backend** | **8000** | `cae-backend` | FastAPI 仿真 API |
| **CAE Frontend** | **3001** | `cae-frontend` | React 仿真界面 |
| **CAE PostgreSQL** | **5433** | `cae-db` | CAE 数据库（Dify 用 5432 内部） |
| **CAE Redis** | **6380** | `cae-redis` | CAE 消息队列（Dify 用 6379 内部） |
| **CAE MinIO** | **9002/9003** | `cae-minio` | 对象存储 |
| **CAE Worker** | — | `cae-worker` | Celery 异步任务 |

## 目录结构

```
simulearn-cae/
├── docker-compose.yml          # 本地开发编排
├── docker-compose.prod.yml     # ★ 服务器生产编排
├── deploy.sh                   # ★ 服务器一键部署脚本
├── .env.example                # 环境变量模板
├── .gitignore
├── README.md
├── backend/
│   ├── Dockerfile              # 含 Gmsh + CalculiX
│   ├── requirements.txt
│   ├── .env                    # 服务器自动生成（git ignored）
│   └── app/
│       ├── main.py             # FastAPI 入口 + CORS
│       ├── core/config.py      # pydantic-settings 配置
│       ├── api/simulation.py   # 上传/状态/结果/VTK 端点
│       ├── models/simulation.py # SimulationTask 模型
│       ├── tasks/
│       │   ├── celery_app.py   # Celery 配置
│       │   └── simulation_tasks.py # 完整仿真管道（Gmsh→CalculiX→VTK）
│       └── services/
│           └── minio_service.py # S3 + 本地存储回退
├── frontend/
│   ├── Dockerfile
│   ├── package.json
│   └── src/
│       ├── App.tsx / App.css   # 主布局（simulearn.cn 同款设计系统）
│       ├── store/index.ts      # Zustand 状态管理
│       ├── api/client.ts       # API 封装
│       └── components/
│           ├── UploadPanel.tsx  # 上传面板 + 材料参数
│           ├── Viewer3D.tsx     # Three.js 3D + VTK.js 云图
│           ├── ResultPanel.tsx  # 应力/位移报告
│           └── ProgressBar.tsx  # 4 步进度条
├── docker/                     # 独立工具镜像（参考用）
│   ├── gmsh/Dockerfile
│   ├── calculix/Dockerfile
│   └── sandbox/                # AI 沙箱（Phase 2）
├── docs/
│   └── TECH-RESEARCH.md        # 技术选型对比报告
└── tests/
    └── data/test_cube.step     # 测试用立方体模型
```

## 核心仿真链路

```
用户上传 STEP/STL
  → MinIO 存储
  → Celery 任务触发
  → Gmsh Python API 生成四面体网格 (.inp)
  → 注入材料属性 + 边界条件
  → CalculiX (ccx) 求解
  → meshio 转换 .frd → .vtk
  → 提取 max stress / max displacement
  → VTK.js 浏览器渲染应力云图
```

## 设计系统（与 simulearn.cn 统一）

CAE 前端使用与 simulearn.cn 完全一致的视觉设计：

| 设计令牌 | 值 |
|----------|-----|
| 主色 | `#10283d` |
| 强调色 | `#0c8f87` |
| 背景色 | `#f3f6f5`（32px 网格点阵） |
| 标题字体 | Inter + Noto Sans SC |
| 正文字体 | Noto Sans SC + Inter |
| 等宽字体 | JetBrains Mono |
| Header | 毛玻璃效果 `backdrop-filter: blur(14px)` |
| 卡片 | 白色 14px 圆角 + hover 浮起 |
| 按钮 | 主按钮青绿填充 / 次要描边 |

详见 `frontend/src/App.css` 中的 CSS 变量。

## 日常开发工作流

```bash
# ── 本地开发 ──
cd simulearn-cae

# 后端
cd backend && pip install -r requirements.txt
uvicorn app.main:app --reload --port 8000

# 前端（另一个终端）
cd frontend && npm install && npm run dev

# 运行测试
cd backend && python -m pytest tests/ -v

# ── 推送到 GitHub ──
git add -A && git commit -m "描述你的改动" && git push

# ── 服务器部署 ──
# 方式 1：阿里云网页终端（推荐——不受校园网限制）
#   浏览器打开 https://swas.console.aliyun.com/
#   → 远程连接 → 执行以下命令：
ssh admin@211.140.243.103   # 或网页终端直接操作
cd ~/simulearn-cae
git pull
bash deploy.sh

# 方式 2：SSH（校园网需先连 VPN）
```

## ⚠️ GitHub 访问问题

服务器在国内，直连 GitHub 可能超时。**现象**：
- `git clone` 报 `Connection timed out`
- `git pull` 报 `Empty reply from server`

**解决**：通常是 **VPN 问题**——**连接 VPN，刷新网页后重试**。也可临时用镜像站：

```bash
# ghproxy 镜像
git clone https://ghproxy.com/https://github.com/xiaoluobo1234/simulearn-cae.git

# 或直接下载压缩包
wget https://ghproxy.com/https://github.com/xiaoluobo1234/simulearn-cae/archive/refs/heads/master.tar.gz
```

## 关键约定

### Docker Compose 项目隔离

CAE 平台使用独立项目名（`-f docker-compose.prod.yml`），与 Dify 完全隔离：
- CAE 镜像以 `cae-` 为前缀命名
- Dify 镜像以 `docker-` 为前缀命名
- 互不干扰

### .env 文件管理

- `.env` 包含数据库密码、MinIO 密钥，**已加入 .gitignore 不会提交**
- `.env.example` 是模板文件，可安全提交
- `deploy.sh` 首次运行时自动从 `.env.example` 生成 `.env` 并填入随机密码

### 仿真超时

- 默认 300 秒（5 分钟），在 `SIMULATION_TIMEOUT` 环境变量配置
- 超大模型可能需要调大

### 前后端通信

- 前端通过 Vite proxy 转发 `/api` 到后端
- 生产环境 Nginx 反向代理（后续配置）

## API 端点

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/` | 服务信息 |
| GET | `/health` | 健康检查 |
| POST | `/api/v1/simulation/upload` | 上传 CAD + 启动仿真 |
| GET | `/api/v1/simulation/status/{id}` | 查询任务状态 |
| GET | `/api/v1/simulation/result/{id}/vtk` | 下载 VTK 结果 |
| GET | `/api/v1/simulation/result/{id}/report` | 结果摘要 JSON |

## 测试

```bash
cd backend
python -m pytest tests/ -v
# 13 passed, 1 skipped (upload test 需要 Redis)
```

## Phase 2 规划（AI 智能体）

- [ ] LangChain Agent 集成 → 自然语言驱动仿真
- [ ] 三层 RAG 知识库（FEM 理论 + 工程经验 + 用户案例）
- [ ] AI 自动生成边界条件（"底面固定，顶面受 100N 压力" → .inp）
- [ ] AI 结果解读 + 安全评估报告
- [ ] Python 沙箱安全执行（`docker/sandbox/` 已预留）

## 常见问题

| 问题 | 原因 | 解决 |
|------|------|------|
| GitHub 超时 | 国内网络限制 | 连 VPN 刷新重试 / 用 ghproxy 镜像 |
| 部署后 502 | Docker 镜像未构建完成 | `docker compose -f docker-compose.prod.yml logs backend` |
| 端口冲突 | 旧容器占用 | `docker compose -f docker-compose.prod.yml down` |
| 仿真失败 | 模型格式不对 | 确保是 .step/.stp/.stl（实体，非面片） |

## 当前状态（2026-06-30）

- ✅ Phase 1 完整项目骨架（45 个文件）
- ✅ 技术选型报告（CalculiX + Gmsh + VTK.js + GPT-4o）
- ✅ 后端正向导入通过 · 13/13 pytest 通过
- ✅ 前端 TypeScript 零错误 · Vite 构建通过
- ✅ 视觉风格与 simulearn.cn 统一
- ✅ GitHub 仓库已创建并推送
- ⏳ 服务器 Docker 镜像构建中
