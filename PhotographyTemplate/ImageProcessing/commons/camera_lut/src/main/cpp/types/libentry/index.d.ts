export interface XComponentContext {
  StartCamera(): void;
  StopCamera(): void;
  RestartCamera(): void;
  StartRecorder(): void;
  StopRecorder(): void;
  StartPlayer(): void;
  StopPlayer(): void;
  AddBW(): number;
  DeleteBW(): void;
  Lut(arraybuffer:ArrayBuffer,w:number,h:number): void;
  Photo(): ArrayBuffer;
  NativeCallArkTS(arraybuffer:ArrayBuffer,w:number,h:number): ArrayBuffer;
}