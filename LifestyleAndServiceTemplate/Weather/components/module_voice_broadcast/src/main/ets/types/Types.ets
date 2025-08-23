export enum VoiceType {
  CN_FEMALE_DEFAULT = 0,
  CN_FEMALE = 13,
  CN_MALE = 21,
  US_FEMALE = 8,
}

@ObservedV2
export class VoicePackage {
  pic: ResourceStr;
  type: VoiceType;
  desc: string;
  used: number;
  rate: number;
  installed: boolean;

  constructor(pic: ResourceStr, type: VoiceType, desc: string, used: number, rate: number, installed: boolean) {
    this.pic = pic;
    this.type = type;
    this.desc = desc;
    this.used = used;
    this.rate = rate;
    this.installed = installed;
  }
}

@ObservedV2
export class VoiceModel {
  @Trace curVoice: VoiceType = VoiceType.CN_FEMALE_DEFAULT;
}