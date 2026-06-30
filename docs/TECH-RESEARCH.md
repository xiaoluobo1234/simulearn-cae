# Phase 0: 技术调研报告 — 在线结构CAE仿真平台

> 日期: 2026-06-30 | 项目: SimuLearn CAE 工业智能体

---

## 1. 求解器对比（线性静力学）

| 维度 | **CalculiX** ⭐推荐 | Code_Aster | Deal.II | SfePy |
|------|---------------------|------------|---------|-------|
| **许可证** | GPLv2 | GPLv2 | LGPL | BSD |
| **输入格式** | Abaqus .inp | MED / .comm | C++ 代码 | Python 脚本 |
| **输出格式** | .frd / .dat | MED / .rmed | 自定义 | VTK / HDF5 |
| **Python绑定** | ❌ 无官方 | ✅ Code_Aster API | ✅ 原生C++/Python | ✅ 纯Python |
| **Docker化难度** | 🟢 简单（单二进制） | 🔴 困难（依赖复杂） | 🟡 中等 | 🟢 简单 |
| **安装体积** | ~50MB | ~2GB | ~200MB | ~100MB |
| **社区活跃度** | ⭐⭐⭐⭐ 高 | ⭐⭐⭐ 中（法国） | ⭐⭐⭐⭐⭐ 很高 | ⭐⭐ 低 |
| **中文资料** | ⭐⭐⭐ 有教程 | ⭐ 很少 | ⭐⭐ 有一些 | ⭐ 几乎没有 |
| **线性静力学精度** | ✅ 优秀（对标Abaqus） | ✅ 优秀 | ✅ 优秀 | ✅ 良好 |
| **求解速度** | 快（稀疏直接求解器） | 中等 | 快 | 较慢（纯Python） |
| **工业案例验证** | ✅ 广泛 | ✅ EDF核工业 | ✅ 学术界 | ❌ 较少 |

### 🏆 推荐: **CalculiX**

**理由**:
1. **Abaqus兼容**: .inp 格式与商业软件Abaqus一致，工程界通用，入门工程师熟悉
2. **轻量Docker化**: 单二进制，镜像 <100MB，适合云端快速启动
3. **社区活跃**: GitHub 700+ stars，论坛活跃，问题响应快
4. **中文资源**: 比 Code_Aster 好找资料
5. **线性静力学验证充分**: 大量工业案例证明与 Abaqus 结果一致

**Code_Aster 备选理由**: 功能最全（非线性/接触/疲劳），但部署太重（2GB+），预研阶段不选。

---

## 2. 网格器对比

| 维度 | **Gmsh** ⭐推荐 | Netgen | TetGen | MeshLab |
|------|-----------------|--------|--------|---------|
| **许可证** | GPLv2 | LGPL | AGPLv3 | GPLv2 |
| **元素类型** | 四面体/六面体/棱柱/金字塔 | 四面体为主 | 四面体 | 三角面片 |
| **CAD导入** | STEP/IGES/BREP/STL ✅ | STEP/IGES/STL ✅ | 仅STL/PLY/OFF | 3D扫描格式 |
| **Python绑定** | ✅ 官方gmsh包 | ❌ 需自己封装 | ✅ python-tetgen | ❌ 无 |
| **GUI** | ✅ 内置 | ✅ 内置 | ❌ 无 | ✅ 内置 |
| **命令行模式** | ✅ 完美支持 | ✅ 支持 | ✅ 支持 | ✅ 支持 |
| **网格质量** | ⭐⭐⭐⭐ 优秀 | ⭐⭐⭐⭐ 优秀 | ⭐⭐⭐ 良好 | ❌ 不适合FEM |
| **.inp导出** | ✅ 支持Abaqus格式 | ❌ 需转换 | ❌ 不支持 | ❌ 不支持 |
| **Docker难度** | 🟢 简单 | 🟡 中等 | 🟢 简单 | 🟢 简单 |
| **社区活跃度** | ⭐⭐⭐⭐⭐ 最高 | ⭐⭐⭐ 中 | ⭐⭐⭐ 中 | ⭐⭐⭐ 中 |
| **学习曲线** | 🟢 平缓 | 🟡 中等 | 🟢 平缓 | 🟢 平缓 |

### 🏆 推荐: **Gmsh**

**理由**:
1. **CalculiX天然搭档**: Gmsh 原生支持导出 Abaqus .inp 格式 → 无缝衔接 CalculiX
2. **Python API 最成熟**: `pip install gmsh` 即可，官方维护
3. **CAD格式支持最广**: STEP/IGES/STL 全覆盖，满足用户需求（R9确定先支持这三种）
4. **命令行友好**: `gmsh -3 model.step -o mesh.inp` 一行搞定
5. **社区最大**: GitHub 1.2k+ stars，大量教程和示例

---

## 3. 后处理可视化对比

