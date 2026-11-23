# BIMPlugins.AvalonEdit

[![Revit 2019+](https://img.shields.io/badge/Revit-2019%2B-blue.svg)](https://github.com/Samveyil/BIMPlugins.AvalonEdit)
[![AvalonEdit 6.3.1](https://img.shields.io/badge/AvalonEdit-6.3.1-blue.svg)](https://github.com/icsharpcode/AvalonEdit/releases/tag/v6.3.1)
[![License MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://github.com/Samveyil/BIMPlugins.AvalonEdit/blob/master/LICENSE.txt)
[![NuGet](https://img.shields.io/nuget/v/BIMPlugins.AvalonEdit.svg)](https://www.nuget.org/packages/BIMPlugins.AvalonEdit)

[AvalonEdit](https://github.com/icsharpcode/AvalonEdit), the WPF code editor, for Revit add-ins, under an assembly name of its own.

## Why

Every add-in runs in the one Revit process. Two add-ins with different versions of AvalonEdit load side by side,
but WPF finds the editor's styles by assembly name (`/ICSharpCode.AvalonEdit;component/TextEditor.xaml`), and the copy
loaded last answers for everyone. So when another add-in loads its AvalonEdit before your editor first opens,
your editor, its search panel and its completion list come up empty.

This package is AvalonEdit built as `BIMPlugins.AvalonEdit`. No other add-in has an assembly with this name,
so nothing is shared: your editor keeps its styles, and other add-ins keep theirs.

Namespaces and XAML are AvalonEdit's, so code and XAML written for AvalonEdit work as they are.

## Installation

```xml
<PackageReference Include="BIMPlugins.AvalonEdit" Version="6.3.1" />
```

Replace `AvalonEdit` with it. The package targets `net462` (Revit 2019–2024) and `net8.0-windows` (Revit 2025+).

If you refer to AvalonEdit's resources by URI, use the new assembly name:
`/BIMPlugins.AvalonEdit;component/...`.

## How it is built

The repository keeps only what BIMPlugins adds. `build.ps1` clones the AvalonEdit release, and `tools/rename.py`
renames the assembly and the pack URIs that name it and signs it with `key/BIMPlugins.AvalonEdit.snk`.
Then it builds and packs:

```powershell
./build.ps1    # artifacts/BIMPlugins.AvalonEdit.<version>.nupkg
```

To move to another AvalonEdit release, change `$AvalonEditVersion` and `$PackageVersion` in `build.ps1`.
A `v<version>` tag publishes the package to NuGet.

## License

MIT, as AvalonEdit. See [LICENSE.txt](LICENSE.txt).
