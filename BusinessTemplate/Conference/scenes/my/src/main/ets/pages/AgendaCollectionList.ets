import {
  AgendaListItem,
  AgendaListItemModel,
  getReserveList,
  getSubSeminarList
} from 'agenda';
import dayJs from 'dayjs';
import { MyConfig } from 'commons';

// 跳转页面入口函数
@Builder
export function AgendaCollectionListBuilder() {
  AgendaCollectionList()
}


@Component
export struct AgendaCollectionList {
  @StorageProp('topRectHeight') topRectHeight: number = 0;
  @StorageLink('token') token: string = '';
  @StorageProp('deviceId') deviceId: string = '';
  @State agendaList: AgendaListItemModel[] = []
  @State agendaAllList: AgendaListItemModel[] = []
  @State isLoading: boolean = true;
  @State isEmpty: boolean = false;
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0;
  @State myCollAgendaList: string[] = [];

  aboutToAppear(): void {
    this.isLoading = true
    this.isEmpty = false
    this.getList()
  }

  // 获取我的收藏列表
  getMyCollAgendaList() {
    this.myCollAgendaList = []
    return getReserveList({
      token: this.token
    }).then((res) => {
      this.myCollAgendaList = res.data;
    }).catch(() => {
      this.myCollAgendaList = []
    })
  }

  async getList() {
    if (this.token) {
      await this.getMyCollAgendaList()
    } else {
      this.myCollAgendaList = []
    }
    getSubSeminarList().then((res) => {
      res.data.forEach((item) => {
        item.name = item?.name.replace('|', '').split('###')[0] || '';
      })
      this.agendaAllList = res.data
      this.agendaList = this.organizationalData(this.myCollAgendaList, res.data)
      if (this.agendaList.length === 0) {
        this.isEmpty = true
      } else {
        this.isEmpty = false
      }
      this.isLoading = false
    })
  }

  getAgendaStatus(startTime: string, endTime: string): string {
    const now = dayJs(); // 当前时间
    const start = dayJs(Number(startTime) * 1000);
    const end = dayJs(Number(endTime) * 1000);
    if (now.isBefore(start)) {
      return '未开始'; // 当前时间早于开始时间
    } else if (now.isAfter(end)) {
      return '已结束'; // 当前时间晚于结束时间
    } else if (now.isAfter(start) && now.isBefore(end)) {
      return '进行中'; // 当前时间在开始和结束之间
    } else {
      return '默认'
    }
  }

  organizationalData(myCollAgendaList: string[], agendaList: AgendaListItemModel[]) {
    // 直接过滤并设置 isCollect 和 favoriteId
    let arrList = agendaList.map((item: AgendaListItemModel) => {
      const index = this.myCollAgendaList.indexOf(item.mThirdSeminarId);
      item.isTimeStatus = this.getAgendaStatus(item.startTime, item.endTime)
      if (index !== -1) {
        item.isCollect = true;
        item.favoriteId = this.myCollAgendaList[index];
      } else {
        item.isCollect = false;
        item.favoriteId = '';
      }
      return item;
    })
      .filter(item => item.isCollect); // 同时过滤出收藏的项


    //我的收藏议题按照开始时间先后顺序展示  如已结束部分按照结束时间排序（倒序）
    arrList = arrList.sort((a, b) => {
      const statusA = a.isTimeStatus;
      const statusB = b.isTimeStatus;
      // 非已结束的议程排在前面，并按 startTime 升序
      if (statusA !== '已结束' && statusB !== '已结束') {
        if (a.startTime === b.startTime) {
          return dayJs(Number(a.endTime)).valueOf() - dayJs(Number(b.endTime)).valueOf();
        }
        return dayJs(Number(a.startTime)).valueOf() - dayJs(Number(b.startTime)).valueOf();
      }
      // 已结束的议程之间比较，按 endTime 倒序
      if (statusA === '已结束' && statusB === '已结束') {
        return dayJs(Number(b.endTime)).valueOf() - dayJs(Number(a.endTime)).valueOf();
      }
      // 已结束的排在最后
      return statusA === '已结束' ? 1 : -1;
    });

    return arrList
  }

  async updateList() {
    await this.getMyCollAgendaList()
    this.agendaList = this.organizationalData(this.myCollAgendaList, this.agendaAllList)
    if (this.agendaList.length === 0) {
      this.isEmpty = true
    } else {
      this.isEmpty = false
    }
  }

  build() {
    NavDestination() {
      Stack() {
        Scroll() {
          Column() {
            GridRow({ gutter: { x: 8, y: 8 } }) {
              ForEach(this.agendaList, (subItem: AgendaListItemModel, index: number) => {
                GridCol({
                  span: {
                    sm: 12,
                    md: 6,
                    lg: 6,
                  },
                }) {
                  AgendaListItem({
                    item: subItem,
                    isRecommend: true,
                    isFavoriteList: true,
                    collectFun: () => {
                      this.updateList()
                    }
                  })
                }
              }, (subItem: AgendaListItemModel) => JSON.stringify(subItem))
            }
          }
          .padding({
            left: 16,
            right: 16,
            bottom: 32,
            top: 12
          })
          .constraintSize({
            minHeight: `100%`
          })
        }
        .edgeEffect(EdgeEffect.Spring)
        .scrollBar(BarState.Off)

        if (this.isEmpty) {
          Column() {
            Image(`${MyConfig.URL}agenda3%2Fno_data_home_agenda.png?token=a27def5d-07d3-4c63-94cc-da5d86579702`).width(150)
            Text('暂无收藏议程，点击♡ 即可收藏议题').fontSize(14).fontColor('#999999')
          }
          .justifyContent(FlexAlign.Center)
        }

        // loading
        if (this.isLoading) {
          Column() {
            LoadingProgress().width(70)
            Text('正在加载...').fontSize(14).fontColor('#999999')
          }
          .width('100%')
          .backgroundColor('#F1F3F5')
          .height('100%')
          .alignItems(HorizontalAlign.Center)
          .justifyContent(FlexAlign.Center)
        }
      }
      .width('100%')
      .height('100%')
    }
    .title('我收藏的议程')
    .onShown(() => {
      if (this.agendaList.length > 0) {
        this.updateList()
      }
    })
    .backgroundColor('#F1F3F5')
    .padding({ top: px2vp(this.topRectHeight) })
  }
}

