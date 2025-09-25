import { getInstance, setPathStack } from '../common/CommonRoute';
import { createDirInSandbox } from '../utils/CompressUtil';

@Builder
export function ZipPageBuilder() {
  ZipPage();
}

@ComponentV2
struct ZipPage {
  aboutToAppear(): void {
    createDirInSandbox(this.getUIContext()?.getHostContext()?.filesDir + '/zipDir')
    createDirInSandbox(this.getUIContext()?.getHostContext()?.filesDir + '/unzipDir')
  }

  build() {
    NavDestination() {
      Column() {
        this.titleBuilder('压缩', $r('app.media.compress'), '#D9EAFF', 'CompressPage')
        this.titleBuilder('解压', $r('app.media.decompress'), '#DEFDF8', 'DecompressPage')
      }
      .width('100%')
      .height('100%')
      .padding({ left: 16, right: 16 })
    }
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .backgroundColor($r('sys.color.background_secondary'))
    .title('压缩工具')
    .onReady((ctx) => {
      setPathStack(ctx.pathStack);
    });
  }

  @Builder
  titleBuilder(title: string, img: ResourceStr, bgColor: ResourceColor, router: string) {
    Column() {
      Row() {
        Text(`${title}工具`)
          .fontSize($r('sys.float.Subtitle_L'))
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: 12 })
      }
      .width('100%')

      Row() {
        Row() {
          Row() {
            Image(img)
              .width(21)
              .height(24)
          }
          .width(48)
          .height(48)
          .backgroundColor(bgColor)
          .borderRadius(8)
          .justifyContent(FlexAlign.Center)
          .margin({ right: 12 })

          Text(`${title}文件`)
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Medium)
        }

        Image($r('app.media.chevron_left_circle'))
          .width(24)
          .height(24)
      }
      .width('100%')
      .padding(12)
      .backgroundColor($r('sys.color.background_primary'))
      .borderRadius(16)
      .justifyContent(FlexAlign.SpaceBetween)
      .onClick(() => {
        getInstance().pushPathByName('CompressPage', router)
      })
    }
    .width('100%')
    .margin({ top: 8, bottom: 8 })
  }
}
