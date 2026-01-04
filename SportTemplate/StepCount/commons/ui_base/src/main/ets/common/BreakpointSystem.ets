import mediaQuery from '@ohos.mediaquery';
import { BREAKPOINT_PROP_NAME, Width } from './Constant';
import { UiLogger } from './UiLogger';
import { AppStorageV2 } from '@kit.ArkUI';

@ObservedV2
export class Breakpoint {
  @Trace
  value: string

  constructor(value: string) {
    this.value = value;
  }
}

export class CommonBreakpointSystem {
  private static smListen: mediaQuery.MediaQueryListener = mediaQuery.matchMediaSync(`(width<${Width.SM})`);
  private static mdListen: mediaQuery.MediaQueryListener =
    mediaQuery.matchMediaSync(`(width>=${Width.SM}) and (width<${Width.MD})`);
  private static lgListen: mediaQuery.MediaQueryListener =
    mediaQuery.matchMediaSync(`(width>=${Width.MD}) and (width<${Width.LG})`);
  private static xlListen: mediaQuery.MediaQueryListener = mediaQuery.matchMediaSync(`(width>=${Width.LG})`);
  private static registered: boolean = false;

  private static updateBreakpoint(value: string) {
    AppStorageV2.connect(Breakpoint, BREAKPOINT_PROP_NAME, () => new Breakpoint(value));
    UiLogger.info(`BreakpointSystem update: ${value}`);
  }

  private static smFunc(result: mediaQuery.MediaQueryResult) {
    if (result.matches) {
      CommonBreakpointSystem.updateBreakpoint('sm');
    }
  }

  private static mdFunc(result: mediaQuery.MediaQueryResult) {
    if (result.matches) {
      CommonBreakpointSystem.updateBreakpoint('md');
    }
  }

  private static lgFunc(result: mediaQuery.MediaQueryResult) {
    if (result.matches) {
      CommonBreakpointSystem.updateBreakpoint('lg');
    }
  }

  private static xlFunc(result: mediaQuery.MediaQueryResult) {
    if (result.matches) {
      CommonBreakpointSystem.updateBreakpoint('xl');
    }
  }

  static register() {
    if (CommonBreakpointSystem.registered) {
      return;
    }
    CommonBreakpointSystem.registered = true;
    CommonBreakpointSystem.smListen.on('change', CommonBreakpointSystem.smFunc);
    CommonBreakpointSystem.mdListen.on('change', CommonBreakpointSystem.mdFunc);
    CommonBreakpointSystem.lgListen.on('change', CommonBreakpointSystem.lgFunc);
    CommonBreakpointSystem.xlListen.on('change', CommonBreakpointSystem.xlFunc);
    UiLogger.info('BreakpointSystem register success.');
  }

  static unRegister() {
    if (!CommonBreakpointSystem.registered) {
      return;
    }
    CommonBreakpointSystem.registered = false;
    CommonBreakpointSystem.smListen.off('change', CommonBreakpointSystem.smFunc);
    CommonBreakpointSystem.mdListen.off('change', CommonBreakpointSystem.mdFunc);
    CommonBreakpointSystem.lgListen.off('change', CommonBreakpointSystem.lgFunc);
    CommonBreakpointSystem.xlListen.off('change', CommonBreakpointSystem.xlFunc);
    UiLogger.info('BreakpointSystem unregister success.');
  }
}