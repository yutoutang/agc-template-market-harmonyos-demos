export class TaskModel {
  title: string
  titleIcon: string = 'app.media.award_coin'
  subTitle: string = '每天最多+500看点'

  constructor(title: string, titleIcon?: string, subTitle?: string) {
    this.title = title
    if (titleIcon) {
      this.titleIcon = titleIcon
    }
    if (subTitle) {
      this.subTitle = subTitle
    }
  }
}