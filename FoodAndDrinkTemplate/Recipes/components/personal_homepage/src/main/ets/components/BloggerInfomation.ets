import { BloggerInfo } from '../types/Index';

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

  @Builder
  userTagBuilder() {
  }

  @Builder
  membershipBuilder() {
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
          }

          Column() {
            Text(this.bloggerInfo.getBeFavorite()).fontSize(12).fontColor($r('sys.color.font_primary'))
            Text('被收藏').fontSize(12).fontColor($r('sys.color.font_primary')).margin({ top: 6 })
          }

          Column() {
            Text(this.bloggerInfo.getBeFollowed()).fontSize(12).fontColor($r('sys.color.font_primary'))
            Text('被跟做').fontSize(12).fontColor($r('sys.color.font_primary')).margin({ top: 6 })
          }
        }

        Button(this.isFollower ? '已关注' : '关注', { controlSize: ControlSize.SMALL })
          .fontSize($r('sys.float.Body_M'))
          .fontColor(this.isFollower ? '#E84026' : $r('sys.color.font_on_primary'))
          .fontWeight(FontWeight.Medium)
          .backgroundColor(this.isFollower ? '#33FD4238' : '#FD4238')
          .visibility(this.isSelf ? Visibility.None : Visibility.Visible)
          .onClick(() => {
            this.followCb(!this.isFollower)
          })
      }.padding(12).width('100%').justifyContent(FlexAlign.SpaceBetween).borderRadius(16)
    }
    .width('100%')
  }
}
