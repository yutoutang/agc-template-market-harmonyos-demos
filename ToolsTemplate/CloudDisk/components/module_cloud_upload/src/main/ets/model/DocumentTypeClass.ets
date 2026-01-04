import { FileType } from 'common';

/**
 * 上传文件状态类
 */
export interface UploadFileStatus {
  // 文件名称
  fileName: string;

  // 文件的原路径
  filePath: string;

  // 文件后缀
  fileSuffix: FileType;

  // 文件大小
  fileSize: number;

  // 创建时间
  createTime: string;

  // 状态码
  code: UploadFileStatusCode;

  // 传输进度
  progress: number;

  // 开始时间
  startTime: number;

  // 传输时间
  progressTime: number;

  // vip状态
  vipStatus: boolean;
}

/**
 * 上传文件状态码
 */
export enum UploadFileStatusCode {
  SUCCESS = '000200',
  FAILED = '000401',
  PROGRESSING = '000100'
}

/**
 * 下载文件状态类
 */
export interface DownloadFileStatus {
  // 文件名称
  fileName: string;

  // 文件的原路径
  filePath: string;

  // 文件后缀
  fileSuffix: FileType;

  // 文件大小
  fileSize: number;

  // 创建时间
  createTime: string;

  // 状态码
  code: DownloadFileStatusCode;

  // 传输进度
  progress: number;

  // 开始时间
  startTime: number;

  // 传输时间
  progressTime: number;

  // vip状态
  vipStatus: boolean;
}

/**
 * 下载文件状态码
 */
export enum DownloadFileStatusCode {
  SUCCESS = '000200',
  FAILED = '000401',
  PROGRESSING = '000100'
}

/**
 * 文档类型枚举
 */
export enum DocumentType {
  PDF,
  TXT,
  DOC,
  DOCX,
  XLS,
  XLSX,
  PPT,
  PPTX
}