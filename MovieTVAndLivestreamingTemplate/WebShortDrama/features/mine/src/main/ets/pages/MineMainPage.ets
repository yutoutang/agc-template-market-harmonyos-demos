import { getMedia, getString, NAV_PAGE_NAME } from '@agctemplate/resources'
import { AppStorageKeys, ListItemModel, Mine, MinePageVM, StatusBarHeight, UserInfoModel } from '@agctemplate/widgets'
import { appRouter, container, PreferConstant, PreferenceUtil } from '@agctemplate/utils';
import { AppStorageV2, promptAction } from '@kit.ArkUI';
import { call } from '@kit.TelephonyKit';
import { CommentInfo, CommentListRes, RequestAPI } from '@agctemplate/server';
import { CommentData } from '../models/messageData';


@ComponentV2
export struct MineMainPage {
  @Local statusBarHeight: StatusBarHeight = AppStorageV2.connect(StatusBarHeight, AppStorageKeys.STATUS_BAR_HEIGHT,
    () => new StatusBarHeight())!;
  @Local userAvatar: ListItemModel = new ListItemModel(getString('app.string.avatar'))
  @Local userName: ListItemModel = new ListItemModel(getString('app.string.nick_name'))
  @Local userPhone: ListItemModel = new ListItemModel(getString('app.string.phone_number'))
  @Local userInfo: UserInfoModel = AppStorageV2.connect(UserInfoModel, 'userInfo', () => new UserInfoModel())!
  @Local vm: MinePageVM = MinePageVM.instance;
  @Local customDialogId: number = 0
  @Local myMessageList: Array<CommentData> = []
  @Local messageCount: string = ''
  @Local isOpen: boolean = false
  @Consumer('curTabIndex') currentIndex: number = 0;
  @Local commonServicesContents: Array<ListItemModel> = [
    new ListItemModel(getString('app.string.my_record'), getMedia('app.media.icon_watched')).setHandle(() => {
      this.goToPage(NAV_PAGE_NAME.WatchRecordsPage.name)
    }),
    new ListItemModel(getString('app.string.my_message'), getMedia('app.media.icon_message'))
      .setHandle(() => {
        this.goToPage(NAV_PAGE_NAME.MyMessagePage.name)
      }),
    new ListItemModel(getString('app.string.my_like'), getMedia('app.media.icon_like')).setHandle(() => {
      this.goToPage(NAV_PAGE_NAME.LikesPage.name)
    }),
    new ListItemModel(getString('app.string.my_award'), getMedia('app.media.icon_award')).setHandle(() => {
      this.currentIndex = 2
    })
  ]
  @Local commonServicesContents_2: Array<ListItemModel> = [
    new ListItemModel(getString('app.string.my_feedback'), getMedia('app.media.icon_feedback')).setHandle(() => {
      this.goToPage(NAV_PAGE_NAME.FeedbackPage.name)
    }),
    new ListItemModel(getString('app.string.my_customer_service'),
      getMedia('app.media.icon_customer_service')).setHandle(() => {
      this.isOpen = !this.isOpen
    }),
    new ListItemModel(getString('app.string.my_setting'), getMedia('app.media.icon_setting')).setHandle(() => {
      this.goToPage(NAV_PAGE_NAME.SetUpPage.name)
    }),
  ]

  @Monitor('vm.userInfo.isPhoneAssociated','myMessageList')
  onMyMessageListChange() {
    if (this.vm.userInfo.isPhoneAssociated) {
      const tempMessageCount = this.myMessageList.reduce((count, item) => {
        return count + (item.replyList ? item.replyList.length : 0);
      }, 0)
      this.commonServicesContents[1].redDot = tempMessageCount === 0 ? '' : tempMessageCount.toString()
    } else {
      this.commonServicesContents[1].redDot = ''
    }
  }

