import { ValueType } from '@kit.ArkData';
import { NewsEnum, RouterMap, RouterUtils } from 'lib_common';
import { LoneTakeAnimationsTransition, LongTakeTransitionParam } from 'module_transition';

export class AvRouter {
  private uiContext: UIContext

  constructor(uiContext: UIContext) {
    this.uiContext = uiContext
  }

  /*
   * 跳转广播详情
   * cardData 数据源
   * componentId  一镜到底id
   * */
  public pushToAvDetails(cardData: Record<string, ValueType | NewsEnum>, componentId: string) {
    let params: Record<string, ValueType | LongTakeTransitionParam | undefined | NewsEnum> = {
      'avId': cardData.id,
      'longTakeTransitionParam': undefined,
      'isCreateSubWindow': cardData.isCreateSubWindow,
    }
    let longTakeTransitionParam: LongTakeTransitionParam | undefined =
      LoneTakeAnimationsTransition.generateLongTakeParam(this.uiContext,
        componentId, 9);
    if (longTakeTransitionParam) {
      params.longTakeTransitionParam = longTakeTransitionParam;
    }
    RouterUtils.pushPathByName(cardData.type === NewsEnum.Broadcast ? RouterMap.AUDIO_DETAILS :
      RouterMap.VIDEO_PROGRAM_DETAILS, params)
  }
}