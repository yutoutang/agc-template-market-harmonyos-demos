import { BreakpointModel, BreakpointType } from 'base_ui';
import { BloggerInfo } from '../types/Index';
import { AppStorageV2 } from '@kit.ArkUI';

@ComponentV2
export struct BloggerInfomation {
  @Param bloggerInfo: BloggerInfo = new BloggerInfo();
  @Param isSelf: boolean = false;
  @Param isLogin: boolean = false;
  @Param isFollower: boolean = false;
  @BuilderParam userTagBuilderParam: () => void = this.userTagBuilder;
  @BuilderParam membershipBuilderParam: () => void = this.membershipBuilder;
  @Event jumpFollowers: () => void = () => {
  }
  @Event login: () => void = () => {
  }
  @Event followCb: (isFollower: boolean) => void = () => {
  }
  columnOptions: BreakpointType<number> = new BreakpointType<number>({
    sm: 2,
    md: 4,
    lg: 4,
    xl: 4,
  });
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;

  @Builder
  userTagBuilder() {
  }

  @Builder
  membershipBuilder() {
  }

  @Computed
  get gridCount() {
    return this.columnOptions.getValue(this.breakPointModel.currentBreakpoint);
  }

  build() {
    Column({ space: 12 }) {
      Column() {
        Column({ space: 12 }) {
          Row() {
            Column() {
              Text(!this.bloggerInfo.name && this.isSelf ? '华为用户' : this.bloggerInfo.name)
                .fontSize(24)
                .fontWeight(FontWeight.Medium)
                .fontColor($r('sys.color.font_primary'))
              this.userTagBuilderParam()
            }.alignItems(HorizontalAlign.Start)

            Image(this.bloggerInfo.avatar).width(64).height(64).borderRadius(32)
          }.width('100%').justifyContent(FlexAlign.SpaceBetween).onClick(() => {
            this.login()
          })

          this.membershipBuilderParam()
        }

        Column() {
          Row() {
            Text(this.bloggerInfo.sex).fontSize(12).fontColor($r('sys.color.font_primary'))
            Row()
              .width(6)
              .height(6)
              .borderRadius(3)
              .backgroundColor($r('sys.color.black'))
              .margin({ left: 8, right: 8 })
            Text(this.bloggerInfo.createdAccount).fontSize(12).fontColor($r('sys.color.font_primary'))
            Row()
              .width(6)
              .height(6)
              .borderRadius(3)
              .backgroundColor($r('sys.color.black'))
              .margin({ left: 8, right: 8 })
            Text(this.bloggerInfo.ipLocation).fontSize(12).fontColor($r('sys.color.font_primary'))
            Row()
              .width(6)
              .height(6)
              .borderRadius(3)
              .backgroundColor($r('sys.color.black'))
              .margin({ left: 8, right: 8 })
            Text(this.bloggerInfo.bloggerType).fontSize(12).fontColor($r('sys.color.font_primary'))
          }.width('100%')

          Column() {
            Text('简介：').fontSize(12).fontColor($r('sys.color.font_primary'))
            Text(this.bloggerInfo.profile).fontSize(12).fontColor($r('sys.color.font_primary'))
          }.width('100%').alignItems(HorizontalAlign.Start).margin({ top: 12 })
        }.padding(12).visibility(!this.isSelf || this.isLogin ? Visibility.Visible : Visibility.None)
      }.width('100%').borderRadius(16)

      Row() {
        Row({ space: 8 }) {
          Column() {
            Text(this.bloggerInfo.getFollowers()).fontSize(12).fontColor($r('sys.color.font_primary'))
            Text('关注').fontSize(12).fontColor($r('sys.color.font_primary')).margin({ top: 6 })
          }.onClick(() => {
            this.jumpFollowers()
          })

          Column() {
            Text(this.bloggerInfo.getFans()).fontSize(12).fontColor($r('sys.color.font_primary'))
            Text('粉丝').fontSize(12).fontColor($r('sys.color.font_primary')).margin({ top: 6 })
          }.margin({left: this.gridCount !== 2 && !this.isSelf ? 40 : 0})

          Column() {
            Text(this.bloggerInfo.getBeFavorite()).fontSize(12).fontColor($r('sys.color.font_primary'))
            Text('被收藏').fontSize(12).fontColor($r('sys.color.font_primary')).margin({ top: 6 })
          }.margin({left: this.gridCount !== 2 && !this.isSelf ? 40 : 0})

          Column() {
            Text(this.bloggerInfo.getBeFollowed()).fontSize(12).fontColor($r('sys.color.font_primary'))
            Text('被跟做').fontSize(12).fontColor($r('sys.color.font_primary')).margin({ top: 6 })
          }.margin({left: this.gridCount !== 2 && !this.isSelf ? 40 : 0})
        }
        .width(this.gridCount === 2 || !this.isSelf ? '80%' : '100%')
        .justifyContent(this.gridCount === 2 || !this.isSelf ? null : FlexAlign.SpaceAround)
        Button(this.isFollower ? '已关注' : '关注', { controlSize: ControlSize.SMALL })
          .fontSize($r('sys.float.Body_M'))
          .fontColor(this.isFollower ? '#E84026' : $r('sys.color.font_on_primary'))
          .fontWeight(FontWeight.Medium)
          .backgroundColor(this.isFollower ? '#33FD4238' : '#FD4238')
          .visibility(this.isSelf ? Visibility.None : Visibility.Visible)
          .onClick(() => {
            this.followCb(!this.isFollower)
          })
      }.padding(12).width('100%')
      .justifyContent(FlexAlign.SpaceBetween).borderRadius(16)
      // .justifyContent(this.gridCount === 2 ? FlexAlign.SpaceBetween : FlexAlign.SpaceAround).borderRadius(16)
    }
    .width('100%')
  }
}
