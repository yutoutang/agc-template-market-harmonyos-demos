import { FeedListPageRouteParam } from 'feed';
import { QueryEnrolledActivitiesResponse } from 'activity';
import { MemberPageParam } from 'member';
import {
  GetUserResponse,
  UserFullInfo,
  MateSelectionCriteria,
  UserInfo,
  UserActionSummary,
  QueryFeedResponse,
  BasicUserInfo,
  CommonUtils,
  Constants,
  QueryFeedType,
  QueryFollowUserType,
  LoginState,
  MockService
} from 'commons';
import Logger from 'commons/src/main/ets/utils/Logger';
import UserService from 'user/src/main/ets/service/UserService';
import FeedService from 'feed/src/main/ets/service/FeedService';
import ActivityService from 'activity/src/main/ets/service/ActivityService';
import { ActionSummaryPageParam, ActionSummaryPageType } from '../model/ActionSummaryPageParam';
import { ApiController, AtomicserviceLogin, PersonalInfo } from 'atomicservice_login';
import { DialPanel } from 'dial_panel';
import { BusinessError } from '@kit.BasicServicesKit';
import { AppStorageV2 } from '@kit.ArkUI';
import { MemberShipVM } from 'membership';

@Builder
export function PersonalPageBuilder() {
  Personal()
}

@ComponentV2
export struct Personal {
  vm: MemberShipVM = MemberShipVM.instance;
  @Local personalInfo: PersonalInfo = new PersonalInfo()
  @Local isLink: boolean = false
  @Local controller: ApiController = new ApiController()
  @Consumer('pageStack') pageStack: NavPathStack = new NavPathStack()
  @Local loginStateStorage : LoginState = AppStorageV2.connect(LoginState, 'LoginState', () => new LoginState())!
  @Local userFullInfo: UserFullInfo | null = null;
  @Local userInfo: UserInfo | null = null;
  @Local userActionSummary: UserActionSummary = new UserActionSummary();
  @Param index: number = 0;
  private uiContext: UIContext = this.getUIContext();
  private dialPanel: DialPanel = new DialPanel(this.uiContext)
    .onMakeCall((e: BusinessError<void>): void => {
      if (e.code) {
        this.showToast(`拨号页面跳转失败 -> code: ${e.code}, msg: ${e.message}`);
      }
    })
    .onWillDismiss((reason: DismissReason): void => {
      if (reason === DismissReason.TOUCH_OUTSIDE) {
        this.showToast('已拦截点击其它区域进行关闭的交互方式');
      } else if (reason === DismissReason.SLIDE_DOWN) {
        this.showToast('已拦截下拉模态窗进行关闭的交互方式');
      } else {
        this.dialPanel.close();
      }
    });

  @Monitor('index')
  onChange() {
    if (this.index === Constants.PAGE_INDEX_PERSONAL) {
      this.getUserInfo();
    }
  }

  unBindPhone = async (): Promise<void> => {
    this.isLink = false
    this.loginStateStorage.loginState = false
    this.personalInfo = new PersonalInfo()
  }

  build() {
    NavDestination() {
      Column() {
        this.buildBasicInfo()

        this.buildActionHistoryArea()

        Column() {
          this.buildContactMatchmaker()
        }
        .width('92%')
        .backgroundColor(Color.White)
        .borderRadius(16)
        .margin({ bottom: 12 })

        Column() {
          this.buildMyMateCriteria()
          Divider().strokeWidth('1px').width('92%')
          this.buildMyFeedRow()
          Divider().strokeWidth('1px').width('92%')
          this.buildMyOrderRow()
          Divider().strokeWidth('1px').width('92%')
          this.buildConfigRow()
        }
        .width('92%')
        .backgroundColor(Color.White)
        .borderRadius(16)
      }
    }.hideTitleBar(true).backgroundColor($r('app.color.page_background_color'))
  }

