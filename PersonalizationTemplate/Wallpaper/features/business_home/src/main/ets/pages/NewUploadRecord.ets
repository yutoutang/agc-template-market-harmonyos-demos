// 上传记录页面
import { promptAction } from '@kit.ArkUI';
import { Context } from '@kit.AbilityKit';
import { DialogResult } from 'upload_recipe';
import { Logger, RouterMap, RouterUtils, TimeUtils } from 'lib_common';
import { ImageInfo, ImageInfos } from 'module_wallpaper_details';
import { DataHelper } from '../data/mock/DataHelper';

const TAG = '[UploadRecordVM]';

@ObservedV2
class UploadRecordVM {
  @Trace selectEdit: boolean = false;
  @Trace selectAll: boolean = false;
  @Trace canDelete: boolean = false;
  @Trace select: ImageInfo[] = [];
  @Trace records: ImageInfo[] = []; // 上传记录列表
  @Trace isLoading: boolean = true;

  addSelect(imageInfo: ImageInfo) {
    imageInfo.select = true;
    this.records = JSON.parse(JSON.stringify(this.records)) as ImageInfo[]
    this.select.push(imageInfo);
    this.selectAll = this.select.length === this.records.length ? true : false;
    this.canDelete = true;
  }

  public hasSelect(url: string): boolean {
    return this.select.some(item => item.url === url);
  }

  addSelectAll() {
    this.select.push(...this.records)

    for (let image of this.records) {
      image.select = true;
    }

    this.records = JSON.parse(JSON.stringify(this.records)) as ImageInfo[]
    this.selectAll = true;
    this.canDelete = true;
  }

  removeSelect(imageInfo: ImageInfo) {

    imageInfo.select = false;
    this.records = JSON.parse(JSON.stringify(this.records)) as ImageInfo[]
    this.select = this.select.filter(item => item.url !== imageInfo.url)
    this.selectAll = false;
    this.canDelete = this.select.length > 0 ? true : false;
  }

  removeSelectAll() {
    for (let image of this.records) {
      image.select = false;
    }

    this.records = JSON.parse(JSON.stringify(this.records)) as ImageInfo[]
    this.select = []
    this.selectAll = false;
    this.canDelete = false;
  }

  delete() {
    DataHelper.getInstance().removeUpload(this.select)
    this.records = JSON.parse(JSON.stringify(DataHelper.getInstance().getUploads())) as ImageInfo[];
    this.select = []
    this.selectAll = false;
    this.selectEdit = this.records.length > 0 ? true : false;
    this.canDelete = this.select.length > 0 ? true : false;
  }

  async goDetail(index: number): Promise<void> {
    try {
      const imageInfos: ImageInfos = {
        url: this.records[index].url,
        list: this.records
      };

      // 跳转到详情页
      RouterUtils.pushPathByName(RouterMap.NEW_ROUTER_MAP_WALLPAPER_DETAIL, imageInfos);
    } catch (error) {
    }
  }
}

@Builder
export function NewUploadRecordPageBuilder() {
  NewUploadRecord()
}

// 页面组件
@ComponentV2
export struct NewUploadRecord {
  private touchChange: boolean = false;
  private vm: UploadRecordVM = new UploadRecordVM();
  private context: Context = getContext();

  // 页面显示时加载数据
  aboutToAppear(): void {
    this.loadRecords();
  }

  // 加载上传记录
  async loadRecords(): Promise<void> {
    this.vm.isLoading = true;
    this.vm.records = JSON.parse(JSON.stringify(DataHelper.getInstance().getUploads())) as ImageInfo[];
    this.vm.isLoading = false;
  }

  clearAllMark(): void {
    try {
      promptAction.showDialog({
        message: '确定要删除所选记录吗？',
        buttons: [
          { text: '取消', color: '#000000' },
          { text: '确定', color: '#0A59F7' }
        ]
      }).then((result: DialogResult) => {
        if (result.index === 1) {
          this.vm.delete();
        }
      });
    } catch (error) {
      Logger.error(TAG, 'open dialog failed. error:' + JSON.stringify(error));
    }
  }

