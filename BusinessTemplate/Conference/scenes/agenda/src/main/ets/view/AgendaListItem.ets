import { isSigned, MyConfig, Phone, UserInfoDetail } from 'commons';
import dayjs from 'dayjs';
import { addReserve, deleteReserve, getReserveList } from '../service/AgendaService';
import { AgendaDetailParam, AgendaListItemModel } from '../viewModel/AgendaModel';

@Component
export struct AgendaListItem {
  @Consume('pageStack') pageStack: NavPathStack;
  @ObjectLink item: AgendaListItemModel;
  @Prop isRecommend: boolean = false;
  @Prop isFavoriteList: boolean = false;
  collectFun?: (item: AgendaListItemModel) => void;
  @StorageLink('isAgree') isAgree: boolean = false;
  @StorageProp('token') token: string = '';
  @StorageLink('userInfo') userInfo: UserInfoDetail = new UserInfoDetail();
  @State myCollAgendaList: string[] = [];
  @State iconTop: number = 34;

  loginSuccess() {
    if (!this.isAgree) {
      this.getSign().then((res) => {
        if (!res) {
          this.pageStack.pushPath({
            name: 'PrivacyDialog',
            param: null,
            onPop: (popInfo: PopInfo) => {
              if (popInfo.result === 'success') {
                this.signPrivacySuccess()
              }
            }
          })
        } else {
          this.signPrivacySuccess()
        }
      })
    } else {
      this.signPrivacySuccess()
    }
  }

  getSign() {
    return isSigned({
      token: this.token,
    }).then(res => {
      if (res.data.isSign === 1) {
        this.isAgree = true;
      } else {
        this.isAgree = false;
      }
      return Promise.resolve(res.data.isSign === 1);
    }).catch(() => {
      return Promise.resolve(false);
    });
  }

  async signPrivacySuccess() {
  }

  async jumpFunc() {
    if (!this.isAgree) {
      await this.getSign();
      if (!this.isAgree) {
        this.pageStack.pushPath({
          name: 'PrivacyDialog',
          param: null,
          onPop: (popInfo: PopInfo) => {
            if (popInfo.result === 'success') {
              this.signPrivacySuccess();
            }
          }
        })
        return
      }
    }
    this.item.isCollect = !this.item.isCollect;
    this.isCollect(this.getUIContext(), this.item);
  }

  /// 是收藏还是取消收藏
  isCollect(context: UIContext, item: AgendaListItemModel) {
    if (item.isCollect) {
      // 收藏
      addReserve({
        token: this.token,
        favoriteId: item.mThirdSeminarId,
      }).then(() => {
        context.getPromptAction().showToast({
          alignment: Alignment.Center,
          message: '收藏成功',
          duration: 500
        });
        this.collectFun && this.collectFun(this.item);
      });
    } else {
      // 取消收藏
      deleteReserve({
        token: this.token,
        favoriteId: item.mThirdSeminarId || '',
      }).then(() => {
        context.getPromptAction().showToast({
          alignment: Alignment.Center,
          message: '取消收藏成功',
          duration: 500
        })
        this.collectFun && this.collectFun(this.item)
      })
    }

  }

  build() {
    Stack({
      alignContent: Alignment.TopEnd
    }) {
      Column() {
        ///  时间
        Row() {
          Column() {
          }
          .width(6)
          .height(6)
          .borderRadius('50%')
          .border({
            width: 1,
            color: '#99000000'
          })
          .margin({ right: 4 })

          if (this.isRecommend) {
            Text(`${dayjs(Number(this.item.startTime) * 1000).format('MM/DD')} `)
              .fontSize(14)
              .fontColor('#99000000')
              .lineHeight(14)
              .fontWeight(700)
          }

          Text(`${dayjs(Number(this.item.startTime) * 1000).format('HH:mm')}-${dayjs(Number(this.item.endTime) * 1000)
            .format('HH:mm')}`)
            .fontSize(14)
            .fontColor('#99000000')
            .lineHeight(14)

          if (this.isRecommend) {
            Blank().layoutWeight(1)
            Column() {
              Text(this.item?.mMeetingTypeCn + '')
                .fontSize(10)
                .fontColor(this.item.mAgendaType === '议程' ?
                  (this.item.mMeetingTypeCn.join(',') === '主题演讲' ? '#F2403D' : '#153AD1') : '#972EC3')
                .fontWeight(500)
            }
            .height(16)
            .justifyContent(FlexAlign.Center)
            .padding({ left: 8, right: 8 })
            .backgroundColor(this.item.mAgendaType === '议程' ?
              (this.item.mMeetingTypeCn.join(',') === '主题演讲' ? '#FFF8F5' : '#E9F8FE') : '#FCF3FE')
            .borderRadius(4)
          }
        }

        // 标题
        Row() {
          Text() {
            Span(this.item.name)
          }
          .fontSize(14)
          .lineHeight(20)
          .fontColor('#000000')
          .layoutWeight(1)
          .fontWeight(700)
          .padding({ right: 60 })
          .textOverflow({
            overflow: TextOverflow.Ellipsis
          })
          .maxLines(2)
          .halfLeading(true)
        }
        .width('100%')
        .margin({ top: 8 })
        .onSizeChange((oldValue, newValue: SizeOptions) => { // 获取最外层盒子高度
          if (newValue.height !== 0) {
            let titleHeight = newValue.height as number
            if (titleHeight > 30) {
              this.iconTop = 39;
            }
          }
        })

        Blank()

        // 地点
        if (this.item.hotel) {
          Row() {
            Image(`${MyConfig.URL}agenda2%2Fagenda_address.png?token=8447ddc5-01da-4e05-9be7-a9dc589c8930`)
              .width(12)
              .margin({
                right: 3,
              });
            Text(this.item.hotel).fontSize(12).fontColor('#99000000').lineHeight(13);
          }
          .padding({
            top: 7,
            right: 13,
            bottom: 7,
            left: 13
          })
          .backgroundColor(this.isFavoriteList ? (this.item.isTimeStatus === '已结束' ? '#0d000000' : '#F7F7F7') :
            this.isRecommend ? '#F7F7F7' : '#FFFFFF')
          .borderRadius('50%')
          .height(28)
          .margin({ top: 8 })
        }

      }
      .height(126)
      .backgroundColor(this.isFavoriteList ? '#FFFFFF' :
        this.isRecommend ? '#FFFFFF' : '#F1F3F5')
      .borderRadius(20)
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Start)
      .padding(12)
      .onClick(() => {
        this.pageStack.pushPath({
          name: 'AgendaDetail',
          param: new AgendaDetailParam(this.item.subSeminarId)
        })
      })
      .opacity(this.isFavoriteList ? (this.item.isTimeStatus === '已结束' ? 0.6 : 1) : 1)

      Stack() {
        Image(this.item.isCollect ?
          `${MyConfig.URL}my2%2Fagenda_collectioned.png?token=1f4e16bb-0412-4781-8410-897e5b35b343` :
          `${MyConfig.URL}agenda2%2Fagenda_collection.png?token=02af0472-2ff3-4a1c-84c6-c05da8906e57`)
          .width(32)
          .onClick(() => {
            this.jumpFunc();
          });
        if (!this.token) {
          Phone({
            cWidth: 32,
            cHeight: 32,
            callback: () => {
              this.loginSuccess()
            }
          })
        }
      }.margin({
        right: 12,
        top: this.iconTop,
      }).opacity(this.isFavoriteList ? (this.item.isTimeStatus === '已结束' ? 0.6 : 1) : 1);
    };
  }
}