| 维度 | **VTK.js** ⭐推荐 | Three.js 手动 | ParaViewWeb | Plotly 3D |
|------|-------------------|---------------|-------------|-----------|
| **许可证** | BSD | MIT | BSD | MIT |
| **科学可视化** | ✅ 原生支持云图/等值面/流线/切片 | ❌ 需手写Shader | ✅ 全功能 | ⚠️ 仅散点/曲面 |
| **FEM后处理** | ✅ Warp(变形动画)/ColorMap(云图)/Probe(探针) | ❌ 需自研 | ✅ 完整 | ❌ 不支持 |
| **文件格式** | VTK/VTU/VTP/STL/OBJ | GLTF/OBJ/STL | VTK全系列 | CSV |
| **CalculiX .frd** | ⚠️ 需转换(.frd→.vtk) | ❌ 不支持 | ⚠️ 需转换 | ❌ 不支持 |
| **性能(10万节点)** | 🟢 流畅 60fps | 🟢 流畅 | 🟢 流畅(服务端渲染) | 🔴 卡顿 |
| **体积** | ~2MB (tree-shaking) | ~800KB | ~40MB(含ParaView后端) | ~3MB |
| **React集成** | ✅ 官方@kitware/vtk.js | ✅ react-three-fiber | ❌ 需iframe | ✅ react-plotly |
| **学习曲线** | 🟡 中等 | 🟢 平缓 | 🔴 陡峭 | 🟢 平缓 |
| **社区活跃度** | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ |

### 🏆 推荐: **VTK.js**

**理由**:
1. **专为科学可视化设计**: 云图(ColorMap)、变形动画(WarpFilter)、探针查询(ProbeFilter)均为内置功能
2. **.frd→.vtk转换**: 写一个简单的Python转换脚本即可（50行），或CalculiX的cgx工具也能导出
3. **性能优秀**: WebGL渲染，10万节点无压力
4. **React友好**: 官方支持，有 TypeScript 类型定义
5. **与Three.js可共存**: 3D建模查看用Three.js，科学云图用VTK.js

---

## 4. LLM / AI智能体框架对比

| 维度 | **GPT-4o** ⭐推荐 | Claude Sonnet 4 | DeepSeek V3 | Qwen3 |
|------|-------------------|-----------------|-------------|-------|
| **CAE领域知识** | ⭐⭐⭐⭐⭐ 最强 | ⭐⭐⭐⭐ 强 | ⭐⭐⭐ 中 | ⭐⭐⭐ 中 |
| **.inp格式理解** | ✅ 能正确生成 | ✅ 能正确生成 | ⚠️ 有时出错 | ⚠️ 有时出错 |
| **Function Calling** | ✅ 最可靠 | ✅ 可靠 | ✅ 支持 | ✅ 支持 |
| **API成本(1M token)** | $2.5 / $10 | $3 / $15 | $0.14 / $0.28 | 免费/廉价 |
| **中文能力** | ⭐⭐⭐⭐ 好 | ⭐⭐⭐⭐ 好 | ⭐⭐⭐⭐⭐ 最好 | ⭐⭐⭐⭐⭐ 最好 |
| **响应速度** | 快 | 快 | 中等 | 快 |
| **安全合规** | 数据出境 | 数据出境 | 可自部署 | 可自部署 |

| AI框架 | **LangChain/LangGraph** ⭐ | AutoGen | CrewAI | 自研 |
|--------|--------------------------|---------|--------|------|
| **成熟度** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ | - |
| **Tool Calling** | ✅ 最完善 | ✅ | ✅ | 需开发 |
| **流式输出** | ✅ | ✅ | ✅ | 需开发 |
| **RAG支持** | ✅ LangChain原生 | ⚠️ | ⚠️ | 需开发 |
| **Python生态** | ✅ | ✅ | ✅ | ✅ |
| **学习曲线** | 🟡 中等 | 🟡 中等 | 🟢 平缓 | 🔴 |

### 🏆 推荐: **GPT-4o + LangChain**

**理由**:
1. **CAE知识最强**: GPT-4o 对 Abaqus .inp 格式、FEM理论理解最准确
2. **Function Calling最可靠**: 减少幻觉，工具调用成功率最高
3. **LangChain生态最成熟**: RAG、Tool、Agent、Memory 组件齐全
4. **成本可控**: GPT-4o-mini 做简单任务 (生成.inp)，GPT-4o 做复杂任务 (结果解读)
5. **后期可迁移**: LangChain 支持切换后端，后期可切 DeepSeek 降成本

---

## 5. 总体结论

| 层级 | 选择 | 备选 |
|------|------|------|
| 前端3D框架 | React Three Fiber + Three.js | - |
| 科学可视化 | VTK.js | - |
| 后端框架 | FastAPI | - |
| 任务队列 | Celery + Redis | - |
| 数据库 | PostgreSQL | - |
| 对象存储 | MinIO | 阿里云OSS |
| 网格划分 | **Gmsh** 🏆 | - |
| FEM求解 | **CalculiX** 🏆 | Code_Aster |
| AI模型 | **GPT-4o** 🏆 | DeepSeek V3 |
| AI框架 | **LangChain / LangGraph** 🏆 | - |
| 安全隔离 | Docker + Python沙箱 | - |
| 容器编排 | Docker Compose (dev) | K8s (prod) |

### 核心链路验证:
```
用户上传 STEP → Gmsh(Docker) 生成 .inp → CalculiX(Docker) 求解
→ 转换 .frd → .vtk → 浏览器 VTK.js 渲染应力云图
```

**单次仿真预估耗时**: 
- 网格划分: 5-30秒
- 求解 (1万节点): 1-10秒  
- 结果转换: <1秒
- **总计: <1分钟** ✅ 体验流畅
