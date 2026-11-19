#!/usr/bin/env python3
"""Normalize Flutter-generated localizations for standalone material_ui."""

from pathlib import Path
import re

PATH = Path("lib/l10n/app_localizations.dart")
source = PATH.read_text(encoding="utf-8")

# gen-l10n formatting can change; match imports rather than exact source lines.
source = re.sub(
    r"""(?m)^\s*import\s+['"]package:flutter_localizations/flutter_localizations\.dart['"];\s*\n?""",
    "",
    source,
)
source = re.sub(
    r"""(?m)^\s*import\s+['"]dart:async['"];\s*\n?""",
    "",
    source,
)

source = re.sub(
    r"""(?m)^\s*import\s+['"]package:flutter/widgets\.dart['"];\s*\n?""",
    "",
    source,
)

material_import = "import 'package:material_ui/material_ui.dart';"
if material_import not in source:
    anchors = list(re.finditer(
        r"""(?m)^import\s+['"]package:flutter/foundation\.dart['"];\s*$""",
        source,
    ))
    if len(anchors) != 1:
        raise SystemExit(
            f"Expected one foundation import in {PATH}; found {len(anchors)}"
        )
    insert_at = anchors[0].end()
    source = source[:insert_at] + f"\n{material_import}" + source[insert_at:]

declaration = re.compile(
    r"static\s+(?:const|final)\s+"
    r"List\s*<\s*LocalizationsDelegate\s*<\s*dynamic\s*>\s*>\s+"
    r"localizationsDelegates\s*="
)
matches = list(declaration.finditer(source))
if len(matches) != 1:
    raise SystemExit(
        f"Expected exactly one localizationsDelegates declaration in {PATH}; "
        f"found {len(matches)}"
    )

# Find the initializer's matching [] pair while ignoring brackets in strings
# and comments, so harmless generator formatting changes do not break parsing.
start = source.find("[", matches[0].end())
if start < 0:
    raise SystemExit(f"Cannot find localizations delegate list in {PATH}")

depth = 0
index = start
quote = None
escaped = False
line_comment = False
block_comment = False
end = None

while index < len(source):
    char = source[index]
    next_char = source[index + 1] if index + 1 < len(source) else ""

    if line_comment:
        if char == "\n":
            line_comment = False
    elif block_comment:
        if char == "*" and next_char == "/":
            block_comment = False
            index += 1
    elif quote is not None:
        if escaped:
            escaped = False
        elif char == "\\":
            escaped = True
        elif char == quote:
            quote = None
    elif char == "/" and next_char == "/":
        line_comment = True
        index += 1
    elif char == "/" and next_char == "*":
        block_comment = True
        index += 1
    elif char in ("'", '"'):
        quote = char
    elif char == "[":
        depth += 1
    elif char == "]":
        depth -= 1
        if depth == 0:
            end = index + 1
            break
    index += 1

if end is None:
    raise SystemExit(f"Unbalanced localizations delegate list in {PATH}")

semicolon = source.find(";", end)
if semicolon < 0:
    raise SystemExit(f"Cannot find end of localizationsDelegates in {PATH}")

replacement = """static final List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    ...GlobalMaterialLocalizations.delegates,
  ];"""
source = source[:matches[0].start()] + replacement + source[semicolon + 1:]

if "package:flutter_localizations/flutter_localizations.dart" in source:
    raise SystemExit(f"Legacy flutter_localizations import remains in {PATH}")
if source.count(material_import) != 1:
    raise SystemExit(f"Expected exactly one material_ui import in {PATH}")

PATH.write_text(source, encoding="utf-8")
print(f"Normalized {PATH} for material_ui.")
