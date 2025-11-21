import { common } from '@kit.AbilityKit';
import { promptAction } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import sdk from 'libveditor.so';
import { EditVideo } from '../model/Index';
import { VideoManageVM } from '../viewmodel/VideoManageVM';

@Builder
export function VideoManageBuilder() {
  VideoManage();
}

@ComponentV2
struct VideoManage {
  vm: VideoManageVM = VideoManageVM.instance;
  @Local bottomHeight: number = 0;
  private context: common.UIAbilityContext = getContext() as common.UIAbilityContext;

  async aboutToAppear(): Promise<void> {
    this.context = getContext() as common.UIAbilityContext;
    this.handlePermission();
  }

  handlePermission() {
    this.vm.checkWritePermission();
    this.vm.requestPermission(this.context, ['ohos.permission.WRITE_MEDIA']);
  }

  @Computed
  get isShowEdit() {
    return ((this.vm.draftTabIndex === 0 && this.vm.drafts.length) ||
      (this.vm.draftTabIndex === 1 && this.vm.recycles.length));
  }

  @Builder
  CreateArea() {
    Column({ space: 12 }) {
      Row({ space: 12 }) {
        Image($r('app.media.waveform_cut')).size({ width: 48, height: 48 });
        Text('开始创作')
          .fontColor($r('sys.color.font_on_primary'))
          .fontWeight(FontWeight.Medium);
      }
      .justifyContent(FlexAlign.Center)
      .width('100%')
      .borderRadius(16)
      .onClick(() => {
        try {
          if (!this.vm.isAccept) {
            promptAction.showToast({ message: '请在“设置-应用和元服务”中打开应用的文件写入权限' });
            this.handlePermission();
            return;
          }
          sdk.InitEditor();
          this.vm.selectVideo();
        } catch (err) {
          promptAction.showToast({ message: '当前设备不支持剪辑，请使用真机使用~' });
          hilog.error(0xFF00, 'VideoClip', JSON.stringify(err));
        }
      })
      .linearGradient({
        direction: GradientDirection.Right, // 渐变方向
        repeating: false, // 渐变颜色是否重复
        colors: [['#000000', 0.0], ['#290000', 0.2], ['#220808', 0.4], ['#0A1410', 0.6], ['#062B1C', 0.8],
          ['#000000', 1.0]], // 数组末尾元素占比小于1时满足重复着色效果
      })
      .padding({ top: 24, bottom: 24 });

      Column({ space: 12 }) {
        Row({ space: 12 }) {
          Text('本地草稿').fontWeight(FontWeight.Bold).fontSize(20);
          if (this.isShowEdit) {
            Image(this.vm.isEdit ? $r('app.media.close_history') : $r('app.media.edit_history'))
              .size({ width: 24, height: 24 })
              .onClick(() => {
                // 清空草稿箱和回收站已选内容
                this.vm.isEdit = !this.vm.isEdit;
                this.vm.selectedDrafts = [];
                this.vm.selectedRecycles = [];
                this.vm.clearCheckStatus();
              });
          }
        }.width('100%').justifyContent(FlexAlign.SpaceBetween);

        Row({ space: 8 }) {
          ForEach(this.vm.draftCategory, (item: string, index: number) => {
            Text(`${item} ${index === 0 ? this.vm.drafts.length : this.vm.recycles.length}`)
              .fontColor(this.vm.draftTabIndex === index ? $r('sys.color.font_on_primary') :
                $r('sys.color.font_primary'))
              .backgroundColor(this.vm.draftTabIndex === index ? $r('sys.color.comp_background_emphasize') :
                $r('sys.color.comp_background_tertiary'))
              .borderRadius(20)
              .onClick(() => {
                this.vm.draftTabIndex = index;
              })
              .padding({
                left: 16,
                right: 16,
                top: 8,
                bottom: 8,
              });
          }, (item: string) => item);
        }.width('100%').justifyContent(FlexAlign.Start);

        if (this.isShowEdit) {
          Grid() {
            ForEach(this.vm.draftTabIndex === 0 ? this.vm.drafts : this.vm.recycles, (item: EditVideo) => {
              GridItem() {
                Column({ space: 4 }) {
                  Stack({ alignContent: Alignment.TopEnd }) {
                    Image(item.previewUri).borderRadius(16);
                    Checkbox().select(item.isSelect).onChange((value: boolean) => {
                      this.vm.draftTabIndex === 0 ? this.vm.selectDraft(item, value) :
                        this.vm.selectRecycle(item, value);
                    }).visibility(this.vm.isEdit ? Visibility.Visible : Visibility.None);
                  };

                  Text(`${item.size} | ${item.duration}`).fontSize(10).opacity(0.6);
                }.alignItems(HorizontalAlign.Start).onClick(() => {
                  sdk.InitEditor();
                  this.vm.handleDraftClickEvent(item);
                });
              };
            }, (item: EditVideo) => item.videoId);
          }
          .columnsTemplate('1fr 1fr 1fr')
          .columnsGap(14)
          .rowsGap(14)
          .width('100%')
          .height('60%')
          .scrollBar(BarState.Off);
        } else {
          Column({ space: 8 }) {
            Image($r('app.media.no_draft')).size({ width: 120, height: 120 });

            Text('暂无本地草稿').fontSize(14).opacity(0.6);
          };
        }
      };
    }.height('calc(100% - 48vp)').padding(16);
  }

  @Builder
  OperateArea() {
    if (this.vm.isEdit) {
      Row() {
        Column({ space: 8 }) {
          Image($r('app.media.ic_delete_draft')).size({ width: 24, height: 24 });
          Text('删除').fontSize(12);
        }.onClick(() => {
          this.vm.moveToRecycle();
        });
      }
      .backgroundColor($r('sys.color.background_primary'))
      .width('100%')
      .height(80)
      .justifyContent(FlexAlign.Center)
      .padding({ top: 8, bottom: 16 })
      .visibility(this.vm.draftTabIndex === 0 ? Visibility.Visible : Visibility.None);

      Row() {
        Column({ space: 8 }) {
          Image($r('app.media.restore_history')).size({ width: 24, height: 24 });
          Text('全部恢复').fontSize(12);
        }.onClick(() => {
          this.vm.restoreToDraft();
        });

        Column({ space: 8 }) {
          Image($r('app.media.ic_delete_draft')).size({ width: 24, height: 24 });
          Text('全部永久删除').fontSize(12);
        }.onClick(() => {
          this.vm.deletePermanently();
        });
      }
      .backgroundColor($r('sys.color.background_primary'))
      .width('100%')
      .height(80)
      .padding({ top: 8, bottom: 16 })
      .justifyContent(FlexAlign.SpaceEvenly)
      .visibility(this.vm.draftTabIndex === 1 ? Visibility.Visible : Visibility.None);
    }
  }

  build() {
    NavDestination() {
      Column() {
        this.CreateArea();
        this.OperateArea();
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .onSizeChange((oldValue: SizeOptions, newValue: SizeOptions) => {
        this.vm.oldScreenWidth = oldValue.width;
        this.vm.oldScreenHeight = oldValue.height;
        this.vm.screenWidth = newValue.width;
        this.vm.screenHeight = newValue.height;
      });
    }
    .backgroundColor($r('sys.color.background_secondary'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM, SafeAreaEdge.TOP])
    .title('视频剪辑')
    .onReady((ctx) => {
      this.vm.pathStack = ctx.pathStack;
    });
  }
}
