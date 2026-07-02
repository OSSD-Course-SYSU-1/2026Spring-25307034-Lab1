/*
 * Copyright (c) 2024
 * 分布式数据对象工具类 - 用于跨端迁移
 */

import { distributedDataObject } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG = 'DistributedDataHelper';
const DOMAIN = 0x0000;

// 定义数据接口
export interface HealthDataRecord {
  stepCount: number;
  calorieCount: number;
  heartRate: number;
  sleepHours: number;
  stepGoal: number;
  timestamp: number;
}

export class DistributedDataHelper {
  private static dObject: distributedDataObject.DataObject | null = null;
  private static sessionId: string = '';

  public static async createSourceDataObject(
    context: common.Context,
    healthData: HealthDataRecord
  ): Promise<string> {
    try {
      DistributedDataHelper.dObject = distributedDataObject.create(context, healthData);
      DistributedDataHelper.sessionId = distributedDataObject.genSessionId();
      DistributedDataHelper.dObject.setSessionId(DistributedDataHelper.sessionId);

      hilog.info(DOMAIN, TAG, `Created source data object, sessionId: ${DistributedDataHelper.sessionId}`);
      return DistributedDataHelper.sessionId;
    } catch (err) {
      hilog.error(DOMAIN, TAG, `Failed to create source: ${JSON.stringify(err)}`);
      return '';
    }
  }

  public static async createTargetDataObject(
    context: common.Context,
    sessionId: string,
    onDataRestored: (data: HealthDataRecord) => void
  ): Promise<void> {
    try {
      const emptyData: HealthDataRecord = {
        stepCount: 0,
        calorieCount: 0,
        heartRate: 0,
        sleepHours: 0,
        stepGoal: 0,
        timestamp: 0
      };

      DistributedDataHelper.dObject = distributedDataObject.create(context, emptyData);

      if (DistributedDataHelper.dObject) {
        DistributedDataHelper.dObject.on('status', (status: string) => {
          hilog.info(DOMAIN, TAG, `Data object status: ${status}`);
          if (status === 'restored' && DistributedDataHelper.dObject) {
            // 通过索引方式访问DataObject属性
            const dObj = DistributedDataHelper.dObject;
            const restoredData: HealthDataRecord = {
              stepCount: (dObj['stepCount'] as number) || 0,
              calorieCount: (dObj['calorieCount'] as number) || 0,
              heartRate: (dObj['heartRate'] as number) || 0,
              sleepHours: (dObj['sleepHours'] as number) || 0,
              stepGoal: (dObj['stepGoal'] as number) || 8000,
              timestamp: (dObj['timestamp'] as number) || 0
            };
            onDataRestored(restoredData);
          }
        });

        DistributedDataHelper.dObject.setSessionId(sessionId);
      }

      hilog.info(DOMAIN, TAG, `Created target data object with sessionId: ${sessionId}`);
    } catch (err) {
      hilog.error(DOMAIN, TAG, `Failed to create target: ${JSON.stringify(err)}`);
    }
  }

  public static getSessionId(): string {
    return DistributedDataHelper.sessionId;
  }
}