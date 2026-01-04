import { AddressUtils } from 'lib_takeaway_api';
import { IRegion } from '../types/Types';

@ComponentV2
export struct CommonCascade {
  @Param province: string = ''
  @Param city: string = ''
  @Param area: string = ''

  @Monitor('area')
  onProvinceChange() {
    this.init()
  }

  @Local text: string = ''
  @Local isShow: boolean = false;
  @Local sheetHeight: number = -1;
  @Local placeholder: string = '省、市、区'
  @Local selectedData: string[] = []
  @Local data: IRegion[] = []
  @Local currentData: IRegion[] = []
  @Local cityData: IRegion[] = []
  @Local areaData: IRegion[] = []
  @Event onChange: (data: string[]) => void = () => {
  }

  aboutToAppear(): void {
    this.init()
  }

  init() {
    this.selectedData = []
    this.text = this.province + this.city + this.area
    if (this.province && this.city && this.area) {
      this.selectedData = [this.province, this.city, this.area]
    }
    this.selectedData.push('请选择')
    const result = getContext().resourceManager.getRawFileContentSync('region.json')
    this.data = JSON.parse(AddressUtils.uint8ArrayToString(result)) as IRegion[]
    this.currentData = this.data
    const province = this.currentData.find((province) => {
      return province.name === this.province
    })
    if (province) {
      this.cityData = province.children!!
    }
    const city = this.cityData.find((province) => {
      return province.name === this.city
    })
    if (city) {
      this.areaData = city.children!!
      this.currentData = this.areaData
    }
  }

  @Builder
  myBuilder() {
    Column() {
      Column() {
        Row() {
          List() {
            ForEach(this.selectedData, (item: string, index: number) => {
              ListItem() {
                Row() {
                  Text(item)
                    .fontSize(14)
                    .fontWeight(FontWeight.Regular)
                    .fontColor(this.selectedData.length - 1 === index ? '#466DFA' : $r('sys.color.font_primary'))
                }
                .padding({ left: 4, right: 4, bottom: 6 })
                .margin({ right: 12 })
                .borderWidth(this.selectedData.length - 1 === index ? { bottom: 2 } : {})
                .borderColor(this.selectedData.length - 1 === index ? '#466DFA' : '')
              }
              .visibility(index === 3 ? Visibility.None : Visibility.Visible)
              .onClick(() => {
                if (this.selectedData.length === 1) {
                  return
                }
                if (index === 0) {
                  this.currentData = this.data
                  this.selectedData = ['请选择']
                }
                if (index === 1) {
                  if (this.selectedData.length === 4) {
                    this.selectedData.splice(1, 2)
                  } else {
                    this.selectedData.splice(1, 1)
                  }
                  this.currentData = this.cityData
                }
                if (index === 2) {
                  this.currentData = this.areaData
                  this.selectedData.splice(2, 1)
                }
              })
            }, (item: string, index: number) => item)
          }
          .listDirection(Axis.Horizontal)
          .height(26)
          .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
          .scrollBar(BarState.Off)
        }
        .width('100%')
        .margin({ bottom: 1 })

        List() {
          ForEach(this.currentData, (item: IRegion) => {
            ListItem() {
              Column() {
                Divider()
                Row() {
                  Text(item.name)
                  if (this.selectedData.length !== 4) {
                    Image($r('app.media.ic_arrow_right'))
                      .width(5)
                      .height(9)
                  }
                }
                .width('100%')
                .justifyContent(FlexAlign.SpaceBetween)
                .padding({ top: 12, bottom: 12 })
              }
              .onClick(() => {
                if (this.selectedData.length === 4 && this.selectedData[2] !== '请选择') {
                  this.selectedData[2] = item.name
                } else {
                  this.selectedData.pop()
                  this.selectedData.push(item.name)
                  this.selectedData.push('请选择')
                  if (item.children) {
                    this.currentData = item.children
                    if (this.selectedData.length === 2) {
                      this.cityData = item.children
                    }
                    if (this.selectedData.length === 3) {
                      this.areaData = item.children
                    }
                  }
                }

                if (this.selectedData.length === 4 && this.selectedData[2] !== '请选择') {
                  this.onChange(this.selectedData)
                  this.isShow = false
                }
              })
            }
          }, (item: IRegion[]) => JSON.stringify(item))
        }
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
      }
      .width('100%')
      .height('100%')
      .padding(12)
      .backgroundColor(Color.White)
      .borderRadius({ topLeft: 16, topRight: 16 })
    }
    .padding({ left: 16, right: 16 })
    .width('100%')
    .height('100%')
  }

  build() {
    Row() {
      Text(this.text ? this.text : this.placeholder)
        .fontSize(12)
        .fontWeight(FontWeight.Regular)
        .fontColor(this.text ? $r('sys.color.font_primary') : $r('sys.color.font_tertiary'))
    }
    .padding({ top: 12, bottom: 12, left: 16 })
    .width('100%')
    .onClick(() => {
      this.isShow = true;
    })
    .bindSheet($$this.isShow, this.myBuilder(), {
      height: this.sheetHeight,
      backgroundColor: '#F1F3F5',
      title: { title: '选择地址' },
      preferType: SheetType.CENTER,
      onDisappear: () => {
        if (this.selectedData.length === 4) {
          this.text = this.selectedData[0] + this.selectedData[1] + this.selectedData[2]
          const data = [this.selectedData[0], this.selectedData[1], this.selectedData[2]]
          this.onChange(data)
        }
      }
    })
  }
}