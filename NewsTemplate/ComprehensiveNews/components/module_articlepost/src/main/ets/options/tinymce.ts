interface BaseEditorOptions {
  before_init?: BridgeCallbackFuncBody
  init_instance_callback?: SetupCallback;
}

export interface RawEditorOptions extends BaseEditorOptions {
  external_plugins?: Record<string, string>;
  mobile?: RawEditorOptions;
  plugins?: string | string[];
}

declare class CallbackFunc {
  type: 'defined' | 'ref'
  name?: string
  definedBody?: string
}

type BridgeCallbackFuncBody = CallbackFunc
type SetupCallback = BridgeCallbackFuncBody