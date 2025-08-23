import dayjs from 'dayjs';
import { getReserveList, getSubSeminarList } from '../service/AgendaService';
import { AgendaListItemModel, InitAgendaList, ObjectItem } from '../viewModel/AgendaModel';
import { LeveTwoActivityList } from '../view/LeveTwoActivityList';

@Builder
export function ActivityListLevelTwoBuilder() {
  ActivityListLevelTwo()
}

interface MyParams {
  type: string
  date: string
  address: string
}

@Component
export struct ActivityListLevelTwo {
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0;
  @StorageProp('topRectHeight') topRectHeight: number = 0;
  @Consume('pageStack') pageStack: NavPathStack
  @StorageProp('token') @Watch('hasToken') token: string = '';
  @StorageProp('deviceId') deviceId: string = '';
  @State type: string = ''
  @State date: string = ''
  @State address: string = ''
  @State agendaData: ObjectItem[] = [] as ObjectItem[]
  @State myCollAgendaList: string[] = [];
  @State isLoading: boolean = true;

  hasToken() {
    if (this.token) {
      try {
        this.getAgedList()
      } catch (e) {
      }
    }
  }

  aboutToAppear(): void {
    let params: MyParams = this.pageStack.getParamByName('ActivityListLevelTwo')[0] as MyParams
    this.type = params.type
    this.date = params.date
    this.address = params.address
  }

  async onShown() {
    await this.getMyCollAgendaList()
    this.setCollect()
  }

  // 获取我的收藏列表
  getMyCollAgendaList() {
    if (!this.token) {
      this.myCollAgendaList = []
      return Promise.resolve()
    }
    return getReserveList({
      token: this.token
    }).then((res) => {
      this.myCollAgendaList = res.data
      return Promise.resolve()
    }).catch(() => {
      return Promise.resolve()
    })
  }

  loadData() {
    Promise.all([
      this.getAgedList(),
      this.getMyCollAgendaList(),
    ]).then(() => {
      this.setCollect()
    })
  }

  setCollect() {
    this.agendaData.forEach((item: ObjectItem) => {
      item.subItems.forEach((subItem: AgendaListItemModel) => {
        subItem.isCollect =  this.myCollAgendaList.indexOf(subItem.mThirdSeminarId) !== -1
      })
    })
  }

  async getAgedList() {
    return getSubSeminarList().then((res) => {
      let list = res.data.map((item: AgendaListItemModel) => {
        return new AgendaListItemModel(item)
      })
      this.agendaData =
        new InitAgendaList(list, '活动', dayjs(Number(this.date) * 1000).format('MM/DD'), this.address).items
      this.agendaData = this.agendaData.filter((item: ObjectItem) => {
        return item.title === this.type
      })
      this.isLoading = false
      return Promise.resolve()
    })
  }

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          if (this.isLoading) {
            Column() {
              LoadingProgress().width(70)
            }.height('100%').width('100%').justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
          } else {
            ForEach(this.agendaData, (item: ObjectItem, index: number) => {
              LeveTwoActivityList(
                {
                  item: this.agendaData[index],
                }
              )
            }, (item: ObjectItem) => JSON.stringify(item))
          }
        }.constraintSize({
          minHeight: '100%',
        })
        .padding({
          bottom: px2vp(this.bottomRectHeight)
        })
      }.scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .title('活动')
    .backgroundColor('#F1F3F5')
    .onShown(() => {
      if (this.agendaData.length === 0) {
        this.loadData()
      } else {
        this.onShown()
      }
    })
    .padding({ top: px2vp(this.topRectHeight) })
  }
}
