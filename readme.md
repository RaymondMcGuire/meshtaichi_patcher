# meshtaichi_patcher

This project is a fork of [BillXu2000/meshtaichi_patcher](https://github.com/BillXu2000/meshtaichi_patcher). It is created to support reading `.ele` and `.node` files.

## Quick Start

### Installation

```bash
pip install meshtaichi_patcher
```

### Build from source

```bash
git submodule update --init --recursive
pip install -U pip setuptools wheel cmake ninja
pip install -e .
```

### Example Usage

```python
import taichi as ti
import meshtaichi_patcher as mtp

ti.init(arch=ti.cpu)

mesh = ti.Mesh()
meta = mtp.mesh2meta("model.ele", relations=["CV", "VC", "VV"], patch_size=256)
obj = mesh.build(meta)
```
