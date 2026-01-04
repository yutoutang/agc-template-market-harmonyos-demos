@ObservedV2
export class CommentModel {
  @Trace location: string = '';
  @Trace totalRate: number = 0;
  @Trace detailRate: DetailRateModel = new DetailRateModel();
  @Trace desc: string = '';
  @Trace isAnonymous: number = 1;
  @Trace enableImg: boolean = false;
}

@ObservedV2
export class DetailRateModel {
  @Trace taste: number = 0;
  @Trace packing: number = 0;
  @Trace delivery: number = 0;
  @Trace experience: number = 0;
}
