# 贡献指南 / Contributing

感谢你有兴趣为 ADOCalendar 做贡献。

Thanks for your interest in contributing to ADOCalendar.

## 报告问题 / Reporting issues

- 先搜索现有 Issues，避免重复提交。
- 描述复现步骤、预期结果和实际结果。
- 提供操作系统、Zamak 版本及相关错误信息；请勿附上设备 UUID、个人记录或其他隐私数据。
- 谱面/API 问题请说明发生时间和网络环境，但不要附上凭据或私人数据。

- Search existing issues first.
- Include reproduction steps, expected and actual behavior.
- Include the OS, Zamak version, and relevant error output. Do not share device UUIDs, personal records, or other private data.
- For API issues, include when and under what network conditions they occurred, without credentials or private data.

## 提交代码 / Code changes

1. 将改动范围保持聚焦，并尽量复用现有模式。
2. 用户可见文本应放在 `src/localization.zm` 和 `src/localization_en.zm`；修改一处时同步更新另一处。
3. 不要提交生成的 EXE、Zamak 缓存、个人配置或保存的用户记录。
4. 提交前在 Windows 和 Zamak CLI `0.2.0` 下运行：

   ```powershell
   zam check .
   zam test .
   ```

5. 若改动涉及打包脚本，请额外运行 `.\build.ps1`，确认 `build\main_<timestamp>.exe` 可生成。

1. Keep changes focused and follow existing patterns.
2. Put user-facing strings in both `src/localization.zm` and `src/localization_en.zm`.
3. Do not commit generated executables, Zamak caches, personal configuration, or saved user records.
4. Before submitting, run `zam check .` and `zam test .` on Windows with Zamak CLI `0.2.0`.
5. If packaging changes, also run `.\build.ps1` and verify it produces `build\main_<timestamp>.exe`.

## Pull Request / 拉取请求

说明改动目的、主要行为变化、验证命令和结果。涉及界面变更时，建议附上截图，并说明中英文界面都已检查。

Describe the motivation, behavior changes, validation commands, and results. For UI changes, screenshots are helpful; confirm both Chinese and English have been checked.

## 许可证 / License

本项目按 GPL-3.0-only 发布。提交贡献即表示你有权按此许可证授权所提交的内容；请勿加入无法确认授权状态的第三方素材或代码。

This project is distributed under GPL-3.0-only. By contributing, you confirm that you have the right to license your submitted contributions under these terms. Do not add third-party assets or code with unclear licensing.
