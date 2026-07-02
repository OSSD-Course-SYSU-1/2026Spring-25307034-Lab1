/*
 * Copyright (c) 2024
 * 目标管理器
 */

// import { notificationManager } from '@kit.NotificationKit';  // 暂时注释
import { preferences } from '@kit.ArkData';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { common } from '@kit.AbilityKit';

export interface HealthGoal {
  dailySteps: number;
  dailyCalories: number;
  dailySleepHours: number;
  enableNotification: boolean;
}

export class GoalManager {
  private static dataPreferences: preferences.Preferences | null = null;

  private static readonly DEFAULT_GOAL: HealthGoal = {
    dailySteps: 8000,
    dailyCalories: 300,
    dailySleepHours: 8,
    enableNotification: true
  };

  public static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      GoalManager.dataPreferences = await preferences.getPreferences(context, 'health_goals');
    } catch (err) {
      hilog.error(0x0000, 'GoalManager', `Init failed: ${err.message}`);
    }
  }

  public static async getGoals(): Promise<HealthGoal> {
    try {
      const prefs = GoalManager.dataPreferences;
      if (!prefs) {
        return GoalManager.DEFAULT_GOAL;
      }

      const steps: number = await prefs.get('dailySteps', GoalManager.DEFAULT_GOAL.dailySteps) as number;
      const calories: number = await prefs.get('dailyCalories', GoalManager.DEFAULT_GOAL.dailyCalories) as number;
      const sleep: number = await prefs.get('dailySleepHours', GoalManager.DEFAULT_GOAL.dailySleepHours) as number;
      const notification: boolean = await prefs.get('enableNotification', GoalManager.DEFAULT_GOAL.enableNotification) as boolean;

      const result: HealthGoal = {
        dailySteps: steps,
        dailyCalories: calories,
        dailySleepHours: sleep,
        enableNotification: notification
      };
      return result;
    } catch (err) {
      hilog.error(0x0000, 'GoalManager', `Get goals failed: ${err.message}`);
      return GoalManager.DEFAULT_GOAL;
    }
  }

  public static async saveGoals(goals: HealthGoal): Promise<void> {
    try {
      const prefs = GoalManager.dataPreferences;
      if (!prefs) {
        return;
      }

      await prefs.put('dailySteps', goals.dailySteps);
      await prefs.put('dailyCalories', goals.dailyCalories);
      await prefs.put('dailySleepHours', goals.dailySleepHours);
      await prefs.put('enableNotification', goals.enableNotification);
      await prefs.flush();
      hilog.info(0x0000, 'GoalManager', 'Goals saved successfully');
    } catch (err) {
      hilog.error(0x0000, 'GoalManager', `Save goals failed: ${err.message}`);
    }
  }

  public static async checkStepGoal(currentSteps: number): Promise<boolean> {
    const goals = await GoalManager.getGoals();
    if (!goals.enableNotification) {
      return false;
    }

    if (currentSteps >= goals.dailySteps) {
      await GoalManager.sendNotification('目标达成！', `恭喜！今日步数已达 ${currentSteps} 步`);
      return true;
    }
    return false;
  }

  public static async getStepProgress(currentSteps: number): Promise<number> {
    const goals: HealthGoal = await GoalManager.getGoals();
    const progress: number = (currentSteps / goals.dailySteps) * 100;
    return Math.min(progress, 100);
  }

  private static async sendNotification(title: string, text: string): Promise<void> {
    // 暂时禁用通知功能，避免模块类型冲突
    hilog.info(0x0000, 'GoalManager', `Notification would be sent: ${title} - ${text}`);
    return;
  }
}