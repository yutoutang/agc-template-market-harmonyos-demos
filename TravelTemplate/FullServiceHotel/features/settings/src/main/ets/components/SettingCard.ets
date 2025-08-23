import { RouterModule } from 'commonlib'
import { AgreementSettingList } from '../commons/Constants'
import { SettingItem } from '../commons/Types'

@ComponentV2
export struct SettingCard {
  @Param
  list: SettingItem[][] = AgreementSettingList

  build() {
    List({ space: 12 }) {
      ForEach(this.list, (group: SettingItem[]) => {
        ListItemGroup({ space: 32 }) {
          ForEach(group, (item: SettingItem) => {
            ListItem() {
              Row() {
                Text(item.label).fontColor($r('app.color.font_color_level1'))
                Image($r('app.media.ic_right_arrow'))
                  .height(16)
                  .fillColor($r('app.color.font_color_level3'))

              }
              .justifyContent(FlexAlign.SpaceBetween)
              .width($r('app.string.width_percent_full'))
            }
            .onClick(() => {
              if (item.routerName) {
                RouterModule.push({
                  url: item.routerName,
                  param: item.routerParams,
                })
              }
            })
          }, (item: SettingItem) => JSON.stringify(item))
        }
        .backgroundColor($r('app.color.background_color_white'))
        .padding($r('app.string.padding_m'))
        .borderRadius($r('app.string.border_radius_16'))
        .divider({ color: $r('app.color.divider_color'), strokeWidth: 1 })
      }, (item: SettingItem[], index: number) => index + '__' + JSON.stringify(item))
    }
    .scrollBar(BarState.Off)
    .backgroundColor($r('app.color.background_color_grey'))
    .padding($r('app.string.padding_l'))
  }
}