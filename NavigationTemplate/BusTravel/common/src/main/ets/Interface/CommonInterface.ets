export class PushParams {
  'payload': Record<string, Notification | string>
  'target': Record<string, Array<string>>
  'pushOptions'?: Record<string, boolean>
}

export class Notification {
  'category': string = ''
  'title': string = ''
  'body': string = ''
  'clickAction': Record<string, number>
  'notifyId': number = 0
}