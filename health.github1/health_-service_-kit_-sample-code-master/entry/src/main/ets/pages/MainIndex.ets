import { router } from '@kit.ArkUI';

@Entry
@Component
struct MainIndex {
  build() {
    Column() {
      // ========== 顶部装饰区域 ==========
      Column() {
        // 运动图标行
        Row() {
          Text('🏃‍♂️').fontSize(42).margin({ right: 12 })
          Text('💪').fontSize(42).margin({ right: 12 })
          Text('🏊‍♂️').fontSize(42).margin({ right: 12 })
          Text('🚴‍♂️').fontSize(42)
        }

        // 主标题
        Text('运动健康服务')
          .fontSize(32)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1A73E8')
          .margin({ top: 15 })

        // 副标题
        Text('开启健康生活')
          .fontSize(14)
          .fontColor('#888888')
          .margin({ top: 5 })
      }
      .width('100%')
      .height('30%')
      .justifyContent(FlexAlign.Center)
      .backgroundColor('#F0F8FF')
      .borderRadius({ bottomLeft: 30, bottomRight: 30 })

      // ========== 按钮区域 ==========
      Scroll() {
        Column() {
          Button('📊 数据源管理').width('85%').height(50).margin({ bottom: 12 })
            .backgroundColor('#1A73E8')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#FFFFFF')
            .onClick(() => {
              router.pushUrl({ url: "pages/DataSourceIndex" })
            })

          Button('📈 采样数据管理').width('85%').height(50).margin({ bottom: 12 })
            .backgroundColor('#34A853')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#FFFFFF')
            .onClick(() => {
              router.pushUrl({ url: "pages/SamplePointIndex" })
            })

          Button('🏃 锻炼记录管理').width('85%').height(50).margin({ bottom: 12 })
            .backgroundColor('#EA4335')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#FFFFFF')
            .onClick(() => {
              router.pushUrl({ url: "pages/ExerciseSequenceIndex" })
            })

          Button('😴 健康记录管理').width('85%').height(50).margin({ bottom: 12 })
            .backgroundColor('#8E44AD')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#FFFFFF')
            .onClick(() => {
              router.pushUrl({ url: "pages/HealthSequenceIndex" })
            })

          Button('🔐 授权管理').width('85%').height(50).margin({ bottom: 12 })
            .backgroundColor('#F39C12')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#FFFFFF')
            .onClick(() => {
              router.pushUrl({ url: "pages/AuthIndex" })
            })

          Button('🎯 运动联动').width('85%').height(50).margin({ bottom: 12 })
            .backgroundColor('#E67E22')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#FFFFFF')
            .onClick(() => {
              router.pushUrl({ url: "pages/WorkoutIndex" })
            })

          Button('🎯 健康目标设置').width('85%').height(50).margin({ bottom: 20 })
            .backgroundColor('#FF6B6B')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#FFFFFF')
            .onClick(() => {
              router.pushUrl({ url: "pages/GoalSettingIndex" })
            })
        }
        .width('100%')
        .padding({ top: 20, bottom: 20 })
      }
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Off)
      .width('100%')
      .layoutWeight(1)

    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FAFAFA')
  }
}