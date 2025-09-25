@ObservedV2
export class UpdateTodoPlanTimeInfo {
  @Trace deleteTaskID: string = ''
  @Trace modifyTaskID: string = ''
  @Trace modifyPlanTime: Date = new Date()
  private static _instance: UpdateTodoPlanTimeInfo

  static get instance() {
    if (!UpdateTodoPlanTimeInfo._instance) {
      UpdateTodoPlanTimeInfo._instance = new UpdateTodoPlanTimeInfo();
    }
    return UpdateTodoPlanTimeInfo._instance;
  }
}