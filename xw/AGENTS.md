# XW — 小歪机器人 v2（交付物仓库）

## OVERVIEW
纯交付物目录，**没有源码、没有构建脚本、没有依赖**。放的是可烧录固件和可下单的 3D 模型。
上游固件项目：https://github.com/tudoom/OpenDeskBotV2 （本目录只存 v2 的成品，不含其源码）。

## STRUCTURE
```text
xw/
├── OpenDeskBotV2-firmware-0.0.56/   # ESP32-S3 固件 0.0.56（deskbot_v2 板）
│   ├── bootloader.bin     # 20 KB   → 0x0
│   ├── partitions.bin     # 3 KB    → 0x8000
│   ├── boot_app0.bin      # 8 KB    → 0xe000
│   ├── firmware.bin       # 1.9 MB  → 0x10000（应用分区）
│   └── README.txt         # 烧录步骤（唯一文档）
├── 小歪机器人v2.0 ov3660摄像头卡子.stp   # 3D 模型（摄像头卡子）
├── 小歪机器人v2.0打印件stp.stp           # 3D 模型（打印件合集）
└── .gitignore
```

## 文件性质
| 类型 | 是否入库 | 说明 |
|------|----------|------|
| `*.bin`（bootloader/partitions/boot_app0/firmware） | **必须入库** | 发布固件，是交付物；已在跟踪，不要加 `*.bin` 通配忽略 |
| `*.stp` | **必须入库** | 3D 交付物，体积大（打印件 7.2 MB）但不可替代 |
| `build/`、`.pio/`、`.pioenvs/` | 忽略 | 构建目录；本目录目前也没有源码，仅作预防 |
| `*.log`、`.DS_Store`、工具运行时状态 | 忽略 | 见 `.gitignore` |

**不要**给 `*.bin` / `*.stp` 加通配忽略规则，也**不要**把大文件挪去 LFS 或外部网盘——交付物就是这个仓库的价值。

## 烧录（摘自 firmware README.txt）
```bash
# 首次烧录 / 换板 / 空片（先整片擦除）
esptool.py --chip esp32s3 --port <串口> erase_flash
esptool.py --chip esp32s3 --port <串口> write_flash \
  0x0 bootloader.bin 0x8000 partitions.bin 0xe000 boot_app0.bin 0x10000 firmware.bin

# 只更新应用（保留设备端设置）
esptool.py --chip esp32s3 --port <串口> write_flash 0x10000 firmware.bin
```
- 已在运行固件的机器可用桌面客户端「固件 → 烧录」，它只重写 `0x10000` 起的应用分区，**不能用于新板或空片**。
- 烧录前退出桌面客户端以释放串口；串口形如 Windows `COM5`、macOS `/dev/cu.usbmodem101`、Linux `/dev/ttyACM0`。
- 烧完屏幕显示「请连接PC服务」待机画面，打开桌面客户端连接即可。

## CONVENTIONS
- 新增固件版本时**新建版本目录**（如 `OpenDeskBotV2-firmware-0.0.57/`），保留旧版本目录，不要原地覆盖 bin——旧版本是回滚依据。
- 版本号以目录名 + `README.txt` 首行为准，两处必须一致。
- 文件名里的中文与空格保持原样（STP 交付名要能对上下游文档）。

## 注意
- 本目录无测试、无校验和；真要复用前先用 `esptool.py verify_flash` 或对比上游 release 的 SHA。
- 该仓库是个人项目，不要在此提交临时抓包、截图或解压残留。
