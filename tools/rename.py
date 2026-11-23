# Turns a clean checkout of AvalonEdit into BIMPlugins.AvalonEdit:
# - the assembly gets a name of its own, so it never shares one with another add-in's AvalonEdit
#   (WPF resolves short-name pack URIs by assembly name, and the last loaded copy would take everyone's styles);
# - the pack URIs inside follow the new name;
# - the assembly is signed with the BIMPlugins key.
# Namespaces and the XAML xmlns stay AvalonEdit's, so code and XAML using AvalonEdit need no change.
# Works on bytes, so files keep their encoding. build.ps1 runs it on a clean checkout:
#   python tools/rename.py <checkout> key/BIMPlugins.AvalonEdit.snk
import os
import re
import shutil
import sys

root, key = sys.argv[1], sys.argv[2]
project_dir = os.path.join(root, "ICSharpCode.AvalonEdit")


def edit(path, pairs):
    with open(path, "rb") as stream:
        data = stream.read()
    for old, new, count in pairs:
        found = data.count(old)
        if found != count:
            raise SystemExit(path + " has changed: " + old.decode() + " found " + str(found) + " times, expected " + str(count))
        data = data.replace(old, new)
    with open(path, "wb") as stream:
        stream.write(data)


# The styles of TextEditor, the search panel and the completion list, and the arrow cursor.
edit(os.path.join(project_dir, "themes", "generic.xaml"), [
    (b"/ICSharpCode.AvalonEdit;component/", b"/BIMPlugins.AvalonEdit;component/", 6),
])

# The assembly name, its namespace kept for the embedded highlighting definitions, and the BIMPlugins key.
shutil.copy(key, os.path.join(project_dir, "bimplugins.snk"))
edit(os.path.join(project_dir, "ICSharpCode.AvalonEdit.csproj"), [
    (b"<OutputType>Library</OutputType>",
     b"<OutputType>Library</OutputType>\r\n    <AssemblyName>BIMPlugins.AvalonEdit</AssemblyName>"
     b"\r\n    <RootNamespace>ICSharpCode.AvalonEdit</RootNamespace>", 1),
    (b"<AssemblyOriginatorKeyFile>ICSharpCode.AvalonEdit.snk</AssemblyOriginatorKeyFile>",
     b"<AssemblyOriginatorKeyFile>bimplugins.snk</AssemblyOriginatorKeyFile>", 1),
])

# The tests' InternalsVisibleTo names AvalonEdit's own key; with the BIMPlugins key it would not build.
info = os.path.join(project_dir, "Properties", "AssemblyInfo.cs")
with open(info, "rb") as stream:
    data = stream.read()
data, count = re.subn(rb"\[assembly: InternalsVisibleTo\([^\]]*\)\]\s*", b"", data, flags=re.S)
if count != 1:
    raise SystemExit("InternalsVisibleTo has changed: found " + str(count) + ", expected 1")
with open(info, "wb") as stream:
    stream.write(data)

print("renamed AvalonEdit to BIMPlugins.AvalonEdit")
