import { BaseTitle } from './basic/BaseTitle';

@ComponentV2
export struct CartPageHeader {
  // 购物车页面是否是作为子路由页面
  @Param isChildRoute: boolean = false;
  // 是否展示管理按钮
  @Param showEdit: boolean = false;
  // 是否编辑态
  @Param isEdit: boolean = false;
  // 切换编辑的回调
  @Event changeEdit: () => void = () => {};
  // 作为子页面时，返回事件回调
  @Event onBack: () => void = () => {};

  @Builder
  titleContentView() {
    Row() {
      Text('购物车')
        .fontSize(this.isChildRoute ? $r('sys.float.Title_S') : $r('sys.float.Title_M'))
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Bold)

      if (this.showEdit) {
        Column() {
          Text(this.isEdit ? '退出管理' : '管理')
            .fontColor($r('sys.color.mask_secondary'))
            .fontSize(14)
        }
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          this.changeEdit();
        })
      }
    }
    .width('100%')
    .height('100%')
    .padding({left: this.isChildRoute ? 0 : 12, right: 12})
    .justifyContent(FlexAlign.SpaceBetween)
  }
  build() {
    BaseTitle({
      showBackBtn: this.isChildRoute,
      onBack: () => {
        this.onBack && this.onBack();
      },
      titleContentBuilder: () => {
        this.titleContentView();
      },
    })
  }
}