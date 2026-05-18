/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2023-2023. All rights reserved.
 */
import { router } from '@kit.ArkUI';

@Entry
@Component
struct MainIndex {
  build() {
    Column() {
      Text($r('app.string.Kit')).fontWeight(FontWeight.Bold).fontSize(40);
      Button($r('app.string.DataSource')).width('80%').margin({ bottom: 10 }).onClick(() => {
        router.pushUrl({ url: "pages/DataSourceIndex" })
      });
      Button($r('app.string.SamplePoint')).width('80%').margin({ bottom: 10 }).onClick(() => {
        router.pushUrl({ url: "pages/SamplePointIndex" })
      });
      Button($r('app.string.ExerciseSequence')).width('80%').margin({ bottom: 10 }).onClick(() => {
        router.pushUrl({ url: "pages/ExerciseSequenceIndex" })
      });
      Button($r('app.string.HealthSequence')).width('80%').margin({ bottom: 10 }).onClick(() => {
        router.pushUrl({ url: "pages/HealthSequenceIndex" })
      });
      Button($r('app.string.Auth')).width('80%').margin({ bottom: 10 }).onClick(() => {
        router.pushUrl({ url: "pages/AuthIndex" })
      });
      Button($r('app.string.Workout')).width('80%').margin({ bottom: 10 }).onClick(() => {
        router.pushUrl({ url: "pages/WorkoutIndex" })
      });
      Button('健康目标设置').width('80%').margin({ bottom: 10 }).fontColor('#FF6B6B').onClick(() => {
        router.pushUrl({ url: "pages/GoalSettingIndex" })
      });
    }.alignItems(HorizontalAlign.Center).height('100%').width('100%')
    .justifyContent(FlexAlign.SpaceEvenly)
  }
}