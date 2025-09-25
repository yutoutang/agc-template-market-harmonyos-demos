import { AppStorageV2, PersistenceV2, promptAction, router } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import {
  AvoidArea,
  UserContactInfo,
  CommonConstants,
  DeliveryDatabase,
  DeliveryRecord,
  JobListItem,
  LeftReturnComponent,
  Logger,
  promptFun,
  SearchType,
  TitleBar,
  BreakPointController,
} from '@ohos_agcit/common_component';
import { picker } from '@kit.CoreFileKit';
import { AttachmentDatabase, getCurrentLocalDate, FileDataSource, ResumeEntity } from 'file_management';

const TAG: string = 'AttachUpload';
let addressList: SearchType[] = CommonConstants.ADDRESS_COLLECTION;
let addressMap: Map<number, SearchType> = new Map<number, SearchType>(
  addressList.map(item => [item.index, item])
);

@Entry
@ComponentV2
export struct JobDelivery {
  private breakPointController: BreakPointController = BreakPointController.instance
  @Local jobInfo: ESObject = router.getParams();
  @Local name: string = '';
  @Local email: string = '';
  @Local telephoneNumber: string = '';
  @Local avoidArea: AvoidArea = AppStorageV2.connect(AvoidArea, () => new AvoidArea(0, 0))!;
  @Local userContactInfo: UserContactInfo =
    PersistenceV2.connect(UserContactInfo, () => new UserContactInfo('', '', ''))!;
  @Local deliveryDatabase: DeliveryDatabase =
    PersistenceV2.connect(DeliveryDatabase, () => new DeliveryDatabase())!;
  @Local attachmentDatabase: AttachmentDatabase =
    PersistenceV2.connect(AttachmentDatabase, () => new AttachmentDatabase())!;
  @Local attachmentLazyList: FileDataSource<ResumeEntity> = new FileDataSource();
  @Local isHalfShow: boolean = false;
  @Local isFullShow: boolean = false;
  @Local resumeUri: string = '';
  @Local resumeName: string = '';
  @Local isDelivery: boolean = this.deliveryDatabase.deliveryList.some(record => record.jobId === this.jobInfo.id)

  aboutToAppear(): void {
    this.attachmentLazyList.clear()
    for (let i = 0; i < this.attachmentDatabase.attachmentList.length; i++) {
      this.attachmentLazyList.pushData(this.attachmentDatabase.attachmentList[i])
    }
  }

