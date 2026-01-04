
/**
 * 身份证识别信息数据类型
 */

export class IDCardInfo {
  name?:string
  sex?:string
  nationality?:string
  address?:string

  constructor(name?: string, sex?: string, nationality?: string, address?: string, birth?: string, idNumber?: string,
    cardImageUri?: string, originalImageUri?: string, frontImageUri?: string, backImageUri?: string, authority?: string,
    validPeriod?: string) {
    this.name = name
    this.sex = sex
    this.nationality = nationality
    this.address = address
    this.birth = birth
    this.idNumber = idNumber
    this.cardImageUri = cardImageUri
    this.originalImageUri = originalImageUri
    this.frontImageUri = frontImageUri
    this.backImageUri = backImageUri
    this.authority = authority
    this.validPeriod = validPeriod
  }
  birth?:string
  idNumber?:string
  cardImageUri?:string
  originalImageUri?:string
  frontImageUri?:string
  backImageUri?:string
  authority?:string
  validPeriod?:string
  //完整的概率。取值范围：(0,1)。值越大，完整的概率越大
  completenessProbability?: string
  //反光的概率。取值范围：(0,1)。值越大，反光的概率越大
  reflectionProbability?: string
  //清晰的概率。取值范围：(0,1)。值越大，清晰的概率越大。
  clarityProbability?: string
  // 遮挡的概率。取值范围：(0,1)。值越大，遮挡的概率越大。
  occlusionProbability?: string
}

/**
 * 身份证质量检测数据阈值枚举
 */
export enum CardQualityEnum {
  // 身份证质量检测的阈值-开发者可在此自定义 注释后是建议值，目前赋值为测试阈值
  completenessRate = 0.85, //0.95
  reflectionRate = 0.25, //0.15
  clarityRate = 0.88, //0.98
  occlusionRate = 0.15, //0.05
}