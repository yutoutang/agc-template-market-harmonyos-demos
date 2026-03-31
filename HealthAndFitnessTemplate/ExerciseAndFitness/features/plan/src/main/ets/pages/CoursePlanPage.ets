import { AdvancedCourse, HotCourse } from 'course';
import { ADVANCED_COURSE_DATA, Course, HOT_COURSE_DATA, RouterMap, RouterUtils } from 'lib_common';
import { NavHeaderBar } from 'lib_widget';

@Builder
export function CoursePlanPageBuilder() {
  CoursePlanPage()
}

@ComponentV2
struct CoursePlanPage {
  scroller: Scroller = new Scroller()
  @Local courseList: Course[] = [
    ...HOT_COURSE_DATA,
    ...ADVANCED_COURSE_DATA,
  ]
  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({
          title: '课程',
        })

        Scroll(this.scroller) {
          Column() {
            HotCourse({
              detailList: this.courseList
            })
          }
          .width('100%')
          .backgroundColor(Color.White)
          .borderRadius(16)
          .padding({ left: 12, right: 12 })
        }
        .layoutWeight(1)
        .align(Alignment.Top)
        .scrollBar(BarState.Off)
        .scrollable(ScrollDirection.Vertical)
        .edgeEffect(EdgeEffect.Spring)
        .margin({ bottom: 30 })
        .width('100%')
        .padding({ left: 12, right: 12 })
      }
      .height('100%')
      .backgroundColor($r('app.color.course_background'))
    }
    .hideTitleBar(true)
  }
}
