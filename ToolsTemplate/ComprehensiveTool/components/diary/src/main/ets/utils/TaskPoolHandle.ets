import { ImageUtils } from './ImageUtils';
import { taskpool } from '@kit.ArkTS';

@Concurrent
function deleteSandboxImg(imgSrcList: string[], newImgSrcList: string[]) {
  const newSet = new Set(newImgSrcList);
  const removedList = newImgSrcList.length > 0 ?
    imgSrcList.filter((src: string) => !newSet.has(src)) : imgSrcList;
  for (let i = 0; i < removedList.length; i++) {
    const src = removedList[i]
    ImageUtils.removeSandboxImg(src);
  }
}

// 将不使用的图片移除
export function handleTaskPoolDelete(imgSrcList: string[], newImgSrcList: string[] = []) {
  // 创建task并传入函数deleteSandboxImg
  let task: taskpool.Task = new taskpool.Task(deleteSandboxImg, imgSrcList, newImgSrcList);
  // 执行task任务
  taskpool.execute(task)
}