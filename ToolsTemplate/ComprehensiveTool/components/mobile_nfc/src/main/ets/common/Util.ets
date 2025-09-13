import display from '@ohos.display';
import { usbManager } from '@kit.BasicServicesKit';
import { promptAction } from '@kit.ArkUI';
import { NFC_TYPE, Operation } from './Enum';
import { nfcCardInfo } from '../db/NfcCardInfo';

export default class Util {
  /**
   * 吐司提示
   * @param name 提示内容
   */
  public static toast(name: string, duration: number = 2000): void {
    promptAction.showToast({
      message: name,
      duration: duration,
      bottom: Util.screenHeight() / 2 - 20,
    });
  }

  /**
   * 去掉浮点的小数
   */
  public static float2Int(value?: number): number {
    if (value === undefined || value === null) {
      return 0;
    }

    if (value < 0) {
      return Math.ceil(value);
    }
    return Math.floor(value);
  }

  /**
   * 屏幕高度(像素比屏幕密度)
   * @returns
   */
  public static screenHeight(): number {
    let defaultDisplay = display.getDefaultDisplaySync();
    let height = defaultDisplay.height / defaultDisplay.scaledDensity;

    if (isNaN(height)) {
      return 0;
    }
    return Util.float2Int(height);
  }

  /**
   * 屏幕宽度(像素比屏幕密度)
   * @returns
   */
  public static screenWeight(): number {
    let defaultDisplay = display.getDefaultDisplaySync();
    let width = defaultDisplay.width / defaultDisplay.scaledDensity;

    if (isNaN(width)) {
      return 0;
    }
    return Util.float2Int(width);
  }

  /**
   * 空字符串检查
   * @param value 检查的值
   * @returns true 为空
   */
  public static isEmpty(value?: string): boolean {
    if (value === undefined || value === null || value === '' || value.length <= 0) {
      return true;
    }
    return false;
  }

  public static isEmptyArray(array: Array<usbManager.USBDevice>): boolean {
    return (array.length === 0 ? true : false);
  }

  public static toHexString(d: number[]): string {
    if (!d || d.length === 0) {
      return '-';
    }
    let str: string = '';
    for (let i = 0; i < d.length; i++) {
      let tmp: string = d[i].toString(16);
      if (tmp.length === 1) {
        tmp = '0' + tmp;
      }
      str += tmp;
    }
    return str;
  }

  static HEX = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'];

  public static toHexString2(d: number[], s: number, n: number): string {
    let ret: string = '';
    let e = s + n;

    for (let i = s; i < e; ++i) {
      let v = d[i];
      ret += Util.HEX[0x0F & (v >> 4)];
      ret += Util.HEX[0x0F & v];
    }
    return ret;
  }

  public static toInt(b: number[], s?: number, n?: number): number {
    if (!s) {
      s = 0;
    }
    if (!n) {
      n = b.length - s;
    }
    let e = s + n;
    let result: number = 0;
    for (let i = s; i < e; i++) {
      result <<= 8;
      result |= b[i] & 0xFF;
    }
    return result;
  }

  public static toIntR(b: number[], start?: number, end?: number): number {
    if (!start) {
      start = b.length - 1;
    }
    if (!end) {
      end = b.length;
    }
    let ret = 0;
    for (let i = start; (i >= 0 && end > 0); --i, --end) {
      ret <<= 8;
      ret |= b[i] & 0xFF;
    }
    return ret;
  }

  public static copyOf(bytes: number[], newLength: number): number[] {
    if (newLength > bytes.length) {
      let ret = [newLength];
      for (let i = 0; i < newLength; i++) {
        ret[i] = bytes[i];
      }
      return ret;
    } else {
      return bytes.slice(0, newLength);
    }
  }

  public static filterString(array: string[], item: string): string[] {
    let result: string[] = [];
    for (let arrayElement of array) {
      if (arrayElement !== item) {
        result.push(arrayElement);
      }
    }
    return result;
  }

  static hex2Bytes(hex: string): number[] {
    if (!(hex != null && hex.length % 2 === 0 && hex.match('[0-9A-Fa-f]+'))) {
      return [];
    }
    let len = hex.length;
    let data: number[] = [];
    for (let i = 0; i < len; i += 2) {
      data[i / 2] = ((parseInt(hex.charAt(i), 16) << 4) + parseInt(hex.charAt(i + 1), 16));
    }
    return data;
  }

  public static acBytesToACMatrix(acBytes: number[]): number[][] | undefined {
    if (acBytes === null) {
      return undefined;
    }

    let acMatrix: number[][] = [[], [], []];
    if (acBytes.length > 2 &&
      ((acBytes[1] >>> 4) & 0x0F) ===
        ((acBytes[0] ^ 0xFF) & 0x0F) &&
      (acBytes[2] & 0x0F) ===
        (((acBytes[0] ^ 0xFF) >>> 4) & 0x0F) &&
      ((acBytes[2] >>> 4) & 0x0F) ===
        ((acBytes[1] ^ 0xFF) & 0x0F)) {
      // C1, Block 0-3
      for (let i = 0; i < 4; i++) {
        acMatrix[0].push(((acBytes[1] >>> 4 + i) & 0x01));
      }
      // C2, Block 0-3
      for (let i = 0; i < 4; i++) {
        acMatrix[1].push(((acBytes[2] >>> i) & 0x01));
      }
      // C3, Block 0-3
      for (let i = 0; i < 4; i++) {
        acMatrix[2].push(((acBytes[2] >>> 4 + i) & 0x01));
      }
      return acMatrix;
    }
    return undefined;
  }

