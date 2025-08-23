import { image } from '@kit.ImageKit';
import { generateBarcode, scanCore } from '@kit.ScanKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { LengthMetrics, promptAction } from '@kit.ArkUI';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import fs from '@ohos.file.fs';
import { UserInfoDetail } from '../viewModel/UserModel';
import { MyConfig } from '../constants/MyConfig';
import { seminarContactsGet } from '../api/serviceLogin';
import dayjs from 'dayjs';

const ticketInfoMap: Record<string, string> = {
  'VIP票': '1',
  '专家票': '2',
  '全通票': '3',
  '单日票': '4',
  '学生票': '5',
  '双日票': '6',
  '员工票': '3',
}
const ticketInfoColorMap: Record<string, string[]> = {
  'VIP票': ['#33F2403D', '#FFF2403D'],
  '专家票': ['#33FFE59C', '#FFFFBD00'],
  '全通票': ['#3395E1FF', '#FF153AD1'],
  '单日票': ['#33ABE66C', '#FF47C95C'],
  '学生票': ['#33DE88F1', '#FF972EC3'],
  '双日票': ['#33FD96D3', '#FFE41891'],
  '员工票': ['#3395E1FF', '#FF153AD1'],
}

// 跳转页面入口函数
@Builder
export function TicketBuilder() {
  Ticket()
}

@Component
export struct Ticket {
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0;
  @StorageProp('topRectHeight') topRectHeight: number = 0;
  @Consume('pageStack') pageStack: NavPathStack
  @StorageProp('currentBreakpoint') currentBreakpoint: string = 'sm'
  @State pixelMap: image.PixelMap | undefined = undefined
  @StorageLink('userInfo') userInfo: UserInfoDetail = new UserInfoDetail()
  @StorageProp('token') token: string = '';
  @StorageProp('deviceId') deviceId: string = '';
  @State roleIndex: string = '3'
  @State roleColor: string[] = []
  @State roleDate: string[] = []

  //保存图片
  async saveImage(pixelMap: PixelMap) {
    const packOptions: image.PackingOption = {
      format: 'image/jpeg',
      quality: 100
    }
    image.createImagePacker().packToData(pixelMap, packOptions).then(async (buffer: ArrayBuffer) => {
      let file: fs.File = null!;
      try {
        const context = this.getUIContext().getHostContext()!
        let helper = photoAccessHelper.getPhotoAccessHelper(context)
        // onClick触发后10秒内通过createAsset接口创建图片文件，10秒后createAsset权限收回。
        let uri = await helper.createAsset(photoAccessHelper.PhotoType.IMAGE, 'jpg')
        file = await fs.open(uri, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE)
        await fs.write(file.fd, buffer);
        this.getUIContext().getPromptAction().showToast({ message: '保存成功' })
      } catch (error) {
        this.getUIContext().getPromptAction().showToast({ message: '保存失败' })
      } finally {
        fs.close(file.fd);
      }

    }).catch((error: BusinessError) => {
      this.getUIContext().getPromptAction().showToast({ message: '保存失败' })
    })
  }

  aboutToAppear() {
    // 获取报名信息
    if (this.token) {
      if (this.userInfo.ticketId) {
        this.createQrcode()
        this.filterTicket()
        return
      }
      seminarContactsGet({
        token: this.token,
      }).then((res) => {
        this.userInfo = res.data as UserInfoDetail;
        this.createQrcode()
        this.filterTicket()
      })
    }
  }

  filterTicket() {
    this.roleIndex = ticketInfoMap[this.userInfo.ticketTypeName as string] || '3'
    this.roleColor = ticketInfoColorMap[this.userInfo.ticketTypeName as string] || ['#3395E1FF', '#FF153AD1']
    let meetDay = this.userInfo.meetDay as string[]
    this.roleDate.push(dayjs(meetDay[0]).format('MM/DD'))
    if (meetDay.length > 1) {
      this.roleDate.push(dayjs(meetDay[meetDay.length-1]).format('MM/DD'))
    }
  }

  createQrcode() {
    // 以QR码为例，码图生成参数
    this.pixelMap = undefined;
    let content: string = this.userInfo.ticketId as string;
    let options: generateBarcode.CreateOptions = {
      scanType: scanCore.ScanType.QR_CODE,
      height: 400,
      width: 400
    }
    try {
      // 码图生成接口，成功返回PixelMap格式图片
      generateBarcode.createBarcode(content, options).then((pixelMap: image.PixelMap) => {
        this.pixelMap = pixelMap;
      }).catch((error: BusinessError) => {
        hilog.error(0x0001, '[generateBarcode]',
          `Failed to get PixelMap by promise with options. Code: ${error.code}, message: ${error.message}`);
      })
    } catch (error) {
      hilog.error(0x0001, '[generateBarcode]',
        `Failed to createBarcode by promise with options. Code: ${error.code}, message: ${error.message}`);
    }
  }


