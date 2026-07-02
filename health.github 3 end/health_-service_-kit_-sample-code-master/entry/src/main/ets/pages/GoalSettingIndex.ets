/*
 * Copyright (c) 2024
 * 健康目标设置页面
 */

import { router } from '@kit.ArkUI';
import { GoalManager, HealthGoal } from '../common/utils/GoalManager';
import { common } from '@kit.AbilityKit';
import { promptAction } from '@kit.ArkUI';

@Entry
@Component
struct GoalSettingIndex {
  @State stepGoal: number = 8000;
  @State calorieGoal: number = 300;
  @State sleepGoal: number = 8;
  @State enableNotification: boolean = true;
  @State loading: boolean = true;

  async aboutToAppear() {
    try {
      await GoalManager.init(getContext(this) as common.UIAbilityContext);
      const goals: HealthGoal = await GoalManager.getGoals();
      this.stepGoal = goals.dailySteps;
      this.calorieGoal = goals.dailyCalories;
      this.sleepGoal = goals.dailySleepHours;
      this.enableNotification = goals.enableNotification;
      this.loading = false;
    } catch (err) {
      this.loading = false;
    }
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Button('← 返回').onClick(() => {
          router.back();
        })
        Text('健康目标设置').fontSize(24).fontWeight(FontWeight.Bold).layoutWeight(1).textAlign(TextAlign.Center)
      }.width('100%').padding(10)

      if (this.loading) {
        LoadingProgress().width(50).height(50).margin({ top: 100 })
      } else {
        Column() {
          // 步数目标
          Text('🚶 每日步数目标').fontSize(18).fontWeight(FontWeight.Bold).margin({ top: 20 })
          Text(this.stepGoal + ' 步').fontSize(14).fontColor('#666')
          Slider({
            value: this.stepGoal,
            min: 1000,
            max: 20000,
            step: 500
          }).onChange((value: number) => {
            this.stepGoal = value;
          }).margin({ left: 20, right: 20 })

          // 卡路里目标
          Text('🔥 每日卡路里目标').fontSize(18).fontWeight(FontWeight.Bold).margin({ top: 20 })
          Text(this.calorieGoal + ' 千卡').fontSize(14).fontColor('#666')
          Slider({
            value: this.calorieGoal,
            min: 100,
            max: 1000,
            step: 50
          }).onChange((value: number) => {
            this.calorieGoal = value;
          }).margin({ left: 20, right: 20 })

          // 睡眠目标
          Text('😴 每日睡眠目标').fontSize(18).fontWeight(FontWeight.Bold).margin({ top: 20 })
          Text(this.sleepGoal + ' 小时').fontSize(14).fontColor('#666')
          Slider({
            value: this.sleepGoal,
            min: 4,
            max: 12,
            step: 0.5
          }).onChange((value: number) => {
            this.sleepGoal = value;
          }).margin({ left: 20, right: 20 })

          // 通知开关
          Row() {
            Text('🔔 启用提醒通知').fontSize(18).fontWeight(FontWeight.Bold)
            Toggle({ type: ToggleType.Switch, isOn: this.enableNotification })
              .onChange((isOn: boolean) => {
                this.enableNotification = isOn;
              })
          }.justifyContent(FlexAlign.SpaceBetween).width('90%').margin({ top: 20 })

          // 保存按钮
          Button('💾 保存设置').width('80%').height(45).margin({ top: 30 })
            .backgroundColor('#007DFF')
            .onClick(async () => {
              const goals: HealthGoal = {
                dailySteps: this.stepGoal,
                dailyCalories: this.calorieGoal,
                dailySleepHours: this.sleepGoal,
                enableNotification: this.enableNotification
              };
              await GoalManager.saveGoals(goals);
              promptAction.showToast({ message: '目标已保存！' });
            })

          // 健康建议
          Text('💡 健康建议').fontSize(16).fontWeight(FontWeight.Bold).margin({ top: 30 })
          Text('• 世界卫生组织建议每日步数不少于8000步\n• 成年人每日卡路里消耗建议300-500千卡\n• 保持7-9小时睡眠有助于身体恢复')
            .fontSize(12).fontColor('#666').margin({ top: 5 })
        }.padding(20)
      }
    }.width('100%').height('100%').backgroundColor('#F5F5F5')
  }
}