OpenDeskBotV2 固件 0.0.56（ESP32-S3，deskbot_v2 板）

升级已有固件：用桌面客户端
  机器已在运行固件时，用 USB 线接上，打开控制台「固件」页点「烧录」即可，不需要安装任何工具。
  它只重写 0x10000 起的应用分区（与本压缩包内的 firmware.bin 完全相同），不能用于新板子或空片。

首次烧录 / 恢复：esptool 全量烧录（pip install esptool）
  烧录前先退出桌面客户端，释放串口。<串口> 形如 Windows 的 COM5、macOS 的 /dev/cu.usbmodem101、Linux 的 /dev/ttyACM0。

  全量烧录（新板子、空片，或从更早固件升级建议先整片擦除）：
    esptool.py --chip esp32s3 --port <串口> erase_flash
    esptool.py --chip esp32s3 --port <串口> write_flash 0x0 bootloader.bin 0x8000 partitions.bin 0xe000 boot_app0.bin 0x10000 firmware.bin

  只更新应用（保留设备端设置）：
    esptool.py --chip esp32s3 --port <串口> write_flash 0x10000 firmware.bin

烧录完成后机器人屏幕显示「请连接PC服务」待机画面，打开桌面客户端连上即可。
更多说明：https://github.com/tudoom/OpenDeskBotV2/blob/main/hardware/README.md
