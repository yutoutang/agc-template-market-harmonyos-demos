/*
 *  Copyright (c) 2025 Huawei Device Co., Ltd.
 *  Licensed under the Apache License, Version 2.0 (the 'License');
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an 'AS IS' BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 */

import {
  BottomEditBar,
  DownloadModel,
  DOWNLOAD_DATA,
  EditButton,
  LeftSwipeComponent,
  Logger,
  NoData,
  PreferConstant,
  PreferenceUtil,
  RouterMap,
  RouterModule,
  SourceTextModifier,
  TopBar,
  TopRowModifier
} from 'commonlib';

@ComponentV2
export struct MyDownloadPage {
  @Local sourceTextModifier: SourceTextModifier = new SourceTextModifier()
  @Local topRowModifier: TopRowModifier = new TopRowModifier()
  @Local downloadList: DownloadModel[] = []
  // 是否左滑
  @Local isLeftSwipe: boolean = false
  // 是否编辑
  @Local isEditDownload: boolean = false
  // 选中计数
  @Local selectCount: number = 0
  // 左滑删除下标
  @Provider() swipeIndex: number = 0

  aboutToAppear(): void {
    let downloadState = PreferenceUtil.getInstance().get(PreferConstant.DOWNLOAD_KEY, '0')
    if (downloadState === '1') {
      this.initDownloadData()
    }
  }

  build() {
    Column() {
      // 顶部
      this.downloadTopBuilder()
      Column() {
        // 有数据时显示下载列表
        this.downloadListBuilder()
        // 无数据时显示
        NoData({ text: $r('app.string.download_no_data') })
          .visibility(this.downloadList.length === 0 ? Visibility.Visible : Visibility.None)
      }
      .layoutWeight(1)

      Blank()
      // 底部编辑栏
      BottomEditBar({
        selectCount: this.selectCount,
        deleteAllDialogContent: '是否删除全部资料？',
        deleteSelectDialogContent: `是否删除这${this.selectCount}份资料？`,
        deleteAllData: () => {
          this.deleteAllData()
        },
        deleteSelectData: () => {
          this.deleteSelectData()
        }
      }).visibility(this.isEditDownload ? Visibility.Visible : Visibility.None)
    }
    .height('100%')
    .width('100%')
  }

