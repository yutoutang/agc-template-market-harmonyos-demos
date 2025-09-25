import { filePreview } from '@kit.PreviewKit';
import { fileIo as fs, fileUri } from '@kit.CoreFileKit';
import { ResumeEntity } from '../../../../Index';
import { getCurrentLocalTime } from '../utils/DateUtil';
import { BusinessError } from '@kit.BasicServicesKit';

@ComponentV2
export struct ResumeComponent {
  @Param @Require resume: ResumeEntity;
  @Event remove: () => void = () => {
  };
  @Local isHalfShow: boolean = false;
  @Local isFullShow: boolean = false;
  @Local newResumeName: string = '';
  context: Context = getContext();
  displayInfo: filePreview.DisplayInfo = {
    x: 100,
    y: 100,
    width: 800,
    height: 800,
  };
  private fileImage: ResourceStr = '';
  private mineType: string = '';

  aboutToAppear(): void {
    this.initData();
  }

  build() {
    Row() {
      Row() {
        Image(this.fileImage)
          .height(40)
          .width(60)
          .padding({
            left: 12,
            right: 12
          })

        Column() {
          Text(this.resume.name + this.resume.suffix)
            .fontWeight(FontWeight.Medium)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('70%');
          Row() {
            Text(this.resume.size)
              .fontSize('12vp')
              .fontColor('#999999');
            Text('  ');
            Text('更新于')
              .fontSize('12vp')
              .fontColor('#999999');
            Text(this.resume.updateTime)
              .fontSize('12vp')
              .fontColor('#999999');
          }
          .margin({ top: 5 });
        }
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Start)
        .height('100%')
        .onClick(async () => {
          // sandbox path to uri
          let uri = fileUri.getUriFromPath(this.resume.uri);

          let fileInfo: filePreview.PreviewInfo = {
            title: this.resume.name,
            uri: uri,
            mimeType: this.mineType,
          };

          filePreview.openPreview(getContext(this), fileInfo, this.displayInfo).then(() => {
            console.info('Succeeded in opening preview');
          }).catch((err: BusinessError) => {
            console.error(`Failed to open preview, err.code = ${err.code}, err.message = ${err.message}`);
          });
        });
      }
      .height('100%')
      .justifyContent(FlexAlign.Start)
      .alignItems(VerticalAlign.Center);

      Blank();

      Image($r('app.media.ic_three_point'))
        .height(20)
        .width(20)
        .margin({ right: 15 })
        .onClick(() => {
          this.isHalfShow = !this.isHalfShow;
        })
        .bindSheet($$this.isHalfShow, this.MySelectBuilder(), {
          height: 180,
          showClose: false
        });
    }
    .padding({ right: 10 })
    .alignItems(VerticalAlign.Center)
    .bindContentCover($$this.isFullShow, this.MyRenameBuilder(), {})
    .borderRadius(20)
    .backgroundColor(Color.White)
    .width('100%')
    .height('100%');
  }

  @Builder
  MySelectBuilder() {
    Column() {
      Row() {
        Button('重命名')
          .fontSize($r('sys.float.Body_L'))
          .height('35%')
          .width(180)
          .fontColor($r('sys.color.font_emphasize'))
          .stateEffect(false)
          .backgroundColor(Color.Transparent);
      }
      .onClick(() => {
        this.isHalfShow = !this.isHalfShow;
        this.isFullShow = !this.isFullShow;
      });

      Row() {
        Button('删除')
          .fontSize($r('sys.float.Body_L'))
          .height('25%')
          .width(180)
          .fontColor($r('sys.color.warning'))
          .stateEffect(false)
          .backgroundColor(Color.Transparent);
      }
      .onClick(() => {
        fs.unlinkSync(this.resume.uri);
        this.remove();
      });

      Row() {
        Button('取消')
          .fontSize($r('sys.float.Body_L'))
          .height('35%')
          .width(180)
          .fontColor($r('sys.color.font_emphasize'))
          .stateEffect(false)
          .backgroundColor(Color.Transparent);
      }
      .onClick(() => {
        this.isHalfShow = false;
      });
    }
    .width('80%')
    // .justifyContent(FlexAlign.SpaceBetween)
    // .align(Alignment.Center)
  }

  @Builder
  MyRenameBuilder() {
    Column() {

      Row(){
        Row(){
          SymbolGlyph($r('sys.symbol.chevron_left'))
            .fontSize(30)
        }
        .padding({left: 12})
        .width(40)
        .height(40)
        .borderRadius(100)
        .backgroundColor('#E6E8E9')
        .margin({ right: 10 })
        .onClick(() => {
          this.isFullShow = false;
        })
      }
      .margin({ top: 20 })
      .width('100%')
      .justifyContent(FlexAlign.Start)


      Column() {
        Text('简历重命名')
          .fontSize('18vp')
          .fontWeight(FontWeight.Bold)
          .width('100%')
          .margin({ top: 40 });
        Text('命名规范建议：姓名-应聘岗位-工作经验')
          .fontSize('16vp')
          .fontWeight(FontWeight.Regular)
          .fontColor('#999999')
          .width('100%')
          .margin({ top: 15, left: 3 });
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start);


      Row() {
        TextInput({ text: this.resume.name })
          .type(InputType.Normal)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .backgroundColor(Color.Transparent)
          .textAlign(TextAlign.Start)
          .border({ width: 0 })
          .borderRadius(0)
          .onChange((input: string) => {
            this.newResumeName = input;
          })
          .width('100%')
          .height('100%')
          .maxLength(36)
          .placeholderColor($r('sys.color.font_secondary'))
          .placeholderFont({ size: $r('sys.float.Body_L'), weight: 400 })
          .showUnderline(true)
          .showCounter(true,
            { thresholdPercentage: 1, highlightBorder: true });
      }
      .margin({ top: 30, bottom: -20 })
      // .height('6%')
      .height(48)
      .alignItems(VerticalAlign.Center);

      Blank();

      Button('保存')
        .width('100%')
        .margin({ bottom: 30 })
        .backgroundColor('#376BFC')
        .onClick(() => {
          // do rename operation
          this.resume.name = this.newResumeName;
          this.resume.updateTime = getCurrentLocalTime();
          this.isFullShow = !this.isFullShow;
        });
    }
    .backgroundColor('#F1F3F5')
    .justifyContent(FlexAlign.Start)
    .padding({
      left: '4%',
      right: '4%',
      top: 20,
      bottom: 10,
    })
    .height('100%')
    .width('100%');
  }

  initData() {
    switch (this.resume.suffix) {
      case '.pdf': {
        this.fileImage = $r('app.media.file_pdf');
        this.mineType = 'application/pdf';
        break;
      }
      case '.txt': {
        this.fileImage = $r('app.media.file_txt');
        this.mineType = 'text/plain';
        break;
      }
      case '.doc': {
        this.fileImage = $r('app.media.file_word');
        this.mineType = 'application/msword';
        break;
      }
      case '.docx': {
        this.fileImage = $r('app.media.file_word');
        this.mineType = 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
        break;
      }

      case '.xls': {
        this.fileImage = $r('app.media.file_excel');
        this.mineType = 'application/vnd.ms-excel';
        break;
      }
      case '.xlsx': {
        this.fileImage = $r('app.media.file_excel');
        this.mineType = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
        break;
      }
      case '.ppt': {
        this.fileImage = $r('app.media.file_ppt');
        this.mineType = 'application/vnd.ms-powerpoint';
        break;
      }
      case '.pptx': {
        this.fileImage = $r('app.media.file_ppt');
        this.mineType = 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
        break;
      }
      default: {
        break;
      }
    }
  }
}
