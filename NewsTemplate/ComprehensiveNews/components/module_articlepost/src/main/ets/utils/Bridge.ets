import { RawEditorOptions } from '../options/tinymce'

class EasyEditor {
  content:string = ''
  config:string | RawEditorOptions = ''
  darkMode:boolean = false
  removeFormat:(confirm:()=> void) => void = () => {}
}

export class EasyEditorBridge {
  private editor: EasyEditor

  constructor(editor: EasyEditor) {
    this.editor = editor
  }

  onContentChanged(content: string) {
    if (this.editor) {
      this.editor.content = content
    }
  }

  fetchContent(): string {
    return this.editor?.content ?? ''
  }

  fetchConfig(): string {
    let config = this.editor?.config ?? '{}'
    if (typeof config === 'string') {
      return config
    }
    return JSON.stringify(config)
  }

  /**
   * 适配暗黑模式
   * @returns 暗黑模式
   */
  darkMode(): boolean {
    return this.editor.darkMode
  }

  /**
   * 清除格式回调
   * @returns 暗黑模式
   */
  removeFormat(confirm:() => void) {
    this.editor.removeFormat(confirm)
  }
}
