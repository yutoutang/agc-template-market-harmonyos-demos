import { SearchPage } from 'module_search';
import { RouterMap, RouterUtils, UserInfo } from 'lib_common'
import { Course, COURSE_DATA } from 'lib_common';
import { MyScrollModifier } from 'lib_common';
import { AppStorageV2 } from '@kit.ArkUI';
import { NavHeaderBar } from 'lib_widget';

interface HotWordInfo {
  id: string,
  path: RouterMap,
  desc: string
}

@ComponentV2
export struct CourseSearch {
  // 模拟后端数据源
  @Local searchSourceData: string[] = []
  @Local scrollModifier: MyScrollModifier = new MyScrollModifier()
  @Local searchCourse: Course[] = []
  @Local loginUser: UserInfo = AppStorageV2.connect(UserInfo, () => new UserInfo())!
  @Local hotWord: HotWordInfo[] = [
    { id: '0010', path: RouterMap.COURSE_DETAIL_PAGE, desc: '马甲线' },
    { id: '0012', path: RouterMap.COMMON_KNOWLEDGE_DETAIL, desc: 'crossfit' },
    { id: '0001', path: RouterMap.COURSE_DETAIL_PAGE, desc: '背阔肌' },
    { id: '0013', path: RouterMap.COMMON_KNOWLEDGE_DETAIL, desc: '如何握推' },
    { id: '0004', path: RouterMap.COURSE_DETAIL_PAGE, desc: '提高握力的方法' },
    { id: '0015', path: RouterMap.COMMON_KNOWLEDGE_DETAIL, desc: '腰肌劳损' },
  ]
  aboutToAppear(): void {
    // 搜索数据源数据
    this.searchCourse = COURSE_DATA
    this.searchSourceData = this.searchCourse.map((item: Course) => {
      return item.courseTitle;
    })
  }

  @Builder
  hotSearchItem() {
    // 热门搜索
    Column() {
      Row() {
        Text('热门搜索')
          .fontSize(18)
          .lineHeight(24)
          .fontColor('#111111')
          .fontWeight(700)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({
        bottom: 12
      })

      Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
        ForEach(this.hotWord, (word: HotWordInfo) => {
          Text(word.desc)
            .fontSize($r('sys.float.Body_M'))
            .textAlign(TextAlign.Center)
            .fontColor('rgba(0, 0, 0, 0.9)')
            .backgroundColor('rgba(0, 0, 0, 0.05)')
            .borderRadius(14)
            .padding({ left: 8, right: 8, top: 4.5, bottom: 4.5 })
            .margin({ right: 8, bottom: 8 })
            .onClick(() => {
              RouterUtils.pushPathByName(word.path, word.id);
            })
        })
      }
      .width('100%')
    }
    .width('100%')
    .justifyContent(FlexAlign.Start)
    .margin({ top: 28, bottom: 4 })
  }

  @Builder
  recommendCourseBuilder() {
    // 推荐课程
    Column() {
      Row() {
        Image($r('app.media.ic_hot'))
          .width(24)
          .height(24)
        Text('推荐课程')
          .fontSize(18)
          .lineHeight(24)
          .fontColor('#111111')
          .fontWeight(700)
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .margin({
        top: 12,
        bottom: 12
      })

      Row() {
        Text('1. ')
          .fontSize($r('sys.float.Body_M'))
          .lineHeight(24)
          .fontColor($r('sys.color.warning'))
        Text('“你真的会跑步吗？”关于跑步机的正确使用训练...')
          .fontSize($r('sys.float.Body_M'))
          .lineHeight(24)
          .fontColor('#111111')
      }
      .onClick(() => {
        RouterUtils.pushPathByName(RouterMap.COURSE_DETAIL_PAGE, '0003');
      })
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .margin({
        bottom: 12
      })

      Row() {
        Text('2. ')
          .fontSize($r('sys.float.Body_M'))
          .lineHeight(24)
          .fontColor($r('sys.color.warning'))
        Text('一对哑铃练遍全身')
          .fontSize($r('sys.float.Body_M'))
          .lineHeight(24)
          .fontColor('#111111')
      }
      .onClick(() => {
        RouterUtils.pushPathByName(RouterMap.COURSE_DETAIL_PAGE, '0006');
      })
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .margin({
        bottom: 12
      })

      Row() {
        Text('3. ')
          .fontSize($r('sys.float.Body_M'))
          .lineHeight(24)
          .fontColor($r('sys.color.warning'))
        Text('舒缓腰部，促进血液循环')
          .fontSize($r('sys.float.Body_M'))
          .lineHeight(24)
          .fontColor('#111111')
      }
      .onClick(() => {
        RouterUtils.pushPathByName(RouterMap.COURSE_DETAIL_PAGE, '0005');
      })
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .margin({
        bottom: 12
      })

      Row() {
        Text('4. ')
          .fontSize($r('sys.float.Body_M'))
          .lineHeight(24)
          .fontColor('rgba(0, 0, 0, 0.6)')
        Text('暴汗自重力量训练')
          .fontSize($r('sys.float.Body_M'))
          .lineHeight(24)
          .fontColor('#111111')
      }
      .onClick(() => {
        RouterUtils.pushPathByName(RouterMap.COURSE_DETAIL_PAGE, '0004');
      })
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .margin({
        bottom: 12
      })

      Row() {
        Text('5. ')
          .fontSize($r('sys.float.Body_M'))
          .lineHeight(24)
          .fontColor('rgba(0, 0, 0, 0.6)')
        Text('提升核心力量')
          .fontSize($r('sys.float.Body_M'))
          .lineHeight(24)
          .fontColor('#111111')
      }
      .onClick(() => {
        RouterUtils.pushPathByName(RouterMap.COURSE_DETAIL_PAGE, '0010');
      })
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .margin({
        bottom: 12
      })
    }
  }

  build() {
    NavDestination() {
      Column() {
        SearchPage({
          searchSourceData: this.searchSourceData,
          clickSearchResult: (searchData) => {
            let item = this.searchCourse.find(course => course.courseTitle === searchData)
            const knowLedgeIdList = ['0012', '0013', '0014', '0015', '0016', '0017']
            if (item?.id) {
              if (knowLedgeIdList.includes(item.id)) {
                RouterUtils.pushPathByName(RouterMap.COMMON_KNOWLEDGE_DETAIL, item.id);
                return
              }
              RouterUtils.pushPathByName(RouterMap.COURSE_DETAIL_PAGE, item.id);
            }
          },
          back: () => {
            RouterUtils.pop()
          },
        })

        this.hotSearchItem()

        this.recommendCourseBuilder()
      }
      .width('100%')
      .padding({ left: $r('app.float.vp_16'), right: $r('app.float.vp_16') , top: $r('app.float.vp_40') })
      .backgroundColor($r('sys.color.background_primary'))
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    }
    .hideTitleBar(true)
  }
}

@Builder
export function CourseSearchBuilder() {
  CourseSearch();
}