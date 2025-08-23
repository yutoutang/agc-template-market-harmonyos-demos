export interface FavoriteAgendaObject {
  total: string;
  items: FavoriteAgendaModel[];
}

export class FavoriteAgendaModel {
  favoriteId: string
  contentType: number
  mThirdSeminarId: string
  createTime: string

  constructor(data: FavoriteAgendaModel) {
    this.favoriteId = data.favoriteId
    this.contentType = data.contentType
    this.mThirdSeminarId = data.mThirdSeminarId
    this.createTime = data.createTime
  }
}