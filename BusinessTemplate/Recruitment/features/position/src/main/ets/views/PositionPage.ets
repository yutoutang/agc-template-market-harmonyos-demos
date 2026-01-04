import { ProtocolRouterParams } from 'aggregated_login';
import { BarVM, PositionCard, PositionInfo, RouterMap } from 'common';
import { phoneRouterControl } from 'oh_router';
import { PositionDetailPageBuilder } from './PositionDetailPage';
import { SearchPageBuilder } from './SearchPage';
import { PositionPageVM } from '../viewmodel/PositionPageVM';
import { CitySelectPageBuilder } from './CitySelectPage';
import { FilterData, FilterPageBuilder } from './FilterPage';

/**
 * @usage: 职位列表主页面，提供职位搜索、筛选和浏览功能。包含搜索入口、筛选标签（推荐/全部/附近）、城市选择、条件筛选和职位列表展示。
 * 主要数据结构包括PositionInfo（职位信息）、PositionPageVM（页面视图模型）、FilterData（筛选数据）。包含if逻辑判断职位列表是否
 * 为空显示空状态。
 * @layout: 页面采用Column垂直布局，顶部为Stack堆叠的搜索栏（带背景图），下方为筛选标签行（推荐/全部/附近+城市+筛选按钮），底部为职位列表。
 * 搜索栏采用Row横向布局，包含搜索图标和提示文字。筛选标签行采用Row布局，左侧为文字标签，右侧为城市选择和筛选按钮。职位列表使用List组件垂直排
 * 列PositionCard。
 * @constraints: 无
 * @domain: 招聘求职
 * @isGen: true
 * @fileType: page
 * @zhName: 职位列表页
 * @subPage: SearchPage,PositionDetailPage,CitySelectPage,FilterPage
 * @component: PositionCard
 * @image: screenshot/position.jpg
 */

@ComponentV2
export struct PositionPage {
  vm: PositionPageVM = new PositionPageVM();

  @Builder
  buildStack() {
    Stack({ alignContent: Alignment.Bottom }) {
      Image($r('app.media.home_top_bg')).width('100%').height('100%')
      // 顶部搜索栏
      Row() {
        Image($r('app.media.search_icon')).width(24)
        Text('职位/公司')
          .fontSize(16)
          .fontColor('#999999')
          .margin({ left: 12 })
          .layoutWeight(1)
      }
      .width('calc(100% - 32vp)')
      .height(40)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#ffffff')
      .borderRadius(20)
      .onClick(() => {
        phoneRouterControl.jumpPage({
          pageName: RouterMap.SEARCH_PAGE,
          builder: wrapBuilder(SearchPageBuilder)
        })
      })
    }.height((40 + BarVM.instance.staBarH) > 84 ? (40 + BarVM.instance.staBarH) : 84)
  }