  @Builder
  buildBasicInfo() {
    Column() {
      Column() {
        AtomicserviceLogin({
          userInfo: this.personalInfo,
          isLink: this.isLink,
          controller: this.controller,
          vip: this.vm.isMember,
          bindPhone: (code: string | undefined) => {
            this.isLink = true
            this.personalInfo.userName = MockService.account.nickname !== '' ? MockService.account.nickname : '大王'
            this.personalInfo.avatar = MockService.account.avatar !== '' ? MockService.account.avatar :
              $r('app.media.avatar_login')  // todo 替换为开发者需要的资源
            MockService.saveAccountInfo(this.personalInfo.userName, MockService.account.phone, MockService.account.sex,
              MockService.account.birthday, this.personalInfo.avatar, '');
            this.getUIContext().getPromptAction().showToast({message: '请通过临时关联账号凭证获取真实手机号'})
          },
          onGetPhoneError: (err) => {
            if (err.code === 1001502014 || err.code === 801) {
              this.getUIContext().getPromptAction().showToast({message: '元服务未获取phone权限或用户授权，此为模拟关联。'})
              this.isLink = true
              this.loginStateStorage.loginState = true
              this.personalInfo.phoneNumber = MockService.account.phone ?? '130****0000'
              this.personalInfo.userName = MockService.account.nickname !== '' ? MockService.account.nickname : '大王'
              this.personalInfo.avatar = MockService.account.avatar !== '' ? MockService.account.avatar :
                $r('app.media.avatar_login')  // todo 替换为开发者需要的资源
              MockService.saveAccountInfo(this.personalInfo.userName, this.personalInfo.phoneNumber,
                MockService.account.sex, MockService.account.birthday, this.personalInfo.avatar, '');
            }
          },
          unBindPhone: this.unBindPhone,
        })

        Divider()
          .margin({ top: 12, bottom: 12 })

        Column() {
          Button('会员中心')
            .backgroundColor($r('app.color.button_background_color'))
            .fontSize($r('sys.float.Body_M'))
            .width(90)
            .height(28)
            .onClick(() => {
              if (!this.loginStateStorage.loginState) {
                this.getUIContext().getPromptAction().showToast({ message: '请先关联账号' })
              } else {
                this.pageStack.pushPathByName('Member', new MemberPageParam(this.isVip()), (popInfo: PopInfo) => {
                  let basicUserInfo = popInfo.result as BasicUserInfo;
                  Logger.debug('userInfo after member=' + JSON.stringify(basicUserInfo))
                  if (basicUserInfo != null && this.userInfo != null) {
                    this.userInfo.isVip = basicUserInfo.isVip
                  }
                });
              }
            })
        }
        .width('92%')
        .margin({ bottom: 12 })
        .alignItems(HorizontalAlign.End)
      }
      .backgroundColor(Color.White)
      .borderRadius(16)
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .width('92%')
    .margin({ bottom: 12 })
  }

  private refreshUserInfo(pop: PopInfo) {
    if (pop != null) {
      let userInfoTmp = pop.result as UserInfo;
      if (userInfoTmp != null) {
        this.userInfo = userInfoTmp;
      }
    }
  }

  @Builder
  buildActionHistoryArea() {
    Row() {
      Column() {
        Row() {
          Text('关注')
            .margin({ right: 4 })
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('app.color.text_font_color_black'))
            .fontFamily(Constants.HARMONY_HEITI)
            .fontWeight(FontWeight.Regular)
          Text(CommonUtils.transCount(this.userActionSummary.followUserCount))
            .fontWeight(500)
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('app.color.text_font_color_black'))
            .fontFamily(Constants.HARMONY_HEITI)
            .fontWeight(FontWeight.Regular)
        }
      }.width('21%').onClick(() => {
        if (this.userActionSummary.followUserCount === 0) {
          this.pageStack.pushPathByName('ActionSummaryPage',
            new ActionSummaryPageParam(Constants.EMPTY_FOLLOW_PAGE_TAB1, Constants.EMPTY_FOLLOW_PAGE_TAB2,
              ActionSummaryPageType.FollowUser, null, null), () => {
              this.getUserInfo();
            });
        } else {
          if (this.userFullInfo != null && this.userFullInfo.userInfo != null &&
            this.userFullInfo.userInfo.uid != null) {
            UserService.queryFollowedUser(this.userFullInfo.userInfo.uid, QueryFollowUserType.QUERY_FOLLOWED_BY_ME)
              .then((data: UserFullInfo[]) => {
                this.pageStack.pushPathByName('ActionSummaryPage',
                  new ActionSummaryPageParam(Constants.EMPTY_FOLLOW_PAGE_TAB1, Constants.EMPTY_FOLLOW_PAGE_TAB2,
                    ActionSummaryPageType.FollowUser, data, null), () => {
                    this.getUserInfo();
                  })
              })
          }
        }
      })

      Column() {
        Row() {
          Text('赞过')
            .margin({ right: 4 })
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('app.color.text_font_color_black'))
            .fontFamily(Constants.HARMONY_HEITI)
            .fontWeight(FontWeight.Regular)
          Text(CommonUtils.transCount(this.userActionSummary.likedCount))
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('app.color.text_font_color_black'))
            .fontFamily(Constants.HARMONY_HEITI)
            .fontWeight(FontWeight.Regular)
        }
      }.width('21%').onClick(() => {
        if (this.userActionSummary.likedCount === 0) {
          this.pageStack.pushPathByName('ActionSummaryPage',
            new ActionSummaryPageParam(Constants.EMPTY_LIKE_PAGE_TAB1, Constants.EMPTY_LIKE_PAGE_TAB2,
              ActionSummaryPageType.Like, null, null), () => {
              this.getUserInfo();
            });
        } else {
          if (this.userFullInfo != null && this.userFullInfo.userInfo != null &&
            this.userFullInfo.userInfo.uid != null) {
            FeedService.getFeedList(QueryFeedType.QUERY_MY_LIKE.toString(), this.userFullInfo.userInfo.uid)
              .then((data: QueryFeedResponse | null) => {
                this.pageStack.pushPathByName('ActionSummaryPage',
                  new ActionSummaryPageParam(Constants.EMPTY_LIKE_PAGE_TAB1, Constants.EMPTY_LIKE_PAGE_TAB2,
                    ActionSummaryPageType.Like, null, data?.list), () => {
                    this.getUserInfo();
                  });
              })
          }
        }
      })

      Column() {
        Row() {
          Text('评论')
            .margin({ right: 4 })
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('app.color.text_font_color_black'))
            .fontFamily(Constants.HARMONY_HEITI)
            .fontWeight(FontWeight.Regular)
          Text(CommonUtils.transCount(this.userActionSummary.commentCount))
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('app.color.text_font_color_black'))
            .fontFamily(Constants.HARMONY_HEITI)
            .fontWeight(FontWeight.Regular)
        }
      }.width('21%').align(Alignment.Start).onClick(() => {
        if (this.userActionSummary.commentCount === 0) {
          this.pageStack.pushPathByName('ActionSummaryPage',
            new ActionSummaryPageParam(Constants.EMPTY_COMMENT_PAGE_TAB1, Constants.EMPTY_COMMENT_PAGE_TAB2,
              ActionSummaryPageType.Comment, null, null), () => {
              this.getUserInfo();
            });
        } else {
          if (this.userFullInfo != null && this.userFullInfo.userInfo != null &&
            this.userFullInfo.userInfo.uid != null) {
            FeedService.getFeedList(QueryFeedType.QUERY_MY_COMMENTED.toString())
              .then((data: QueryFeedResponse | null) => {
                this.pageStack.pushPathByName('ActionSummaryPage',
                  new ActionSummaryPageParam(Constants.EMPTY_COMMENT_PAGE_TAB1, Constants.EMPTY_COMMENT_PAGE_TAB2,
                    ActionSummaryPageType.Comment, null, data?.list), () => {
                    this.getUserInfo();
                  });
              })
          }
        }
      })
    }.width('92%').margin({ bottom: 12 })
  }

  private isVip(): boolean {
    return this.userInfo != null && this.userInfo.isVip != null && this.userInfo.isVip === Constants.YES;
  }

  private showToast(msg: string): void {
    this.uiContext.getPromptAction().showToast({ message: msg });
  }

  @Builder
  buildContactMatchmaker() {
    Row() {
      Image($r('app.media.service_fill')).width(24).height(24).margin(12)

      Text('联系专属红娘')
        .fontSize($r('sys.float.Body_M'))
        .width('75%')
        .textAlign(TextAlign.Start)
        .margin({ top: 12, bottom: 12 })

      Image($r('app.media.ic_right_arrow'))
        .width(24)
        .height(24)
        .margin({ left: 12, right: 12 })
        .objectFit(ImageFit.Fill)
    }
    .width('100%')
    .height(48)
    .alignItems(VerticalAlign.Center)
    .onClick(() => {
      this.dialPanel
        .setTitle('联系专属红娘')
        .setPhoneNumber('12345678901')
        .setAutoClosePanel(false) // 成功跳转后不自动关闭模态窗
        .open();
    });
  }

  @Builder
  buildMyMateCriteria() {
    Row() {
      Image($r('app.media.icon_mate_criteria')).width(24).height(24).margin(12)

      Text('择偶标准')
        .fontSize($r('sys.float.Body_M')).width('75%').textAlign(TextAlign.Start).margin({ top: 12, bottom: 12 })

      Image($r('app.media.ic_right_arrow'))
        .width(24)
        .height(24)
        .margin({ left: 12, right: 12 })
        .objectFit(ImageFit.Fill)
    }.width('100%').height(48).alignItems(VerticalAlign.Center).onClick(() => {
      this.pageStack.pushPathByName('MateCriteriaPage', this.userFullInfo, (popInfo: PopInfo) => {
        Logger.debug('------popResult=' + JSON.stringify(popInfo.result))
        if (this.userFullInfo != null) {
          this.userFullInfo.mateSelectionCriteria = JSON.parse(JSON.stringify(popInfo.result as MateSelectionCriteria));
        }
      });
    });
  }

  @Builder
  buildMyFeedRow() {
    Row() {
      Image($r('app.media.icon_my_feed')).width(24).height(24).margin(12)

      Text('我的动态')
        .fontSize($r('sys.float.Body_M')).width('75%').textAlign(TextAlign.Start).margin({ top: 12, bottom: 12 })

      Image($r('app.media.ic_right_arrow'))
        .width(24)
        .height(24)
        .margin({ left: 12, right: 12 })
        .objectFit(ImageFit.Fill)
    }.width('100%').height(48).alignItems(VerticalAlign.Center).onClick(() => {
      if (this.userFullInfo != null && this.userFullInfo.userInfo != null &&
        this.userFullInfo.userInfo.uid != null) {
        let currentUser: BasicUserInfo = UserInfo.toBasicUserInfo(this.userFullInfo.userInfo);
        // 我的动态，所以查询时传入了2个currentUser
        this.pageStack.pushPathByName('FeedList',
          new FeedListPageRouteParam(QueryFeedType.QUERY_BY_USER, currentUser, currentUser, '我的动态'),
          (popInfo: PopInfo) => {
            this.getUserInfo();
          });
      }
    });
  }

  @Builder
  buildMyOrderRow() {
    Row() {
      Image($r('app.media.icon_my_order')).width(24).height(24).margin(12)
      Text('我的订单')
        .fontSize($r('sys.float.Body_M')).width('75%').textAlign(TextAlign.Start).margin({ top: 12, bottom: 12 })

      Image($r('app.media.ic_right_arrow'))
        .width(24)
        .height(24)
        .objectFit(ImageFit.Fill)
        .margin({ left: 12, right: 16 })

    }.width('100%').height(48).alignItems(VerticalAlign.Center).onClick(() => {
      if (this.userFullInfo != null && this.userFullInfo.userInfo != null &&
        this.userFullInfo.userInfo.uid != null) {
        ActivityService.queryEnrolledActivities(this.userFullInfo.userInfo.uid)
          .then((data: QueryEnrolledActivitiesResponse | null) => {
            if (data != null) {
              this.pageStack.pushPathByName('MyActivitiesPage', data.list);
            }
          })
      }
    })
  }

  @Builder
  buildConfigRow() {
    Row() {
      Image($r('app.media.icon_config')).width(24).height(24).margin(12)
      Text('设置')
        .fontSize($r('sys.float.Body_M')).width('75%').textAlign(TextAlign.Start).margin({ top: 12, bottom: 12 })

      Image($r('app.media.ic_right_arrow'))
        .width(24)
        .height(24)
        .objectFit(ImageFit.Fill)
        .margin({ left: 12, right: 12 })

    }.width('100%').height(48).alignItems(VerticalAlign.Center).onClick(() => {
      this.pageStack.pushPathByName('ConfigPage', null, () => {
        Logger.debug('PersonalPage, onConfigPagePop');
        let newRegisterFlag: boolean | null | undefined = AppStorage.get(Constants.NEW_REGISTER_FLAG);
        if (newRegisterFlag != null && newRegisterFlag !== undefined && newRegisterFlag) {
          Logger.debug('PersonalPage, newRegisterFlag is true')
          this.getUserInfo();
          Logger.debug('PersonalPage pageStack=' + JSON.stringify(this.pageStack))
        }
      })
    });
  }

  aboutToAppear(): void {
    this.getUserInfo();
    this.personalInfo.avatar = MockService.account.avatar
    this.personalInfo.phoneNumber = MockService.account.phone
    this.personalInfo.userName = MockService.account.nickname
    this.getUIContext().getHostContext()?.eventHub.on('refreshUserInfo', () => {
      this.personalInfo.avatar = MockService.account.avatar
      this.personalInfo.phoneNumber = MockService.account.phone
      this.personalInfo.userName = MockService.account.nickname
    })
  }

  aboutToDisappear(): void {
    this.getUIContext().getHostContext()?.eventHub.off('refreshUserInfo')
  }

  private getUserInfo() {
    let unionId: string | undefined = AppStorage.get(Constants.UNION_ID);
    UserService.getUserFullInfoByUnionId(unionId).then((data: GetUserResponse | null) => {
      if (data != null && data.userFullInfo != null) {
        this.userFullInfo = data.userFullInfo;
        if (data.userFullInfo.userInfo != null) {
          this.userInfo = data.userFullInfo.userInfo;
        }
        if (this.userFullInfo.userActionSummary != null) {
          this.userActionSummary = this.userFullInfo.userActionSummary;
        }
      }
    });
  }

  @Builder
  EditIconBuilder(): CustomBuilder {
    Image($r('app.media.icon_edit_user')).width(20).height(20)
  }
}

