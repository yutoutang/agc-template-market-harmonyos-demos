import { insightIntent, InsightIntentExecutor } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';


/**
 * 意图调用样例 */
export default class InsightIntentExecutorImpl extends InsightIntentExecutor {
  private static readonly VIEW_REPAYMENT = 'ViewPerformanceActivity';

  /**
   * override 执行前台UIAbility意图
   *
   * @param name 意图名称
   * @param param 意图参数
   * @param pageLoader 窗口
   * @returns 意图调用结果
   */
  onExecuteInUIAbilityForegroundMode(name: string, param: Record<string, Object>, pageLoader: window.WindowStage):
    Promise<insightIntent.ExecuteResult> {
    // 根据意图名称分发处理逻辑。接入方可根据实际业务实现页面跳转
    switch (name) {
      case InsightIntentExecutorImpl.VIEW_REPAYMENT:
        return this.viewRepayment(param, pageLoader);
      default:
        break;
    }
    return Promise.resolve({
      code: -1,
      result: {
        message: 'unknown intent'
      }
    } as insightIntent.ExecuteResult)
  }


  /**
   * 实现调用查看还款功能
   *
   * @param param 意图参数
   * @param pageLoader 窗口
   */
  private viewRepayment(param: Record<string, Object>,
    pageLoader: window.WindowStage): Promise<insightIntent.ExecuteResult> {
    return new Promise((resolve, reject) => {
      let para: Record<string, string> = {
        'result': JSON.stringify(param)
      };
      let localStorage: LocalStorage = new LocalStorage(para);
      AppStorage.setOrCreate('result', para)
      pageLoader.loadContent('pages/Index', localStorage)
        .then(() => {
          resolve({
            code: 0,
            result: {
              message: 'Intent execute succeed'
            }
          });
        })
        .catch((err: BusinessError) => {
          console.log('loadContent error', err)
          // TODO 调用失败的情况
          resolve({
            code: -1,
            result: {
              message: 'Intent execute failed'
            }
          })
        });
    })
  }
}