  /**
   * 下载列表
   */
  @Builder
  downloadListBuilder() {
    List({ space: 8 }) {
      ForEach(this.downloadList, ((item: DownloadModel, index: number) => {
        ListItem() {
          Row() {
            Image(item.isDelete ? $r('app.media.selected_on') : $r('app.media.selected_off'))
              .width($r('app.float.vp_24'))
              .height($r('app.float.vp_24'))
              .margin({ right: $r('app.float.vp_12') })
              .visibility(this.isEditDownload ? Visibility.Visible : Visibility.None)
            Row() {
              Image($r(`app.media.ic_grid_${item.fileType}`))
                .width($r('app.float.vp_40'))
                .height($r('app.float.vp_40'))
              Column() {
                Text(item.materialName)
                  .fontSize($r('sys.float.Body_L'))
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r('sys.color.font_primary'))
                  .height('21vp')
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .wordBreak(WordBreak.BREAK_ALL)
                Text() {
                  Span($r('app.string.material_source'))
                  Span(item.materialSource)
                }
                .attributeModifier(this.sourceTextModifier)
              }
              .layoutWeight(1)
              .height($r('app.float.vp_40'))
              .justifyContent(FlexAlign.SpaceBetween)
              .alignItems(HorizontalAlign.Start)
              .margin({ left: $r('app.float.vp_12') })
            }
            .width('100%')
            .padding({
              top: $r('app.float.vp_16'),
              bottom: $r('app.float.vp_16'),
              left: $r('app.float.vp_12'),
              right: $r('app.float.vp_12')
            })
            .borderRadius(16)
            .backgroundColor($r('sys.color.background_primary'))
          }
          .width('100%')
          .onClick(() => {
            if (this.isEditDownload) {
              // 是否勾选数据
              this.isSelectData(item)
            } else {
              // 预览文件
              this.previewFile(item)
            }
          })
        }
        .padding({ left: $r('app.float.vp_16'), right: $r('app.float.vp_16') })
        .transition({ type: TransitionType.Delete, opacity: 0 })
        .swipeAction({
          edgeEffect: SwipeEdgeEffect.None,
          end: {
            builder: () => {
              this.downloadLeftSwipeBuilder(index)
            },
            actionAreaDistance: this.isEditDownload ? 0 : 26,
            onStateChange: (state: SwipeActionState) => {
              if (state === SwipeActionState.EXPANDED) {
                this.isLeftSwipe = true
              } else if (state === SwipeActionState.COLLAPSED) {
                this.isLeftSwipe = false
              }
            },
          }
        })
      }), (item: DownloadModel, index: number) => item.materialName + index)
    }
    .width('100%')
    .height('auto')
    .scrollBar(BarState.Off)
    .padding({ bottom: $r('app.float.vp_8'), top: $r('app.float.vp_8') })
  }

  /**
   * 左滑删除
   */
  @Builder
  downloadLeftSwipeBuilder(index: number) {
    LeftSwipeComponent({
      index: index,
      dialogContent: '是否删除此份资料？',
      confirmLeftSwipeDelete: () => {
        this.confirmLeftSwipeDelete()
      }
    }).visibility(this.isEditDownload ? Visibility.None : Visibility.Visible)
  }

  /**
   * 顶部
   */
  @Builder
  downloadTopBuilder() {
    Row() {
      TopBar({ title: $r('app.string.my_download') })
      EditButton({
        isEdit: this.isEditDownload,
        onClickEdit: () => {
          this.onClickEdit()
        }
      })
    }
    .attributeModifier(this.topRowModifier)
  }

  /**
   * 我的下载数据初始化
   */
  initDownloadData() {
    DOWNLOAD_DATA.forEach((item: DownloadModel) => {
      let downloadModel: DownloadModel = new DownloadModel()
      downloadModel.id = item.id
      downloadModel.materialName = item.materialName
      downloadModel.materialSource = item.materialSource
      downloadModel.fileType = item.fileType
      downloadModel.time = item.time
      downloadModel.isDelete = false
      this.downloadList.push(downloadModel)
    })
    //按照时间顺序由近及远
    this.downloadList.sort((a, b) => b.time - a.time)
  }

  /**
   * 点击编辑按钮
   */
  onClickEdit() {
    if (!this.isLeftSwipe && this.downloadList.length > 0) {
      this.isEditDownload = !this.isEditDownload
      if (!this.isEditDownload) {
        this.selectCount = 0
        this.downloadList.forEach((item: DownloadModel) => {
          item.isDelete = false
        })
      }
    }
  }

  /**
   * 确认左滑删除
   */
  confirmLeftSwipeDelete() {
    this.downloadList.splice(this.swipeIndex, 1)
    this.isLeftSwipe = false
    PreferenceUtil.getInstance().put(PreferConstant.DOWNLOAD_KEY, '0')
  }

  /**
   * 删除选中数据
   */
  deleteSelectData() {
    this.downloadList = this.downloadList.filter((it: DownloadModel) => !it.isDelete)
    this.isEditDownload = false
    this.selectCount = 0
    PreferenceUtil.getInstance().put(PreferConstant.DOWNLOAD_KEY, '0')
  }

  /**
   * 删除全部数据
   */
  deleteAllData() {
    this.downloadList = []
    this.isEditDownload = false
    PreferenceUtil.getInstance().put(PreferConstant.DOWNLOAD_KEY, '0')
  }

  /**
   * 预览文件
   * @param item
   */
  previewFile(item: DownloadModel) {
    RouterModule.push({ url: RouterMap.LOOK_FILE_PAGE })
  }

  /**
   * 是否勾选数据
   * @param item
   */
  isSelectData(item: DownloadModel) {
    item.isDelete = !item.isDelete
    if (item.isDelete) {
      this.selectCount++;
    } else {
      this.selectCount--;
    }
  }
}

@Builder
export function MyDownloadPageBuilder() {
  MyDownloadPage()
}