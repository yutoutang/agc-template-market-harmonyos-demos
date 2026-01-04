// 引入必要的模块
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { fileIo as fs } from '@kit.CoreFileKit';
import { picker } from '@kit.CoreFileKit';
import util from '@ohos.util';
import { Location } from '../types/Types';

// 定义GPX轨迹点数据结构
export interface GpxTrackPoint {
  lat: number; // 纬度
  lon: number; // 经度
  ele?: number; // 高程（可选）
  time?: string; // 时间戳（可选）
}

// 定义GPX轨迹段数据结构
export interface GpxTrackSegment {
  points: GpxTrackPoint[]; // 轨迹点数组
  name: string
}

// 定义GPX轨迹数据结构
export interface GpxTrack {
  name?: string; // 轨迹名称（可选）
  segments: GpxTrackSegment[]; // 轨迹段数组
}

// GPX文件处理器主类
export class GpxFileProcessor {
  private context: common.UIAbilityContext;

  constructor(context: common.UIAbilityContext) {
    this.context = context;
  }

  // 更简洁的写法（使用数组reduce方法）
  static calculateCenterPointSimple(coordinates: Location[]): Location {
    if (!coordinates || coordinates.length === 0) {
      return { latitude: 0, longitude: 0 };
    }

    const sum = coordinates.reduce((acc, coord) => {
      return {
        latitude: acc.latitude + coord.latitude,
        longitude: acc.longitude + coord.longitude
      };
    }, { latitude: 0, longitude: 0 });

    return {
      latitude: sum.latitude / coordinates.length,
      longitude: sum.longitude / coordinates.length
    };
  }

  /**
   * 主流程：选择GPX文件、解析
   */
  async processGpxFile() {
    try {
      // 1. 选择GPX文件
      const sourceFileUri = await this.selectGpxFile();
      if (!sourceFileUri) {
        return false;
      }

      // 2. 读取文件内容
      const gpxContent = await this.readFileContent(sourceFileUri);
      if (!gpxContent) {
        return false;
      }

      // 3. 解析GPX内容
      const tracks = this.parseGpx(gpxContent);
      if (tracks.length === 0) {
        return false;
      }
      return tracks

    } catch (error) {
      return false;
    }
  }

  // 重新生成并保存
  async outGpxFile(locations: Location[]) {
    try {

      // 1.生成GPX内容
      const newGpxContent = this.buildGpxEnhanced(locations);

      // 2. 保存新GPX文件
      await this.saveGpxFile(newGpxContent);
    } catch (error) {
    }

  }

  /**
   * 选择GPX文件
   */
  private async selectGpxFile(): Promise<string | null> {
    try {
      // 创建文件选择选项:cite[1]
      const documentSelectOptions = new picker.DocumentSelectOptions();
      documentSelectOptions.maxSelectNumber = 1; // 最多选择1个文件
      documentSelectOptions.fileSuffixFilters = ['.gpx']; // 过滤只显示.gpx文件

      // 创建文件选择器实例:cite[1]
      const documentViewPicker = new picker.DocumentViewPicker(this.context);

      // 拉起文件选择界面
      const uris = await documentViewPicker.select(documentSelectOptions);

      if (uris && uris.length > 0) {
        return uris[0];
      }
      return null;
    } catch (error) {
      return null;
    }
  }

  private async readFileContent(fileUri: string): Promise<string | null> {
    let fd: number | undefined;
    try {
      const file = fs.openSync(fileUri, fs.OpenMode.READ_ONLY);
      fd = file.fd;

      const fileStat = fs.statSync(file.fd);
      const fileSize = fileStat.size;

      if (fileSize <= 0) {
        return null;
      }

      // 读取文件内容到缓冲区
      const buffer = new ArrayBuffer(fileSize);
      const bytesRead = fs.readSync(file.fd, buffer);

      if (bytesRead !== fileSize) {
        return null;
      }

      // 使用鸿蒙官方的TextDecoder
      const textDecoder = new util.TextDecoder() //  .TextDecoder('utf-8');
      const content = textDecoder.decode(new Uint8Array(buffer));
      return content;

    } catch (error) {
      return null;
    } finally {
      if (fd !== undefined) {
        fs.closeSync(fd);
      }
    }
  }

