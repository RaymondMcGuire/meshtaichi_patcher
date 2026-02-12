# meshtaichi_patcher

`meshtaichi_patcher` 是一个把 Python 与 MeshTaichi 网格元数据系统连接起来的工具库。  
它通过 `pybind11` 将 C++ patching 核心暴露给 Python，用于从网格文件生成 Taichi `Mesh` 所需的 patch 元信息与关系数据。

## 项目定位

- 输入: `.obj`（三角网格）或 TetGen 的 `.node/.ele(/.face)`（四面体网格）
- 处理: 生成元素关系（V/E/F/C）、聚类分 patch、构建 relation meta
- 输出: 可直接给 `ti.Mesh.generate_meta(...)` / `mesh.build(meta)` 的元数据

## 快速开始

### 1) 直接安装

```bash
pip install meshtaichi_patcher
```

### 2) 从源码编译安装

```bash
git submodule update --init --recursive
pip install -U pip setuptools wheel cmake ninja
pip install -e .
```

## 最小用例

```python
import taichi as ti
import meshtaichi_patcher as mtp

ti.init(arch=ti.cpu)

mesh = ti.Mesh()
meta = mtp.mesh2meta("model.obj", relations=["FV", "VF", "VV"], patch_size=256)
obj = mesh.build(meta)
```

## 项目文档

完整中文文档见 `docs/PROJECT_GUIDE.zh-CN.md`，包括:

- 架构与数据流总结
- 目录结构说明
- 安装/编译/配置细节
- 运行示例与常见问题
