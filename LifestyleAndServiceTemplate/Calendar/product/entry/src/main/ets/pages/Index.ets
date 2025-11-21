import { ThemeModel } from 'common';
import { TabContainer } from './TabContainer'
import { PersistenceV2 } from '@kit.ArkUI';
import { RouterModule } from 'router_module';

@Entry
@ComponentV2
struct Index {
  @Local theme: ThemeModel = PersistenceV2.connect(ThemeModel, () =>new ThemeModel())!;
  build() {
    Navigation(RouterModule.getStack()) {
      TabContainer()
    }
    .hideTitleBar(true)
    .backgroundColor(this.theme.themeState.current)
    .mode(NavigationMode.Stack)
  }
}