import { GlobalContext, PreferenceUtil } from 'common';

export class FilePreferenceUtil {
  // 静态变量：上传已完成文件关键词
  public static UPLOAD_COMPLETED_FILE_KEYWORD = 'upload_completed_file_keyword';
  // 静态变量：下载已完成文件关键词
  public static DOWNLOAD_COMPLETED_FILE_KEYWORD = 'download_completed_file_keyword';
  // 静态变量：上传进行中文件关键词
  public static UPLOAD_PROGRESSING_FILE_KEYWORD = 'upload_progressing_file_keyword';
  // 静态变量：下载进行中文件关键词
  public static DOWNLOAD_PROGRESSING_FILE_KEYWORD = 'download_progressing_file_keyword';
  // 静态变量：上传任务失败文件关键词
  public static UPLOAD_FAILED_FILE_KEYWORD = 'upload_failed_file_keyword';
  // 静态变量：下载任务失败文件关键词
  public static DOWNLOAD_FAILED_FILE_KEYWORD = 'download_failed_file_keyword';
  // 首选项工具对象
  public preferenceUtil: PreferenceUtil = PreferenceUtil.getInstance(GlobalContext.getUIAbilityContext(), 'cloud_disk_database');
  // 全局单例
  private static _rootInstance: FilePreferenceUtil;

  public static get rootInstance(): FilePreferenceUtil {
    if (FilePreferenceUtil._rootInstance === undefined) {
      FilePreferenceUtil._rootInstance = new FilePreferenceUtil()
    }
    return FilePreferenceUtil._rootInstance;
  }

  /**
   * 获取UPLOAD_COMPLETED_FILE_KEYWORD的value，返回string
   */
  public getUploadCompletedFileList(): string {
    const data: string = this.preferenceUtil.get(FilePreferenceUtil.UPLOAD_COMPLETED_FILE_KEYWORD, '') as string;
    return data
  }

  /**
   * 设置UPLOAD_COMPLETED_FILE_KEYWORD的value，返回boolean
   */
  public setUploadCompletedFileList(arrayJson: string): boolean {
    try {
      this.preferenceUtil.put(FilePreferenceUtil.UPLOAD_COMPLETED_FILE_KEYWORD, arrayJson);
    } catch (err) {
      return false;
    }
    return true;
  }

  /**
   * 获取UPLOAD_PROGRESSING_FILE_KEYWORD的value，返回string
   */
  public getUploadProgressingFileList(): string {
    const data: string = this.preferenceUtil.get(FilePreferenceUtil.UPLOAD_PROGRESSING_FILE_KEYWORD, '') as string;
    return data
  }

  /**
   * 设置UPLOAD_PROGRESSING_FILE_KEYWORD的value，返回boolean
   */
  public setUploadProgressingFileList(arrayJson: string): boolean {
    try {
      this.preferenceUtil.put(FilePreferenceUtil.UPLOAD_PROGRESSING_FILE_KEYWORD, arrayJson);
    } catch (err) {
      return false;
    }
    return true;
  }

  /**
   * 获取UPLOAD_FAILED_FILE_KEYWORD的value，返回string
   */
  public getUploadFailedFileList(): string {
    const data: string = this.preferenceUtil.get(FilePreferenceUtil.UPLOAD_FAILED_FILE_KEYWORD, '') as string;
    return data
  }

  /**
   * 设置UPLOAD_FAILED_FILE_KEYWORD的value，返回boolean
   */
  public setUploadFailedFileList(arrayJson: string): boolean {
    try {
      this.preferenceUtil.put(FilePreferenceUtil.UPLOAD_FAILED_FILE_KEYWORD, arrayJson);
    } catch (err) {
      return false;
    }
    return true;
  }

  /**
   * 获取DOWNLOAD_COMPLETED_FILE_KEYWORD的value，返回string
   */
  public getDownloadCompletedFileList(): string {
    const data: string = this.preferenceUtil.get(FilePreferenceUtil.DOWNLOAD_COMPLETED_FILE_KEYWORD, '') as string;
    return data
  }

  /**
   * 设置DOWNLOAD_COMPLETED_FILE_KEYWORD的value，返回boolean
   */
  public setDownloadCompletedFileList(arrayJson: string): boolean {
    try {
      this.preferenceUtil.put(FilePreferenceUtil.DOWNLOAD_COMPLETED_FILE_KEYWORD, arrayJson);
    } catch (err) {
      return false;
    }
    return true;
  }

  /**
   * 获取DOWNLOAD_PROGRESSING_FILE_KEYWORD的value，返回string
   */
  public getDownloadProgressingFileList(): string {
    const data: string = this.preferenceUtil.get(FilePreferenceUtil.DOWNLOAD_PROGRESSING_FILE_KEYWORD, '') as string;
    return data
  }

  /**
   * 设置DOWNLOAD_PROGRESSING_FILE_KEYWORD的value，返回boolean
   */
  public setDownloadProgressingFileList(arrayJson: string): boolean {
    try {
      this.preferenceUtil.put(FilePreferenceUtil.DOWNLOAD_PROGRESSING_FILE_KEYWORD, arrayJson);
    } catch (err) {
      return false;
    }
    return true;
  }

  /**
   * 获取DOWNLOAD_PROGRESSING_FILE_KEYWORD的value，返回string
   */
  public getDownloadFailedFileList(): string {
    const data: string = this.preferenceUtil.get(FilePreferenceUtil.DOWNLOAD_FAILED_FILE_KEYWORD, '') as string;
    return data
  }

  /**
   * 设置DOWNLOAD_PROGRESSING_FILE_KEYWORD的value，返回boolean
   */
  public setDownloadFailedFileList(arrayJson: string): boolean {
    try {
      this.preferenceUtil.put(FilePreferenceUtil.DOWNLOAD_FAILED_FILE_KEYWORD, arrayJson);
    } catch (err) {
      return false;
    }
    return true;
  }
}