  public static async getCardName(nfcType?: number, name?: string): Promise<string> {
    if (!name) {
      switch (nfcType) {
        case NFC_TYPE.NFC_TYPE_DOOR:
          name = '我的门禁卡';
          break;
        case NFC_TYPE.NFC_TYPE_BUS:
          name = '我的公交卡';
          break;
        case NFC_TYPE.NFC_TYPE_BIKE:
          name = '我的电动车卡';
          break;
        case NFC_TYPE.NFC_TYPE_ELEVATOR:
          name = '我的电梯卡';
          break;
        case NFC_TYPE.NFC_TYPE_BANK:
          name = '我的银行卡';
          break;
        default:
          name = '我的卡片';
          break;
      }
    }
    let index = 1;
    let tName = name;
    while ((await nfcCardInfo.findByName(name))) {
      name = tName + index++;
    }
    return name;
  }

  public static isKeyBReadable(c1: number, c2: number, c3: number): boolean {
    return c1 === 0 && ((c2 === 0 && c3 === 0) || (c2 === 1 && c3 === 0) || (c2 === 0 && c3 === 1));
  }

  public static getOperationRequirements(c1: number, c2: number, c3: number, op: Operation, isSectorTrailer: boolean,
    isKeyBReadable: boolean): number {
    if (isSectorTrailer) {
      if (op !== Operation.ReadKeyA && op !== Operation.ReadKeyB &&
        op !== Operation.ReadAC && op !== Operation.WriteKeyA &&
        op !== Operation.WriteKeyB && op !== Operation.WriteAC) {
        return 4;
      }
      if (c1 === 0 && c2 === 0 && c3 === 0) {
        if (op === Operation.WriteKeyA || op === Operation.WriteKeyB ||
          op === Operation.ReadKeyB || op === Operation.ReadAC) {
          return 1;
        }
        return 0;
      } else if (c1 === 0 && c2 === 1 && c3 === 0) {
        if (op === Operation.ReadKeyB || op === Operation.ReadAC) {
          return 1;
        }
        return 0;
      } else if (c1 === 1 && c2 === 0 && c3 === 0) {
        if (op === Operation.WriteKeyA || op === Operation.WriteKeyB) {
          return 2;
        }
        if (op === Operation.ReadAC) {
          return 3;
        }
        return 0;
      } else if (c1 === 1 && c2 === 1 && c3 === 0) {
        if (op === Operation.ReadAC) {
          return 3;
        }
        return 0;
      } else if (c1 === 0 && c2 === 0 && c3 === 1) {
        if (op === Operation.ReadKeyA) {
          return 0;
        }
        return 1;
      } else if (c1 === 0 && c2 === 1 && c3 === 1) {
        if (op === Operation.ReadAC) {
          return 3;
        }
        if (op === Operation.ReadKeyA || op === Operation.ReadKeyB) {
          return 0;
        }
        return 2;
      } else if (c1 === 1 && c2 === 0 && c3 === 1) {
        if (op === Operation.ReadAC) {
          return 3;
        }
        if (op === Operation.WriteAC) {
          return 2;
        }
        return 0;
      } else if (c1 === 1 && c2 === 1 && c3 === 1) {
        if (op === Operation.ReadAC) {
          return 3;
        }
        return 0;
      } else {
        return -1;
      }
    } else {
      if (op !== Operation.Read && op !== Operation.Write && op !==
      Operation.Increment && op !== Operation.DecTransRest) {
        return -1;
      }
      if (c1 === 0 && c2 === 0 && c3 === 0) {
        return (isKeyBReadable) ? 1 : 3;
      } else if (c1 === 0 && c2 === 1 && c3 === 0) {
        if (op === Operation.Read) {
          return (isKeyBReadable) ? 1 : 3;
        }
        return 0;
      } else if (c1 === 1 && c2 === 0 && c3 === 0) {
        if (op === Operation.Read) {
          return (isKeyBReadable) ? 1 : 3;
        }
        if (op === Operation.Write) {
          return 2;
        }
        return 0;
      } else if (c1 === 1 && c2 === 1 && c3 === 0) {
        if (op === Operation.Read || op === Operation.DecTransRest) {
          return (isKeyBReadable) ? 1 : 3;
        }
        return 2;
      } else if (c1 === 0 && c2 === 0 && c3 === 1) {
        if (op === Operation.Read || op === Operation.DecTransRest) {
          return (isKeyBReadable) ? 1 : 3;
        }
        return 0;
      } else if (c1 === 0 && c2 === 1 && c3 === 1) {
        if (op === Operation.Read || op === Operation.Write) {
          return 2;
        }
        return 0;
      } else if (c1 === 1 && c2 === 0 && c3 === 1) {
        if (op === Operation.Read) {
          return 2;
        }
        return 0;
      } else if (c1 === 1 && c2 === 1 && c3 === 1) {
        return 0;
      } else {
        return -1;
      }
    }
  }
};