/*
 * Copyright (c) 2024
 * 运动健康服务 - 精简一屏版（平板无需滚动）
 */

import { router } from '@kit.ArkUI';
import { window } from '@kit.ArkUI';
import { abilityAccessCtrl, Permissions } from '@kit.AbilityKit';
import { promptAction } from '@kit.ArkUI';
import { DistributedDataHelper, HealthDataRecord } from '../common/utils/DistributedDataHelper';

interface FeatureItem {
  icon: string;
  title: string;
  bgColor: string;
  route: string;
}

interface BannerItem {
  imageUrl: string;
  title: string;
  subtitle: string;
}

@Entry
@Component
struct MainIndex {
  @State currentBreakpoint: string = 'sm';
  @State greeting: string = '';
  @State stepCount: number = 7842;
  @State stepGoal: number = 10000;
  @State calorieCount: number = 342;
  @State heartRate: number = 72;
  @State sleepHours: number = 7.5;
  private mainWindow: window.Window | null = null;

  private hotFeatures: FeatureItem[] = [
    { icon: '📊', title: '数据源', bgColor: '#E8F0FE', route: 'pages/DataSourceIndex' },
    { icon: '📈', title: '采样', bgColor: '#E6F4EA', route: 'pages/SamplePointIndex' },
    { icon: '🏃', title: '锻炼', bgColor: '#FCE8E6', route: 'pages/ExerciseSequenceIndex' },
    { icon: '😴', title: '健康', bgColor: '#EDE7F6', route: 'pages/HealthSequenceIndex' },
    { icon: '🔐', title: '授权', bgColor: '#FEF3E2', route: 'pages/AuthIndex' },
    { icon: '🎯', title: '联动', bgColor: '#FDEBD8', route: 'pages/WorkoutIndex' },
    { icon: '🏅', title: '目标', bgColor: '#FFE8E8', route: 'pages/GoalSettingIndex' }
  ];

  private bannerData: BannerItem[] = [
    {
      imageUrl: 'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?w=750&h=350&fit=crop',
      title: '🏃 跑步计划',
      subtitle: '今天完成 5km 户外跑'
    },
    {
      imageUrl: 'https://images.unsplash.com/photo-1517649763962-0c623066013b?w=750&h=350&fit=crop',
      title: '🚴 骑行挑战',
      subtitle: '周末环湖骑行 30km'
    },
    {
      imageUrl: 'https://images.unsplash.com/photo-1530549387789-4c1017266635?w=750&h=350&fit=crop',
      title: '🏊 游泳训练',
      subtitle: '每周 3 次，每次 45 分钟'
    }
  ];

  async aboutToAppear() {
    try {
      this.updateGreeting();
      await this.requestDistributedPermission();

      if (AppStorage.get<boolean>('isDataRestored')) {
        this.stepCount = AppStorage.get<number>('stepCount') || this.stepCount;
        this.calorieCount = AppStorage.get<number>('calorieCount') || this.calorieCount;
        this.heartRate = AppStorage.get<number>('heartRate') || this.heartRate;
        this.sleepHours = AppStorage.get<number>('sleepHours') || this.sleepHours;
        this.stepGoal = AppStorage.get<number>('stepGoal') || this.stepGoal;
        AppStorage.set('isDataRestored', false);
      }

      const win = await window.getLastWindow(getContext(this));
      this.mainWindow = win;
      const properties = win.getWindowProperties();
      const width = px2vp(properties.windowRect.width);
      this.currentBreakpoint = this.getBreakpoint(width);
      win.on('windowSizeChange', (size: window.Size) => {
        this.currentBreakpoint = this.getBreakpoint(px2vp(size.width));
      });
    } catch (err) {
      console.error('aboutToAppear error: ' + JSON.stringify(err));
    }
  }

  aboutToDisappear() {
    try {
      if (this.mainWindow) {
        this.mainWindow.off('windowSizeChange');
      }
    } catch (err) {
      console.error('aboutToDisappear error: ' + JSON.stringify(err));
    }
  }

  private getBreakpoint(windowWidth: number): string {
    return windowWidth < 600 ? 'sm' : 'lg';
  }

  private fs(sm: number, lg: number): number {
    return this.currentBreakpoint === 'sm' ? sm : lg;
  }

  private getContentWidth(): string {
    return '92%';
  }

