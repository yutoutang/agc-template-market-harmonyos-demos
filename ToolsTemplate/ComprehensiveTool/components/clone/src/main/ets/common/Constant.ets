import { hilog } from '@kit.PerformanceAnalysisKit'

export const LENGTH_TRANSFER_HEADER = 5

export const LENGTH_RECORD_DATA_IN_HEADER = 4

export const LENGTH_READ_FILE_CHUNK = 30 * 1024 * 1024

export const LENGTH_WRITE_FILE_CHUNK = 30 * 1024 * 1024

export enum WorkerMessageType {
  LISTEN, //监听
  RECEIVE, //接收
  CONNECT, //连接
  SEND, //发送
  CLOSE_CLIENT, // 关闭客户端
  SAVE_FILE //保存文件
}

export enum BinaryMessageType {
  // 文件传输开始
  FILE_START = 0x01,
  // 文件数据分片
  FILE_CHUNK = 0x02,
  // 文件传输结束
  FILE_END = 0x03,
  // 传输联系人
  CONTACT = 0x04,
  // 传输文件数
  FILE_COUNT = 0x05,
}

export enum FileType {
  CONTACT,
  IMAGE,
  VIDEO,
  DOCUMENT,
  AUDIO
}

// 传输类型枚举
export enum TransferType {
  Send = 'Send',
  Receive = 'Receive'
}

// 传输的状态
export enum TransferState {
  BEFORE,
  MIDDLE,
  AFTER,
  ERROR
}

export function getFileTypeIcon(fileType: FileType): ResourceStr {
  switch (fileType) {
    case FileType.IMAGE:
      return ALLOWED_TRANSFER_FILE_TYPE[0].icon
    case FileType.VIDEO:
      return ALLOWED_TRANSFER_FILE_TYPE[1].icon;
    case FileType.DOCUMENT:
      return ALLOWED_TRANSFER_FILE_TYPE[2].icon;
    case FileType.AUDIO:
      return ALLOWED_TRANSFER_FILE_TYPE[3].icon;
    default:
      return ALLOWED_TRANSFER_FILE_TYPE[2].icon;
  }
}

export const ALLOWED_TRANSFER_FILE_TYPE: FileTypeDisplayVo[] = [
  {
    name: '联系人',
    type: FileType.CONTACT,
    icon: $r('app.media.clone_contact'),
  },
  {
    name: '图片',
    type: FileType.IMAGE,
    icon: $r('app.media.clone_contact'),
  },
  {
    name: '视频',
    type: FileType.VIDEO,
    icon: '',

  },
]

export interface FileTypeDisplayVo {
  name: string,
  type: FileType,
  icon: ResourceStr
}

export interface FileBasic {
  uri: string,
  size: number,
}

@ObservedV2
export class MainFile {
  @Trace list: FileBasic[] = []
  // 列表数量
  @Trace size: number = 0
  // 是否选中
  @Trace isSelected: boolean = true
  // 传输或者接收的个数
  @Trace count: number = 0
  // 列表文件的总大小
  @Trace fileSize: number = 0
  // 列表文件接收的大小
  @Trace recvSize: number = 0
}

/**
 * 日志打印类
 */
class Logger {
  private domain: number;
  private prefix: string;
  private format: string = '%{public}s, %{public}s';

  constructor(prefix: string) {
    this.prefix = prefix;
    this.domain = 0xFF00;
    this.format.toUpperCase();
  }

  debug(...args: string[]) {
    hilog.debug(this.domain, this.prefix, this.format, args);
  }

  info(...args: string[]) {
    hilog.info(this.domain, this.prefix, this.format, args);
  }

  warn(...args: string[]) {
    hilog.warn(this.domain, this.prefix, this.format, args);
  }

  error(...args: string[]) {
    hilog.error(this.domain, this.prefix, this.format, args);
  }
}

export default new Logger('Clone');