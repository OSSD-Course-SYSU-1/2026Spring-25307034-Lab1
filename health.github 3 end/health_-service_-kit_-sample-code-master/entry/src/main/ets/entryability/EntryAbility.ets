import { healthStore } from '@kit.HealthServiceKit';
import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { ExportUtil } from '../common/utils/ExportUtil';
import { GoalManager } from '../common/utils/GoalManager';
import { DistributedDataHelper, HealthDataRecord } from '../common/utils/DistributedDataHelper';

export default class EntryAbility extends UIAbility {
  private mainWindow: window.Window | null = null;

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
    healthStore.init(this.context);
    // 初始化工具类
    ExportUtil.init(this.context);
    GoalManager.init(this.context);

    // 检查是否有迁移数据（冷启动）
    this.handleContinueData(want);
  }

  /**
   * 处理应用已被拉起时的迁移数据（热启动）
   */
  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onNewWant');
    this.handleContinueData(want);
  }

  onDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
    if (this.mainWindow) {
      this.mainWindow.off('windowSizeChange');
    }
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/MainIndex', (err, data) => {
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(0x0000, 'testTag', 'Succeeded in loading the content. Data: %{public}s', JSON.stringify(data) ?? '');
    });
  }

  onWindowStageDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground');
  }

  /**
   * 跨端迁移：保存数据（源端调用）
   */
  async onContinue(wantParam: Record<string, Object>): Promise<AbilityConstant.OnContinueResult> {
    hilog.info(0x0000, 'testTag', 'onContinue called');

    try {
      // 从 AppStorage 获取当前健康数据
      const stepCount = AppStorage.get<number>('stepCount') || 7842;
      const calorieCount = AppStorage.get<number>('calorieCount') || 342;
      const heartRate = AppStorage.get<number>('heartRate') || 72;
      const sleepHours = AppStorage.get<number>('sleepHours') || 7.5;
      const stepGoal = AppStorage.get<number>('stepGoal') || 10000;

      const healthData: HealthDataRecord = {
        stepCount: stepCount,
        calorieCount: calorieCount,
        heartRate: heartRate,
        sleepHours: sleepHours,
        stepGoal: stepGoal,
        timestamp: Date.now()
      };

      // 创建分布式数据对象
      const sessionId = await DistributedDataHelper.createSourceDataObject(this.context, healthData);

      if (sessionId) {
        wantParam['dataSessionId'] = sessionId;
        wantParam['targetDevice'] = wantParam.targetDevice || '';
        hilog.info(0x0000, 'testTag', `onContinue success, sessionId: ${sessionId}`);
        return AbilityConstant.OnContinueResult.AGREE;
      }

      return AbilityConstant.OnContinueResult.REJECT;
    } catch (err) {
      hilog.error(0x0000, 'testTag', `onContinue error: ${JSON.stringify(err)}`);
      return AbilityConstant.OnContinueResult.REJECT;
    }
  }

  /**
   * 处理迁移过来的数据（对端接收）
   */
  private handleContinueData(want: Want): void {
    try {
      const sessionId = want.parameters?.dataSessionId as string;
      if (sessionId) {
        hilog.info(0x0000, 'testTag', `Received continue data, sessionId: ${sessionId}`);

        // 接收分布式数据
        DistributedDataHelper.createTargetDataObject(this.context, sessionId, (data: HealthDataRecord) => {
          hilog.info(0x0000, 'testTag', `Data restored: steps=${data.stepCount}, calories=${data.calorieCount}`);

          // 存储到 AppStorage，供页面使用
          AppStorage.setOrCreate('stepCount', data.stepCount);
          AppStorage.setOrCreate('calorieCount', data.calorieCount);
          AppStorage.setOrCreate('heartRate', data.heartRate);
          AppStorage.setOrCreate('sleepHours', data.sleepHours);
          AppStorage.setOrCreate('stepGoal', data.stepGoal);
          AppStorage.setOrCreate('isDataRestored', true);
        });
      }
    } catch (err) {
      hilog.error(0x0000, 'testTag', `handleContinueData error: ${JSON.stringify(err)}`);
    }
  }
}