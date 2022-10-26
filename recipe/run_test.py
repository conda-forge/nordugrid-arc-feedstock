import os
from pathlib import Path

# Avoid letting arc/__init__.py supress errors
import arc
import _arc


conda_prefix = Path(os.environ["CONDA_PREFIX"])
assert str(conda_prefix) == arc.ArcLocation.Get(), repr(arc.ArcLocation.Get())
assert str(conda_prefix / "share" / "arc") == arc.ArcLocation.GetDataDir(), repr(arc.ArcLocation.GetDataDir())
assert str(conda_prefix / "lib" / "arc" ) == arc.ArcLocation.GetLibDir(), repr(arc.ArcLocation.GetLibDir())
assert (str(conda_prefix / "lib" / "arc"),) == arc.ArcLocation.GetPlugins(), repr(arc.ArcLocation.GetPlugins())
assert str(conda_prefix / "libexec" / "arc") == arc.ArcLocation.GetToolsDir(), repr(arc.ArcLocation.GetToolsDir())
