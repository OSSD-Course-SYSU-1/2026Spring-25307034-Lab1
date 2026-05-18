/*
 * Copyright (c) 2024
 * 图表工具类
 */

/*
 * Copyright (c) 2024
 * 图表工具类
 */

import { hilog } from '@kit.PerformanceAnalysisKit';

export interface ChartData {
  labels: string[];
  datasets: ChartDataset[];
}

export interface ChartDataset {
  label: string;
  data: number[];
  color: string;
}

export class ChartHelper {
  public static convertToChartData(
    rawData: Record<string, string | number>[],
    dateField: string,
    valueField: string,
    labelText: string
  ): ChartData {
    const labels: string[] = [];
    const values: number[] = [];

    for (let i = 0; i < rawData.length; i++) {
      const item = rawData[i];
      const timestamp = item[dateField] as number;
      const date = new Date(timestamp);
      const dateStr = (date.getMonth() + 1) + "/" + date.getDate();
      labels.push(dateStr);
      values.push(item[valueField] as number);
    }

    return {
      labels: labels,
      datasets: [{
        label: labelText,
        data: values,
        color: "#007DFF"
      }]
    };
  }

  public static generateChartHTML(chartData: ChartData): string {
    const labelsStr = JSON.stringify(chartData.labels);
    const datasetsStr = JSON.stringify(chartData.datasets);

    return '<!DOCTYPE html>' +
      '<html><head>' +
      '<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"><\/script>' +
      '<style>body{margin:0;padding:20px;}canvas{width:100%;height:300px;}</style>' +
      '</head><body>' +
      '<canvas id="myChart"></canvas>' +
      '<script>' +
      'const ctx = document.getElementById("myChart").getContext("2d");' +
      'new Chart(ctx, { type: "line", data: { labels: ' + labelsStr + ', datasets: ' + datasetsStr + ' } });' +
      '<\/script>' +
      '</body></html>';
  }

  public static logChartRender(chartType: string): void {
    hilog.info(0x0000, "ChartHelper", "Chart rendered: " + chartType);
  }
}