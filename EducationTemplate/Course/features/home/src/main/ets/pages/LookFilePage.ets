/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { pdfService, PdfView, pdfViewManager } from '@kit.PDFKit';
import { fileIo } from '@kit.CoreFileKit';
import { TopBar } from 'commonlib';
import { emitter } from '@kit.BasicServicesKit';

@ComponentV2
export struct LookFilePage {
  private controller: pdfViewManager.PdfController = new pdfViewManager.PdfController();

  aboutToAppear(): void {
    let context = this.getUIContext().getHostContext() as Context;
    let dir: string = context.filesDir
    // 确保在工程目录src/main/resources/rawfile里存在input.pdf文档
    let filePath: string = dir + '/PiPConfiguration.pdf';
    let res = fileIo.accessSync(filePath);
    if (!res) {
      let content: Uint8Array = context.resourceManager.getRawFileContentSync('rawfile/PiPConfiguration.pdf');
      let fdSand =
        fileIo.openSync(filePath, fileIo.OpenMode.WRITE_ONLY | fileIo.OpenMode.CREATE | fileIo.OpenMode.TRUNC);
      fileIo.writeSync(fdSand.fd, content.buffer);
      fileIo.closeSync(fdSand.fd);
    }
    (async () => {
      // 该监听方法只能在文档加载前调用一次
      this.controller.registerPageCountChangedListener((pageCount: number) => {
      });
      await this.controller.loadDocument(filePath);
    })()
  }

  aboutToDisappear(): void {
    emitter.emit('livePlayer', { data: { isPlaying: true } })
  }

  build() {
    Column() {
      TopBar({ title: '预览' })
        .margin({ left: $r('app.float.vp_16') })
      PdfView({
        controller: this.controller,
        pageFit: pdfService.PageFit.FIT_WIDTH,
        showScroll: true
      })
        .id('pdfview_app_view')
        .layoutWeight(1);
    }
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Start)
    .width('100%')
    .height('100%')
  }
}

@Builder
export function LookFileBuilder() {
  LookFilePage()
}