import dayjs from 'dayjs';
import { AgendaItemModel, AgendaModel } from './AgendaDetailModel';
import { FavoriteAgendaModel } from './FavoriteAgendaModel';

export interface AgendaObject {
  total: string;
  items: AgendaListItemModel[];
}

export class AgendaSearchResultParam {
  address: string;
  type: string;
  technoSphere: string;
  isFilter: number;

  constructor(isFilter: number, id: string, type: string, technoSphere: string) {
    this.isFilter = isFilter
    this.address = id
    this.type = type
    this.technoSphere = technoSphere
  }
}

export class AgendaDetailParam {
  id: string;

  constructor(id: string) {
    this.id = id
  }
}

@Observed
export class AgendaListItemModel {
  name: string;
  startTime: string;
  endTime: string;
  hotel: string;
  mMategoryI: string[];
  crowdArea: string[];
  mMeetingTypeCn: string[];
  subjectDesc: string;
  mThirdSeminarId: string;
  subSeminarId: string;
  agendaList: AgendaModel[]
  _agendaList?: AgendaItemModel[]
  mAgendaType: string;
  isCollect?: boolean;
  favoriteId?: string;
  isTimeStatus?: string; //默认 -1  0：未开始 1：进行中 2：已结束
  isShowHomeAgenda: string[];
  isShowHomeAgendaSort: number;

  constructor(data?: AgendaListItemModel) {
    this.name = data?.name.replace('|', '').split('###')[0] || '';
    this.startTime = data?.startTime || '';
    this.endTime = data?.endTime || '';
    this.hotel = data?.hotel || '';
    this.mMategoryI = data?.mMategoryI || [];
    this.crowdArea = data?.crowdArea || [];
    this.mMeetingTypeCn = data?.mMeetingTypeCn || [];
    this.subjectDesc = data?.subjectDesc || '';
    this.mThirdSeminarId = data?.mThirdSeminarId || '';
    this.subSeminarId = data?.subSeminarId || '';
    this.agendaList = data?.agendaList || [];
    this.mAgendaType = data?.mAgendaType || '';
    this.isCollect = data?.isCollect || false;
    this.favoriteId = data?.favoriteId || '';
    this.isTimeStatus = data?.isTimeStatus || '默认';
    this.isShowHomeAgenda = data?.isShowHomeAgenda || [];
    this.isShowHomeAgendaSort = data?.isShowHomeAgendaSort || 999;
  }
}

export const agendaDate: string[] = ['09/26', '09/27', '09/28']

export const addressList: string[] = ['大广场', '溪流村庄']

export const addressShowList: string[] = ['大广场', '小山村']

@Observed
export class SwiperItemsObject {
  dateIndex: number
  agendaList: ObjectItem[]
  activityList: ObjectItem[]

  constructor(dateIndex: number, agendaList: ObjectItem[], activityList: ObjectItem[]) {
    this.dateIndex = dateIndex
    this.agendaList = agendaList
    this.activityList = activityList
  }
}

@Observed
export class ObjectItem {
  title?: string
  time?: string
  address?: string
  subItems: AgendaListItemModel[]
  isShowMore?: boolean

  constructor(title: string, subItems: AgendaListItemModel[], time?: string, address?: string, isShowMore?: boolean) {
    this.title = title
    this.time = time
    this.address = address
    this.subItems = subItems
    this.isShowMore = isShowMore || false
  }
}

@Observed
export class InitAgendaList {
  items: ObjectItem[]

