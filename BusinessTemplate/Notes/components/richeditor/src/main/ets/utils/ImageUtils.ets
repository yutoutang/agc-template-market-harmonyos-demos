/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import { image } from '@kit.ImageKit';

export class ImageUtils {
  /**
   * Read the screenshot PixelMap object into the buffer area
   * @param {PixelMap} pixelMap - Screenshot PixelMap
   * @param {number[]} scrollYOffsets - Component scrolls an array of y-axis offsets
   * @param {number} listWidth - List component width
   * @param {number} listHeight - List component height
   * @returns {image.PositionArea} Picture buffer area
   */
  // [Start get_snapshot_area]
  static async getSnapshotArea(uiContext: UIContext, pixelMap: PixelMap, scrollYOffsets: number[], listWidth: number,
    listHeight: number): Promise<image.PositionArea> {
    // Gets the number of bytes per line of image pixels.
    let stride = pixelMap.getBytesNumberPerRow();
    // Get the total number of bytes of image pixels.
    let bytesNumber = pixelMap.getPixelBytesNumber();
    let buffer: ArrayBuffer = new ArrayBuffer(bytesNumber);
    // 	Region size, read based on region.   PositionArea represents the data within the specified area of the image.
    let len = scrollYOffsets.length;

    // // Except for the first screenshot, you don't need to crop it, and you need to crop the new parts
    if (scrollYOffsets.length >= 2) {
      // Realistic roll distance
      let realScrollHeight = scrollYOffsets[len-1] - scrollYOffsets[len-2];
      if (listHeight - realScrollHeight > 0) {
        let cropRegion: image.Region = {
          x: 0,
          y: uiContext.vp2px(listHeight - realScrollHeight),
          size: {
            height: uiContext.vp2px(realScrollHeight),
            width: uiContext.vp2px(listWidth),
          },
        };
        // Crop roll area
        await pixelMap.crop(cropRegion);
      }
    }

    let imgInfo = pixelMap.getImageInfoSync();
    // Region size, read based on region. PositionArea represents the data within the specified area of the image.
    let area: image.PositionArea = {
      pixels: buffer,
      offset: 0,
      stride: stride,
      region: {
        size: {
          width: imgInfo.size.width,
          height: imgInfo.size.height,
        },
        x: 0,
        y: 0,
      },
    };
    // Write data to a specified area
    pixelMap.readPixelsSync(area);
    return area;
  }

  // [End get_snapshot_area]

  /**
   * Merge image area array into long screenshots
   * @param {image.PositionArea[]} areaArray - screenshot area
   * @param {number} lastOffsetY - The offset Y of the last screenshot
   * @param {number} listWidth - List component width
   * @param {number} listHeight - List component height
   * @returns {PixelMap} Long image after merge
   */
  // [Start merge_image]
  static async mergeImage(uiContext: UIContext, areaArray: image.PositionArea[], lastOffsetY: number, listWidth: number,
    listHeight: number): Promise<PixelMap> {
    // Create a long screenshot PixelMap
    let opts: image.InitializationOptions = {
      editable: true,
      pixelFormat: 4,
      size: {
        width: uiContext.vp2px(listWidth),
        height: uiContext.vp2px(lastOffsetY + listHeight),
      },
    };

    let longPixelMap: PixelMap | null = null;
    try {
      longPixelMap = image.createPixelMapSync(opts);
    } catch (err) {
      console.error(`createPixelMapSync失败: ${(err as Error).message}`);
      throw new Error(`创建长截图失败: ${(err as Error).message}`);
    }

    let imgPosition: number = 0;

    for (let i = 0; i < areaArray.length; i++) {
      let readArea = areaArray[i];
      let area: image.PositionArea = {
        pixels: readArea.pixels,
        offset: 0,
        stride: readArea.stride,
        region: {
          size: {
            width: readArea.region.size.width,
            height: readArea.region.size.height,
          },
          x: 0,
          y: imgPosition,
        },
      };
      imgPosition += readArea.region.size.height;
      longPixelMap.writePixelsSync(area);
    }
    return longPixelMap;
  }

  // [End merge_image]
}