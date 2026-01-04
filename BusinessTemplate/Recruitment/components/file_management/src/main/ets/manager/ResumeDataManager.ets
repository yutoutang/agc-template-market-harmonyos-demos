import { FileDataSource } from '../model/FileDataSource';
import { ResumeEntity } from '../model/ResumeEntity';


/**
 * 简历数据管理单例
 * 用于在不同页面间共享简历数据
 */
export class ResumeDataManager {
  private static instance: ResumeDataManager;
  public resumeData: FileDataSource<ResumeEntity> = new FileDataSource();

  private constructor() {
  }

  static getInstance(): ResumeDataManager {
    if (!ResumeDataManager.instance) {
      ResumeDataManager.instance = new ResumeDataManager();
    }
    return ResumeDataManager.instance;
  }
}