  @Builder
  TicketCard() {
    Column() {
      Stack(){
        Image(MyConfig.URL+ 'home2%2Fbg_vip_card.png?token=2c9b8bef-9584-4d3f-83ee-c96c2f58d1d6')
          .width('100%')
          .height(64)
          .borderRadius({topLeft: 16, topRight: 16})

        Row({ space: 10 }){
          Image(MyConfig.URL + 'home2%2Fic_public_equity.png?token=447bef99-fc98-44cf-950a-e4ec91001ef6')
            .width(24)
            .height(24)
          Text('VIP票')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('sys.color.font_on_primary'))
        }
      }

      // 获取生成码后显示
      if (this.pixelMap) {
        Row(){
          Image(this.pixelMap).width(160).height(160)
        }
        .justifyContent(FlexAlign.Center)
        .height(272)
        .width('100%')
        .backgroundColor(Color.White)
      }

      Stack({alignContent: Alignment.Top}){
        Image(MyConfig.URL + 'upload%2Fbg_vip_card_bottom.png?token=eb2e5733-6b06-4b1d-8b79-1c75fbb0dbfc')
          .width('100%')
          .height(104)

        Column({ space: 12 }){
          Row(){
            Image(MyConfig.URL + 'home_new%2Fticket_date.png?token=03e2736e-ab63-4063-9092-e23f25a317c2')
              .width(20)
              .height(16)
              .padding({ right: 5 })
            Text('会议日期')
              .fontSize(14)
              .fontColor($r('sys.color.font_primary'))
            Blank()
            Text('09/26—09/28')
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('sys.color.font_primary'))
          }
          .width('100%')

          Row(){
            Image(MyConfig.URL + 'home_new%2Fticket_addr.png?token=7f180f75-cc90-4a40-826a-ee3d76375ad8')
              .width(20)
              .height(16)
              .padding({ right: 5 })
            Text('会议地点')
              .fontSize(14)
              .fontColor($r('sys.color.font_primary'))
            Blank()
            Text('中国·广东')
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('sys.color.font_primary'))
          }
          .width('100%')
        }
        .padding({ top: 24, left: 24, right: 24 })
      }
      .height(104)
      .backgroundColor(Color.White)
      .borderRadius({bottomLeft: 16, bottomRight: 16})
    }
    .margin({
      top: 12
    })
    .height(440)
    .width('100%')
    .backgroundColor('#F1F3F5')
  }

  build() {
    NavDestination() {
      Column() {

        Scroll(){
          Column(){
            this.TicketCard()

            Blank()
              .layoutWeight(1)
            Row() {
              SaveButton({
                icon: SaveIconStyle.FULL_FILLED,
                text: SaveDescription.SAVE_TO_GALLERY,
                buttonType: ButtonType.Capsule
              })
                .fontSize(14)
                .width(150)
                .height(40)
                .backgroundColor('#F2403D')
                .onClick(async (event: ClickEvent, result: SaveButtonOnClickResult) => {
                  if (result === SaveButtonOnClickResult.SUCCESS) {
                    try {
                      let pb: CustomBuilder = (): void => { this.TicketCard() };
                      this.getUIContext().getComponentSnapshot()
                        .createFromBuilder(pb)
                        .then((pixmap: image.PixelMap) => {
                          if (pixmap) {
                            this.saveImage(pixmap)
                          } else {
                            this.getUIContext().getPromptAction().showToast({ message: '保存失败' })
                          }
                        }).catch((err: Error) => {
                        console.log('error: ' + err)
                      })
                    } catch (error) {
                      this.getUIContext().getPromptAction().showToast({ message: '保存失败' })
                    }
                  } else {
                    this.getUIContext().getPromptAction().showToast({ message: '设置权限失败！' })
                  }
                })
            }
            .margin({bottom: 36})
          }

        }
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)

      }
      .padding({
        left: 16, right: 16
      })
      .width('100%')
      .height('100%')
      .backgroundImagePosition(Alignment.Bottom)
      .backgroundImageSize(ImageSize.FILL)
    }
    .backgroundColor('#F1F3F5')
    .padding({ top: px2vp(this.topRectHeight) })
    .title('我的门票')
  }
}