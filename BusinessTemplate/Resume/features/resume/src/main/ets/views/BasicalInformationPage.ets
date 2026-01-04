/**
 * 基本信息页面
 * 用于编辑简历的个人基本信息,包括姓名、手机号、邮箱、头像等
 */

import { CommonHeader, BreakpointModel } from 'common'
import { OHPage, phoneRouterControl } from 'oh_router'
import { PersonalInformationModel } from '../viewsmodel/BasicalInformationModel'
import { fileIo as fs } from '@kit.CoreFileKit'
import { util } from '@kit.ArkTS'
import { CenterEditDialogParams, CenterEditDialogController } from '../comp/TextEditDialog'
import { InfoRow } from '../comp/InfoRow'
import { UnsavedChangesDialogController } from '../comp/UnsavedChangesDialog'
import { AppStorageV2 } from '@kit.ArkUI'
import { OHPageConfig } from 'oh_router'
import { FunctionalButton, functionalButtonComponentManager } from '@kit.ScenarioFusionKit'
@Builder
export function PersonalInformationPageBuilder() {
  PersonalInformationPage()
}

@ComponentV2
export struct PersonalInformationPage {
  @Local personal: PersonalInformationModel = PersonalInformationModel.instance
  @Local tempName: string = ''
  @Local tempPhone: string = ''
  @Local tempEmail: string = ''
  @Local tempEditText: string = ''
  @Local currentEditKey: string = ''
  @Local saving: boolean = false
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Local initialData: string = ''
  @Local tempAvatarUrl: ResourceStr = ''
  @Local tempAvatarBuffer: string = ''

  aboutToAppear(): void {
    // 初始化临时变量
    this.tempName = this.personal.data.name
    this.tempPhone = this.personal.data.phone
    this.tempEmail = this.personal.data.email
    this.tempAvatarUrl = this.personal.data.avatarUrl
    this.tempAvatarBuffer = this.personal.data.avatarUrlBase64 || ''
    // 保存初始状态用于检测是否有修改
    this.initialData = JSON.stringify({
      name: this.personal.data.name,
      phone: this.personal.data.phone,
      email: this.personal.data.email,
      avatar: this.personal.data.avatarUrl
    })
  }

  build() {
    OHPage({
      childBuilder: () => {
        this.render()
      },
      useSafePadding: false,
      pageConfig: new OHPageConfig({
        onBackPress: () => {
          this.handleBack()
          return true
        }
      })
    })
  }