  private getGridColumns(): string {
    return '1fr 1fr 1fr 1fr';
  }

  private async requestDistributedPermission() {
    try {
      const atManager = abilityAccessCtrl.createAtManager();
      const permission: Permissions = 'ohos.permission.DISTRIBUTED_DATASYNC';
      const grantStatus = await atManager.checkAccessToken(0, permission);
      if (grantStatus !== abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
        await atManager.requestPermissionsFromUser(getContext(this), [permission]);
      }
    } catch (err) {
      console.error('Permission request failed: ' + JSON.stringify(err));
    }
  }

  private updateGreeting() {
    const hour = new Date().getHours();
    if (hour < 6) {
      this.greeting = '夜深了，早点休息';
    } else if (hour < 12) {
      this.greeting = '早上好，运动达人';
    } else if (hour < 14) {
      this.greeting = '中午好，记得吃午饭';
    } else if (hour < 18) {
      this.greeting = '下午好，保持活力';
    } else {
      this.greeting = '晚上好，放松一下';
    }
  }

  private getStepProgress(): number {
    return (this.stepCount / this.stepGoal) * 100;
  }

  private getStepCountText(): string {
    return this.stepCount.toString();
  }

  private getProgressPercent(): string {
    return Math.floor(this.getStepProgress()).toString();
  }

  private getCalorieText(): string {
    return this.calorieCount.toString();
  }

  private getHeartRateText(): string {
    return this.heartRate.toString();
  }

  private getSleepText(): string {
    return this.sleepHours.toString();
  }

  private async shareToOtherDevice() {
    try {
      AppStorage.setOrCreate('stepCount', this.stepCount);
      AppStorage.setOrCreate('calorieCount', this.calorieCount);
      AppStorage.setOrCreate('heartRate', this.heartRate);
      AppStorage.setOrCreate('sleepHours', this.sleepHours);
      AppStorage.setOrCreate('stepGoal', this.stepGoal);

      const healthData: HealthDataRecord = {
        stepCount: this.stepCount,
        calorieCount: this.calorieCount,
        heartRate: this.heartRate,
        sleepHours: this.sleepHours,
        stepGoal: this.stepGoal,
        timestamp: Date.now()
      };

      const sessionId = await DistributedDataHelper.createSourceDataObject(getContext(this), healthData);
      promptAction.showToast({ message: sessionId ? '数据已就绪' : '分享失败' });
    } catch (err) {
      console.error('Share failed: ' + JSON.stringify(err));
      promptAction.showToast({ message: '分享失败' });
    }
  }

