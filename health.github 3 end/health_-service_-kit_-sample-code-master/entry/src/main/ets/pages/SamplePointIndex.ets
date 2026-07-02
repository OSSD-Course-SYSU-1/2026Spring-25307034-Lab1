/*
 * Copyright (c) 2024
 * 采样数据管理页面 - 图表展示和数据导出功能
 */

import { SamplePointManagement } from '../common/bean/SamplePointManagement';
import { ChartHelper, ChartData } from '../common/utils/ChartHelper';
import { ExportUtil } from '../common/utils/ExportUtil';
import { TrendAnalysis, DailyData, TrendResult } from '../common/utils/TrendAnalysis';
import { promptAction } from '@kit.ArkUI';
import { webview } from '@kit.ArkWeb';

// 定义类来替代对象字面量
class ChartDataItem {
  date: number = 0;
  steps: number = 0;
}

class ExportDataItem {
  date: string = '';
  steps: number = 0;
  calories: number = 0;
  distance: number = 0;
}

@Entry
@Component
struct SamplePointIndex {
  @State log: string = '';
  @State showChart: boolean = false;
  @State chartHTML: string = '';
  @State trendResult: string = '';
  @State weeklyData: DailyData[] = [];
  webController: webview.WebviewController = new webview.WebviewController();

  build() {
    Scroll() {
      Column() {
        Text('采样数据管理').fontWeight(FontWeight.Bold).fontSize(30).height('5%');

        Row() {
          Button('保存数据').width('32%').onClick(async () => {
            this.log = await SamplePointManagement.saveData();
          });
          Button('读取数据').width('32%').onClick(async () => {
            this.log = await SamplePointManagement.readData();
          });
          Button('聚合查询').width('32%').onClick(async () => {
            this.log = await SamplePointManagement.aggregateData();
          });
        }.height('8%').margin({ top: 5 });

        Row() {
          Button('📊 查看图表').width('32%').onClick(async () => {
            await this.loadChartData();
            this.showChart = true;
          });
          Button('📈 周趋势').width('32%').onClick(async () => {
            await this.loadWeeklyTrend();
          });
          Button('📉 月趋势').width('32%').onClick(async () => {
            await this.loadMonthlyTrend();
          });
        }.height('8%').margin({ top: 5 });

        Row() {
          Button('💾 导出CSV').width('32%').onClick(async () => {
            await this.exportToCSV();
          });
          Button('📄 导出JSON').width('32%').onClick(async () => {
            await this.exportToJSON();
          });
        }.height('8%').margin({ top: 5 });

        Row() {
          Button('按条件删除').width('48%').onClick(async () => {
            this.log = await SamplePointManagement.deleteByRequest();
          });
          Button('按数据删除').width('48%').onClick(async () => {
            this.log = await SamplePointManagement.deleteBySamplePoint();
          });
        }.height('8%').margin({ top: 5 });

        if (this.showChart) {
          Column() {
            Text('📊 健康数据趋势图').fontSize(16).fontWeight(FontWeight.Bold).margin({ top: 10 });
            Web({ src: this.chartHTML, controller: this.webController }).width('100%').height(300);
            Button('关闭图表').onClick(() => {
              this.showChart = false;
            }).margin({ top: 5 });
          }.margin({ top: 10 }).width('100%');
        }

        if (this.trendResult) {
          Column() {
            Text('📋 趋势分析报告').fontSize(16).fontWeight(FontWeight.Bold).margin({ top: 10 });
            Text(this.trendResult).fontSize(12).padding(10).backgroundColor('#F5F5F5').width('100%');
          }.margin({ top: 10 }).width('100%');
        }

        Column() {
          Text('📝 日志输出').fontSize(15).fontWeight(FontWeight.Bold);
          Text(this.log).fontSize(10).textAlign(TextAlign.Start);
        }.alignItems(HorizontalAlign.Start).width('95%').margin({ top: 10 });

      }.alignItems(HorizontalAlign.Center).width('100%').padding({ bottom: 20 })
    }.scrollable(ScrollDirection.Vertical).scrollBar(BarState.Auto)
  }

