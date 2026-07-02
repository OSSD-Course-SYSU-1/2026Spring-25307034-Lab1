/*
 * Copyright (c) 2024
 * 趋势分析工具 - 周/月数据对比分析
 */

import { healthStore } from '@kit.HealthServiceKit';
import { InitUtils } from './InitUtils';
import { hilog } from '@kit.PerformanceAnalysisKit';

export interface DailyData {
  date: string;
  timestamp: number;
  steps: number;
  calories: number;
  distance: number;
}

export interface TrendResult {
  period: string;
  totalSteps: number;
  avgSteps: number;
  maxSteps: number;
  minSteps: number;
  bestDay: string;
  daysWithData: number;
}

export class TrendAnalysis {
  public static async getWeeklyData(): Promise<DailyData[]> {
    const weeklyData: DailyData[] = [];
    const now: Date = new Date();
    const dayOfWeek: number = now.getDay();
    const startOfWeek: Date = new Date(now);
    startOfWeek.setDate(now.getDate() - dayOfWeek + (dayOfWeek === 0 ? -6 : 1));
    startOfWeek.setHours(0, 0, 0, 0);

    for (let i = 0; i < 7; i++) {
      const date: Date = new Date(startOfWeek);
      date.setDate(startOfWeek.getDate() + i);
      const data: DailyData = await TrendAnalysis.getDailyStepData(date);
      weeklyData.push(data);
    }
    return weeklyData;
  }

  public static async getMonthlyData(): Promise<DailyData[]> {
    const monthlyData: DailyData[] = [];
    const now: Date = new Date();
    const year: number = now.getFullYear();
    const month: number = now.getMonth();
    const daysInMonth: number = new Date(year, month + 1, 0).getDate();

    for (let i = 1; i <= daysInMonth; i++) {
      const date: Date = new Date(year, month, i);
      const data: DailyData = await TrendAnalysis.getDailyStepData(date);
      monthlyData.push(data);
    }
    return monthlyData;
  }

  private static async getDailyStepData(date: Date): Promise<DailyData> {
    const startOfDay: number = date.setHours(0, 0, 0, 0);
    const endOfDay: number = date.setHours(23, 59, 59, 999);
    const dataSourceId: string = await InitUtils.getDataSourceId();

    try {
      const samplePointReadRequest: healthStore.SamplePointReadRequest = {
        samplePointDataType: healthStore.samplePointHelper.dailyActivities.DATA_TYPE,
        startTime: startOfDay,
        endTime: endOfDay
      };

      const samplePoints: healthStore.SamplePoint[] = await healthStore.readData<healthStore.samplePointHelper.dailyActivities.Model>(samplePointReadRequest);

      let steps: number = 0;
      let calories: number = 0;
      let distance: number = 0;

      for (const point of samplePoints) {
        const fields = point.fields as healthStore.samplePointHelper.dailyActivities.Fields;
        if (fields) {
          steps += fields.step || 0;
          calories += fields.calorie || 0;
          distance += fields.distance || 0;
        }
      }

      const result: DailyData = {
        date: `${date.getMonth() + 1}/${date.getDate()}`,
        timestamp: startOfDay,
        steps: steps,
        calories: calories,
        distance: distance
      };
      return result;
    } catch (err) {
      hilog.error(0x0000, 'TrendAnalysis', `Failed to get data for ${date}: ${err.message}`);
      const emptyResult: DailyData = {
        date: `${date.getMonth() + 1}/${date.getDate()}`,
        timestamp: startOfDay,
        steps: 0,
        calories: 0,
        distance: 0
      };
      return emptyResult;
    }
  }

  public static analyzeTrend(data: DailyData[]): TrendResult {
    if (data.length === 0) {
      const emptyResult: TrendResult = {
        period: '',
        totalSteps: 0,
        avgSteps: 0,
        maxSteps: 0,
        minSteps: 0,
        bestDay: '',
        daysWithData: 0
      };
      return emptyResult;
    }

    let totalSteps: number = 0;
    let maxSteps: number = 0;
    let minSteps: number = Number.MAX_VALUE;
    let bestDay: string = '';
    let daysWithData: number = 0;

    for (const day of data) {
      if (day.steps > 0) {
        daysWithData++;
      }
      totalSteps += day.steps;
      if (day.steps > maxSteps) {
        maxSteps = day.steps;
        bestDay = day.date;
      }
      if (day.steps < minSteps && day.steps > 0) {
        minSteps = day.steps;
      }
    }

    if (minSteps === Number.MAX_VALUE) {
      minSteps = 0;
    }

    const result: TrendResult = {
      period: data.length === 7 ? '本周' : '本月',
      totalSteps: totalSteps,
      avgSteps: Math.round(totalSteps / data.length),
      maxSteps: maxSteps,
      minSteps: minSteps,
      bestDay: bestDay,
      daysWithData: daysWithData
    };
    return result;
  }

  public static formatTrendReport(trend: TrendResult): string {
    const report: string = '\n========== ' + trend.period + '健康报告 ==========\n' +
      '📊 总步数：' + trend.totalSteps + ' 步\n' +
      '📈 日均步数：' + trend.avgSteps + ' 步\n' +
      '🏆 最佳日期：' + trend.bestDay + '（' + trend.maxSteps + ' 步）\n' +
      '📉 最少步数：' + trend.minSteps + ' 步\n' +
      '📅 有数据天数：' + trend.daysWithData + ' 天\n' +
      '====================================\n';
    return report;
  }
}