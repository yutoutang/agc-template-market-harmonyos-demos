import { window } from '@kit.ArkUI';

export interface PaddingType {
  top: number;
  bottom: number;
  left: number;
  right: number;
}

export interface AvoidAreaCallback {
  type: window.AvoidAreaType;
  area: window.AvoidArea;
}