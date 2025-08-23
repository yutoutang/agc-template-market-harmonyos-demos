import { getDictTags, getMyTag, MyConfig, setTags, TagChildItem, TagItem } from 'commons';
import { promptAction } from '@kit.ArkUI';

// 跳转页面入口函数
@Builder
export function InterestTagsBuilder() {
  InterestTags();
}


@Component
struct InterestTags {
  @StorageProp('topRectHeight') topRectHeight: number = 0;
  @StorageProp('token') token: string = '';
  @StorageProp('deviceId') deviceId: string = '';
  @State list: TagItem[] = [];
  @State selectTag: string = '';
  @State loading: boolean = true;

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

  // 标签列表
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
        alignment: Alignment.Center,
        message: '保存成功',
        duration: 2000,
      });
    });
  }

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          if (this.loading) {
            LoadingProgress()
              .layoutWeight(1)
              .width(80);
          } else {

            Text('根据兴趣标签为您推荐感兴趣的议题')
              .fontSize(12)
              .lineHeight(17)
              .fontColor('#66191919')
              .margin({ left: 16, bottom: 14 });

            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.list, (item: TagItem) => {
                TagChildItem({ item: item });
              }, (item: TagItem) => item.id);
            }.padding({
              left: 16,
              bottom: 48,
            });

            Column() {
              Button('保存')
                .width('100%')
                .constraintSize({
                  maxWidth: 328,
                })
                .height(40)
                .backgroundColor('#153AD1')
                .fontSize($r('sys.float.Body_M'))
                .margin({
                  top: 16,
                })
                .onClick(() => {
                  this.submitData();
                });
            }.width('100%').padding({ left: 16, right: 16 });

          }
        }
        .alignItems(HorizontalAlign.Start)
        .constraintSize({
          minHeight: '100%',
        });
      }
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring);
    }
    .title('我的兴趣标签')
    .padding({ top: px2vp(this.topRectHeight) });
  }
}