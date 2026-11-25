# yaml-config

影视仓 / OK影视类播放器订阅配置的迁移镜像。

## 来源

- 原始地址：`https://dxawi.github.io/0/0.json`
- 快照时间：2026-11-25
- 内容：48 个站点（`sites`）+ 4 条直播源（`lives`）+ 1 个 `spider` 字段
- 原始文件已备份于 `backup/0.original.json`（18,598 字节，SHA-256 `2d83952867f64bcf89285ae21ceda6409529fa5ac94575e2aba9696d09983ab0`）

## 文件

| 文件 | 说明 |
|---|---|
| `0/0.json` | 订阅配置本体。站点/直播源字段与原始文件一致，仅 `spider` 字段被替换（见下） |
| `spider/fan.txt` | 同源 spider JAR，1,376,462 字节，MD5 `0ce2eae734b7eff47763f3f9e1d8525b` |
| `backup/0.original.json` | 原始配置备份，`spider` 仍指向失效的 Zoho 链接 |
| `deploy.sh` | 一键创建仓库、推送、开启 Pages 的脚本 |

## 使用地址（独立仓库 + Pages）

仓库推送到 GitHub 并开启 Pages 后，订阅地址为：

```
https://zzh-persistence.github.io/yaml-config/0/0.json
```

开启 Pages 的步骤：仓库 `Settings` → `Pages` → `Build and deployment` → Source 选 `Deploy from a branch` → Branch 选 `main` / `(root)` → Save。等待约 1–2 分钟构建完成后即可访问。

备用地址（无需开启 Pages，推送后立即可用）：

```
https://raw.githubusercontent.com/zzh-persistence/yaml-config/main/0/0.json
```

jsDelivr 加速地址：

```
https://cdn.jsdelivr.net/gh/zzh-persistence/yaml-config@main/0/0.json
```

## spider 替换说明（重要）

原配置的 `spider` 指向 Zoho 网盘脚本，该链接持续返回 HTTP 429（经代理、直连、cookie 重试均无效），判定为该分享链接本身被风控。因此按方案 A 替换为同源 spider：

- 当前值：`https://zzh-persistence.github.io/yaml-config/spider/fan.txt;md5;0ce2eae734b7eff47763f3f9e1d8525b`
- 来源仓库：`xiaolong69/tv` 的 `spider/19/fan.txt`（下载后验证为 JAR 格式，MD5 与源仓库声明值一致）
- 验证方式：解压 JAR 检查 `classes.dex`，其内 `XxxGuard` 类与配置中 `csp_Xxx` 爬虫名一一对应

**覆盖率**：配置共 29 个不同的 `csp_` 爬虫名，该 JAR 覆盖 **18 个**：

`Alllive, Anime1, AppTT, AppYsV2, Auete, Bili, Dm84, DouDou, Jpys, KkSs, Libvio, NewCz, Nmyswv, Push, SixV, UuSs, WoGG, YCyz`

**仍缺失 11 个，对应站点不可用**：

`Ddrk, Kekys, LiteApple, MIPanSo, NanGua, NiNi, PanSearch, PanSou, YiSo, Ysj, Zxzj`

**请勿**把 `spider` 改为 `drpy2.min.js` 等通用 JS 引擎——实测该类引擎不含任何 `csp_` 爬虫定义，替换后 29 个爬虫全部失效。

配置中另有 10 个站点使用直连 API（非 `csp_`），其中部分第三方域名已无法访问，属于上游失效，与本镜像无关。

## 完整性校验

```bash
# 校验配置 JSON
curl -sSL https://zzh-persistence.github.io/yaml-config/0/0.json | sha256sum

# 校验 spider JAR 的 MD5
curl -sSL https://zzh-persistence.github.io/yaml-config/spider/fan.txt | md5sum
```

当前 `0/0.json` 的 SHA-256 与 `spider/fan.txt` 的 MD5 以仓库实际文件为准（`deploy.sh` 推送前会打印）。

## 合规提示

本配置仅聚合第三方公开接口地址，不含媒体内容本身。部分第三方站点可能存在版权合规风险，请仅用于你有权访问的内容，不要二次分发。
