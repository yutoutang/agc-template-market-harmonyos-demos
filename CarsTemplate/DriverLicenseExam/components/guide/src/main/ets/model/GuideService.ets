import { GuideData, LICENSE_TYPE, DRIVE_STAGE } from './model'
import { promptAction } from '@kit.ArkUI';

@ObservedV2
export class GuideService {
  private static _instance: GuideService;

  public static get instance() {
    if (!GuideService._instance) {
      GuideService._instance = new GuideService();
    }
    return GuideService._instance;
  }

  @Trace private completeGuidance: boolean = false; // 是否完成导引
  @Trace public guideData: GuideData = GuideData.instance;

  public changeGuidanceStatus(uiContext:UIContext) {
    if (this.guideData.city && this.guideData.licenseType && this.guideData.driveStage) {
      this.completeGuidance = true;
      return;
    }
    this.checkData(uiContext);
  }

  public isCompleteGuidance():boolean {
    return this.completeGuidance;
  }

  public updateCity(city: string):void {
    this.guideData.city = city;
  }

  public updateLicenseType(type: LICENSE_TYPE):void {
    this.guideData.licenseType = type;
  }

  public updateDriveStage(stage: DRIVE_STAGE):void {
    this.guideData.driveStage = stage;
  }

  public getGuideData():GuideData {
    return this.guideData;
  }

  private checkData(uiContext:UIContext) {
    if (this.guideData.city === '') {
      uiContext.getPromptAction().showToast({
        message: $r('app.string.select_city'),
        duration: 1500,

      })
      return;
    }
    if (this.guideData.licenseType === undefined) {
      uiContext.getPromptAction().showToast({
        message: $r('app.string.select_license_type'),
        duration: 1500,
      })
      return;
    }
    if (this.guideData.driveStage === undefined) {
      uiContext.getPromptAction().showToast({
        message: $r('app.string.select_drive_stage'),
        duration: 1500,
      })
      return;
    }
  }
}