  @Monitor('vm.userInfo.isPhoneAssociated')
  onUserLoginChange() {
    container.resolve(RequestAPI).getCommentList({
      pageSize: 1,
      pageNum: 20
    }).then((res) => {
      let commentListRes: CommentListRes = new CommentListRes(res.getBody())
      commentListRes.commentList?.map((commentInfo: CommentInfo) => {
        if (commentInfo.name === this.userInfo.nickname) {
          const tempMessageList: Array<CommentData> = []
          tempMessageList.push(commentInfo as CommentData)
          this.myMessageList = PreferenceUtil.getInstance(getContext())
            .get(PreferConstant.MY_MESSAGE_LIST_SETTINGS, tempMessageList) as Array<CommentData>
          PreferenceUtil.getInstance(getContext()).put(PreferConstant.MY_MESSAGE_LIST_SETTINGS, this.myMessageList)
        }
      })
    })
  }

  build() {
    Mine({
      userInfoHandler: () => {
        appRouter.push({
          builderName: NAV_PAGE_NAME.PersonalInfoPage.name, params: {
            userAvatar: [
              this.userAvatar.setContentImage(this.vm.localInfo.avatar ? this.vm.localInfo.avatar :
                this.vm.userInfo.avatar)
                .setHandle(() => {
                  appRouter.push({
                    builderName: NAV_PAGE_NAME.ChangePage.name
                  })
                })],
            userDetail: [this.userName.setContentText(this.vm.localInfo.nickname ? this.vm.localInfo.nickname :
              this.vm.userInfo.nickname)
              .setHandle(() => {
                appRouter.push({
                  builderName: NAV_PAGE_NAME.ChangePage.name
                })
              }),
              this.userPhone.setContentText(this.vm.userInfo.cellphone).setHandle(() => {
                promptAction.showToast({ message: getString('app.string.phone_tip'), alignment: Alignment.Center });
              })]
          }
        })
      },
      commonServicesContents: this.commonServicesContents,
      commonServicesContents_2: this.commonServicesContents_2
    })
      .padding({ top: `${px2vp(this.statusBarHeight.value)}vp` })
      .bindSheet($$this.isOpen, this.buildMakeCallComponent(), {
        title: this.buildTitle(),
        height: 265
      })
  }

  @Builder
  buildTitle() {
    Text('联系客服')
      .fontSize($r('sys.float.Title_S'))
      .fontWeight(FontWeight.Medium)
  }

  @Builder
  buildMakeCallComponent() {
    Column() {
      Column() {
        Text('0000-00000000')
          .fontSize(18)
          .fontColor('#E6000000')
          .lineHeight(30)
          .halfLeading(true)
        Button() {
          Row() {
            Image(getMedia('app.media.path_1'))
              .height(14)
              .objectFit(ImageFit.Contain)
              .margin({ right: 5 })
            Text('一键拨号')
              .fontSize(15)
              .fontColor(Color.White)
              .fontWeight(600)
          }
        }
        .width('100%')
        .height(45)
        .type(ButtonType.Normal)
        .backgroundColor($r('sys.color.alert'))
        .borderRadius(21)
        .onClick(() => {
          if (canIUse('SystemCapability.Applications.Contacts')) {
            call.makeCall('0000-00000000');
          }
          this.isOpen = false;
        })

        Button() {
          Text('取消')
            .fontSize(15)
            .fontColor($r('sys.color.mask_secondary'))
            .fontWeight(600)
        }
        .width('100%')
        .height(45)
        .type(ButtonType.Normal)
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .borderRadius(20)
        .onClick(() => this.isOpen = false)
      }
      .width('100%')
      .height(170)
      .backgroundColor(Color.White)
      .borderRadius(16)
      .padding({ left: 16, right: 16 })
      .justifyContent(FlexAlign.SpaceEvenly)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Start)
    .padding({
      left: 16,
      right: 16,
      bottom: 56,
      top: 8
    })
  }

  goToPage(url: string) {
    if (this.vm.userInfo.isPhoneAssociated) {
      appRouter.push({ builderName: url })
    } else {
      appRouter.push({ builderName: NAV_PAGE_NAME.LoginPage.name })
    }
  }
}

@Builder
export function MineMainPageBuilder(index: number) {
  MineMainPage()
}