  build() {
    Scroll() {
      Column() {

        // ======== 1. 顶部区域 (20%) ========
        Column() {
          Stack({ alignContent: Alignment.TopEnd }) {
            Column() {
              Text(this.greeting)
                .fontSize(this.fs(20, 24))
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF')
              Text('保持运动，健康每一天')
                .fontSize(this.fs(12, 13))
                .fontColor('#FFFFFF')
                .opacity(0.8)
                .margin({ top: 4 })
            }
            .width('100%')
            .height('100%')
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)

            Row({ space: 10 }) {
              Row() {
                Text('🔄').fontSize(this.fs(14, 16))
                Text('分享').fontSize(this.fs(11, 12)).fontColor('#FFFFFF').margin({ left: 4 })
              }
              .padding({ left: 12, right: 12, top: 5, bottom: 5 })
              .backgroundColor('rgba(255,255,255,0.2)')
              .borderRadius(18)
              .onClick(() => this.shareToOtherDevice())

              Row() {
                Text('📊').fontSize(this.fs(14, 16))
                Text('报告').fontSize(this.fs(11, 12)).fontColor('#FFFFFF').margin({ left: 4 })
              }
              .padding({ left: 12, right: 12, top: 5, bottom: 5 })
              .backgroundColor('rgba(255,255,255,0.2)')
              .borderRadius(18)
            }
            .margin({ top: 12, right: this.fs(16, 24) })
          }
        }
        .width('100%')
        .height('20%')
        .linearGradient({ angle: 135, colors: [['#1A73E8', 0], ['#4285F4', 1]] })
        .borderRadius({ bottomLeft: 28, bottomRight: 28 })

        // ======== 2. 步数卡片 + 轮播图 ========
        if (this.currentBreakpoint === 'sm') {
          Column() {
            this.buildStepCard()
            this.buildBannerSwiper()
          }
          .width('100%')
          .alignItems(HorizontalAlign.Center)
        } else {
          Row() {
            this.buildStepCard()
            this.buildBannerSwiper()
          }
          .width(this.getContentWidth())
          .margin({ top: -16 })
        }

        // ======== 3. 数据卡片 (三列) ========
        Column() {
          Text('📊 今日数据概览')
            .fontSize(this.fs(15, 17))
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
            .margin({ bottom: 12 })

          Row({ space: 10 }) {
            this.buildStatItem('🔥', this.getCalorieText(), '千卡', '#FFF3E0')
            this.buildStatItem('💓', this.getHeartRateText(), 'bpm', '#FFEBEE')
            this.buildStatItem('😴', this.getSleepText(), '小时', '#E8F5E9')
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
        }
        .width(this.getContentWidth())
        .padding(this.fs(16, 20))
        .backgroundColor('#FFFFFF')
        .borderRadius(20)
        .margin({ top: this.fs(14, 18) })
        .shadow({ radius: 12, color: '#00000010', offsetY: 4 })

        // ======== 4. 热门功能 (4列网格) ========
        Column() {
          Row() {
            Text('🔥 热门功能')
              .fontSize(this.fs(16, 18))
              .fontWeight(FontWeight.Bold)
              .fontColor('#1A1A1A')
            Blank()
            Text('查看全部')
              .fontSize(this.fs(12, 13))
              .fontColor('#1A73E8')
          }
          .width('100%')
          .margin({ bottom: this.fs(10, 12) })

          Grid() {
            ForEach(this.hotFeatures, (item: FeatureItem) => {
              GridItem() {
                this.buildFeatureItem(item)
              }
            })
          }
          .columnsTemplate(this.getGridColumns())
          .rowsGap(this.fs(8, 10))
          .columnsGap(this.fs(8, 10))
          .width('100%')
        }
        .width(this.getContentWidth())
        .padding(this.fs(14, 18))
        .backgroundColor('#F8F9FB')
        .borderRadius(20)
        .margin({ top: this.fs(12, 16) })

        // ======== 5. 健康小贴士 (精简为1行) ========
        Column() {
          Row() {
            Text('💡 健康小贴士')
              .fontSize(this.fs(14, 16))
              .fontWeight(FontWeight.Bold)
              .fontColor('#2E7D32')
            Blank()
            Text('更多')
              .fontSize(this.fs(11, 12))
              .fontColor('#66BB6A')
          }
          .width('100%')
          .margin({ bottom: 6 })

          Text('每天8杯水 · 久坐活动 · 优质睡眠 · 每周运动')
            .fontSize(this.fs(12, 13))
            .fontColor('#555555')
            .width('100%')
        }
        .width(this.getContentWidth())
        .padding(this.fs(14, 18))
        .backgroundColor('#E8F5E9')
        .borderRadius(20)
        .margin({ top: this.fs(12, 16), bottom: this.fs(16, 20) })

      }
      .width('100%')
      .backgroundColor('#F5F5F5')
    }
    .scrollable(ScrollDirection.Vertical)
    .scrollBar(BarState.Auto)
    .width('100%')
    .height('100%')
  }

