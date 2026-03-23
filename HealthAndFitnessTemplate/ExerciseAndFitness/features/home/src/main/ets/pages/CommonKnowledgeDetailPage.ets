import { BreakpointModel, BreakpointNameEnum, CommonContent, COMMON_CONTENT, Course, COURSE_DATA } from 'lib_common';
import { NavHeaderBar } from 'lib_widget';
import { CommonKnowledgePageVM } from '../viewmodels/CommonKnowledgePageVM';
import { AppStorageV2 } from '@kit.ArkUI';

@Builder
export function CommonKnowledgeDetailPageBuilder() {
  CommonKnowledgeDetailPage()
}

@ComponentV2
struct CommonKnowledgeDetailPage {
  scroller: Scroller = new Scroller()
  vm: CommonKnowledgePageVM = new CommonKnowledgePageVM();
  @Local courseId: string = ''
  @Local label: string = ''
  @Local isStar: boolean = AppStorage.get(this.courseId) as boolean
  @Local course: Course = COURSE_DATA[Number(this.courseId) - 1]
  @Local commonContent: CommonContent = COMMON_CONTENT[Number(this.courseId) - 1]
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;

  async aboutToAppear() {
    this.label = COURSE_DATA.find(item => item.id === this.courseId)!.courseTitle
    this.isStar = AppStorage.get(this.courseId) as boolean
    this.vm.addHistory(this.label)
  }

  @Computed
  get imageMargin() {
    if ([BreakpointNameEnum.SM, BreakpointNameEnum.MD].includes(this.breakPointModel.currentBreakpoint)) {
      return 16;
    }
    return 24;
  }

  @Computed
  get imageWidth() {
    if ([BreakpointNameEnum.SM].includes(this.breakPointModel.currentBreakpoint)) {
      return 328;
    }
    if ([BreakpointNameEnum.MD].includes(this.breakPointModel.currentBreakpoint)) {
      return 458;
    }
    return 600;
  }

  @Computed
  get borderMargin() {
    if ([BreakpointNameEnum.SM].includes(this.breakPointModel.currentBreakpoint)) {
      return 16;
    }
    if ([BreakpointNameEnum.MD].includes(this.breakPointModel.currentBreakpoint)) {
      return 24;
    }
    return 32;
  }

  @Builder
  starBuilder() {
    Image(this.isStar ? $r('app.media.star') : $r('app.media.no_star'))
      .width(40)
      .height(40)
      .onClick(() => {
        if (!this.isStar) {
          if (this.vm.saveAction(this.label)) {
            this.isStar = true;
            AppStorage.setOrCreate<boolean>(this.courseId, true)
          }
        } else {
          if (this.vm.deleteAction(this.label)) {
            this.isStar = false;
            AppStorage.setOrCreate<boolean>(this.courseId, false)
          }
        }
      })
  }

  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({
          title: '详情',
          rightPartBuilder: () => {
            this.starBuilder();
          },
        })

        Scroll(this.scroller) {
          Column() {
            Column() {
              Text(this.course?.courseTitle)
                .fontWeight(FontWeight.Medium)
                .fontSize(20)
                .lineHeight(27)
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
            .padding({ bottom: 13 })

            Column() {
              Text(this.course?.description)
                .fontWeight(FontWeight.Medium)
                .fontSize($r('sys.float.Body_L'))
              Flex({ justifyContent: FlexAlign.Center }) {
                Image(this.course.cover)
                  .width(this.imageWidth)
                  .borderRadius(16)
                  .aspectRatio(1.5)
              }
              .width('100%')
              .margin({ top: this.imageMargin, bottom: this.imageMargin })
              Column() {
                Text(this.commonContent.intro)
                  .fontWeight(FontWeight.Medium)
                  .fontSize($r('sys.float.Body_L'))
                Text('')
                  .height(20)
                Text(this.commonContent.contentType)
                  .fontSize($r('sys.float.Body_L'))
                  .fontWeight(FontWeight.Medium)

                ForEach(this.commonContent.content, (content: string) => {
                  Text(content)
                    .fontSize($r('sys.float.Body_L'))
                    .fontWeight(FontWeight.Medium)
                  Text('')
                    .height(20)
                })

                Text(this.commonContent.type)
                  .fontSize($r('sys.float.Body_L'))
                  .fontWeight(FontWeight.Medium)

                ForEach(this.commonContent.advice, (content: string) => {
                  Text(content)
                    .fontSize($r('sys.float.Body_L'))
                    .fontWeight(FontWeight.Medium)
                })
              }
              .alignItems(HorizontalAlign.Start)
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
          }
        }
        .layoutWeight(1)
        .align(Alignment.Top)
        .scrollBar(BarState.Off)
        .scrollable(ScrollDirection.Vertical)
        .edgeEffect(EdgeEffect.Spring)
        .width('100%')
        .padding({ left: this.borderMargin, right: this.borderMargin })
      }
      .height('100%')
      .width('100%')
    }
    .hideTitleBar(true)
    .padding({bottom: 15})
    .backgroundColor($r('app.color.home_background'))
    .onReady((context: NavDestinationContext) => {
      this.courseId = context.pathInfo?.param as string
      this.course = COURSE_DATA.find(item => item.id === this.courseId)!
      this.commonContent = COMMON_CONTENT.find(item => item.id === this.courseId)!
      this.aboutToAppear()
    })
  }
}
