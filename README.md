# ADOCalendar

冰火日历是一款使用 [Zamak](https://zamak.veyralux.org/) 编写的 Windows 桌面应用。它按设备 ID 生成每日运势，并从 TUForums API 获取每日谱面推荐。界面支持简体中文和 English。

ADOCalendar is a Windows desktop app written in [Zamak](https://zamak.veyralux.org/). It generates a daily fortune from the device ID and retrieves a daily level recommendation from the TUForums API. The interface supports Simplified Chinese and English.

## 项目背景 / Background

本项目的设想来源于作者约一年前编写的 Python 版 ADOCalendar。0.0.16 是对该 Python 版的完全重写：使用 Zamak 重新实现应用，并借助 AI Agent 协作完成代码编写与迭代。这也是一次将既有 Python 项目迁移到 Zamak、并实践以 Zamak 与 AI Agent 协作重写应用的有效案例。

The idea for this project came from an ADOCalendar Python version written by the author about a year ago. Version 0.0.16 is a complete rewrite of that Python version: the application was reimplemented in Zamak, with an AI Agent assisting with implementation and iteration. This project is also a practical example of migrating an existing Python application to Zamak and using Zamak together with an AI Agent to rewrite an application.

## 功能 / Features

- 按设备 ID 生成稳定的每日运势和宜忌。
- 按日期选择每日谱面，并展示谱面信息。
- 冰蓝、午夜蓝和暖阳橙三种主题。
- 在“关于”页面切换简体中文和 English。
- 将当日记录追加保存到“文档/ADOCalendar/userinfo.txt”。
- 提供带应用图标的单文件、无控制台 Windows 可执行程序。

- Stable daily fortune and recommendations based on the device ID.
- A date-seeded daily level recommendation with level details.
- Ice Blue, Midnight Blue, and Warm Sunset themes.
- Switch between Simplified Chinese and English from the About page.
- Append the day's record to `Documents/ADOCalendar/userinfo.txt`.
- A single-file Windows executable with an application icon and no console window.

## 获取应用 / Get the app

从 GitHub **Releases** 下载最新的 `ADOCalendar_<version>.exe`，双击运行。应用需要联网访问 TUForums API。启动时，单文件程序会将内嵌应用解压到 Windows 临时目录运行，并在应用退出后尝试删除该临时文件。

Download the latest `ADOCalendar_<version>.exe` from GitHub **Releases** and run it. Internet access is required for the TUForums API. On launch, the single-file executable extracts its embedded app to the Windows temporary directory and attempts to remove that file after the app exits.

### 隐私说明 / Privacy

程序读取 Windows `Win32_ComputerSystemProduct.UUID`，仅用于本机每日运势的种子计算；该 ID 不会作为 API 请求参数发送。谱面请求会访问 TUForums API。用户主动保存的记录写入 Windows“文档”目录下的 `ADOCalendar/userinfo.txt`。

The app reads `Win32_ComputerSystemProduct.UUID` to seed the fortune calculation locally; it is not sent as an API request parameter. Level requests go to the TUForums API. Records are written only when requested by the user, to `ADOCalendar/userinfo.txt` under the Windows Documents folder.

## 从源码构建 / Build from source

要求：

- Windows
- [Node.js](https://nodejs.org/)
- Zamak CLI `0.2.0`

安装 Zamak 并验证：

```powershell
npm install --global @veyralux/zamak@0.2.0
zam --version
```

在仓库根目录执行：

```powershell
zam check .
zam test .
.\build.ps1
```

发布版会生成在 `build\main_<timestamp>.exe`。构建脚本还会在 `build` 目录留下 Zamak 编译产物；日常开发时请勿将构建产物或缓存提交到源码仓库。

## 项目结构 / Project layout

```text
src/
  main.zm             Application logic and GUI
  localization.zm    Simplified Chinese strings
  localization_en.zm English strings
build.ps1             Windows single-file packaging script
icon.ico              Application icon
zam.toml              Zamak project configuration
```

## 参与贡献 / Contributing

欢迎提交 Issue 和 Pull Request。提交前请阅读 [CONTRIBUTING.md](CONTRIBUTING.md)，并运行 `zam check .` 和 `zam test .`。新增或修改界面文案时，请同步更新 `src/localization.zm` 和 `src/localization_en.zm`。

Issues and pull requests are welcome. Before contributing, read [CONTRIBUTING.md](CONTRIBUTING.md) and run `zam check .` and `zam test .`. When adding or changing UI text, update both localization modules.

## 版本 / Version

当前版本：**0.0.16**。变更记录见 [CHANGELOG.md](CHANGELOG.md)。

Current version: **0.0.16**. See [CHANGELOG.md](CHANGELOG.md) for release notes.

## 许可证 / License

本项目采用 **GNU General Public License v3.0 only（GPL-3.0-only）**。许可证全文见 [LICENSE](LICENSE)。这表示本项目按 GPL 第 3 版授权，不额外授予改用后续 GPL 版本的选择。

This project is licensed under the **GNU General Public License v3.0 only (GPL-3.0-only)**. See [LICENSE](LICENSE) for the full license text. The project is licensed under GPL version 3 only, without an additional option to use later GPL versions.
