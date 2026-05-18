/*
 * Copyright (c) 2024
 * 设备选择器 - 多设备数据源管理
 */

import { healthStore } from '@kit.HealthServiceKit';
import { InitUtils } from './InitUtils';
import { hilog } from '@kit.PerformanceAnalysisKit';

export interface DeviceInfo {
  dataSourceId: string;
  deviceName: string;
  manufacturer: string;
  model: string;
  isCurrent: boolean;
}

export class DeviceSelector {
  private static devices: DeviceInfo[] = [];
  private static currentDeviceId: string = '';

  public static async getAllDevices(): Promise<DeviceInfo[]> {
    try {
      const request: healthStore.DataSourceReadRequest = {};
      const dataSources: healthStore.DataSource[] = await healthStore.readDataSource(request);

      DeviceSelector.devices = [];
      for (const source of dataSources) {
        const device: DeviceInfo = {
          dataSourceId: source.dataSourceId || '',
          deviceName: source.deviceInfo?.name || '未知设备',
          manufacturer: source.deviceInfo?.manufacturer || '未知厂商',
          model: source.deviceInfo?.model || '未知型号',
          isCurrent: source.dataSourceId === DeviceSelector.currentDeviceId
        };
        DeviceSelector.devices.push(device);
      }

      if (!DeviceSelector.currentDeviceId && DeviceSelector.devices.length > 0) {
        DeviceSelector.currentDeviceId = DeviceSelector.devices[0].dataSourceId;
        DeviceSelector.devices[0].isCurrent = true;
      }

      return DeviceSelector.devices;
    } catch (err) {
      hilog.error(0x0000, 'DeviceSelector', `Failed to get devices: ${err.message}`);
      return [];
    }
  }

  public static async switchDevice(dataSourceId: string): Promise<boolean> {
    try {
      DeviceSelector.currentDeviceId = dataSourceId;
      InitUtils.setDataSourceId(dataSourceId);

      for (let i = 0; i < DeviceSelector.devices.length; i++) {
        DeviceSelector.devices[i].isCurrent = (DeviceSelector.devices[i].dataSourceId === dataSourceId);
      }

      hilog.info(0x0000, 'DeviceSelector', `Switched to device: ${dataSourceId}`);
      return true;
    } catch (err) {
      hilog.error(0x0000, 'DeviceSelector', `Failed to switch device: ${err.message}`);
      return false;
    }
  }

  public static getCurrentDeviceId(): string {
    return DeviceSelector.currentDeviceId;
  }
}