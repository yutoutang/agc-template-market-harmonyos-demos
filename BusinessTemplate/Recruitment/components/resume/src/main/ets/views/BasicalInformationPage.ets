import { CommonHeader, BarVM, PermissionUtil } from 'common'
import { OHPage, OHPageConfig, phoneRouterControl } from 'oh_router'
import { PersonalInformationModel } from '../viewsmodel/BasicalInformationModel'
import { fileIo as fs, fileUri } from '@kit.CoreFileKit'
import { util } from '@kit.ArkTS'
import { BusinessError } from '@kit.BasicServicesKit'
import { common } from '@kit.AbilityKit'
import { photoAccessHelper } from '@kit.MediaLibraryKit'
import { CenterEditDialogParams, CenterEditDialogPageBuilder } from '../comp/CenterEditDialog'
import { InfoRow } from '../comp/InfoRow'
import { camera, cameraPicker } from '@kit.CameraKit'
import { UnsavedChangesDialogController } from 'job_intention'
import { CenterEditDialogController } from '../comp/TextEditDialog'
import { CommonSingleDialogController, DegreeSelectDialogParams } from 'job_intention'
import { FunctionalButton, functionalButtonComponentManager } from '@kit.ScenarioFusionKit'

@Builder
export function PersonalInformationPageBuilder() {
  PersonalInformationPage()
}

@ComponentV2
export struct PersonalInformationPage {
  @Local personal: PersonalInformationModel = PersonalInformationModel.instance
  @Local tempName: string = ''
  @Local tempAge: string = ''
  @Local tempGender: string = ''
  @Local tempWorkStartDate: string = ''
  @Local tempEditText: string = ''
  @Local tempPhone: string = ''
  @Local tempEmail: string = ''
  @Local currentEditKey: string = ''
  @Local saving: boolean = false
  @Local showAvatarSheet: boolean = false
  @Local showGenderSheet: boolean = false
  @Local dialogStack: NavPathStack = new NavPathStack()
  @Local dialogOpen: boolean = false
  private select: number | number[] = 0;
  private ages: string[] = [];
  private workYears: string[] = [];
  @Local v: string = '';
  @Local initialData: string = ''

