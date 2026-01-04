/**
 * 全局运动语音提示设置
 */
@ObservedV2
export class DailyRunningVoiceSetting {
  // 步行有目标
  @Trace walkTargetVoiceOn: boolean = true;
  // 步行遛狗
  @Trace walkDogVoiceOn: boolean = true;
  // 语音播报设置
  @Trace walkVoiceOn: boolean = true; // 步行
  // 步行自由
  @Trace walkFreeVoiceOn: boolean = true;
  @Trace cyclingVoiceOn: boolean = true; // 骑行
  // 骑行自由
  @Trace cyclingFreeVoiceOn: boolean = true;
  // 骑行有目标
  @Trace cyclingTargetVoiceOn: boolean = true;
  @Trace clockBaseVoiceOn: boolean = true; // 定时运动
  // 跑步
  @Trace joggingVoiceOn: boolean = true;
  // 跑步自由
  @Trace joggingFreeVoiceOn: boolean = true;
  // 跑步有目标
  @Trace joggingTargetVoiceOn: boolean = true;
}