import { CommentRatingItem } from '../components/CommentRatingItem';
import { StoreSelectionSheet } from '../components/StoreSelectionSheet';
import { SubmitCommentVM } from '../viewmodels/SubmitCommentVM';
import { RatingLayoutType } from '../commons/Enums'
import { CommonButton } from 'module_ui_base';
import { StoreItem } from '../commons/Types';

@Builder
export function SubmitCommentPageBuilder() {
  SubmitComment()
}

@ComponentV2
export struct SubmitComment {
  vm: SubmitCommentVM = new SubmitCommentVM();
  @Local
  showDialog: boolean = false;

  aboutToAppear(): void {
    this.vm.getHotelList()
  }

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          this.storeSelectBuilder();
          Divider().margin({ top: $r('app.string.space_l'), bottom: $r('app.string.space_l') })
          this.starRatingBuilder();
          this.textAreaBuilder()
        }
      }
      .align(Alignment.Top)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .layoutWeight(1)
      .padding($r('app.string.space_l'))

      CommonButton({
        title: this.vm.commentModel.isAnonymous ? '匿名提交' : '提交',
        bgColor: $r('app.color.background_color_grey'),
        handleClick: () => {
          this.vm.submitComment();
        },
      })
    }
    .title('发表评价')
    .height('100%')
    .backgroundColor($r('app.color.background_color_grey'))
    .bindSheet($$this.showDialog, this.storeSelectionSheetBuilder(), {
      title: { title: '门店选择' },
      height: 300,
    })
    .onReady((context) => {
      this.vm.stack = context.pathStack
    })
  }

  @Builder
  storeSelectBuilder() {
    Row() {
      Text('门店选择').commonTextStyle().layoutWeight(1);
      if (this.vm.hotelList.length === 1) {
        Row() {
          Text(this.vm.checkedHotel?.name ?? '').commonTextStyle();
        };
      } else {
        Row() {
          Text(this.vm.checkedHotel ? this.vm.checkedHotel.name : '请选择')
            .commonTextStyle()
            .fontWeight(FontWeight.Medium)
            .margin({ right: $r('app.string.space_s') })
          Image($r('app.media.ic_right_arrow')).height('24lpx');
        }
        .onClick(() => {
          this.showDialog = true;
        });
      }
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
  }

  @Builder
  starRatingBuilder() {
    Column({ space: 16 }) {
      CommentRatingItem({
        rating: this.vm.commentModel.totalRate!!,
        layoutType: RatingLayoutType.VERTICAL,
        starSize: 24,
      })

      CommentRatingItem({
        label: '服务周到',
        rating: this.vm.commentModel.detailRate.service!!,
      });
      CommentRatingItem({
        label: '环境卫生',
        rating: this.vm.commentModel.detailRate.environment!!,
      });
      CommentRatingItem({
        label: '设施设备',
        rating: this.vm.commentModel.detailRate.device!!,
      });
      CommentRatingItem({
        label: '综合体验',
        rating: this.vm.commentModel.detailRate.experience!!,
      });
    }
  }

  @Builder
  textAreaBuilder() {
    Column() {
      TextArea({
        text: this.vm.commentModel.desc,
        placeholder: '请留下您的宝贵意见吧~',
      })
        .placeholderFont({ size: $r('app.string.font_size_14') })
        .placeholderColor($r('app.color.font_color_level3'))
        .width('100%')
        .height(150)
        .fontSize($r('app.string.font_size_14'))
        .fontColor($r('app.color.font_color_level1'))
        .backgroundColor($r('app.color.background_color_white'))
        .maxLength(200)
        .showCounter(true)
        .padding($r('app.string.space_m'))
        .margin({
          top: $r('app.string.space_m'),
          bottom: $r('app.string.space_m'),
        })
        .onChange((value: string) => {
          this.vm.commentModel.desc = value;
        });
      Row() {
        Text('匿名评论').margin({ right: $r('app.string.space_s') }).fontSize($r('app.string.font_size_12'));
        Text('其他用户将无法看到您的头像与昵称')
          .fontSize($r('app.string.font_size_12'))
          .fontColor($r('app.color.font_color_level2'));
      }
      .width('100%');
    }
  }

  @Builder
  storeSelectionSheetBuilder() {
    StoreSelectionSheet({
      hotelList: this.vm.hotelList,
      handleConfirm: (store: StoreItem) => {
        this.vm.checkedHotel = store
        this.showDialog = false
      },
    })
  }
}

@Extend(Text)
function commonTextStyle() {
  .fontSize($r('app.string.font_size_14'));
}