import {
  AdaptiveButton,
  AvoidArea,
  CommonConstants,
  Divider,
  FilterButton,
  JobListItem,
  SearchType,
  TitleBar,
  TopBar,
} from '@ohos_agcit/common_component';
import { AppStorageV2, router } from '@kit.ArkUI';
import { JSON } from '@kit.ArkTS';
import { FileDataSource } from 'file_management';


let addressList: SearchType[] = CommonConstants.ADDRESS_COLLECTION;

@Entry
@ComponentV2
export struct Job {
  allList: Array<JobListItem> = CommonConstants.JOB_LIST
  buttonList: SearchType[] = CommonConstants.RECRUITMENT_COLLECTION;
  jobTypeList: SearchType[] = CommonConstants.JOB_COLLECTION;
  myDivider: Divider = new Divider(1, 0, 0, $r('app.color.divider_gray'));
  @Param @Once jobTypeSelectIndex: number = 0;
  @Local recruitmentSelectIndex: number | undefined = undefined;
  @Local addressSelectIndex: number | undefined = undefined;
  @Local lazyListData: FileDataSource<JobListItem> = new FileDataSource();
  @Local avoidArea: AvoidArea = AppStorageV2.connect(AvoidArea, () => new AvoidArea(0, 0))!;
  @Local address: number | undefined = undefined;
  @Local recruitmentType: number | undefined = undefined;
  @Local isHalfShow: boolean = false;
  @Local searchInput: string = '';

  aboutToAppear() {
    this.updateList(this.allList);
  }

  build() {
    Column() {
      TopBar({ text: $r('app.string.job') })
        .width('100%')
        .height(56)
        .alignSelf(ItemAlign.Start);

      // job search
      Row() {
        Row() {
          Search({ placeholder: '职位搜索' })
            .width('85%')
            .onSubmit((input: string) => {
              this.searchInput = input.toLowerCase();
              this.updateList(this.filterByCondition());
            })
            .onChange((input: string) => {
              this.searchInput = input;
              if (this.searchInput === '') {
                this.updateList(this.filterByCondition());
              }
            });
          Blank();
          Image(this.isHalfShow ? $r('app.media.filter_focus') : $r('app.media.filter_unfocus'))
            .width(40)
            .height(40)
            .objectFit(ImageFit.Contain)
            .onClick(() => {
              this.isHalfShow = !this.isHalfShow;
            });
        }
        .width('100%')
        .height(40);
      }
      .height(56)
      .width('100%');

      // job type
      Row() {
        ForEach(this.buttonList, (item: SearchType) => {
          FilterButton({
            title: item.title,
            selfIndex: item.index,
            clickIndex: this.jobTypeSelectIndex,
            invoke: (selfIndex: number) => {
              this.jobTypeSelectIndex = selfIndex;
              this.updateList(this.filterByCondition());
            }
          })
        }, (item:SearchType) => JSON.stringify(item))
      }
      .justifyContent(FlexAlign.SpaceAround)
      .alignItems(VerticalAlign.Center)
      .height(56)
      .width('100%')

      // job list
      List({ space: 10 }) {
        LazyForEach(this.lazyListData, (item: JobListItem) => {
          ListItem() {
            Column() {
              Text(item.name)
                .width('100%')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .textAlign(TextAlign.Start);
              Row() {
                Text(CommonConstants.ADDRESS_MAP.get(item.address) + ' · ' + item.jobType)
                  .fontSize(12)
                  .fontColor('rgba(0,0,0,0.60)');
                Blank();
                Text(item.publishTime)
                  .fontSize(12)
                  .fontColor('rgba(0,0,0,0.60)');
              }
              .margin({ top: 5 })
              .width('100%');
            }
            .onClick(() => {
              router.pushUrl({
                url: 'pages/jobRoute/JobDetail',
                params: item,
              }, router.RouterMode.Standard);
            })
            .justifyContent(FlexAlign.SpaceEvenly)
            .height(63);
          };
        }, (item: JobListItem) => JSON.stringify(item));
      }
      .width('100%')
      .layoutWeight(1)
      .padding({ top: 10 })
      .divider(this.myDivider)
      .edgeEffect(EdgeEffect.Spring)
      .scrollBar(BarState.Off);
    }
    .padding({
      top: px2vp(this.avoidArea.topRectHeight),
      left: '4%',
      right: '4%',
    })
    .width('100%')
    .height('100%')
    .bindSheet($$this.isHalfShow, this.MyFilterBuilder(), {
      height: 500,
    })
  }