  @Builder
  buildStepCard() {
    Column() {
      Row() {
        Column() {
          Row() {
            Text('🚶').fontSize(this.fs(22, 26))
            Text('今日步数').fontSize(this.fs(14, 16)).fontColor('#555555').margin({ left: 6 })
          }
          Text(this.getStepCountText())
            .fontSize(this.fs(36, 46))
            .fontWeight(FontWeight.Bold)
            .fontColor('#1A1A1A')
            .margin({ top: 4 })
          Row() {
            Text('目标 ' + this.stepGoal + ' 步')
              .fontSize(this.fs(12, 13))
              .fontColor('#888888')
          }
          .margin({ top: 2 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Column() {
          Stack() {
            Circle().width(this.fs(64, 88)).height(this.fs(64, 88)).fill('#E8F0FE')
            Circle().width(this.fs(54, 74)).height(this.fs(54, 74)).fill('#1A73E8')
            Column() {
              Text(this.getProgressPercent())
                .fontSize(this.fs(15, 22))
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF')
              Text('%')
                .fontSize(this.fs(9, 12))
                .fontColor('#FFFFFF')
                .opacity(0.7)
            }
          }
          Text('完成度').fontSize(this.fs(10, 12)).fontColor('#888888').margin({ top: 4 })
        }
        .margin({ left: this.fs(8, 14) })
      }
      .width('100%')

      Row() {
        Text('已完成 ' + this.stepCount + ' 步')
          .fontSize(this.fs(11, 12)).fontColor('#888888')
        Blank()
        Text('还差 ' + (this.stepGoal - this.stepCount) + ' 步')
          .fontSize(this.fs(11, 12)).fontColor('#1A73E8').fontWeight(FontWeight.Bold)
      }
      .width('100%')
      .margin({ top: this.fs(10, 12) })

      Progress({
        value: this.getStepProgress(),
        total: 100,
        type: ProgressType.Linear
      })
        .width('100%')
        .height(this.fs(5, 7))
        .color('#1A73E8')
        .backgroundColor('#E8F0FE')
        .style({ strokeRadius: this.fs(2.5, 3.5) })
    }
    .width(this.currentBreakpoint === 'sm' ? this.getContentWidth() : '40%')
    .padding(this.currentBreakpoint === 'sm' ? 16 : this.fs(18, 24))
    .backgroundColor('#FFFFFF')
    .borderRadius(20)
  }

  @Builder
  buildStatItem(icon: string, value: string, unit: string, bgColor: string) {
    Column() {
      Row() {
        Text(icon).fontSize(this.fs(18, 22))
      }
      .width(this.fs(36, 44))
      .height(this.fs(36, 44))
      .backgroundColor(bgColor)
      .borderRadius(this.fs(18, 22))
      .justifyContent(FlexAlign.Center)

      Text(value)
        .fontSize(this.fs(18, 24))
        .fontWeight(FontWeight.Bold)
        .fontColor('#1A1A1A')
        .margin({ top: 6 })

      Text(unit)
        .fontSize(this.fs(10, 11))
        .fontColor('#888888')
        .margin({ top: 1 })
    }
    .width('30%')
    .padding({ top: 12, bottom: 12 })
    .backgroundColor('#FAFAFA')
    .borderRadius(18)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  buildFeatureItem(item: FeatureItem) {
    Column() {
      Text(item.icon)
        .fontSize(this.fs(24, 28))
        .margin({ bottom: 2 })
      Text(item.title)
        .fontSize(this.fs(11, 12))
        .fontColor('#333333')
        .fontWeight(FontWeight.Medium)
    }
    .width('100%')
    .height(this.fs(64, 72))
    .backgroundColor(item.bgColor)
    .borderRadius(14)
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      router.pushUrl({ url: item.route })
    })
  }

  @Builder
  buildBannerSwiper() {
    Column() {
      Stack({ alignContent: Alignment.Bottom }) {
        Swiper() {
          ForEach(this.bannerData, (item: BannerItem) => {
            Stack({ alignContent: Alignment.Bottom }) {
              Image(item.imageUrl)
                .width('100%')
                .height('100%')
                .objectFit(ImageFit.Cover)
                .borderRadius(14)

              Column() {
                Text(item.title)
                  .fontSize(this.fs(14, 16))
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FFFFFF')
                Text(item.subtitle)
                  .fontSize(this.fs(10, 12))
                  .fontColor('#FFFFFF')
                  .opacity(0.85)
                  .margin({ top: 2 })
              }
              .width('100%')
              .padding({ left: 14, right: 14, bottom: 12, top: 32 })
              .linearGradient({
                angle: 180,
                colors: [['rgba(0,0,0,0)', 0], ['rgba(0,0,0,0.55)', 1]]
              })
              .borderRadius({ bottomLeft: 14, bottomRight: 14 })
            }
            .width('100%')
            .height('100%')
          })
        }
        .width('100%')
        .height(this.currentBreakpoint === 'sm' ? 140 : 170)
        .autoPlay(true)
        .interval(4000)
        .loop(true)
        .indicator(
          Indicator.dot()
            .itemWidth(5)
            .itemHeight(5)
            .selectedItemWidth(14)
            .selectedItemHeight(5)
            .color('rgba(255,255,255,0.3)')
            .selectedColor('#FFFFFF')
            .bottom(10)
        )
      }
    }
    .width(this.currentBreakpoint === 'sm' ? this.getContentWidth() : '60%')
    .padding({ left: this.currentBreakpoint === 'sm' ? 0 : 14 })
  }
}