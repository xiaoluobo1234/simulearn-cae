import { useState } from "react";
import { UploadPanel } from "./components/UploadPanel";
import { Viewer3D } from "./components/Viewer3D";
import { ResultPanel } from "./components/ResultPanel";
import { ProgressBar } from "./components/ProgressBar";
import { useSimStore } from "./store";
import "./App.css";

export default function App() {
  const { status, taskId } = useSimStore();
  const [viewMode, setViewMode] = useState<"model" | "result">("model");

  return (
    <div className="app">
      {/* ── Header — matches simulearn.cn glassmorphism ── */}
      <header className="app-header">
        <div className="header-inner">
          <a href="https://simulearn.cn" className="header-brand" title="回到 SimuLearn">
            <span className="logo-mark" aria-hidden="true">
              <i /><i /><i /><i />
            </span>
            <span>
              <strong>SimuLearn</strong>
              <small>CAE · 在线仿真</small>
            </span>
          </a>

          <div className="header-actions">
            {taskId && (
              <span className="header-status-pill">
                {taskId.slice(0, 8)}&hellip;
              </span>
            )}
            <a href="https://simulearn.cn/tools" className="back-link">
              工具脚本 ↗
            </a>
          </div>
        </div>
      </header>

      {/* ── Main ── */}
      <main className="app-main">
        <aside className="sidebar">
          <UploadPanel />
          {status && status !== "completed" && status !== "failed" && <ProgressBar />}
          {status === "completed" && (
            <ResultPanel
              onViewModeChange={(mode) => setViewMode(mode)}
              viewMode={viewMode}
            />
          )}
          {status === "failed" && <ErrorCard />}
        </aside>

        <section className="viewer">
          <Viewer3D viewMode={viewMode} />
        </section>
      </main>
    </div>
  );
}

function ErrorCard() {
  const { error } = useSimStore();
  return (
    <div className="card error-box">
      <strong>❌ 仿真失败</strong>
      {error || "未知错误，请检查模型文件是否包含实体几何。"}
    </div>
  );
}
