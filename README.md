# PeerColab CLI

The PeerColab CLI is a companion to [app.peercolab.com](https://app.peercolab.com) that generates typed client code from your PeerColab models. It runs locally on your machine and writes generated code directly into your source code repository.

## How It Works

PeerColab separates the design of your system from the implementation:

1. [**app.peercolab.com**](https://app.peercolab.com) is where you model your product architecture, defining operations, types, and events.
2. **PeerColab CLI** runs locally on your machine. When you export a library from app.peercolab.com, the CLI generates code files and writes them to your configured local path.
3. **Language Engines**. The CLI supports **TypeScript**, **C# (.NET)**, and **Python**. Each language engine produces typed models, operation stubs, and event contracts that match your PeerColab model. The generated code depends on the **PeerColab Engine** runtime package for the chosen language.

```
Design at app.peercolab.com  →  Export  →  PeerColab CLI writes typed code to your project
```

## Install

The installer downloads the right binary for your platform, names it `peercolab`, and places it on your `PATH`.

### macOS / Linux

```bash
curl -fsSL https://raw.githubusercontent.com/New-Horizon-Tech/peercolab-codegen-public/main/install.sh | bash
```

Installs to `~/.local/bin/peercolab` by default. Override with `PEERCOLAB_INSTALL_DIR=/some/dir`.

### Windows (PowerShell)

```powershell
iwr -useb https://raw.githubusercontent.com/New-Horizon-Tech/peercolab-codegen-public/main/install.ps1 | iex
```

Installs to `%LOCALAPPDATA%\Programs\peercolab\peercolab.exe` and adds that directory to your user `PATH`. Open a new terminal to pick up the change.

After installation, run it from any directory:

```
peercolab
```

### Manual install

If you'd rather not run a piped script, download the binary directly and place it on your `PATH`:

- [Windows (x64)](https://github.com/New-Horizon-Tech/peercolab-codegen-public/releases/latest/download/peercolab-win-x64.exe)
- [macOS (x64)](https://github.com/New-Horizon-Tech/peercolab-codegen-public/releases/latest/download/peercolab-osx-x64)
- [macOS (arm64)](https://github.com/New-Horizon-Tech/peercolab-codegen-public/releases/latest/download/peercolab-osx-arm64)
- [Linux (x64)](https://github.com/New-Horizon-Tech/peercolab-codegen-public/releases/latest/download/peercolab-linux-x64)
- [Linux (arm64)](https://github.com/New-Horizon-Tech/peercolab-codegen-public/releases/latest/download/peercolab-linux-arm64)

Linux/macOS:

```bash
# Rename, make executable, move onto PATH
mv peercolab-linux-x64 peercolab
chmod +x peercolab
mv peercolab ~/.local/bin/

# macOS only: clear Gatekeeper quarantine if needed
xattr -d com.apple.quarantine ~/.local/bin/peercolab 2>/dev/null || true
```

Windows: rename `peercolab-win-x64.exe` to `peercolab.exe` and move it to a directory on your `PATH`.

### Notes

- Only one instance can run at a time. If the tool is already running, a second launch will exit automatically.
- The tool checks for updates on startup. Use `--auto-update` to update without being prompted.

## Using with app.peercolab.com

1. Start the CLI on your machine by running `peercolab`.
2. Open [app.peercolab.com](https://app.peercolab.com) and navigate to your library.
3. Configure the export settings. Choose the target language and the local path where code should be written.
4. Export from app.peercolab.com. The CLI generates the files and writes them into your project.

### Output folder structure

The CLI creates a folder named after your **system** inside the local path you chose in app.peercolab.com. For example, if your system is called `Payments` and you export to `/home/user/myproject/src`, the generated code will be written to:

```
/home/user/myproject/src/Payments/
```

**Important:** This folder is fully overwritten on every export. Do not choose a local path that already contains a folder with the same name as your system, unless that folder is exclusively managed by the CLI.

## Supported Languages

| Language | Output | Runtime Dependency |
|----------|--------|--------------------|
| **TypeScript** | `.ts` files with imports, typed models, and operation stubs | [`@peercolab/engine`](https://www.npmjs.com/package/@peercolab/engine) (npm) |
| **C# (.NET)** | `.cs` files with namespaces and typed models | [`PeerColabEngine`](https://www.nuget.org/packages/PeerColabEngine) (NuGet) |
| **Python** | `.py` files with typed classes and imports | [`peercolab-engine`](https://pypi.org/project/peercolab-engine/) (pip) |

The generated code provides the types and contracts for your PeerColab models. The runtime engine package handles transport and serialization.

---

For more information, visit [peercolab.com](https://www.peercolab.com/) or [contact us](https://www.peercolab.com/contact).
