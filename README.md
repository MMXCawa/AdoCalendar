# 冰火日历 ADOCalendar

## 简介

冰火日历是一款基于 Python 的桌面日历工具，结合 ADOFAI 谱面推荐、每日运势、宜忌事项等趣味功能。界面美观，支持自定义字体和多彩标签，适合 ADOFAI 玩家和日常娱乐使用。

## 主要功能

- 显示当前日期和星期
- 每日随机生成 ADOFAI 谱面推荐（含作者、难度、通过人数等信息）
- 每日运势生成（0~100分，特殊日期有彩蛋）
- 随机生成宜/忌事项，内容不重复
- 用户名输入并保存到本地（含运势、宜忌等信息）
- 一键启动 ADOFAI 游戏（Steam 版）
- 一键查看每日关卡、更新日志、关于信息
- 自动检查 GitHub 最新版本并提示更新

## 使用方法(如果你用合法手段(如作者对源代码进行测试时，目前这种机会很少))。因为可能存在盗用风险，源码将不会公开

1. 安装依赖库（建议使用 Python 3.7+）：

   ```bash
   pip install requests easygui pillow
   ```

2. 运行程序：

   ```bash
   python ADOCalendar0.0.10.py
   ```

3. 按界面提示输入用户名，体验每日关卡推荐、运势、宜忌等功能。

## 主要界面说明

- 日期、运势、宜/忌事项均居中美观排版
- 右侧显示每日关卡推荐（自动获取最新谱面信息）
- 下方按钮区：保存到本地、启动游戏、查看关卡、更新日志、关于

## 文件说明

- `ADOCalendar0.0.10.exe` 主程序文件
- `userinfo.txt` 用户信息保存文件（自动生成）

## 鸣谢

- 作者：MMXCawa、B130MYS  
- 特别感谢：Ariaelle、Rycuko、Flacko、Giough、Icebomb丶ye、SwidmV、ColdCat

## 版本信息

- 自己看Release

## 其他说明

- 本程序仅供学习和娱乐使用，谱面数据来源于 [tuforums.com](https://tuforums.com)
- 如遇网络或证书问题，可参考 README 末尾“常见问题”部分

## 常见问题

- **无法打开adofai/每日关卡页面**：请保证网络环境正常，以访问steam/tuf服务器。
- **字体显示异常**：请确保系统已安装所需字体（如“Microsoft YaHei”）。

## 主页

- [GitHub 项目主页](https://github.com/MMXCawa/ADOCalendar)
- readme.md来源：Github Copilot

欢迎反馈建议和贡献代码！
