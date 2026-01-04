import { PermissionUtil } from '../uitils/PermissionUtil';
import { interactiveLiveness } from '@kit.VisionKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';

@ObservedV2
export class VerifyFaceVM {
  @Trace isFaceVerifyDone: boolean = false
  @Trace isFaceVerifySuccess: boolean = false

  startToFaceVerify(context: UIContext,
    succeededCallBack: (result: interactiveLiveness.InteractiveLivenessResult, isFaceSuccess: boolean) => void) {
    PermissionUtil.requestPermissions(['ohos.permission.CAMERA'], context, () => {
      let isSilentMode = 'INTERACTIVE_MODE' as interactiveLiveness.DetectionMode;
      let actionsNum = 3 as interactiveLiveness.ActionsNumber;
      let routerOptions: interactiveLiveness.InteractiveLivenessConfig = {
        actionsNum: actionsNum,
        isSilentMode: isSilentMode,
        routeMode: 'back' as interactiveLiveness.RouteRedirectionMode
      };
      try {
        interactiveLiveness.startLivenessDetection(routerOptions, (err: BusinessError,
          result: interactiveLiveness.InteractiveLivenessResult) => {
          // 当路由跳转错误时，获取结果失败，result返回undefined
          if (err.code !== 0 && !result) {
            // 在发生错误如路由跳转失败/参数错误/权限被拒绝时，会抛出错误码，详见ArkTS API错误码
            hilog.error(0x0001, 'LivenessCollectionIndex', `Failed to detect. Code：${err.code}，message：${err.message}`);
            this.isFaceVerifySuccess = false
            succeededCallBack(result, false)
            return;
          }
          this.isFaceVerifyDone = true
          this.isFaceVerifySuccess = true
          succeededCallBack(result, true)
        })
      } catch (err) {
        hilog.error(0x0001, 'VerifyFaceVM', `Failed to detect. Code：${err.code}，message：${err.message}`);
      }
    })
  }
}