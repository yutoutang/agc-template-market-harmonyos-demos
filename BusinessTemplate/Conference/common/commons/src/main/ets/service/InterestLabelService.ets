
export class InterestLabelService {
  private  static _instance: InterestLabelService;
  public static get instance() {
    if (!InterestLabelService._instance) {
      InterestLabelService._instance = new InterestLabelService()
    }
    return InterestLabelService._instance;
  }

  private interestLabels: string = '';

  public setInterestLabels(labels: string) {
   this.interestLabels = labels;
  }

  public getInterestLabels() {
    return this.interestLabels;
  }
}