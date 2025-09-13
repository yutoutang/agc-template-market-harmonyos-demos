import { ToastUtil } from '@pura/harmony-utils';
import { tag } from '@kit.ConnectivityKit';
import { HashMap, HashSet, PlainArray } from '@kit.ArkTS';
import Common, { Operation } from '../Common';
import MifareClassicReader from '../reader/MifareClassicReader';
import MCReader from '../MCReader';

export default class WriteManager {
  tag: tag.TagInfo;
  cardType: number;
  mDumpWithPos: HashMap<number, HashMap<number, number[]>> = new HashMap<number, HashMap<number, number[]>>();

  constructor(tag: tag.TagInfo, cardType: number) {
    this.tag = tag;
    this.cardType = cardType;
  }

  async initDumpWithPosFromDump(dump: string[]): Promise<number> {
    this.mDumpWithPos.clear();
    let sector = 0;
    let block = 0;
    for (let i = 0; i < dump.length; i++) {
      if (dump[i].startsWith('+')) {
        let tmp: string[] = dump[i].split(': ');
        sector = parseInt(tmp[tmp.length-1]);
        block = 0;
        this.mDumpWithPos.set(sector, new HashMap<number, number[]>());
      } else if (!dump[i].concat('-')) {
        this.mDumpWithPos.get(sector).set(block++, Common.hex2Bytes(dump[i]));
      } else {
        block++;
      }
    }
    return await this.checkDumpAgainstTag();
  }

  async checkDumpAgainstTag(): Promise<number> {
    let reader: MCReader | undefined = this.checkForTagAndCreateReader();
    if (!reader) {
      ToastUtil.showToast('错误:测试克隆时标签丢失');
      return -10;
    }

    let max: number = 0;
    let temp = this.mDumpWithPos.keys();
    for (let tempValue of temp) {
      max = tempValue > max ? tempValue : max;
    }
    if (reader.getSectorCount() - 1 < max) {
      ToastUtil.showToast('错误:标签容量小于选定的扇区');
      reader.close();
      return -10;
    }

    let keyMap: PlainArray<number[][]>;
    try {
      keyMap = await MifareClassicReader.getKeyMap(tag.getMifareClassic(this.tag), reader.getSectorCount());
    } catch (e) {
      ToastUtil.showToast('错误:丢失标签');
      return -10;
    }
    let dataPos: HashMap<number, number[]> = new HashMap<number, number[]>();
    for (let sector of this.mDumpWithPos.keys()) {
      let i = 0;
      let blocks: number[] = [];
      for (let block of this.mDumpWithPos.get(sector).keys()) {
        blocks.push(block);
      }
      dataPos.set(sector, blocks);
    }
    let writeOnPos: HashMap<number, HashMap<number, number>> = await reader.isWritableOnPositions(dataPos, keyMap);
    reader.close();

    if (!writeOnPos) {
      ToastUtil.showToast('错误:测试克隆时标签丢失');
      return -10;
    }

    let list: Array<HashMap<string, string>> = [];
    let writeOnPosSafe: HashMap<number, HashMap<number, number>> = new HashMap<number, HashMap<number, number>>();

    let sectors: HashSet<number> = new HashSet<number>();
    for (let sector of this.mDumpWithPos.keys()) {
      if (keyMap.getIndexOfKey(sector) < 0) {
        this.addToList(list, '扇区: ' + sector, '密钥(A和B)未知');
      } else {
        sectors.add(sector);
      }
    }

    for (let sector of sectors) {
      if (!writeOnPos.get(sector)) {
        this.addToList(list, '扇区: ' + sector, '无效的访问条件或死扇区:(');
        continue;
      }
      let keys: number[][] = keyMap.get(sector);
      let blocks = this.mDumpWithPos.get(sector).keys();
      for (let block of blocks) {
        let isSafeForWriting = true;
        let position = '扇区: ' + sector + ', 块' + ': ' + block;

        if (sector === 0 && block === 0) {
          continue;
        }
        if ((sector < 31 && block === 3) || sector >= 31 && block === 15) {
          let sectorTrailer: string = Common.bytes2Hex(this.mDumpWithPos.get(sector).get(block));
          let acCheck: number = this.checkAccessConditions(sectorTrailer, false);
          switch (acCheck) {
            case 1:
              ToastUtil.showToast('错误:访问条件无效');
              return -10;
            case 2:
              this.addToList(list, position, '警告:访问控制条件将不可逆');
              break;
          }
        }

        let writeInfo: number = writeOnPos.get(sector).get(block);
        switch (writeInfo) {
          case 0:
            this.addToList(list, position, '只读块');
            isSafeForWriting = false;
            break;
          case 1:
            if (!keys || keys.length < 1 || !keys[0]) {
              this.addToList(list, position, '写访问密钥(A)未知');
              isSafeForWriting = false;
            }
            break;
          case 2:
            if (!keys || keys.length < 2 || !keys[1]) {
              this.addToList(list, position, '写访问密钥(B)未知');
              isSafeForWriting = false;
            }
            break;
          case 3:
            writeInfo = (keys && keys.length > 0 && keys[0]) ? 1 : 2;
            break;
          case 4:
            if (!keys || keys.length < 1 || !keys[0]) {
              this.addToList(list, position, '写访问密钥(A)未知');
              isSafeForWriting = false;
            } else {
              this.addToList(list, position, '访问条件为只读');
            }
            break;
          case 5:
            if (!keys || keys.length < 2 || !keys[1]) {
              this.addToList(list, position, '写访问密钥(B)未知');
              isSafeForWriting = false;
            } else {
              this.addToList(list, position, '访问条件为只读');
            }
            break;
          case 6:
            if (!keys || keys.length < 2 || !keys[1]) {
              this.addToList(list, position, '写访问密钥(B)未知');
              isSafeForWriting = false;
            } else {
              this.addToList(list, position, '密钥(A和B)只读');
            }
            break;
          case -1:
            this.addToList(list, position, '发生了一些奇怪的错误:(');
            isSafeForWriting = false;
        }
        if (isSafeForWriting) {
          if (!writeOnPosSafe.get(sector)) {
            let blockInfo: HashMap<number, number> = new HashMap<number, number>();
            blockInfo.set(block, writeInfo);
            writeOnPosSafe.set(sector, blockInfo);
          } else {
            writeOnPosSafe.get(sector).set(block, writeInfo);
          }
        }
      }
    }

    return await this.writeDump(writeOnPosSafe, keyMap);
  }

