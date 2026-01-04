import { common } from '@kit.AbilityKit';

export class GlobalContext {
  private static context: common.UIAbilityContext;
  private static uiContext: UIContext;

   public  static async initUIAbilityContext(context: common.UIAbilityContext): Promise<void> {
    GlobalContext.context = context;
  }

  public static getUIAbilityContext(): common.UIAbilityContext {
    return GlobalContext.context;
  }

  public static initUIContext(context: UIContext): void {
    GlobalContext.uiContext = context;
  }

  public static getUIContext(): UIContext {
    return GlobalContext.uiContext;
  }
}