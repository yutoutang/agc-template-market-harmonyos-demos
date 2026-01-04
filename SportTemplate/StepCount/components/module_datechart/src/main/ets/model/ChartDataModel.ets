export class CharDataModel {
  data: number
  date: Date
  obj?: Object

  constructor(data: number, date: Date, obj?: Object) {
    this.data = data
    this.date = date
    this.obj = obj
  }
}