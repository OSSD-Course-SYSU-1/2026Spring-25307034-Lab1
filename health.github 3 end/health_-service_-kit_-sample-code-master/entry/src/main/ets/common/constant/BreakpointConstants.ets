/*
* Copyright (c) 2024
* 断点常量定义 - 用于多设备响应式布局
*/

export type BreakpointType = 'xs' | 'sm' | 'md' | 'lg' | 'xl';

export interface BreakpointMap {
  xs: number;
  sm: number;
  md: number;
  lg: number;
  xl: number;
}

export interface GridColumnMap {
  xs: number;
  sm: number;
  md: number;
  lg: number;
  xl: number;
}

export interface GridGutterMap {
  xs: number;
  sm: number;
  md: number;
  lg: number;
  xl: number;
}

export interface HeaderHeightMap {
  xs: string;
  sm: string;
  md: string;
  lg: string;
  xl: string;
}

export interface ButtonHeightMap {
  xs: number;
  sm: number;
  md: number;
  lg: number;
  xl: number;
}

export interface ButtonFontSizeMap {
  xs: number;
  sm: number;
  md: number;
  lg: number;
  xl: number;
}

export const BREAKPOINTS: BreakpointMap = {
  xs: 0,
  sm: 320,
  md: 600,
  lg: 840,
  xl: 1200
};

export const GRID_COLUMNS: GridColumnMap = {
  xs: 4,
  sm: 4,
  md: 8,
  lg: 12,
  xl: 12
};

export const GRID_GUTTER: GridGutterMap = {
  xs: 8,
  sm: 12,
  md: 16,
  lg: 20,
  xl: 24
};

export const HEADER_HEIGHT: HeaderHeightMap = {
  xs: '35%',
  sm: '30%',
  md: '25%',
  lg: '22%',
  xl: '20%'
};

export const BUTTON_HEIGHT: ButtonHeightMap = {
  xs: 44,
  sm: 48,
  md: 52,
  lg: 56,
  xl: 60
};

export const BUTTON_FONT_SIZE: ButtonFontSizeMap = {
  xs: 14,
  sm: 15,
  md: 16,
  lg: 17,
  xl: 18
};