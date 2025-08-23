import { MyConfig } from 'commons'

const addressDictId = MyConfig.MYADDRESSDICTID
const meetingTypeDictSanId = MyConfig.METTINGTYPESANID
const meetingTypeDictXiId = MyConfig.METTINGTYPEXIID
const technoSphereDictId = MyConfig.TECH_NOSPHERE_ID
const childAddressDictId = MyConfig.CHILDMYADDRESSDICTID
const childMeetingTypeDictSanId = MyConfig.CHILDMETTINGTYPESANID
const childMeetingTypeDictXiId = MyConfig.CHILD_MMETTINGTY_PEXIID
const childTechnoSphereDictId = MyConfig.CHILD_TECHNOSPHERE_ID
const allMeetingTypeDictId = MyConfig.allMmettingTypexiId
const childAllMeetingTypeDictId = MyConfig.childAllMmettingTypexIid


export class FilterDIctList {
  addressList: DictListItem[]
  meetingTypeList: DictListItem[]
  technoSphereList: DictListItem[]
  meetingTypeListXi: DictListItem[]
  allMeetingTypeList: DictListItem[]

  constructor(data: DictListItem[]) {
    this.addressList = []
    this.meetingTypeList = []
    this.technoSphereList = []
    this.meetingTypeListXi = []
    this.allMeetingTypeList = []
    data.forEach(item => {
      if (item.paramId === addressDictId.toString()) {
        let myItems: DictListItem[] = JSON.parse(JSON.stringify(item.child))[`${childAddressDictId}`]
        myItems.forEach((childItem) => {
          this.addressList.push(new DictListItem(childItem))
        })
      }
      if (item.paramId === meetingTypeDictSanId.toString()) {
        let myItems: DictListItem[] = JSON.parse(JSON.stringify(item.child))[`${childMeetingTypeDictSanId}`]
        myItems.forEach((childItem) => {
          this.meetingTypeList.push(new DictListItem(childItem))
        })
      }
      if (item.paramId === meetingTypeDictXiId.toString()) {
        let myItems: DictListItem[] = JSON.parse(JSON.stringify(item.child))[`${childMeetingTypeDictXiId}`]
        myItems.forEach((childItem) => {
          this.meetingTypeListXi.push(new DictListItem(childItem))
        })
      }
      if (item.paramId === allMeetingTypeDictId.toString()) {
        let myItems: DictListItem[] = JSON.parse(JSON.stringify(item.child))[`${childAllMeetingTypeDictId}`]
        myItems.forEach((childItem) => {
          this.allMeetingTypeList.push(new DictListItem(childItem))
        })
      }
      if (item.paramId === technoSphereDictId.toString()) {
        let myItems: DictListItem[] = JSON.parse(JSON.stringify(item.child))[`${childTechnoSphereDictId}`]
        myItems.forEach((childItem) => {
          this.technoSphereList.push(new DictListItem(childItem))
        })
      }
    })
  }
}

@Observed
export class DictListItem {
  paramId: string
  name: string
  dicId: string
  child: string[]
  isSelect: boolean

  constructor(data: DictListItem) {
    this.paramId = data.paramId
    this.name = data.name
    this.dicId = data.dicId
    this.child = data.child || []
    this.isSelect = data.isSelect || false
  }
}