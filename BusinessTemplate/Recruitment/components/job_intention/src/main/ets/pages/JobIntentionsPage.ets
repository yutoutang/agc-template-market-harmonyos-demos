import { UIContext, KeyboardAvoidMode } from '@kit.ArkUI';
import { PageName } from '../common/CustomTypes';
import { JobIntentions } from '../components/JobIntentions';
import { TitleBar } from '../components/TitleBar';
import { CareerObjectiveItem, CareerObjectiveModel } from '../viewmodel/CareerObjectiveModel';

@Builder
export function JobIntentionsPageBuilder() {
  JobIntentionsPage()
}

@ComponentV2
struct JobIntentionsPage {
  @Local navPathStack: NavPathStack = new NavPathStack();
  private uiContext: UIContext = this.getUIContext();
  private cacheKeyboardAvoidMode: KeyboardAvoidMode = KeyboardAvoidMode.OFFSET;
  goToDetail = (index: number, item?: CareerObjectiveItem) => {
    CareerObjectiveModel.instance.startEdit(index, item)
    this.navPathStack.pushPathByName(PageName.CareerObjective, null)
  }

  public aboutToAppear(): void {
    this.cacheKeyboardAvoidMode = this.uiContext.getKeyboardAvoidMode();
  }

  build() {
    NavDestination() {
      Column() {
        TitleBar({
          title: '求职意向',
          onBack: () => this.navPathStack.pop('back')
        })

        JobIntentions({ goToDetail: this.goToDetail })
      }
      .width('100%')
      .height('100%')
      .padding({
        top: 32,
        bottom: 32,
        left: 16,
        right: 16
      })
      .backgroundColor('#FFF1F3F5')
    }
    .hideTitleBar(true)
    .onShown(() => this.uiContext.setKeyboardAvoidMode(KeyboardAvoidMode.RESIZE))
    .onWillDisappear(() => this.uiContext.setKeyboardAvoidMode(this.cacheKeyboardAvoidMode))
    .onReady((ctx: NavDestinationContext) => this.navPathStack = ctx.pathStack)
    .onBackPressed(() => {
      this.navPathStack.pop('back')
      return true
    })
  }
}

