// todo: AgentFrameworkKit小艺智能体相关功能，暂不支持模拟器，请使用真机调试
// import { FunctionComponent, FunctionController } from '@kit.AgentFrameworkKit';
import { common } from '@kit.AbilityKit';
import { AppConstants } from 'lib_common';
import { UtilLog } from '@hw-agconnect/util-log';

@ComponentV2
export struct BaseAgent {
  @Param queryText: string = '';
  @Param sizeType: ControlSize = ControlSize.SMALL;
  @Local isAgentSupport: boolean = false;
  // todo: AgentFrameworkKit小艺智能体相关功能，暂不支持模拟器，请使用真机调试
  // functionController: FunctionController = new FunctionController();

  aboutToAppear() {
    this.checkAgentSupport(this.getUIContext());
  }

  async checkAgentSupport(uiContext: UIContext) {
    try {
      let context = uiContext?.getHostContext() as common.UIAbilityContext;
      // todo: AgentFrameworkKit小艺智能体相关功能，暂不支持模拟器，请使用真机调试
      // this.isAgentSupport = await this.functionController.isAgentSupport(context, AppConstants.AGENT_ID);
    } catch (err) {
      UtilLog.error(0x0001, 'check agent support failed', `err code: ${err.code}, message: ${err.message}`);
    }
  }

  build() {
    if (this.isAgentSupport) {
      /* todo: AgentFrameworkKit小艺智能体相关功能，暂不支持模拟器，请使用真机调试
      FunctionComponent({
        agentId: AppConstants.AGENT_ID,
        onError: (err: BusinessError) => {
          UtilLog.error(0x0001, 'News Agent', `err: ${JSON.stringify(err)}, message: ${err.message}`);
        },
        options: {
          title: '新闻助手',
          queryText: this.queryText,
          titleFontSize: 14,
          controlSize: this.sizeType,
        },
      });
      */
    }
  }
}