  @Builder
  render() {
    Stack() {
      Column() {
        CommonHeader({
          title: '基本信息',
          onReturnClick: () => {
            this.handleBack()
          },
        })
        Column() {
          this.avatarRow()

          Divider().strokeWidth('1px').width('100%').color($r('sys.color.comp_divider'))
          InfoRow({
            title: '姓名',
            value: this.tempName || '请填写姓名',
            isSecondary: !this.tempName,
            onClickRow: () => {
              this.openEditName()
            }
          })
          Divider().strokeWidth('1px').width('100%').color($r('sys.color.comp_divider'))
          InfoRow({
            title: '手机号',
            value: this.tempPhone || '请填写手机号',
            isSecondary: !this.tempPhone,
            onClickRow: () => {
              this.openEditPhone()
            }
          })
          Divider().strokeWidth('1px').width('100%').color($r('sys.color.comp_divider'))
          InfoRow({
            title: '邮箱',
            value: this.tempEmail || '请填写邮箱',
            isSecondary: !this.tempEmail,
            onClickRow: () => {
              this.openEditEmail()
            }
          })
          Divider().strokeWidth('1px').width('100%').color($r('sys.color.comp_divider'))
          Blank()
        }
        .width('100%')
        .layoutWeight(1)

        Button('保存')
          .width('100%')
          .height(44)
          .backgroundColor('#0A59F7')
          .borderRadius(22)
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.comp_background_list_card'))
          .enabled(!this.saving)
          .margin({ bottom: 16 })
          .onClick(() => {
            this.saveData()
          })
      }
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Start)
      .width('100%')
      .height('100%')
      .padding({
        left: this.breakPointModel.pagePadding,
        right: this.breakPointModel.pagePadding
      })
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  avatarRow() {
    Row() {
      Text('个人照片')
        .fontSize(14)
        .fontColor($r('sys.color.font_primary'))
      Blank()
      FunctionalButton({
        params: {
          openType: functionalButtonComponentManager.OpenType.CHOOSE_AVATAR,
          label: '',
          styleOption: {
            styleConfig: new functionalButtonComponentManager.ButtonConfig()
              .type(ButtonType.Normal)
              .backgroundImage(this.tempAvatarUrl)
              .backgroundImageSize(ImageSize.Cover)
              .backgroundColor($r('sys.color.brand'))
              .width(50)
              .height(50)
              .borderRadius(25),
          },
        },
        controller: new functionalButtonComponentManager.FunctionalButtonController().onChooseAvatar((err, data) => {
          if (err) {
            return;
          }
          let url = data.avatarUri!;
          let avatarFile: fs.File | null = null;
          let arrayBuffer: ArrayBuffer
          try {
            avatarFile = fs.openSync(url, fs.OpenMode.READ_ONLY);
            let newPath: string =
              this.getUIContext().getHostContext()?.cacheDir + `/${util.generateRandomUUID(false)}.png`;
            fs.copyFileSync(avatarFile.fd, newPath);
            url = 'file://' + newPath;

            let stat = fs.statSync(avatarFile.fd);
            arrayBuffer = new ArrayBuffer(stat.size);
            fs.readSync(avatarFile.fd, arrayBuffer);
          } finally {
            if (avatarFile) {
              fs.closeSync(avatarFile);
            }
          }

          let avatarString = this.arrayBuffer2Base64(arrayBuffer)
          this.tempAvatarUrl = url as ResourceStr
          this.tempAvatarBuffer = avatarString
        }),
      })

      SymbolGlyph($r('sys.symbol.chevron_right'))
        .fontSize('24vp')
        .fontColor([$r('sys.color.font_fourth')])
        .margin({ left: 4 })
    }
    .width('100%')
    .height(77)
  }

  openEditName() {
    this.tempEditText = this.tempName
    this.currentEditKey = 'name'
    this.openCenterDialog(this.getCenterTitle(), this.getCenterPlaceholder(), this.tempEditText)
  }

  openEditPhone() {
    this.tempEditText = this.tempPhone
    this.currentEditKey = 'phone'
    this.openCenterDialog(this.getCenterTitle(), this.getCenterPlaceholder(), this.tempEditText)
  }

  openEditEmail() {
    this.tempEditText = this.tempEmail
    this.currentEditKey = 'email'
    this.openCenterDialog(this.getCenterTitle(), this.getCenterPlaceholder(), this.tempEditText)
  }

  openCenterDialog(title: string, placeholder: string, value: string) {
    const params: CenterEditDialogParams = {
      title: title,
      placeholder: placeholder,
      value: value,
      onCancel: () => {
      },
      onConfirm: (v: string) => {
        this.handleCenterConfirm(v)
      }
    }
    CenterEditDialogController.openDialog(this.getUIContext(), params)
  }

  getCenterTitle(): string {
    return this.currentEditKey === 'name' ? '姓名' : (this.currentEditKey === 'phone' ? '手机号' : '邮箱')
  }

  getCenterPlaceholder(): string {
    return this.currentEditKey === 'name' ? '请填写您的姓名' :
      (this.currentEditKey === 'phone' ? '请填写您的手机号' : '请填写您的邮箱')
  }

  handleCenterConfirm(value: string): void {
    const v: string = (value ?? '').trim()
    if (this.currentEditKey === 'name') {
      if (!v) {
        this.getUIContext().getPromptAction().showToast({ message: '姓名不能为空' });
        return
      }
      this.tempName = v
    } else if (this.currentEditKey === 'phone') {
      // 国内手机号正则：1开头，第二位为3-9，后面9位数字
      const phoneRegex = /^1[3-9]\d{9}$/
      if (!phoneRegex.test(v)) {
        this.getUIContext().getPromptAction().showToast({ message: '请输入正确的手机号' });
        return
      }
      this.tempPhone = v
    } else if (this.currentEditKey === 'email') {
      if (!v || v.indexOf('@') === -1) {
        this.getUIContext().getPromptAction().showToast({ message: '请输入正确的邮箱' });
        return
      }
      this.tempEmail = v
    }
  }

  // 入参为Uint8Array
  uint8Array2Base64(uint8Array: Uint8Array): string {
    let base64Helper = new util.Base64Helper();
    return base64Helper.encodeToStringSync(uint8Array);
  }

  // 入参为ArrayBuffer，可转换为Uint8Array后再转base64
  arrayBuffer2Base64(arrayBuffer: ArrayBuffer): string {
    return this.uint8Array2Base64(new Uint8Array(arrayBuffer));
  }

  // 保存数据到Model
  saveData(): void {
    if (!this.tempName) {
      this.getUIContext().getPromptAction().showToast({ message: '请填写姓名' })
      return
    }
    if (!this.tempPhone) {
      this.getUIContext().getPromptAction().showToast({ message: '请填写手机号' })
      return
    }
    if (!this.tempEmail) {
      this.getUIContext().getPromptAction().showToast({ message: '请填写邮箱' })
      return
    }

    this.saving = true
    this.personal.setName(this.tempName)
    this.personal.setPhone(this.tempPhone)
    this.personal.setEmail(this.tempEmail)
    // 保存头像
    if (this.tempAvatarUrl !== this.personal.data.avatarUrl) {
      this.personal.setAvatar(this.tempAvatarUrl)
    }
    if (this.tempAvatarBuffer !== this.personal.data.avatarUrlBase64) {
      this.personal.setAvatarBuffer(this.tempAvatarBuffer)
    }
    setTimeout(() => {
      this.getUIContext().getPromptAction().showToast({ message: '保存成功' })
      this.saving = false
      phoneRouterControl.popPage()
    }, 300)
  }

  // 检查是否有未保存的修改
  hasUnsavedChanges(): boolean {
    const currentData = JSON.stringify({
      name: this.tempName,
      phone: this.tempPhone,
      email: this.tempEmail,
      avatar: this.tempAvatarUrl
    })
    return currentData !== this.initialData
  }

  // 处理返回
  handleBack(): void {
    if (this.hasUnsavedChanges()) {
      UnsavedChangesDialogController.openDialog(this.getUIContext(), {
        onConfirm: () => {
          phoneRouterControl.popPage()
        },
        onCancel: () => {
        }
      })
    } else {
      phoneRouterControl.popPage()
    }
  }
}

