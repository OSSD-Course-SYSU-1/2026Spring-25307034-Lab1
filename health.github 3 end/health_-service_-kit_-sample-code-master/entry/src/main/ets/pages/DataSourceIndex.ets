/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2023-2023. All rights reserved.
 */
/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 * 修改：添加设备切换功能
 */

import { DataSourceManagement } from '../common/bean/DataSourceManagement';
import { DeviceSelector, DeviceInfo } from '../common/utils/DeviceSelector';
import { promptAction } from '@kit.ArkUI';

@Entry
@Component
struct Index {
  @State log: string = '';
  @State devices: DeviceInfo[] = [];
  @State showDeviceList: boolean = false;

  async aboutToAppear() {
    await this.loadDevices();
  }

  async loadDevices() {
    this.devices = await DeviceSelector.getAllDevices();
  }

  build() {
    Column() {
      Text($r('app.string.DataSource')).fontWeight(FontWeight.Bold).fontSize(30).height('20%');

      // 第一行：设备切换按钮
      Row() {
        Button('📱 设备列表').width('50%').onClick(async () => {
          await this.loadDevices();
          this.showDeviceList = !this.showDeviceList;
        });
      }.height('10%');

      // 设备列表区域
      if (this.showDeviceList && this.devices.length > 0) {
        Column() {
          Text('可用设备').fontSize(16).fontWeight(FontWeight.Bold).margin({ top: 5 });
          ForEach(this.devices, (device: DeviceInfo) => {
            Row() {
              Column() {
                Text(device.deviceName).fontSize(14).fontWeight(FontWeight.Bold)
                Text(`${device.manufacturer} ${device.model}`).fontSize(10).fontColor('#666')
              }.alignItems(HorizontalAlign.Start).layoutWeight(1)

              if (device.isCurrent) {
                Text('当前').fontSize(12).fontColor('#00AA00')
              } else {
                Button('切换').fontSize(12).height(30).onClick(async () => {
                  const success = await DeviceSelector.switchDevice(device.dataSourceId);
                  if (success) {
                    promptAction.showToast({ message: `已切换到 ${device.deviceName}` });
                    await this.loadDevices();
                  } else {
                    promptAction.showToast({ message: '切换失败' });
                  }
                })
              }
            }.width('95%').padding(8).margin({ top: 5 }).backgroundColor('#F0F0F0').borderRadius(8)
          })
        }.width('100%').margin({ top: 10 })
      }

      // 原有按钮
      Row() {
        Button($r('app.string.InsertDataSource')).width('50%').onClick(async () => {
          this.log = await DataSourceManagement.insertDataSource();
          await this.loadDevices(); // 刷新设备列表
        });
      }.height('10%');

      Row() {
        Button($r('app.string.UpdateDataSource')).width('50%').onClick(async () => {
          this.log = await DataSourceManagement.updateDataSource();
        });
      }.height('10%');

      Row() {
        Button($r('app.string.ReadDataSource')).width('50%').onClick(async () => {
          this.log = await DataSourceManagement.readDataSource();
        });
      }.height('10%');

      // 日志区域
      Column() {
        Text($r('app.string.Print_log')).fontSize(15).fontWeight(FontWeight.Bold);
        Text(this.log).fontSize(10).textAlign(TextAlign.Start);
      }.alignItems(HorizontalAlign.Start).width('90%')

    }.alignItems(HorizontalAlign.Center).height('100%').width('100%')
    .justifyContent(FlexAlign.Start)
  }
}