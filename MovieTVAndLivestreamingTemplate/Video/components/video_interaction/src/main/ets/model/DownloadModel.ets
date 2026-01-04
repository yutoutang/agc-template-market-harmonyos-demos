export enum DownloadStatus {
  Cancel = 0,
  Loading = 1,
  Complete = 2
}

@ObservedV2
export class UrlModel {
  @Trace id: string
  @Trace status: DownloadStatus
  @Trace url: string
  @Trace taskId?: string = ''

  constructor(id: string, status: DownloadStatus, url: string) {
    this.id = id
    this.status = status
    this.url = url
  }
}