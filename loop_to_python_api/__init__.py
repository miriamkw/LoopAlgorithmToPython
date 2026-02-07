import os
import platform
from pathlib import Path

if platform.system() == "Windows":
    # Get the path to your dlibs/windows folder relative to this file
    dll_dir = Path(__file__).parent / "dlibs" / "windows"

    if dll_dir.exists():
        # This is the "Magic Sauce" for Windows Python
        os.add_dll_directory(str(dll_dir.resolve()))