  async loadChartData() {
    try {
      const weeklyData: DailyData[] = await TrendAnalysis.getWeeklyData();

      const mockRawData: ChartDataItem[] = [];
      for (let i = 0; i < weeklyData.length; i++) {
        const item: ChartDataItem = new ChartDataItem();
        item.date = new Date(weeklyData[i].timestamp).getTime();
        item.steps = weeklyData[i].steps;
        mockRawData.push(item);
      }

      const finalData: Record<string, string | number>[] = [];
      for (let i = 0; i < mockRawData.length; i++) {
        const map: Record<string, string | number> = {};
        map.date = mockRawData[i].date;
        map.steps = mockRawData[i].steps;
        finalData.push(map);
      }

      const chartData: ChartData = ChartHelper.convertToChartData(finalData, 'date', 'steps', '步数');
      this.chartHTML = ChartHelper.generateChartHTML(chartData);
      ChartHelper.logChartRender('weekly_steps');
      this.log = '图表加载成功';
    } catch (err) {
      this.log = `图表加载失败: ${err.message}`;
    }
  }

  async loadWeeklyTrend() {
    try {
      this.weeklyData = await TrendAnalysis.getWeeklyData();
      const trend: TrendResult = TrendAnalysis.analyzeTrend(this.weeklyData);
      this.trendResult = TrendAnalysis.formatTrendReport(trend);
      this.log = '周趋势分析完成';
    } catch (err) {
      this.log = `周趋势分析失败: ${err.message}`;
    }
  }

  async loadMonthlyTrend() {
    try {
      const monthlyData: DailyData[] = await TrendAnalysis.getMonthlyData();
      const trend: TrendResult = TrendAnalysis.analyzeTrend(monthlyData);
      this.trendResult = TrendAnalysis.formatTrendReport(trend);
      this.log = '月趋势分析完成';
    } catch (err) {
      this.log = `月趋势分析失败: ${err.message}`;
    }
  }

  async exportToCSV() {
    try {
      const data: DailyData[] = await TrendAnalysis.getWeeklyData();

      const exportList: ExportDataItem[] = [];
      for (let i = 0; i < data.length; i++) {
        const item: ExportDataItem = new ExportDataItem();
        item.date = data[i].date;
        item.steps = data[i].steps;
        item.calories = data[i].calories;
        item.distance = data[i].distance;
        exportList.push(item);
      }

      const finalData: Record<string, string | number>[] = [];
      for (let i = 0; i < exportList.length; i++) {
        const map: Record<string, string | number> = {};
        map.date = exportList[i].date;
        map.steps = exportList[i].steps;
        map.calories = exportList[i].calories;
        map.distance = exportList[i].distance;
        finalData.push(map);
      }

      const filePath: string = await ExportUtil.exportToCSV(finalData, 'health_data', ['date', 'steps', 'calories', 'distance']);
      this.log = `CSV已导出: ${filePath}`;
      promptAction.showToast({ message: '导出成功！' });
    } catch (err) {
      this.log = `导出失败: ${err.message}`;
      promptAction.showToast({ message: '导出失败' });
    }
  }

  async exportToJSON() {
    try {
      const data: DailyData[] = await TrendAnalysis.getWeeklyData();

      const exportList: ExportDataItem[] = [];
      for (let i = 0; i < data.length; i++) {
        const item: ExportDataItem = new ExportDataItem();
        item.date = data[i].date;
        item.steps = data[i].steps;
        item.calories = data[i].calories;
        item.distance = data[i].distance;
        exportList.push(item);
      }

      const finalData: Record<string, string | number>[] = [];
      for (let i = 0; i < exportList.length; i++) {
        const map: Record<string, string | number> = {};
        map.date = exportList[i].date;
        map.steps = exportList[i].steps;
        map.calories = exportList[i].calories;
        map.distance = exportList[i].distance;
        finalData.push(map);
      }

      const filePath: string = await ExportUtil.exportToJSON(finalData, 'health_data');
      this.log = `JSON已导出: ${filePath}`;
      promptAction.showToast({ message: '导出成功！' });
    } catch (err) {
      this.log = `导出失败: ${err.message}`;
      promptAction.showToast({ message: '导出失败' });
    }
  }
}