  async writeDump(writeOnPos: HashMap<number, HashMap<number, number>>,
    keyMap: PlainArray<number[][]>): Promise<number> {
    if (writeOnPos.length === 0) {
      ToastUtil.showToast('没有数据可写');
      return -10;
    }

    let reader: MCReader | undefined = this.checkForTagAndCreateReader();
    if (!reader) {
      ToastUtil.showToast('连接NFC卡片出现问题');
      return -10;
    }

    for (let sector of writeOnPos.keys()) {
      let keys: number[][] = keyMap.get(sector);
      for (let block of writeOnPos.get(sector).keys()) {
        let writeKey: number[] = [];
        let useAsKeyB = true;
        let wi: number = writeOnPos.get(sector).get(block);
        if (wi === 1 || wi === 4) {
          writeKey = keys[0];
          useAsKeyB = false;
        } else if (wi === 2 || wi === 5 || wi === 6) {
          writeKey = keys[1];
        }

        let result = 0;
        for (let i = 0; i < 2; i++) {
          result = await reader.writeBlock(sector, block,
            this.mDumpWithPos.get(sector).get(block),
            writeKey, useAsKeyB);
          if (result === 0) {
            break;
          }
        }

        if (result !== 0) {
          ToastUtil.showToast('错误:写入发生错误.\\n这可能很糟…');
          reader.close();
          return -10;
        }
      }
    }
    reader.close();
    return 1;
  }

  addToList(list: Array<HashMap<string, string>>, position: string, reason: string) {
    let item: HashMap<string, string> = new HashMap<string, string>();
    item.set('position', position);
    item.set('reason', reason);
    list.push(item);
  }

  checkAccessConditions(sectorTrailer: string, showToasts: boolean): number {
    let acBytes: number[] = Common.hex2Bytes(sectorTrailer.substring(12, 18));
    let acMatrix: number[][] | undefined = Common.acBytesToACMatrix(acBytes);
    if (!acMatrix) {
      if (showToasts) {
        ToastUtil.showToast('错误:访问条件无效');
      }
      return 1;
    }
    let keyBReadable: boolean = Common.isKeyBReadable(
      acMatrix[0][3], acMatrix[1][3], acMatrix[2][3]);
    let writeAC: number = Common.getOperationRequirements(
      acMatrix[0][3], acMatrix[1][3], acMatrix[2][3],
      Operation.WriteAC, true, keyBReadable);
    if (writeAC === 0) {
      if (showToasts) {
        ToastUtil.showToast('警告:访问控制条件将不可逆');
      }
      return 2;
    }
    return 0;
  }


  checkForTagAndCreateReader(): MCReader | undefined {
    let reader: MCReader | undefined;
    let tagLost: boolean = false;
    if (this.tag && (reader = MCReader.get(this.tag))) {
      try {
        reader.connect();
      } catch (e) {
        tagLost = true;
      }
      if (!tagLost && !reader.isConnected()) {
        reader.close();
        tagLost = true;
      }
      if (!tagLost) {
        return reader;
      }
    }

    ToastUtil.showToast('错误:未发现MIFARE Classic标签');
    return reader;
  }
};