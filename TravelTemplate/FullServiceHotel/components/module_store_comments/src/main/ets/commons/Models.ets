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
  @Trace service: number = 0;
  @Trace environment: number = 0;
  @Trace device: number = 0;
  @Trace experience: number = 0;
}
