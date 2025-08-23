import { calendarManager } from '@kit.CalendarKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { abilityAccessCtrl, Permissions } from '@kit.AbilityKit';
import { JSON } from '@kit.ArkTS';
import { promptAction } from '@kit.ArkUI';


export async function requestCalendarPermissions(context: Context): Promise<boolean> {
  const atManager = abilityAccessCtrl.createAtManager();
  const permissions: Array<Permissions> = [
    'ohos.permission.READ_CALENDAR',
    'ohos.permission.WRITE_CALENDAR'
  ];
  try {
    const result = await atManager.requestPermissionsFromUser(context, permissions);
    return result.authResults.every(granted => granted === 0); // 检查所有权限是否授予
  } catch (error) {
    console.error(`权限申请失败: Code=${error.code}, Message=${error.message}`);
    return false;
  }
}

export async function addEvent(context: Context, eventParams: calendarManager.Event, callback: () => void) {
  const hasPermission = await requestCalendarPermissions(context);
  if (!hasPermission) {
    console.error('权限未授予');
    return;
  }

  try {
    const calendar = await calendarManager.getCalendarManager(context).getCalendar();
    const event: calendarManager.Event = {
      type: calendarManager.EventType.NORMAL,
      title: eventParams.title,
      startTime: eventParams.startTime * 1000,
      endTime: eventParams.endTime * 1000,
      location: eventParams.location,
      reminderTime: [30],
      service: eventParams.service
    };
    calendar.addEvent(event, (err: BusinessError, data: number): void => {
      if (err) {
        console.error(`Failed to addEvent, err -> ${JSON.stringify(err)}`);
        promptAction.showToast({ message: '添加失败' })
      } else {
        console.info(`Succeeded to add event, id -> ${data}`);
        promptAction.showToast({ message: '添加成功' })
        callback()
      }
    });
  } catch (error) {
    console.error(`添加失败: Code=${error.code}, Message=${error.message}`);
    promptAction.showToast({ message: '添加失败' })
  }
}


export async function requestPermissionOnSetting(context: Context) {
  const permissions: Permissions[] = ['ohos.permission.READ_CALENDAR','ohos.permission.WRITE_CALENDAR'];
  let atManager = abilityAccessCtrl.createAtManager();
  return atManager.requestPermissionOnSetting(context, permissions)
    .then((data: Array<abilityAccessCtrl.GrantStatus>) => {
      console.info('data:' + JSON.stringify(data));
    })
    .catch((err: BusinessError) => {
      console.error('data:' + JSON.stringify(err));
    });
}