  // keyWord 议程题目、议程地点、出席嘉宾 从这里面找
  constructor(data?: AgendaListItemModel[], type?: string, date?: string, address?: string, keyWord?: string) {
    let categorizedItems: Record<string, AgendaListItemModel[]> = {}
    this.items = []
    if (data) {
      // 筛选当前的类型是活动还是 议程
      data = data.filter(item => item.mAgendaType === type)

      if (date === '09/26') {
        data = data.filter(item => {
          return item.mMeetingTypeCn.join(',') === '主题演讲'
        })
      } else {
        if (date) {
          data = data.filter((item) => {
            return dayjs(Number(item.startTime) * 1000).format('MM/DD') === date
          })
        }
        if (address) {
          if (date === '09/26') {
            data = data.filter(item => {
              return item.mMategoryI.join(',') === address || item.mMategoryI.join(',') === '主题演讲'
            })
          } else {
            data = data.filter(item => {
              return item.mMategoryI.join(',') === address
            })
          }

        }

        // day2-3
        // 大广场：
        // 议程：开发者主题演讲，HarmonyOS公开课，专题论坛，鸿蒙生态峰会；
        // 活动：Codelabs训练营，Tech.Hour，HarmonyOS极客马拉松，星光直播间
        //
        //
        // 小山村：
        // 议程：专题论坛，开放演讲，产品体验馆，高峰论坛；
        // 活动：Codelabs训练营，极客挑战赛，扫地僧见面会，产品体验馆
        let typeOrder: string[] = [];
        if (type === '议程') {
          if (address === '大广场') {
            typeOrder = ['鸿蒙生态峰会', '开发者主题演讲', 'HarmonyOS公开课', '专题论坛（大广场）', '鸿蒙时代合伙人'];
          } else {
            typeOrder = ['高峰论坛', '专题论坛（溪流村庄）', '开放演讲'];
          }
        } else {
          //   this.this.item.subItems[0].mMeetingTypeCn.join(',') HarmonyOS 极客马拉松
          // 0  this.this.item.subItems[0].mMeetingTypeCn.join(',') CodeLabs 训练营
          if (address === '大广场') {
            typeOrder = ['codeLabs大广场', '开发者聚乐部', 'HarmonyOS极客马拉松'];
          } else {
            typeOrder = ['某云产品体验官', 'AI应用开发馆', 'codeLabs溪刘坡村', '扫地僧见面会'];
          }
        }
        // 先按照时间排序
        data.sort((a, b) => {
          if (a.startTime === b.startTime) {
            return dayjs(parseInt(a.endTime) * 1000).valueOf() - dayjs(parseInt(b.endTime) * 1000).valueOf()
          }
          return dayjs(parseInt(a.startTime) * 1000).valueOf() - dayjs(parseInt(b.startTime) * 1000).valueOf()
        })
        // 对 data 进行排序
        data.sort((a, b) => {
          const indexA = typeOrder.indexOf(a.mMeetingTypeCn.join(',').replace(/\s+/g, '')); // 获取 a 的类型索引
          const indexB = typeOrder.indexOf(b.mMeetingTypeCn.join(',').replace(/\s+/g, '')); // 获取 b 的类型索引
          return (indexA === -1 ? Infinity : indexA) - (indexB === -1 ? Infinity : indexB); // 排序逻辑
        });


      }

      data.forEach(item => {
        if (item.agendaList && item.agendaList[0]) {
          item._agendaList = item.agendaList[0].agendas || []
        }
        if (item.mMeetingTypeCn.join(',') && !categorizedItems[item.mMeetingTypeCn.join(',')]) {
          categorizedItems[item.mMeetingTypeCn.join(',')] = [] as AgendaListItemModel[];
        }
        categorizedItems[item.mMeetingTypeCn.join(',')].push(item as AgendaListItemModel);
      });

      // 转换成数组给到items
      let keys: string[] = []
      keys = Object.keys(categorizedItems)
      keys.forEach(key => {
        let isShowMore = categorizedItems[key][0].mAgendaType === '活动' ? true : false
        this.items.push(new ObjectItem(key, categorizedItems[key], categorizedItems[key][0].startTime,
          categorizedItems[key][0].mMategoryI.join(','), isShowMore))
      })
    }
  }
}

export interface hostArr {
  items: hostItem[]
}

export interface hostItem {
  subSeminarId: string,
  hot: number
}








