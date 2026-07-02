/*
 * Copyright (c) 2024
 * 数据导出工具类
 */

import { fileIo } from '@kit.CoreFileKit';
import { common } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { util } from '@kit.ArkTS';

export class ExportUtil {
  private static context: common.UIAbilityContext;

  public static init(context: common.UIAbilityContext): void {
    ExportUtil.context = context;
  }

  public static async exportToCSV(
    data: Record<string, string | number>[],
    fileName: string,
    headers?: string[]
  ): Promise<string> {
    if (!data || data.length === 0) {
      throw new Error('No data to export');
    }

    const columnHeaders: string[] = headers || Object.keys(data[0]) as string[];
    let csvContent: string = columnHeaders.join(',') + '\n';

    for (const row of data) {
      const rowValues: string[] = columnHeaders.map(header => {
        let value = row[header];
        if (value === undefined || value === null) {
          value = '';
        }
        if (typeof value === 'string' && (value.includes(',') || value.includes('"'))) {
          value = `"${value.replace(/"/g, '""')}"`;
        }
        return String(value);
      });
      csvContent += rowValues.join(',') + '\n';
    }

    const filePath: string = `${ExportUtil.context.filesDir}/${fileName}.csv`;
    const file: fileIo.File = fileIo.openSync(filePath, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
    const encoder = new util.TextEncoder();
    const buffer: Uint8Array = encoder.encodeInto(csvContent);
    fileIo.writeSync(file.fd, buffer);
    fileIo.closeSync(file);

    hilog.info(0x0000, 'ExportUtil', `CSV exported to: ${filePath}`);
    return filePath;
  }

  public static async exportToJSON(
    data: Record<string, string | number>[],
    fileName: string
  ): Promise<string> {
    const jsonContent: string = JSON.stringify(data, null, 2);
    const filePath: string = `${ExportUtil.context.filesDir}/${fileName}.json`;
    const file: fileIo.File = fileIo.openSync(filePath, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
    const encoder = new util.TextEncoder();
    const buffer: Uint8Array = encoder.encodeInto(jsonContent);
    fileIo.writeSync(file.fd, buffer);
    fileIo.closeSync(file);

    hilog.info(0x0000, 'ExportUtil', `JSON exported to: ${filePath}`);
    return filePath;
  }
}