  // 格式化时间
  formatTime(timeString: string): string {
    try {
      const date = new Date(timeString);
      return `${date.getFullYear()}/${(date.getMonth() + 1).toString().padStart(2, '0')}/${date.getDate()
        .toString()
        .padStart(2, '0')} ${date.getHours().toString().padStart(2, '0')}:${date.getMinutes()
        .toString()
        .padStart(2, '0')}`;
    } catch (error) {
      return timeString;
    }
  }

  // 跳转到壁纸详情页
  async navigateToDetail(record: ImageInfo): Promise<void> {
    let list = await DataHelper.getInstance().getUploads();

    const imageInfos: ImageInfos = {
      url: record.url,
      list: list
    };

    // 跳转到详情页
    RouterUtils.pushPathByName(RouterMap.NEW_ROUTER_MAP_WALLPAPER_DETAIL, imageInfos);
  }

  build() {
    NavDestination() {
      Column() {
        // 顶部导航栏
        this.buildTopBar()
        // 主要内容区域
        this.buildContent()
        this.BottomSelectEdit();
      }
      .margin({ top: 40 })
      .height('100%')
      .layoutWeight(1)
      .backgroundColor($r('sys.color.background_secondary'))
    }
    .hideTitleBar(true)
  }

  // 顶部导航栏
  @Builder
  buildTopBar() {
    Row() {
      // 返回按钮
      Image($r('app.media.ic_back'))
        .width(40)
        .height(40)
        .margin({ left: 16 })
        .onClick(() => RouterUtils.pop());
      Text('上传记录')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .margin({ left: 12 })
        .layoutWeight(1);
      // 清空按钮
      if (this.vm.records.length > 0) {
        Image($r('app.media.icon_edit'))
          .width(40)
          .aspectRatio(1)
          .margin({ right: 16 })
          .visibility(this.vm.selectEdit ? Visibility.None : Visibility.Visible)
          .onClick(() => this.vm.selectEdit = true);

        Text('退出编辑')
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_emphasize'))
          .margin({ right: 16 })
          .visibility(this.vm.selectEdit ? Visibility.Visible : Visibility.None)
          .onClick(() => {
            this.vm.selectEdit = false
            this.vm.removeSelectAll()
          });
      }
    }
    .width('100%')
    .height(56)
    .backgroundColor($r('sys.color.comp_background_primary'))
    .alignItems(VerticalAlign.Center);
  }

  // 内容区域
  @Builder
  buildContent() {
    if (this.vm.isLoading) {
      LoadingProgress()
        .size({ width: 72, height: 72 })
        .layoutWeight(1);
    } else if (this.vm.records.length === 0) {
      // 空状态提示
      this.buildEmptyState();
    } else {
      // 上传列表
      this.buildRecordList();
    }
  }