  aboutToAppear(): void {
    this.tempName = this.personal.data.name
    this.tempAge = this.personal.data.age
    this.tempGender = this.personal.data.gender
    this.tempWorkStartDate = this.personal.data.workStartDate
    this.tempPhone = this.personal.data.phone
    this.tempEmail = this.personal.data.email
    // 保存初始状态用于检测是否有修改
    this.initialData = JSON.stringify({
      name: this.personal.data.name,
      age: this.personal.data.age,
      gender: this.personal.data.gender,
      avatar: this.personal.data.avatarUrl,
      workStartDate: this.personal.data.workStartDate
    })
    // 生成0-100岁的数组
    for (let i = 0; i <= 100; i++) {
      this.ages.push(i + '岁')
    }
    // 生成工作年份数组 (2000-2025)
    const currentYear = new Date().getFullYear();
    for (let year = 2000; year <= currentYear; year++) {
      for (let month = 1; month <= 12; month++) {
        this.workYears.push(`${year}.${month.toString().padStart(2, '0')}`)
      }
    }
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

  build() {
    OHPage({
      childBuilder: () => {
        this.render()
      },
      useSafePadding: true,
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
            isDraftPosition: true,
            onClickRow: () => {
              this.openEditName()
            }
          })
          Divider().strokeWidth('1px').width('100%').color($r('sys.color.comp_divider'))
          InfoRow({
            title: '性别',
            value: this.tempGender || '请选择性别',
            isDraftPosition: true,
            isSecondary: !this.tempGender,
            onClickRow: () => {
              this.showGenderSheet = true
            }
          })
            .bindSheet(this.showGenderSheet, this.genderSheetBuilder(), this.avatarSheetOptions)
          Divider().strokeWidth('1px').width('100%').color($r('sys.color.comp_divider'))
          InfoRow({
            title: '年龄',
            value: this.tempAge || '请填写年龄',
            isSecondary: !this.tempAge,
            isDraftPosition: true,
            onClickRow: () => {
              this.openAgeDialog()
            }
          })
          Divider().strokeWidth('1px').width('100%').color($r('sys.color.comp_divider'))
          InfoRow({
            title: '参加工作时间',
            value: this.getWorkExperience(),
            isSecondary: !this.personal.data.workStartDate,
            isDraftPosition: true,
            onClickRow: () => {
              this.openWorkDayDialog()
            }
          })

          Divider().strokeWidth('1px').width('100%').color($r('sys.color.comp_divider'))
          Blank()
        }
        .width('100%')
        .layoutWeight(1)

        Row() {
          Button('保存')
            .width('90%')
            .height(44)
            .backgroundColor('#0A59F7')
            .borderRadius(22)
            .fontSize($r('sys.float.Body_L'))
            .fontColor($r('sys.color.font_on_primary'))
            .enabled(!this.saving)
            .onClick(() => {
              this.saveData()
            })
        }
        .width('100%')
        .height(56)
        .justifyContent(FlexAlign.Center)
        .padding({ bottom: BarVM.instance.aiBarH })
      }
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Start)
      .width('100%')
      .height('100%')

      Navigation(this.dialogStack) {
      }
      .width('100%')
      .height('100%')
      .hideTitleBar(true)
      .hideNavBar(true)
      .navDestination(this.dialogDestination)
      .hitTestBehavior(this.dialogOpen ? HitTestMode.Default : HitTestMode.None)
    }
    .padding({
      top: BarVM.instance.staBarH,
      bottom: BarVM.instance.aiBarH
    })
    .width('100%')
    .height('100%')
  }

  @Builder
  dialogDestination(name: string, _param: string) {
    if (name === 'CenterEditDialog') {
      wrapBuilder(CenterEditDialogPageBuilder).builder()
    }
  }

  @Builder
  genderButtons() {
    Row({ space: 12 }) {
      ForEach(['男', '女'], (item: string) => {
        Column() {
          Text(item)
            .fontSize(14)
            .fontColor(this.personal.data.gender === item ? '#FFFFFF' : '#333333')
        }
        .width(60)
        .height(32)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(this.personal.data.gender === item ? '#0A59F7' : '#F5F5F5')
        .borderRadius('50%')
        .onClick(() => {
          this.personal.setGender(item)
        })
      }, (item: string, index: number) => `${JSON.stringify(item)}_${index}}`)
    }
  }

  @Builder
  avatarRow() {
    Stack() {
      Row() {
        Text('个人照片')
          .fontSize(14)
          .fontColor($r('sys.color.font_primary'))
        Blank()
        Image(this.personal.data.avatarUrl)
          .width(40)
          .height(40)
          .borderRadius(20)
          .draggable(false)
          .copyOption(CopyOptions.None)
          .onClick(() => {
            this.showAvatarSheet = true
          })
          .bindSheet(this.showAvatarSheet, this.avatarSheetBuilder(), this.avatarSheetOptions)

        SymbolGlyph($r('sys.symbol.chevron_right'))
          .fontSize('24vp')
          .fontColor([$r('sys.color.font_fourth')])
          .margin({ left: 8 })
      }
      .width('100%')
      .height(77)

      FunctionalButton({
        params: {
          openType: functionalButtonComponentManager.OpenType.CHOOSE_AVATAR,
          label: '',
          styleOption: {
            styleConfig: new functionalButtonComponentManager.ButtonConfig()
              .type(ButtonType.Normal)
              .backgroundImageSize(ImageSize.Cover)
              .backgroundColor(Color.Transparent)
              .width('100%')
              .height(80)
              .borderRadius(0),
          },
        },
        controller: new functionalButtonComponentManager.FunctionalButtonController().onChooseAvatar((err, data) => {
          if (err) {
            // this.handleError(err);
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
          this.personal.setAvatar(url as ResourceStr)
        }),
      })
    }
  }

  getWorkExperience(): string {
    if (!this.personal.data.workStartDate) {
      return '请填写参加工作时间';
    }
    const parts = this.personal.data.workStartDate.split('.');
    const year = parts[0];
    const month = parts[1];
    const startDate = new Date(parseInt(year), parseInt(month) - 1);
    const now = new Date();
    const monthsDiff = (now.getFullYear() - startDate.getFullYear()) * 12 + (now.getMonth() - startDate.getMonth());
    const years = Math.floor(monthsDiff / 12);
    return `${this.personal.data.workStartDate}（${years}年经验）`;
  }

  openEditName() {
    this.tempName = this.personal.data.name
    this.tempEditText = this.tempName
    this.currentEditKey = 'name'
    this.openCenterDialog(this.getCenterTitle(), this.getCenterPlaceholder(), this.tempEditText)
  }

  openAgeDialog() {

    const params: DegreeSelectDialogParams = {
      selected: this.tempAge || '20岁',
      title: '年龄',
      range: this.ages,
      onConfirm: (val: string) => {
        this.tempAge = val
      },
      onCancel: () => {
      }
    }
    CommonSingleDialogController.openDialog(this.getUIContext(), params)

  }

  openWorkDayDialog() {
    const params: DegreeSelectDialogParams = {
      selected: this.tempWorkStartDate || '2020.12',
      title: '参加工作时间',
      range: this.workYears,
      onConfirm: (val: string) => {
        this.personal.setWorkStartDate(val);
        this.tempWorkStartDate = val
      },
      onCancel: () => {
      }
    }
    CommonSingleDialogController.openDialog(this.getUIContext(), params)

  }

  TextPicker(data: string) {
    let range: string[] = [];
    let selectedIndex = 0;

    if (data === 'workStartDate') {
      range = this.workYears;
      // 从当前工作时间中查找对应的索引
      if (this.personal.data.workStartDate) {
        const index = this.workYears.indexOf(this.personal.data.workStartDate);
        if (index !== -1) {
          selectedIndex = index;
        }
      }
    }

    this.getUIContext().showTextPickerDialog({
      range: range,
      selected: selectedIndex,
      defaultPickerItemHeight: 40,
      cancelButtonStyle: { fontColor: '#666666' },
      onAccept: (value: TextPickerResult) => {
        const selectedValue = value.value as string;
        if (data === 'workStartDate') {
          this.personal.setWorkStartDate(selectedValue);
          this.tempWorkStartDate = selectedValue
        }
      },
    })
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
    this.saving = true
    this.personal.setName(this.tempName)
    this.personal.setAge(this.tempAge)
    this.personal.setGender(this.tempGender)
    this.personal.setWorkStartDate(this.tempWorkStartDate)
    this.personal.setPhone(this.tempPhone)
    this.personal.setEmail(this.tempEmail)
    setTimeout(() => {
      this.getUIContext().getPromptAction().showToast({ message: '保存成功' })
      this.saving = false
      phoneRouterControl.popPage()
    }, 300)
  }

  openCenterDialog(title: string, placeholder: string, value: string) {
    const params: CenterEditDialogParams = {
      title: title,
      placeholder: placeholder,
      value: value,
      onCancel: () => {
        this.dialogOpen = false
      },
      onConfirm: (v: string) => {
        this.handleCenterConfirm(v);
        this.dialogOpen = false
      }
    }
    this.dialogOpen = true
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
    // 通过 onConfirm 回调关闭由对话页自身执行
  }

  handleAvatarError(err: BusinessError) {
    if (err && (err.code === 1001500001 || err.code === 1001600003)) {
      this.getUIContext().getPromptAction().showToast({ message: '头像功能暂不可用，请稍后重试' })
      return
    }
    this.getUIContext().getPromptAction().showToast({ message: '头像更换失败' })
  }

  get avatarSheetOptions() {
    return {
      height: SheetSize.FIT_CONTENT,
      showClose: false,
      preferType: SheetType.BOTTOM,
      onWillDisappear: () => {
        this.showAvatarSheet = false
      },
    } as SheetOptions
  }

  @Builder
  avatarSheetBuilder() {
    Column() {
      Button('拍摄')
        .width('100%')
        .height(48)
        .fontSize($r('sys.float.Body_L'))
        .fontColor($r('sys.color.font_primary'))
        .backgroundColor('#FFFFFF')
        .onClick(async () => {
          await this.takePhotoByCamera()
        })
      Divider().strokeWidth('1px').width('100%').color($r('sys.color.comp_divider'))
      Button('从手机相册选择')
        .width('100%')
        .height(48)
        .fontSize($r('sys.float.Body_L'))
        .fontColor($r('sys.color.font_primary'))
        .backgroundColor('#FFFFFF')
        .onClick(async () => {
          await this.pickPhotoFromAlbum()
        })
      Divider().strokeWidth('1px').width('100%').color($r('sys.color.comp_divider'))
      Button('取消')
        .width('100%')
        .height(48)
        .fontSize($r('sys.float.Body_L'))
        .fontColor($r('sys.color.font_tertiary'))
        .backgroundColor('#FFFFFF')
        .onClick(() => {
          this.showAvatarSheet = false
        })
    }
    .width('100%')
    .padding({
      left: 0,
      right: 0,
      top: 8,
      bottom: 8
    })
    .backgroundColor($r('sys.color.background_primary'))
  }

  @Builder
  genderSheetBuilder() {
    Column() {
      Button('男')
        .width('100%')
        .height(48)
        .fontSize($r('sys.float.Body_L'))
        .fontColor($r('sys.color.font_emphasize'))
        .backgroundColor('#FFFFFF')
        .onClick(() => {
          this.tempGender = '男'
          this.showGenderSheet = false
        })
      Divider().strokeWidth('1px').width('100%').color($r('sys.color.comp_divider'))
      Button('女')
        .width('100%')
        .height(48)
        .fontSize($r('sys.float.Body_L'))

        .fontColor($r('sys.color.font_emphasize'))
        .backgroundColor('#FFFFFF')
        .onClick(() => {
          this.tempGender = '女'
          this.showGenderSheet = false
        })
      Divider().strokeWidth('1px').width('100%').color($r('sys.color.comp_divider'))
      Button('取消')
        .width('100%')
        .height(48)
        .fontSize($r('sys.float.Body_L'))
        .fontColor($r('sys.color.font_tertiary'))
        .backgroundColor('#FFFFFF')
        .onClick(() => {
          this.showGenderSheet = false
        })
    }
    .width('100%')
    .padding({
      left: 0,
      right: 0,
      top: 8,
      bottom: 8
    })
    .backgroundColor($r('sys.color.background_primary'))
  }

  async pickPhotoFromAlbum(): Promise<void> {
    try {
      const uris: string[] = await this.pickImageLocal(1)
      if (uris && uris.length > 0) {
        const abilityCtx: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext
        let url: string = uris[0]
        let file: fs.File | null = null
        try {
          file = fs.openSync(url, fs.OpenMode.READ_ONLY)
          const newPath: string = abilityCtx.cacheDir + '/' + util.generateRandomUUID(false) + '.png'
          fs.copyFileSync(file.fd, newPath)
          url = 'file://' + newPath
        } finally {
          if (file) {
            fs.closeSync(file)
          }
        }
        this.personal.setAvatar(url as ResourceStr)
        this.showAvatarSheet = false
      }
    } catch (e) {
      this.getUIContext().getPromptAction().showToast({ message: '选择失败' })
    }
  }

  async takePhotoByCamera(): Promise<void> {
    try {
      // 使用CameraPicker直接调用相机拍照
      const abilityCtx: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext
      const pathDir = abilityCtx.filesDir
      const fileName = `avatar_${new Date().getTime()}.jpg`
      const filePath = pathDir + '/' + fileName

      // 创建临时文件
      fs.createRandomAccessFileSync(filePath, fs.OpenMode.CREATE)
      const uri = fileUri.getUriFromPath(filePath)

      // 配置相机选择器
      const pickerProfile: cameraPicker.PickerProfile = {
        cameraPosition: camera.CameraPosition.CAMERA_POSITION_FRONT, // 使用前置摄像头（适合拍摄头像）
        saveUri: uri
      }

      // 调用相机拍照
      const result: cameraPicker.PickerResult = await cameraPicker.pick(
        getContext(),
        [cameraPicker.PickerMediaType.PHOTO],
        pickerProfile
      )

      if (result.resultCode === 0 && result.mediaType === cameraPicker.PickerMediaType.PHOTO) {
        let url: string = result.resultUri
        let file: fs.File | null = null
        let arrayBuffer: ArrayBuffer

        try {
          file = fs.openSync(url, fs.OpenMode.READ_ONLY)
          const stat = fs.statSync(file.fd)
          arrayBuffer = new ArrayBuffer(stat.size)
          fs.readSync(file.fd, arrayBuffer)
        } finally {
          if (file) {
            fs.closeSync(file)
          }
        }
        this.personal.setAvatar(url as ResourceStr)
        this.showAvatarSheet = false
      }
    } catch (e) {
      this.getUIContext().getPromptAction().showToast({ message: '调用相机失败' })
    }
  }

  async takePhotoByCameras(): Promise<void> {
    try {
      // 使用系统图片选择器，用户可在选择器内选择拍照
      const uris: string[] = await this.pickImageLocal(1)
      if (uris && uris.length > 0) {
        const abilityCtx: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext
        let url: string = uris[0]
        let file: fs.File | null = null
        try {
          file = fs.openSync(url, fs.OpenMode.READ_ONLY)
          const newPath: string = abilityCtx.cacheDir + '/' + util.generateRandomUUID(false) + '.jpg'
          fs.copyFileSync(file.fd, newPath)
          url = 'file://' + newPath
        } finally {
          if (file) {
            fs.closeSync(file)
          }
        }
        this.personal.setAvatar(url as ResourceStr)
        this.showAvatarSheet = false
      }
    } catch (e) {
      this.getUIContext().getPromptAction().showToast({ message: '拍摄失败' })
    }
  }

  async pickImageLocal(maxSelectNumber: number, preselectedUris?: Array<string>): Promise<Array<string>> {
    const options: photoAccessHelper.PhotoSelectOptions = {
      isEditSupported: true,
      isOriginalSupported: true,
      completeButtonText: photoAccessHelper.CompleteButtonText.TEXT_DONE,
      MIMEType: photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE,
      maxSelectNumber: maxSelectNumber,
      isPreviewForSingleSelectionSupported: true,
      preselectedUris: preselectedUris
    }
    const picker: photoAccessHelper.PhotoViewPicker = new photoAccessHelper.PhotoViewPicker()
    try {
      const result: photoAccessHelper.PhotoSelectResult = await picker.select(options)
      return result.photoUris
    } catch (_) {
      return []
    }
  }

  // 检查是否有未保存的修改
  hasUnsavedChanges(): boolean {
    const currentData = JSON.stringify({
      name: this.tempName,
      age: this.tempAge,
      gender: this.tempGender,
      avatar: this.personal.data.avatarUrl,
      workStartDate: this.tempWorkStartDate,
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

