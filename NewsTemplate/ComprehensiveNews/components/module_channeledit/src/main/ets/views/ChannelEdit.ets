import { ChannelsSortEdit } from '../components/ChannelsSortEdit'
import { CustomTabBar } from '../components/CustomTabBar'
import { TabInfo } from '../model/Model'

@ComponentV2
export struct ChannelEdit {
  @Param currentIndex: number = 1
  @Param channelsList: TabInfo[] = []
  @Param fontSizeRatio: number = 1
  @Local isShowSheet: boolean = false
  @Local selectChannelList: TabInfo[] = []
  @Event onSave: (select: TabInfo[], unselect: TabInfo[]) => void
  @Event onChange: (index: number, item: TabInfo) => void
  @Local listScroller: Scroller = new Scroller();

  aboutToAppear(): void {
    this.selectChannelList = this.channelsList.filter(value => value.selected)
  }

  sortChannelsList(channelsList: TabInfo[], selected: TabInfo[]): void {
    if (!channelsList || !selected || channelsList.length <= 1) {
      return;
    }

    const positionMap = new Map<string | number, number>();
    selected.forEach((item, index) => {
      positionMap.set(item.id, index);
    });

    channelsList.sort((a, b) => {
      const aInSelected = positionMap.has(a.id);
      const bInSelected = positionMap.has(b.id);
      if (aInSelected && bInSelected) {
        return (positionMap.get(a.id) || 0) - (positionMap.get(b.id) || 0);
      }
      if (aInSelected && !bInSelected) {
        return -1;
      }
      if (!aInSelected && bInSelected) {
        return 1;
      }
      const originalIndexA = channelsList.findIndex(item => item.id === a.id);
      const originalIndexB = channelsList.findIndex(item => item.id === b.id);
      return originalIndexA - originalIndexB;
    });
  }

  handleChannel(select: TabInfo[], unselect: TabInfo[]) {
    this.sortChannelsList(this.channelsList, select)
    let hasId = select.some(item => item.id === this.channelsList[this.currentIndex].id)
    if (!hasId) {
      this.onChange(1, this.channelsList[1])
    }
    select.forEach((item) => {
      let findValue = this.channelsList.find(value => value.id === item.id)
      if (findValue) {
        findValue.selected = true
      }
    })
    unselect.forEach((item) => {
      let findValue = this.channelsList.find(value => value.id === item.id)
      if (findValue) {
        findValue.selected = false
      }
    })
  }

  handleChange(content: TabInfo) {
    let index = this.channelsList.findIndex(item => item.id === content.id)
    if (index !== -1) {
      this.isShowSheet = false
      this.listScroller.scrollToIndex(index, true)
      this.onChange(index, content)
    }
  }

  @Builder
  gridEditSheetBuilder() {
    Column() {
      ChannelsSortEdit({
        dataList: this.channelsList,
        fontSizeRatio: this.fontSizeRatio,
        onSave: (select: TabInfo[], unselect: TabInfo[]) => {
          this.handleChannel(select, unselect)
          this.onSave(select, unselect)
        },
        onChannelClick: (content: TabInfo) => {
          this.handleChange(content)
        },
      })
    }
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Start)
    .padding({ left: 16, right: 16 })
  }

  @Builder
  sheetTitleBuilder() {
    Text('自定义')
      .fontColor($r('sys.color.font_primary'))
      .fontSize(16 * this.fontSizeRatio)
      .fontWeight(FontWeight.Medium)
  }

  build() {
    Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
      CustomTabBar({
        listScroller: this.listScroller,
        myChannels: this.channelsList.filter(value => value.selected),
        fontSizeRatio: this.fontSizeRatio,
        currentIndex: this.currentIndex,
        onIndexChange: (index: number, item: TabInfo) => {
          this.onChange(index, item)
        },
      })
        .flexGrow(1)
      Row() {
        Image($r('app.media.tab_more'))
          .width(24)
          .height(24)
          .fillColor($r('sys.color.font_primary'))
      }
      .accessibilityText('频道编辑按钮')
      .onClick(() => {
        this.isShowSheet = !this.isShowSheet
      })

    }
    .backgroundColor($r('sys.color.background_primary'))
    .bindSheet($$this.isShowSheet, this.gridEditSheetBuilder(), {
      detents: [SheetSize.MEDIUM, SheetSize.LARGE, 200],
      preferType: SheetType.BOTTOM,
      showClose: true,
      title: this.sheetTitleBuilder,
    })
    .padding({ left: 16, right: 16 })
    .height(56)
  }
}
