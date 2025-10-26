
@ObservedV2
export class HtmlModel {
  @Trace initialHtmlContent: string = ''
  @Trace undoStack: string[] = [];
  @Trace redoStack: string[] = [];
  @Trace htmlContent: string = ''

  // 内容发生变化
  htmlContentChange(html: string) {
    this.htmlContent = html;
  }

  // 撤销操作
  undo(currentHtml: string) {
    if (this.undoStack.length > 0) {
      // 当前值放进 redo 栈
      this.redoStack.push(currentHtml);
      this.undoStack.pop();
    }
    if (this.initialHtmlContent === currentHtml) {
      this.undoStack = [];
    }
  }

  // 取消撤销操作
  redo(currentHtml: string) {
    if (this.redoStack.length > 0) {
      // 当前值放进 undo 栈
      this.undoStack.push(currentHtml);
      this.redoStack.pop();
    }
  }
}