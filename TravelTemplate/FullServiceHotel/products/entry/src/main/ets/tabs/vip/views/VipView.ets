import { CommonConstants } from 'commonlib';
import { https, VipGradeItem } from 'network';
import { EquityItem, VipGradeItemModel } from '../models/VipGrade';
import { CommonButton, CommonHeader } from 'componentlib';
import { CallDialog } from 'module_call_dialog';

@Builder
export function vipViewBuilder() {
  VipView();
}

@ComponentV2
export struct VipView {
  @Local
  private index: number = 0;
  @Local
  private vipGradeList: VipGradeItemModel[] = [];
  @Local
  private currentItem: VipGradeItemModel = new VipGradeItemModel();

  async aboutToAppear() {
    const res = await https.getGradeList();
    if (res.code === 0) {
      let initList: VipGradeItem[] = res.data;
      initList.forEach((item) => {
        const grandItem = new VipGradeItemModel(item);
        this.vipGradeList.push(grandItem);
      });
      if (this.vipGradeList.length) {
        this.currentItem = new VipGradeItemModel(initList[0]);
      }
    }
  }

  build() {
    Column() {
      CommonHeader({ title: '会员', isSubTitle: false })
      Scroll() {
        Column() {
          if (this.vipGradeList.length) {
            Swiper() {
              ForEach(this.vipGradeList, (item: VipGradeItemModel, index: number) => {
                Row() {
                  Image(item.gradeCover)
                    .aspectRatio(2)
                    .objectFit(ImageFit.Fill)
                    .borderRadius($r('app.string.border_radius_16'))
                }
                .margin({
                  right: $r('app.string.margin_l'),
                })
              }, (item: VipGradeItemModel) => JSON.stringify(item));
            }
            .width('100%')
            .autoPlay(false)
            .indicator(false)
            .loop(false)
            .vertical(false)
            .index(this.index)
            .disableSwipe(false)
            .onChange((index: number) => {
              this.currentItem.update(this.vipGradeList[index]);
            })
            .displayCount(1)
            .nextMargin(16, true)
            .prevMargin(16, false)

            Column() {
              this.vipInfoBuilder();
              this.vipLabelBuilder();
            }
            .padding({
              left: $r('app.string.padding_l'),
              right: $r('app.string.padding_l'),
            })
          }
        };
      }
      .scrollBar(BarState.Off)
      .layoutWeight(1)
      .edgeEffect(EdgeEffect.Spring)

      CallDialog({
        phoneNumber: CommonConstants.TEL_NUMBER,
      }) {
        CommonButton({
          icon: $r('app.media.ic_phone'),
          title: '联系我们',
        })
          .margin({ top: $r('app.string.margin_l') })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background_color_grey'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
  }

  @Builder
  vipInfoBuilder() {
    Column() {
      Text(this.currentItem.gradeName)
        .fontSize($r('app.string.font_size_16'))
        .fontWeight(500)
        .fontColor($r('app.color.font_color_level1'))
        .margin($r('app.string.margin_l'));
      Grid() {
        ForEach(this.currentItem.equityList, (item: EquityItem) => {
          GridItem() {
            Column() {
              Image(item.equityIcon)
                .height(40)
                .width(40);
              Text(item.equityName)
                .fontSize($r('app.string.font_size_14'))
                .maxLines(1)
                .fontColor($r('app.color.font_color_level1'))
                .margin({ top: $r('app.string.margin_s') });
            };
          };
        }, (item: EquityItem) => JSON.stringify(item));
      }
      .editMode(false)
      .supportAnimation(false)
      .columnsTemplate('1fr 1fr 1fr 1fr')
      .rowsGap($r('app.string.margin_m'))
      .alignItems(GridItemAlignment.STRETCH)
      .width('100%')
      .height(180);
    }
    .width('100%');
  }

  @Builder
  vipLabelBuilder() {
    Column() {
      Text(this.currentItem.introTitle)
        .fontSize($r('app.string.font_size_16'))
        .fontColor($r('app.color.font_color_level1'))
        .fontWeight(500)
        .margin({ bottom: $r('app.string.margin_s') });

      Text(this.currentItem.introText)
        .fontSize($r('app.string.font_size_14'))
        .lineHeight(20)
        .fontColor($r('app.color.font_color_level1'))
        .margin({ bottom: $r('app.string.margin_s') });
    }
    .alignItems(HorizontalAlign.Start)
    .padding($r('app.string.padding_m'))
    .backgroundColor($r('app.color.background_color_white'))
    .borderRadius($r('app.string.border_radius_16'))
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Start);
  }
}
