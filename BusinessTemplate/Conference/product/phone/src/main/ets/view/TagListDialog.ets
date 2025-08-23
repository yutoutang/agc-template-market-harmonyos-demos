import { getDictTags, getMyTag, MyConfig, setTags, TagChildItem, TagItem, UserInfoDetail } from 'commons';
import { promptAction } from '@kit.ArkUI';

@CustomDialog
export default struct TagListDialog {
  @Consume('pageStack') pageStack: NavPathStack;
  @StorageLink('userInfo') userInfo: UserInfoDetail = new UserInfoDetail();
  @StorageProp('token') token: string = '';
  @StorageLink('isShowTagDialog') isShowTagDialog: string = '';
  @StorageLink('isAgree') isAgree: boolean = false;
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0;
  @State list: TagItem[] = [];
  @State selectTag: string = '';
  @State loading: boolean = true;
  controller?: CustomDialogController;

  aboutToAppear(): void {
    this.loadData();
  }

  getContactTag() {
    if (!this.token) {
      return Promise.resolve('');
    }
    return getMyTag({
      token: this.token,
    }).then((res) => {
      this.selectTag = res.data;
    });
  }

  loadData() {
    Promise.all([
      this.getTagList(),
      this.getContactTag(),
    ]).then(() => {
      this.organizationalData(this.list);
    });
  }

  getTagList() {
    return getDictTags().then(async (res) => {
      let list = res.data || [];
      this.list = list.map((item) => {
        return new TagItem(item as TagItem);
      });
    });
  }

  organizationalData(list: TagItem[]) {
    list.forEach((item) => {
      let title: string = item.title || '';
      if (this.selectTag && this.selectTag.indexOf(title) > -1) {
        item.isSelect = true;
      }
    });
    this.loading = false;
  }

  // 保存
  submitData() {
    let tagArr: string[] = [];
    this.list.forEach((item) => {
      if (item.isSelect) {
        tagArr.push(item.title?.toString() || '');
      }
    });
    if (tagArr.length === 0) {
      this.getUIContext().getPromptAction().showToast({
        message: '请选择标签',
        duration: 2000,
      });
      return;
    }
    setTags({
      token: this.token,
      interestLabels: tagArr.join('^^'),
    }).then(() => {
      this.getUIContext().getPromptAction().showToast({
        message: '保存成功',
        duration: 2000,
      });
      this.controller?.close();
      this.isShowTagDialog = 'showEd';
    });

  }

  build() {
    Column() {
      Column() {
        Column() {
          Row() {
            Text('选择兴趣标签').fontSize(20).lineHeight(28).fontColor('#111111').fontWeight(500);
            Image(`${MyConfig.URL}agenda3%2Fclose1Icon.png?token=3577485c-a68d-4ac4-bf60-9bd027d4ca4b`)
              .width(40)
              .onClick(() => {
                this.controller?.close();
                this.isShowTagDialog = 'showEd';
              });
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween);

          Text('根据兴趣标签为你推荐大会议程(可多选)')
            .fontSize(12)
            .lineHeight(17)
            .fontColor('#66191919')
            .margin({ top: 5, bottom: 14 });

          Stack() {
            Column() {
              Scroll() {
                Flex({ wrap: FlexWrap.Wrap }) {
                  ForEach(this.list, (item: TagItem) => {
                    TagChildItem({ item: item });
                  }, (item: TagItem) => item.id);
                };
              }
              .height(256)
              .edgeEffect(EdgeEffect.Spring);

              Button('保存')
                .width('100%')
                .constraintSize({
                  maxWidth: 328,
                })
                .height(40)
                .backgroundColor($r('sys.color.comp_background_emphasize'))
                .fontSize($r('sys.float.Body_M'))
                .margin({
                  top: 16,
                })
                .onClick(() => {
                  this.submitData();
                });

              Text('可前往“我的”页面查看或调整兴趣标签')
                .fontSize(12)
                .lineHeight(17)
                .fontColor('#66191919')
                .margin({
                  top: 14,
                })
                .width('100%')
                .textAlign(TextAlign.Center);
            }
            .visibility(this.loading ? Visibility.Hidden : Visibility.Visible);

            if (this.loading) {
              LoadingProgress()
                .width(80);
            }
          };

        }
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.Start);
      }
      .padding(16)
      .width('100%');
    }
    .backgroundColor(Color.White)
    .padding({ bottom: px2vp(this.bottomRectHeight) })
    .borderRadius({
      topLeft: 32,
      topRight: 32,
    });
  }
}