  build() {
    Column() {
      Column(){
        Scroll(){
          Column(){
            Row() {
              LeftReturnComponent()
                .onClick(() => {
                  router.back();
                });
              TitleBar({ text: '简历投递' });
            }
            .height(56)
            .alignItems(VerticalAlign.Center)
            .width(CommonConstants.FULL_WIDTH)
            .alignItems(VerticalAlign.Center)
            .padding({
              bottom: 8
            })

            Column() {
              Text(this.jobInfo.name)
                .fontSize(16)
                .fontColor('rgba(0,0,0,0.90)')
                .fontWeight(FontWeight.Medium)
              if (this.jobInfo.address) {
                Text(addressMap.get(this.jobInfo.address)?.title + ' · ' + this.jobInfo.jobType)
                  .fontSize(14)
                  .fontColor('rgba(0,0,0,0.60)')
                  .margin({ top: 5 })
              } else {
                Text(this.jobInfo.jobType)
                  .fontSize($r('app.float.font_size_16'))
                  .fontColor($r('app.color.common_gray'))
                  .margin({ top: 5 })
              }
            }
            .borderRadius(16)
            .backgroundColor(Color.White)
            .width('100%')
            .height(64)
            .alignItems(HorizontalAlign.Start)
            .padding({
              top: 11,
              bottom: 11,
              left: 12,
              right: 12
            })

            Text('应聘者信息')
              .fontSize($r('app.float.font_size_14'))
              .fontColor($r('app.color.common_gray'))
              .fontWeight(CommonConstants.FONT_WEIGHT_600)
              .alignSelf(ItemAlign.Start)
              .height(64)
              .width('100%')

            // message input
            Column() {
              this.MessageInput('姓名', ContentType.USER_NAME, this.userContactInfo.realName, (val: string) => {
                this.name = val;
                this.userContactInfo.realName = val
              })
              Divider()
                .strokeWidth('1px')
                .color($r('sys.color.comp_divider'))
                .opacity(0.2)

              this.MessageInput('手机号码', ContentType.PHONE_NUMBER, this.userContactInfo.phoneNumber, (val: string) => {
                this.telephoneNumber = val;
                this.userContactInfo.phoneNumber = val
              })
              Divider().strokeWidth('1px').color($r('sys.color.comp_divider')).opacity(0.2)

              this.MessageInput('邮箱', ContentType.EMAIL_ADDRESS, this.userContactInfo.email, (val: string) => {
                this.email = val;
                this.userContactInfo.email = val
              })
            }
            .padding({top: 4, bottom: 4, left: '5%', right: '5%'})
            .borderRadius(16)
            .backgroundColor(Color.White)
            .width('100%')
            .height(152)

            // resume
            Column() {
              Row() {
                Text() {
                  Span('简历')
                    .fontColor(Color.Black)
                  Span('*')
                    .fontColor(Color.Red)
                }
                .fontWeight(FontWeight.Medium)
                .fontSize(16)

                Blank()

                Text($r('app.string.upload_attachment'))
                  .fontColor($r('app.color.common_blue'))
                  .fontSize(14)
                  .onClick(() => {
                    this.isHalfShow = !this.isHalfShow
                  })
              }
              .width('100%')

              Text('文件大小不超过50M; 支持格式为pdf')
                .fontColor($r('app.color.common_gray'))
                .fontSize($r('app.float.font_size_13'))
                .opacity(0.6)
                .margin({ top: 13 })
                .width('100%')

              if (this.resumeName !== '') {
                Row(){
                  Text(this.resumeName)
                    .fontColor('rgba(0,0,0,0.90)')
                    .fontSize(14)

                  Blank()

                  Image($r('app.media.trash'))
                    .width(16)
                    .height(16)
                    .onClick(() => {
                      let record = this.deliveryDatabase.deliveryList.
                      find((record) => record.jobId === this.jobInfo.id);
                      if (record) {
                        this.deliveryDatabase.deliveryList.splice(
                          this.deliveryDatabase.deliveryList.indexOf(record), 1)
                      }
                      this.resumeUri = '';
                      this.resumeName = '';
                      this.isDelivery = false;
                    })
                }
                .width('100%')
                .margin({ top: 15 })
              }
            }
            .alignItems(HorizontalAlign.Start)
            .width('100%')
            .height(this.resumeName === '' ? 75 : 105)
            .borderRadius(16)
            .backgroundColor(Color.White)
            .margin({ top: 12 })
            .padding({
              top: 14,
              left: 12,
              right: 12,
              bottom: 14
            })
          }
        }
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
      .width('100%')
      .layoutWeight(1)

      Blank()

      Button(this.isDelivery ? '已投递' : '简历投递')
        .fontSize($r('sys.float.Body_L'))
        .backgroundColor($r('app.color.common_blue'))
        .width('100%')
        .height(39)
        .onClick(() => {
          if (this.isDelivery) {
            promptFun('您已投递，请勿重复投递', 1000)
          } else {
            if (this.name === '' || this.telephoneNumber === '' || this.email === '' || this.resumeUri.length === 0) {
              promptFun('请填写个人信息以及上传简历附件', 1000)
            } else {
              let deliveryRecord: DeliveryRecord = new DeliveryRecord()
              deliveryRecord.jobId = this.jobInfo.id
              deliveryRecord.submitTime = getCurrentLocalDate()
              this.deliveryDatabase.deliveryList.push(deliveryRecord)
              this.isDelivery = this.deliveryDatabase.deliveryList.some(record => record.jobId === this.jobInfo.id)
              promptFun('投递简历成功', 1000)
              router.back();
            }
          }
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.common_background'))
    .bindSheet($$this.isHalfShow, this.UploadHalfSheetBuilder(), {
      height: '20%',
    })
    .bindContentCover($$this.isFullShow, this.AttachmentFullSheetBuilder(), {})
    .padding({
      top: px2vp(this.avoidArea.topRectHeight),
      bottom: px2vp(this.avoidArea.bottomRectHeight),
      left: '4%',
      right: '4%'
    })
  }

  @Builder
  MessageInput(title: string,contentType:ContentType, content:string, invoke: (val: string) => void) {
    Row() {
      Text() {
        Span(title)
          .fontColor(Color.Black)
        Span('*')
          .fontColor(Color.Red)
      }
      .fontWeight(FontWeight.Medium)
      .fontSize(16)
      .width('28%')
      .height('100%')

      Blank();

      Column() {
        TextInput({ placeholder: '请输入（必填）', text:content})
          .placeholderFont({ size: $r('sys.float.Body_L') })
          .placeholderColor($r('sys.color.font_secondary'))
          .layoutWeight(1)
          .contentType(contentType)
          .backgroundColor(Color.Transparent)
          .fontSize($r('app.float.font_size_16'))
          .textAlign(TextAlign.End)
          .width('100%')
          .onChange((val: string) => {
            invoke(val)
            content = val
          })
          .onEditChange((isEditing: boolean) => {
            if (!isEditing) {
              if (title === '手机号码') {
                let isPhoneNumber = /^1[3-9]\d{9}$/.test(content);
                if (!isPhoneNumber) {
                  promptAction.showToast({ message: '手机号码不正确。' });
                }
              }
              if (title === '邮箱') {
                let isEmail =  /^([a-zA-Z0-9_\.\-])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z]{2,4})+$/.test(content);
                if (!isEmail) {
                  promptAction.showToast({ message: '邮箱格式不正确。' });
                }
              }
            }
          })
        ;
      }
      .width('66%');
    }
    .alignItems(VerticalAlign.Center)
    .height(48)
    .width('100%')
  }

  @Builder
  UploadHalfSheetBuilder() {
    Column() {
      Row() {
        Button($r('app.string.upload_from_local'))
          .fontSize($r('sys.float.Body_L'))
          .height('40%')
          .width('60%')
          .fontColor($r('sys.color.font_emphasize'))
          .stateEffect(false)
          .backgroundColor(Color.Transparent)
      }
      .onClick(() => {
        this.isHalfShow = !this.isHalfShow
        try {
          let documentPicker = new picker.DocumentViewPicker(getContext());
          documentPicker
            .select({
              maxSelectNumber: 1,
              fileSuffixFilters: ['文档|.pdf'],
            })
            .then((documentSelectResult: Array<string>) => {
              console.info('DocumentViewPicker.select successfully, uri: ' + JSON.stringify(documentSelectResult));
              let uri: string = documentSelectResult[0];

              let fileArray = uri.split('/');
              let fileName = fileArray[fileArray.length - 1]
              this.resumeName = decodeURIComponent(fileName)
              this.resumeUri = uri
            })
            .catch((err: BusinessError) => {
              Logger.error(TAG, `'DocumentViewPicker.select failed with err: ${JSON.stringify(err)}`);
            });
        } catch (err) {
          Logger.error(TAG, `'DocumentViewPicker failed with err: ${JSON.stringify(err)}`);
        }
      })

      Row() {
        Button($r('app.string.upload_from_management'))
          .fontSize($r('sys.float.Body_L'))
          .height('40%')
          .width('60%')
          .fontColor($r('sys.color.font_emphasize'))
          .stateEffect(false)
          .backgroundColor(Color.Transparent)
      }
      .onClick(() => {
        this.isFullShow = !this.isFullShow
        this.isHalfShow = !this.isHalfShow
      })
    }
    .justifyContent(FlexAlign.SpaceAround)
  }

  @Builder
  AttachmentFullSheetBuilder() {
    Column() {
      Column() {
        Row() {
          LeftReturnComponent()
            .onClick(() => {
              router.back();
            });
          TitleBar({ text: '简历管理' });
        }
        .height(56)
        .alignItems(VerticalAlign.Center)
        .width(CommonConstants.FULL_WIDTH)
        .alignItems(VerticalAlign.Center);
      }
      .padding({
        top: px2vp(this.avoidArea.topRectHeight),
        left: '6%',
        right: '6%'
      })
      .height('10%')
      .width('100%')
      .justifyContent(FlexAlign.Start)

      Column() {
        LazyForEach(this.attachmentLazyList, (item: ResumeEntity, index: number) => {
          Row() {
            Image($r('app.media.file_pdf'))
              .height(70)
              .width(70)

            Column() {
              Text(item.name + item.suffix)
                .fontWeight(FontWeight.Medium)
                .width('70%')
              Row() {
                Text(item.size)
                  .fontSize($r('app.float.font_size_12'))
                  .fontColor($r('app.color.common_gray_light'))
                Text('  ')
                Text('更新于')
                  .fontSize($r('app.float.font_size_12'))
                  .fontColor($r('app.color.common_gray_light'))
                Text(item.updateTime)
                  .fontSize($r('app.float.font_size_12'))
                  .fontColor($r('app.color.common_gray_light'))
              }
              .margin({ top: 5 })
            }
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Start)
            .height('100%')
          }
          .height(80)
          .borderRadius(20)
          .backgroundColor(Color.White)
          .margin({ top: '3.5%' })
          .onClick(() => {
            this.resumeUri = item.uri
            this.resumeName = decodeURIComponent(item.name + item.suffix)
            this.isFullShow = !this.isFullShow
          })
        })
      }
      .height('40%')
      .width('100%')
      .padding({ top: '5%' })
    }
    .backgroundColor($r('app.color.common_background'))
    .justifyContent(FlexAlign.Start)
    .height('100%')
    .width('100%')
  }
}