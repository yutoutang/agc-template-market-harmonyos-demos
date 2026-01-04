
// 运行状态控制枚举
export enum ControlType {
  Start,
  Pause,
  End,
  Setting,
  Lock,
  Unlock,
  Begin
}

// 语音播报模型
export interface RunningVoiceModel {
  step: number
  finish: boolean
}

export enum RunState {
  Start,
  Pause,
  Stop
}