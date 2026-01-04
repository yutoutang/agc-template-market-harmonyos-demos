import { IDCardInfo } from '../models/IDCardInfoType'
import { uploadIDCard } from './UploadIDCard'

@ComponentV2
export struct VerifyCard {
  @Local myIdCardInfo: IDCardInfo | undefined = undefined

  @Event verifyCallBack: (info: IDCardInfo) => void = (info: IDCardInfo) => {
  }

  build() {
    Column({ space: 10 }) {
      uploadIDCard({
        callBackCardInfo: (info: IDCardInfo) => {
          this.myIdCardInfo = info
          this.verifyCallBack(info)
        }
      })
    }
    .width('100%')
  }
}
