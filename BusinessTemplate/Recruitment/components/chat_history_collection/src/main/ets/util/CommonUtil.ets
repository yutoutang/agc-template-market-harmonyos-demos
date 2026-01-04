import { util } from '@kit.ArkTS';

export function arrayBufferToString(arr: ArrayBuffer) {
  let decoder = util.TextDecoder.create('utf-8');
  return decoder.decodeToString(new Uint8Array(arr));
}