  private filterByCondition() {
    let filterList = this.allList.filter(item => item.recruitmentTag === this.jobTypeSelectIndex);
    if (this.recruitmentSelectIndex !== undefined) {
      filterList = filterList.filter(item => item.recruitmentType === this.recruitmentSelectIndex);
    }
    if (this.addressSelectIndex !== undefined) {
      filterList = filterList.filter(item => item.address === this.addressSelectIndex);
    }
    if (this.searchInput !== '') {
      filterList = filterList.filter(item => item.name.toLowerCase().includes(this.searchInput));
    }
    return filterList;
  }

  private updateList(list: Array<JobListItem>) {
    this.lazyListData.clear();

    for (let i = 0; i < list.length; i++) {
      this.lazyListData.pushData(list[i]);
    }
  }

  @Builder
  MyFilterBuilder() {
    Column() {
      Text('筛选')
        .fontSize($r('app.float.font_size_22'))
        .fontWeight(CommonConstants.FONT_WEIGHT_700)
        .margin({ bottom: 30 })
      Text('职位类型')
        .fontSize($r('app.float.font_size_18'))
        .fontWeight(CommonConstants.FONT_WEIGHT_600)
        .margin({ bottom: 20 })
      Grid() {
        ForEach(this.jobTypeList, (item: SearchType) => {
          GridItem() {
            AdaptiveButton({
              item: item,
              clickIndex: this.recruitmentSelectIndex,
              invoke: (index: number) => {
                if (this.recruitmentSelectIndex === index) {
                  this.recruitmentSelectIndex = undefined
                } else {
                  this.recruitmentSelectIndex = index
                }
              }
            })
          }
        }, (item: SearchType) => JSON.stringify(item))
      }
      .columnsGap(12)
      .rowsGap(10)
      .width('100%')

      Text('工作地点')
        .fontSize($r('app.float.font_size_18'))
        .fontWeight(CommonConstants.FONT_WEIGHT_600)
        .margin({ top: 20, bottom: 20 })
      Grid() {
        ForEach(addressList, (item: SearchType) => {
          GridItem() {
            AdaptiveButton({
              item: item,
              clickIndex: this.addressSelectIndex,
              invoke: (index: number) => {
                if (this.addressSelectIndex === index) {
                  this.addressSelectIndex = undefined
                } else {
                  this.addressSelectIndex = index
                }
              }
            })
          }
        }, (item: SearchType) => JSON.stringify(item))
      }
      .columnsGap(12)
      .rowsGap(10)
      .width('100%')

      Row() {
        Button('重置')
          .fontColor($r('sys.color.font_emphasize'))
          .backgroundColor($r('app.color.button_gray'))
          .width('45%')
          .onClick(() => {
            this.recruitmentSelectIndex = undefined
            this.addressSelectIndex = undefined
            this.updateList(this.allList)
            this.isHalfShow = false

          })

        Button('完成')
          .fontColor($r('sys.color.font_on_primary'))
          .backgroundColor($r('sys.color.font_emphasize'))
          .width('45%')
          .onClick(() => {
            this.updateList(this.filterByCondition());
            this.isHalfShow = false
          })
      }
      .justifyContent(FlexAlign.SpaceAround)
      .width('100%')
      .margin({ top: 30 })
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .padding({
      left: '4%',
      right: '4%',
      top: 20,
      bottom: px2vp(this.avoidArea.bottomRectHeight)
    })
  }
}