  /**
   * 解析GPX内容
   */
  private parseGpx(gpxContent: string): GpxTrack[] {
    const tracks: GpxTrack[] = [];

    try {
      let nameMath: ESObject = gpxContent.match(/<name>([\s\S]*?)<\/name>/i)
      let name: string = ''
      if (nameMath) {
        name = nameMath[1].trim();
      }

      // 使用正则表达式匹配trk标签:cite[6]
      const trackRegex = /<trk>([\s\S]*?)<\/trk>/gi;
      let trackMatch: ESObject;

      while ((trackMatch = trackRegex.exec(gpxContent)) !== null) {
        const trackBlock: ESObject = trackMatch[1];
        const track: GpxTrack = { segments: [] };

        // 提取轨迹段(citation:6]
        const segRegex = /<trkseg>([\s\S]*?)<\/trkseg>/gi;
        let segMatch: ESObject;

        while ((segMatch = segRegex.exec(trackBlock)) !== null) {
          const segBlock: ESObject = segMatch[1];
          const segment: GpxTrackSegment = { points: [], name: '' };

          // 提取轨迹点:cite[6]
          const ptRegex = /<trkpt[^>]*lat='([^']*)'[^>]*lon='([^']*)'[^>]*>([\s\S]*?)<\/trkpt>/gi;
          let ptMatch: ESObject;

          while ((ptMatch = ptRegex.exec(segBlock)) !== null) {
            const lat = parseFloat(ptMatch[1]);
            const lon = parseFloat(ptMatch[2]);
            const pointContent: ESObject = ptMatch[3];

            const point: GpxTrackPoint = { lat, lon };

            // 提取高程（如果存在）
            const eleMatch: ESObject = pointContent.match(/<ele>([\s\S]*?)<\/ele>/i);
            if (eleMatch) {
              point.ele = parseFloat(eleMatch[1]);
            }

            // 提取时间戳（如果存在）
            const timeMatch: ESObject = pointContent.match(/<time>([\s\S]*?)<\/time>/i);
            if (timeMatch) {
              point.time = timeMatch[1].trim();
            }

            segment.points.push(point);
            segment.name = name
          }

          if (segment.points.length > 0) {
            track.segments.push(segment);
          }
        }

        if (track.segments.length > 0) {
          tracks.push(track);
        }
      }
      return tracks;

    } catch (error) {
      return [];
    }
  }

  /**
   * 构建GPX内容（增强版）
   */
  private buildGpxEnhanced(locations: Location[]): string {
    // GPX文件头
    let gpxContent = `<?xml version='1.0' encoding='UTF-8'?>
<gpx version='1.1' creator='HarmonyOS-GPX-Processor' xmlns='http://www.topografix.com/GPX/1/1'>
  <metadata>
    <time>${new Date().toISOString()}</time>
  </metadata>
  <trk>
    <name>轨迹 ${new Date().toLocaleDateString()}</name>
    <trkseg>
${locations.map(loc => `      <trkpt lat='${loc.latitude}' lon='${loc.longitude}'>
      </trkpt>`).join('\n')}
    </trkseg>
  </trk>
</gpx>`;
    return gpxContent;
  }

  /**
   * 保存GPX文件
   */
  private async saveGpxFile(gpxContent: string): Promise<boolean> {
    let fd: number | undefined;
    try {
      // 创建文件保存选项:cite[1]:cite[4]
      const documentSaveOptions = new picker.DocumentSaveOptions();
      documentSaveOptions.newFileNames = [this.getCurrentDateTimeForFilename() + 'output.gpx']; // 建议的文件名

      // 创建文件保存器实例
      const documentSavePicker = new picker.DocumentViewPicker(this.context);

      // 拉起文件保存界面
      const saveUri = await documentSavePicker.save(documentSaveOptions);

      if (!saveUri) {
        return false;
      }

      // 创建文件并写入内容:cite[4]
      const file = fs.openSync(saveUri[0], fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE);
      fd = file.fd;
      // 将字符串编码为Uint8Array并写入文件
      const encoder = new util.TextEncoder(); // 修正：使用util.TextEncoder
      const data = encoder.encode(gpxContent) // .encode(gpxContent);
      fs.writeSync(fd, data.buffer); // 修正：使用异步写入方法

      return true;

    } catch (error) {
      return false;
    } finally {
      // 确保文件描述符被关闭
      if (fd !== undefined) {
        fs.closeSync(fd);
      }
    }
  }

  getCurrentDateTimeForFilename(): string {
    const now = new Date();

    const year = now.getFullYear();
    const month = String(now.getMonth() + 1).padStart(2, '0');
    const day = String(now.getDate()).padStart(2, '0');
    const hours = String(now.getHours()).padStart(2, '0');
    const minutes = String(now.getMinutes()).padStart(2, '0');

    return `${year}${month}${day}_${hours}${minutes}`;
  }

  distanceToZoom(distance: number): number {
    // 基于已知数据点：2.78km→14, 23.5km→11.3
    // 使用对数关系：zoom = 15.3 - 1.27 * ln(distance)
    const zoom = 15.3 - 1.27 * Math.log(distance);

    // 限制在合理范围内并保留一位小数
    return Number(Math.max(8, Math.min(20, zoom)).toFixed(1));
  }
}