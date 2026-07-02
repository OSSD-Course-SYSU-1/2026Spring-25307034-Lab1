/*
 * Copyright (c) 2024
 * 响应式布局工具类 - 用于多设备适配
 */

import { BreakpointType, BREAKPOINTS } from '../constant/BreakpointConstants';

export class ResponsiveLayout {
  public static getBreakpoint(windowWidth: number): BreakpointType {
    if (windowWidth < BREAKPOINTS.sm) {
      return 'xs';
    } else if (windowWidth < BREAKPOINTS.md) {
      return 'sm';
    } else if (windowWidth < BREAKPOINTS.lg) {
      return 'md';
    } else if (windowWidth < BREAKPOINTS.xl) {
      return 'lg';
    } else {
      return 'xl';
    }
  }

  public static isPhone(breakpoint: BreakpointType): boolean {
    return breakpoint === 'xs' || breakpoint === 'sm';
  }

  public static isFoldable(breakpoint: BreakpointType): boolean {
    return breakpoint === 'md';
  }

  public static isTabletOrPC(breakpoint: BreakpointType): boolean {
    return breakpoint === 'lg' || breakpoint === 'xl';
  }

  public static getButtonHeight(breakpoint: BreakpointType): number {
    switch (breakpoint) {
      case 'xs':
        return 44;
      case 'sm':
        return 48;
      case 'md':
        return 52;
      case 'lg':
        return 56;
      case 'xl':
        return 60;
      default:
        return 52;
    }
  }

  public static getButtonFontSize(breakpoint: BreakpointType): number {
    switch (breakpoint) {
      case 'xs':
        return 14;
      case 'sm':
        return 15;
      case 'md':
        return 16;
      case 'lg':
        return 17;
      case 'xl':
        return 18;
      default:
        return 16;
    }
  }

  public static getHeaderHeight(breakpoint: BreakpointType): string | number {
    switch (breakpoint) {
      case 'xs':
        return '35%';
      case 'sm':
        return '30%';
      case 'md':
        return '25%';
      case 'lg':
        return '22%';
      case 'xl':
        return '20%';
      default:
        return '25%';
    }
  }
}

export class BreakPointValue<T> {
  private values: Record<BreakpointType, T>;

  constructor(values: Record<BreakpointType, T>) {
    this.values = values;
  }

  public getValue(breakpoint: BreakpointType): T {
    return this.values[breakpoint];
  }
}