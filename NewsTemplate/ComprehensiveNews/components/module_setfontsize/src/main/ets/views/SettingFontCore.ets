import { ButtonGroup } from '../components/ButtonGroup'
import { FontSizeSlider } from '../components/FontSizeSlider';
import { BUTTON_LIST, Constants } from '../common/Constants'
import { getPageMargin } from '../common/Utils';

@ComponentV2
export struct SettingFontCore {
  // 字体比例初始值
  @Once @Param currentRatio: number = 1;
  // 当前断点
  @Param breakpoint: string = 'sm';
  // 确认调整的回调
  @Event confirm: (ratio: number) => void = () => {
  };
  @Local selectId: string = '1';

  @Computed
  get showListSample() {
    return this.selectId === '1';
  }

  @Computed
  get needBarShadow() {
    return ['sm', 'md'].includes(this.breakpoint);
  }

  build() {
    Column() {
      Column() {
        ButtonGroup({
          buttonList: BUTTON_LIST,
          selectedId: this.selectId!!,
        })
        Scroll() {
          if (this.showListSample) {
            this.listSample()
          } else {
            this.detailSample()
          }
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .align(Alignment.Top)
        .padding({ top: 16, bottom: 16 })
      }
      .layoutWeight(1)
      .padding({
        left: getPageMargin(this.breakpoint),
        right: getPageMargin(this.breakpoint),
      })

      this.bottomCard()
    }
  }

  @Builder
  bottomCard() {
    Column() {
      FontSizeSlider({
        currentRatio: this.currentRatio!!,
      })
      Button('确定')
        .height(40)
        .width(Constants.FULL_PERCENT)
        .margin({ top: 16, bottom: 16 })
        .onClick(() => {
          this.confirm(this.currentRatio);
        })
    }
    .shadow({
      offsetY: -4,
      radius: 8,
      color: this.needBarShadow ? '#E5E5E5' : Color.Transparent,
    })
    .padding({
      left: getPageMargin(this.breakpoint),
      right: getPageMargin(this.breakpoint),
    })
  }

  @Builder
  listSample() {
    Row({ space: 12 }) {
      Column({ space: 4 }) {
        Text('住建部称住宅层高标准将提至不低于3米，层高低的房子不值钱了？')
          .fontSize(16 * this.currentRatio)
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Medium)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Text('央视新闻  2小时前')
          .fontSize(12)
          .fontColor($r('sys.color.font_tertiary'))
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .padding({ top: 4, bottom: 4 })

      Image($r('app.media.sample_list'))
        .borderRadius(4)
        .height(72)
        .draggable(false)
    }
    .width('100%')

  }

  @Builder
  detailSample() {
    Column() {
      Text('住建部称住宅层高标准将提至不低于3米，层高低的房子不值钱了？')
        .fontSize(20 * this.currentRatio)
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Medium)
      Row({ space: 12 }) {
        Image($r('app.media.sample_user_icon'))
          .width(40)
          .draggable(false)

        Column({ space: 2 }) {
          Text('新闻客户端')
            .fontSize(14)
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Medium)
          Text('2025-05-04 12:30')
            .fontSize(12)
            .fontColor($r('sys.color.font_tertiary'))
        }
        .alignItems(HorizontalAlign.Start)

        Blank()
        Button('关注')
          .height(28)
          .fontSize($r('sys.float.Body_M'))
      }
      .width('100%')
      .padding({ top: 12, bottom: 12 })
      .margin({ top: 8 })

      Text('“竞高品质住宅建设方案”是北京今年首批集中供地提出的竞拍规则之一。30个开拍地块中，有8个因触及“竞地价+竞公共租赁住房面积”或“竞地价+竞政府持有商品住宅产权份额”等上限后转入“竞高标准商品住宅建设方案”环节，最终，通过评选组评分确定了8宗商品住宅用地竞得人。')
        .fontSize(16 * this.currentRatio)
        .fontColor($r('sys.color.font_primary'))
        .margin({ top: 16 })
      Image($r('app.media.sample_detail'))
        .width('100%')
        .draggable(false)
        .margin({ top: 16 })
    }
  }
}