  // 空状态提示
  @Builder
  buildEmptyState() {
    Column() {
      Image($r('app.media.ic_upload'))
        .width(120)
        .height(120)
        .margin({ bottom: 20 });
      Text('暂无上传记录')
        .fontSize(16)
        .fontColor($r('sys.color.font_tertiary'));
    }
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center);
  }

  // 上传壁纸列表
  @Builder
  buildRecordList() {
    List({ space: 12 }) {
      ForEach(this.vm.records, (record: ImageInfo, index: number) => {
        ListItem() {
          // 单条记录项
          this.buildRecordItem(record, index);
        }
      }, (record: ImageInfo, index: number) => JSON.stringify(record) + '_' + index)
    }
    .id('uploadRecordList')
    .width('100%')
    .height('100%')
    .layoutWeight(1)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    .padding(16);
  }

  // 构建单条记录项
  @Builder
  buildRecordItem(record: ImageInfo, index: number) {
    Row() {
      Toggle({ type: ToggleType.Checkbox, isOn: record.select })
        .selectedColor($r('sys.color.comp_background_emphasize'))
        .margin({ right: 16 })
        .visibility(this.vm.selectEdit ? Visibility.Visible : Visibility.None)
        .onChange((isOn: boolean) => {
          if (isOn) {
            this.vm.addSelect(record)
          } else {
            this.vm.removeSelect(record)
          }
        })

      Row() {
        Stack() {
          Image(record.url)
            .width(88)
            .height(156)
            .borderRadius(8)
            .objectFit(ImageFit.Cover)

          if (record.isVideo) {
            Image($r('app.media.ic_live'))
              .objectFit(ImageFit.Cover)
              .width(24)
              .height(24).margin(4)
          }
        }.alignContent(Alignment.TopStart)

        Column() {
          Column() {
            Row() {
              Text(record.type)
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor($r('sys.color.font_primary'))
                .textAlign(TextAlign.Center)
                .layoutWeight(1)
                .align(Alignment.Center)
            }
            .width(66)
            .height(28)
            .border({
              width: 1,
              color: '#66000000',
              radius: 33
            })
            .margin({ left: 10 })
            .justifyContent(FlexAlign.Center)

            // 关键词
            Text(record.keywords.split(',').join(' '))
              .fontSize(14)
              .fontColor($r('sys.color.font_primary'))
              .maxLines(1)
              .margin({ top: 8, left: 10 })
              .textAlign(TextAlign.Start)
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)

          Column() {
            Row() {
              Image(record.userAvatar)
                .width(16)
                .height(16)
                .borderRadius(8)
                .objectFit(ImageFit.Cover)
                .margin({ right: 6, left: 10 })

              Text(record.userName)
                .fontSize(12)
                .fontColor($r('sys.color.font_primary'))
                .maxLines(1)
            }
            .alignItems(VerticalAlign.Center)
            .justifyContent(FlexAlign.Start)

            Row() {
              Text('上传时间：')
                .fontSize(12)
                .fontColor($r('sys.color.font_tertiary'))
              Text(TimeUtils.formatDate(record.time, 'YYYY-MM-DD HH:mm'))
                .fontSize(12)
                .fontColor($r('sys.color.font_tertiary'))
            }
            .margin({ top: 6, left: 10 })
            .alignItems(VerticalAlign.Center)
            .justifyContent(FlexAlign.Start)
          }
          .alignItems(HorizontalAlign.Start)
        }
        .layoutWeight(1)
        .height(156)
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(HorizontalAlign.Start)
      }
      .backgroundColor($r('sys.color.comp_background_primary'))
      .padding(8)
      .layoutWeight(1)
      .borderRadius(12)
      .onClick(() => {
        this.vm.goDetail(index);
      });
    }
  }

  @Builder
  BottomSelectEdit() {
    Row() {
      Row() {
        Toggle({ type: ToggleType.Checkbox, isOn: this.vm.selectAll })
          .selectedColor($r('sys.color.comp_background_emphasize'))
          .onChange((isOn: boolean) => {
            if (this.touchChange) {
              if (isOn) {
                this.vm.addSelectAll()
              } else {
                this.vm.removeSelectAll()
              }
            }
            this.touchChange = false;
          }).onTouch((event: TouchEvent) => {
          this.touchChange = true;
        })
        Text('全选')
          .fontSize($r('sys.float.Body_L'))
          .margin({ left: 16 })
      }.alignItems(VerticalAlign.Center)

      Button('删除')
        .height(40)
        .width(120)
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Medium)
        .enabled(this.vm.canDelete)
        .backgroundColor($r('sys.color.comp_background_emphasize'))
        .onClick(() => {
          this.clearAllMark();
        });
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .width('100%')
    .padding({ left: 16, right: 16, bottom: 16 })
    .height(72)
    .backgroundColor($r('sys.color.comp_background_primary'))
    .visibility(this.vm.selectEdit ? Visibility.Visible : Visibility.None)
  }
}