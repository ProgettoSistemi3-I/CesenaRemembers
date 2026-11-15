#!/usr/bin/env python3
"""Normalize Flutter 3.50 generated localizations for standalone material_ui."""

from pathlib import Path
import re

PATH = Path("lib/l10n/app_localizations.dart")
source = PATH.read_text(encoding="utf-8")

# gen-l10n still emits the legacy flutter_localizations import. Keeping it
# beside material_ui makes GlobalMaterialLocalizations ambiguous.
source = source.replace(
    "import 'package:flutter_localizations/flutter_localizations.dart';\n",
    "",
)

material_import = "import 'package:material_ui/material_ui.dart';"
if material_import not in source:
    anchor = "import 'package:flutter/foundation.dart';"
    if anchor not in source:
        raise SystemExit(f"Cannot find import insertion point in {PATH}")
    source = source.replace(anchor, f"{anchor}\n{material_import}", 1)

# The material_ui delegates are supplied as a runtime list, not a const list.
# Its combined list includes Material, Cupertino and Widgets localizations.
pattern = re.compile(
    r"static\\s+(?:const|final)\\s+"
    r"List<LocalizationsDelegate<dynamic>>\\s+localizationsDelegates"
    r"\\s*=\\s*<LocalizationsDelegate<dynamic>>\\s*\\[.*?\\];",
    re.DOTALL,
)
replacement = """static final List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    ...GlobalMaterialLocalizations.delegates,
  ];"""
source, replacements = pattern.subn(replacement, source, count=1)
if replacements != 1:
    raise SystemExit(
        f"Expected exactly one generated localizationsDelegates list in {PATH}; "
        f"found {replacements}"
    )

if "package:flutter_localizations/flutter_localizations.dart" in source:
    raise SystemExit(f"Legacy flutter_localizations import remains in {PATH}")
if source.count(material_import) != 1:
    raise SystemExit(f"Expected exactly one material_ui import in {PATH}")

PATH.write_text(source, encoding="utf-8")
print(f"Normalized {PATH} for material_ui.")
