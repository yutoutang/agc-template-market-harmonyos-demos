import { RouteMap } from './common/CommonConst';
import { Context, Contact,SelectMode } from './common/Types';


@ComponentV2
export struct PersonManage {
  @Param
  public navPathStack: NavPathStack = new NavPathStack();
  @Param
  public selectMode: SelectMode = SelectMode.SINGLE_SELECT;
  @Param
  public disableId:string[]=[]
  @BuilderParam
  private contentBuilder: () => void = buildEmptyComponent;
  private readonly ctx: Context = new Context();

  @Event
  public onSelect: (data: Contact | Contact[]) => void = () => {
  };

  @Event
  public onBeforeNavigate: () => boolean = () => true;

  public aboutToAppear(): void {
    this.ctx.navPathStack = this.navPathStack;
    this.ctx.selectMode = this.selectMode;
    this.ctx.onSelect = this.onSelect;
    this.ctx.disableId = this.disableId
  }

  @Monitor('navPathStack', 'selectMode', 'onSelect','disableId')
  public onAttributeChange(iMonitor: IMonitor): void {
    for (let k of iMonitor.dirty) {
      let v: IMonitorValue<ESObject> | undefined = iMonitor.value<ESObject>(k);
      if (v) {
        switch (k) {
          case 'navPathStack':
            this.ctx.navPathStack = v.now as NavPathStack;
            break;
          case 'selectMode':
            this.ctx.selectMode = v.now as SelectMode;
            break;
          case 'disableId':
            this.ctx.disableId = v.now as string[];
            break;
          case 'onSelect':
            this.ctx.onSelect = v.now as (data: Contact | Contact[]) => void;
            break;
        }
      }
    }
  }

  public build(): void {
    Column() {
      this.contentBuilder();
    }
    .width('auto')
    .height('auto')
    .onClick(() => {
      if (this.onBeforeNavigate()) {
        this.navPathStack.pushPathByName(RouteMap.COMMON_PERSON_PAGE, this.ctx);
      }
    });
  }
}

@Builder
function buildEmptyComponent() {
  // No need to do anything
}