  @Builder
  buildTag() {
    // 筛选标签
    Row() {
      Text('推荐')
        .fontSize(this.vm.selectedFilter === 0 ? 18 : 16)
        .fontColor(this.vm.selectedFilter === 0 ? '#333333' : '#666666')
        .fontWeight(this.vm.selectedFilter === 0 ? FontWeight.Bold : FontWeight.Normal)
        .onClick(() => {
          this.vm.selectedFilter = 0
          this.vm.initPositionList()
        })

      Text('全部')
        .fontSize(this.vm.selectedFilter === 1 ? 18 : 16)
        .fontColor(this.vm.selectedFilter === 1 ? '#333333' : '#666666')
        .fontWeight(this.vm.selectedFilter === 1 ? FontWeight.Bold : FontWeight.Normal)
        .margin({ left: 24 })
        .onClick(() => {
          this.vm.selectedFilter = 1
          this.vm.initPositionList()
        })

      Text('附近')
        .fontSize(this.vm.selectedFilter === 2 ? 18 : 16)
        .fontColor(this.vm.selectedFilter === 2 ? '#333333' : '#666666')
        .fontWeight(this.vm.selectedFilter === 2 ? FontWeight.Bold : FontWeight.Normal)
        .margin({ left: 24 })
        .onClick(() => {
          this.vm.selectedFilter = 2;
          this.vm.getCurrentLocation();
        })

      Blank()

      Row() {
        Text(this.vm.selectedCity)
          .fontSize(14)
          .fontColor(this.vm.selectedCity === '城市' ? '#666666' : 'rgba(86, 74, 247, 1)')
          .textOverflow({
            overflow: TextOverflow.Ellipsis
          })
          .maxLines(1)
          .constraintSize({
            maxWidth: 100
          })
        Image(this.vm.selectedCity === '城市' ? $r('app.media.filter_icon') : $r('app.media.filter_selected_icon'))
          .width(4)
          .height(4)
          .position({
            right: -8,
            bottom: -2
          })
      }
      .padding({
        left: 12,
        right: 12,
        top: 6,
        bottom: 6
      })
      .backgroundColor(this.vm.selectedCity === '城市' ? 'rgba(0,0,0, 0.06)' : 'rgba(86, 74, 247, 0.10)')
      .borderRadius(4)
      .onClick(() => {
        phoneRouterControl.jumpPage({
          pageName: RouterMap.CITY_SELECT_PAGE,
          builder: wrapBuilder(CitySelectPageBuilder),
          onPop: (popInfo) => {
            if (popInfo.result) {
              this.vm.selectedCity = popInfo.result as string;
            }
          }
        })
      })

      Row() {
        Text(this.vm.selectedCount === 0 ? '筛选' : `筛选·${this.vm.selectedCount}`)
          .fontSize(14)
          .fontColor(this.vm.selectedCount === 0 ? '#666666' : 'rgba(86, 74, 247, 1)')
        Image(this.vm.selectedCount === 0 ? $r('app.media.filter_icon') : $r('app.media.filter_selected_icon'))
          .width(4)
          .height(4)
          .position({
            right: -8,
            bottom: -2
          })
      }
      .padding({
        left: 12,
        right: 12,
        top: 6,
        bottom: 6
      })
      .backgroundColor(this.vm.selectedCount === 0 ? 'rgba(0,0,0, 0.06)' : 'rgba(86, 74, 247, 0.10)')
      .borderRadius(4)
      .margin({ left: 8 })
      .onClick(() => {
        phoneRouterControl.jumpPage({
          pageName: RouterMap.FILTER_PAGE,
          builder: wrapBuilder(FilterPageBuilder),
          onPop: (popInfo) => {
            if (popInfo.result) {
              const filterData = popInfo.result as FilterData
              const selectedItems = filterData.selectedItems as string[]
              this.vm.applyFilter(selectedItems)
            }
          }
        })
      })
    }
    .width('100%')
    .padding({
      left: 16,
      right: 16,
      top: 16,
      bottom: 6
    })
  }

  build() {
    Column() {
      this.buildStack()
      this.buildTag()
      if (this.vm.positionList.length === 0) {
        Column() {
          Image($r('app.media.ic_no_search_result_found'))
            .width(120)
            .height(120)
            .margin({ top: 120 })

          Text('暂时没有搜索到您要找的内容呢')
            .fontSize(14)
            .fontColor('rgba(0,0,0,0.40)')
        }
        .width('100%')
        .layoutWeight(1)
      } else {
        // 职位列表
        List({ space: 8 }) {
          ForEach(this.vm.positionList, (item: PositionInfo, index: number) => {
            ListItem() {
              PositionCard({ positionInfoData: item })
                .onClick(() => {
                  phoneRouterControl.jumpPage({
                    pageName: RouterMap.POSITION_DETAIL_PAGE,
                    param: {
                      content: item.id,
                      isSheet: false,
                    } as ProtocolRouterParams,
                    builder: wrapBuilder(PositionDetailPageBuilder),
                  })
                })
            }
          }, (item: PositionInfo) => item.id)
        }
        .scrollBar(BarState.Off)
        .layoutWeight(1)
        .padding({ top: 8, left: 16, right: 16 })
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
      }

    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F1F3F5')
  }
}
