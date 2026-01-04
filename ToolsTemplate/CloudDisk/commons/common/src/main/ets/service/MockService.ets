/**
 * @fileType: common
 * @zhName: 模拟数据服务类
 */
import { JSON, util } from '@kit.ArkTS';
import { BusinessError } from '@kit.BasicServicesKit';
import { FileInfoPlain, FileType } from '../model/FileInfo';
import { FileInfo, TCLogger } from '../../../../Index';
import { PreferenceUtil } from '../util/PreferenceUtil';

const mockPrivateSpaceName: string = '隐私空间'
const TAG: string = 'MockService'
const currentFileListKey: string = 'currentFileList'
const recycleBinFileListKey: string = 'recycleBinFileList'
const collectFileListKey: string = 'collectFileList'
const privateSpaceListKey: string = 'privateSpaceList'

// 模拟数据
@ObservedV2
export class MockService {
  // 添加trace时赋值给别的trace变量时不会生成新的地址
  @Trace public static currentFileList: FileInfo[] = [];
  @Trace public static allFileList: FileInfo[] = [];
  // 全局下载,上传,分享,回收站,收藏数组
  @Trace public static fileResult: FileMockInfo[] = []
  @Trace public static downloadFileList: FileInfo[] = [];
  @Trace public static uploadFileList: FileInfo[] = [];
  @Trace public static shareFileList: FileInfo[] = [];
  @Trace public static recycleBinFileList: FileInfo[] = [];
  @Trace public static collectFileList: FileInfo[] = [];
  // 隐私空间
  public static privateSpaceInfo: FileInfo = new FileInfo(FileType.PrivateSpace, mockPrivateSpaceName)

  public static init() {
    const preferenceUtil: PreferenceUtil = PreferenceUtil.getInstance()
    // 取缓存数据
    if (preferenceUtil.has(currentFileListKey)) {
      // 文件列表
      const currentStr: string = preferenceUtil.get(currentFileListKey) as string
      let currentArr: FileInfoPlain[] = JSON.parse(currentStr) as FileInfoPlain[]
      MockService.currentFileList = currentArr.map(item => FileInfo.fromPlain(item))

      // 隐私空间
      if (preferenceUtil.has(privateSpaceListKey)) {
        const privateSpaceContent: string = preferenceUtil.get(privateSpaceListKey) as string
        MockService.privateSpaceInfo = FileInfo.fromPlain(JSON.parse(privateSpaceContent) as FileInfoPlain)
      } else {
        TCLogger.info(TAG, 'privatespace is default')
      }

      // 回收站
      if (preferenceUtil.has(recycleBinFileListKey)) {
        const recycleBinStr: string = preferenceUtil.get(recycleBinFileListKey) as string
        let recycleBinArr: FileInfoPlain[] = JSON.parse(recycleBinStr) as FileInfoPlain[]
        MockService.recycleBinFileList = recycleBinArr.map(item => FileInfo.fromPlain(item))
      } else {
        TCLogger.info(TAG, 'collect is default')
      }

      // 收藏列表ids
      if (preferenceUtil.has(collectFileListKey)) {
        const collectIds: number[] = preferenceUtil.get(collectFileListKey) as number[]
        MockService.searchCollectContent(collectIds, MockService.currentFileList)
        MockService.searchCollectContent(collectIds, MockService.recycleBinFileList)
      } else {
        TCLogger.info(TAG, 'collect is defalut')
      }

      // 首页文件
      MockService.searchAllFiles(MockService.currentFileList)

      return
    }
  }

  // 查找收藏内容
  private static searchCollectContent(ids: number[], fileList: FileInfo[]) {
    fileList.forEach(item => {
      if (ids.includes(item.fileId)) {
        MockService.collectFileList.push(item)
      } else {
        TCLogger.info(TAG, 'current is not collected')
      }

      if (item.contentList.length > 0) {
        MockService.searchCollectContent(ids, item.contentList)
      } else {
        TCLogger.info(TAG, 'contentlist is empty')
      }
    })
  }

  // 查找收藏内容
  private static searchAllFiles(fileList: FileInfo[]) {
    fileList.forEach(item => {
      if (item.fileType !== FileType.Director) {
        MockService.allFileList.push(item)
      } else {
        MockService.searchAllFiles(item.contentList)
      }
    })
  }

  public static searchFileListBy(ids: Set<number>, fileList: FileInfo[],target: FileInfo[]) {
    fileList.forEach(item => {
      if (ids.has(item.fileId)) {
        target.push(item)
      } else {
        MockService.searchFileListBy(ids, item.contentList, target)
      }
    })
  }

  public static backUpCurrentFileList() {
    MockService.fileResult.forEach((mockInfo: FileMockInfo, index: number) => {
      const fileInfo: FileInfo = MockService.createFileInfoInstanceBy(mockInfo)
      if (MockService.fileResult.length - 1 === index) {
        MockService.currentFileList.push(fileInfo)
      }
    })
  }

  // 文件还原
  public static restoreFileList(fileList: FileInfo[]) {
    let result: FileInfo[] = []
    fileList.forEach((item) => {
      let searchItem: FileInfo | undefined =
        MockService.searchFileInfoBy(item.parentFileId, MockService.currentFileList)
      if (searchItem === undefined) {
        result.push(item)
      } else {
        MockService.addFileListToTargetList([item], searchItem.contentList)
      }
    })

    if (result.length === 0) {
      TCLogger.info(TAG, 'filelist is all restore')
      return
    }

    MockService.addFileListToTargetList(result, MockService.currentFileList)
  }

  // 查找父类文件
  public static searchFileInfoBy(parentFileId: number, fileList: FileInfo[]): FileInfo | undefined {
    if (parentFileId === 0) {
      return undefined
    }

    for (let index = 0; index < fileList.length; index++) {
      const element = fileList[index];
      if (element.fileId === parentFileId) {
        return element
      }

      if (element.fileId === 0) {
        continue
      }

      let result = MockService.searchFileInfoBy(parentFileId, element.contentList)
      if (result !== undefined) {
        return result
      }

      TCLogger.info(TAG, 'current place not found')
    }

    return undefined
  }

  // 判断文件是否在根目录下
  public static checkFileIsBasicPath(fileId: number, fileList: FileInfo[]): boolean {
    if (fileId === 0) {
      return false
    }

    for (let index = 0; index < fileList.length; index++) {
      const element = fileList[index];
      if (element.fileId === fileId) {
        TCLogger.info(TAG, `current place found, fileId: ${element.fileId}`)
        return true
      }
    }

    return false
  }

  // 添加文件到隐私空间-首页
  public static addFileListToPrivateSpaceHomePage(fileList: FileInfo[]) {
    const ids: Set<number> = new Set()
    MockService.privateSpaceInfo.contentList.forEach((item) => {
      ids.add(item.fileId)
    })

    fileList.forEach((item) => {
      if (ids.has(item.fileId)) {
        TCLogger.info(TAG, 'file is existed')
      } else {
        const fatherItem = MockService.searchFileInfoBy(item.parentFileId, MockService.currentFileList)
        if (fatherItem !== undefined) {
          MockService.deleteFileListFromTargetList([item], fatherItem.contentList)
        } else {
          TCLogger.info(TAG, 'not found homepage ')
        }
        MockService.privateSpaceInfo.contentList.push(item)
      }
    })
  }

  // 添加文件到隐私空间-文件列表
  public static addFileListToPrivateSpaceFilePage(fileList: FileInfo[]) {
    MockService.dealWithRecycleAddFiles(fileList, MockService.privateSpaceInfo.contentList)
    MockService.addFileListToTargetList(fileList, MockService.privateSpaceInfo.contentList)
  }

  // 递归创建文件信息
  private static createFileInfoInstanceBy(mockInfo: FileMockInfo): FileInfo {
    const fileInfo: FileInfo = new FileInfo(mockInfo.fileType, mockInfo.fileName, mockInfo.createTime)
    fileInfo.fileId = mockInfo.fileId
    fileInfo.parentFileId = mockInfo.parentFileId ?? 0
    fileInfo.fileSize = mockInfo.fileSize ?? ''
    fileInfo.resolution = mockInfo.resolution ?? ''
    fileInfo.updateTime = mockInfo.updateTime ?? ''
    fileInfo.path = mockInfo.path ?? ''
    fileInfo.downloadUrl = mockInfo.downloadUrl ?? ''
    fileInfo.duration = mockInfo.duration ?? ''
    fileInfo.thumbnailUrl = mockInfo.thumbnailUrl ?? ''
    if (mockInfo.childFiles !== undefined && mockInfo.childFiles.length > 0) {
      mockInfo.childFiles.forEach((subInfo: FileMockInfo) => {
        const childInfo = MockService.createFileInfoInstanceBy(subInfo)
        fileInfo.contentList.push(childInfo)
      })
    }

    return fileInfo
  }

  // 添加文件到指定数组,不改变原数组
  public static addFileListToTargetList(fileList: FileInfo[], targetList: FileInfo[]) {
    // 回收站需要判断是否已有列表，并判断列表内容
    if (targetList === MockService.recycleBinFileList) {
      MockService.dealWithRecycleAddFiles(fileList, targetList)
    }

    const ids: Set<number> = new Set()
    targetList.forEach((item) => {
      ids.add(item.fileId)
    })

    fileList.forEach((item) => {
      if (ids.has(item.fileId)) {
        TCLogger.info(TAG, 'file is existed')
      } else {
        targetList.push(item)
      }
    })
  }

  // 处理回收站添加文件前的清理
  private static dealWithRecycleAddFiles(fileList: FileInfo[], targetList: FileInfo[]) {
    // 处理文件添加到回收站,先删除文件然后才能删除文件夹
    fileList.forEach((item) => {
      for (let i = targetList.length - 1; i >= 0; i--) {
        const element = targetList[i];
        if (element.parentFileId === 0) {
          continue
        }

        // 确认父子关系,当前列表中移出还原到原始列表
        if (element.parentFileId === item.fileId) {
          targetList.splice(i, 1)
          item.contentList.push(element)
          continue
        }

        // 非父子关系，向下一级查找
        let nextLevelFileInfo = MockService.searchFileInfoBy(element.parentFileId, item.contentList)
        if (nextLevelFileInfo !== undefined) {
          targetList.splice(i, 1)
          nextLevelFileInfo.contentList.push(element)
          continue
        }

        // 当前目录到下一级目录都未查询到
        TCLogger.info(TAG, 'collectlist not found')
      }
    })
  }

  // 从原数组中删除指定内容,不改变原数组
  public static deleteFileListFromTargetList(fileList: FileInfo[], targetList: FileInfo[]) {
    if (fileList.length === 0) {
      TCLogger.info(TAG, 'delete list is empty')
      return
    }

    // 待删除id列表
    const ids: Set<number> = new Set()
    fileList.forEach((item) => {
      ids.add(item.fileId)
    })

    // 待删除索引列表
    let delIndexes: number[] = []
    targetList.forEach((item, index) => {
      if (ids.has(item.fileId)) {
        delIndexes.push(index)
      }
    })

    // 倒叙
    delIndexes.sort((a: number, b: number) => {
      return b - a
    })

    for (let i = targetList.length - 1; i >= 0; i--) {
      if (delIndexes.includes(i)) {
        targetList.splice(i, 1)
      }
    }
  }

  // 添加数组，避免重复添加,返回新数组
  public static addFileList(add: FileInfo[], to: FileInfo[]): FileInfo[] {
    let result: FileInfo[] = []
    const ids: Set<number> = new Set()
    to.forEach((item) => {
      result.push(item)
      ids.add(item.fileId)
    })

    add.forEach((item) => {
      if (!ids.has(item.fileId)) {
        result.push(item)
      }
    })

    return result
  }

  // 删除数组,返回新数组
  public static deleteFileList(del: FileInfo[], from: FileInfo[]): FileInfo[] {
    let result: FileInfo[] = []
    const ids: Set<number> = new Set()
    del.forEach((item) => {
      ids.add(item.fileId)
    })

    result = from.filter((item) => !ids.has(item.fileId))

    return result
  }

  // 保存所有数据
  public static saveAllContent() {
    const preferenceUtil: PreferenceUtil = PreferenceUtil.getInstance()

    // 文件列表
    const subList: FileInfo[] = MockService.currentFileList.filter((item) => item.fileType !== FileType.PrivateSpace)
    const currentStr: string = JSON.stringify(subList.map(item => item.toJSON()))
    preferenceUtil.put(currentFileListKey, currentStr ?? '')
    TCLogger.info(TAG, 'currentStr=' + currentStr)

    // 收藏列表ids
    if (MockService.collectFileList.length > 0) {
      let collectIds: number[] = []
      MockService.collectFileList.forEach(item => collectIds.push(item.fileId))
      preferenceUtil.put(collectFileListKey, collectIds)
    } else {
      preferenceUtil.delete(collectFileListKey)
      TCLogger.info(TAG, 'collect is empty')
    }

    // 回收站
    if (MockService.recycleBinFileList.length > 0) {
      const recycleBinStr: string = JSON.stringify(MockService.recycleBinFileList.map(item => item.toJSON()))
      preferenceUtil.put(recycleBinFileListKey, recycleBinStr ?? '')
    } else {
      preferenceUtil.delete(recycleBinFileListKey)
      TCLogger.info(TAG, 'collect is empty')
    }

    // 隐私空间
    if (MockService.privateSpaceInfo.contentList.length > 0) {
      const privateSpaceStr: string = JSON.stringify(MockService.privateSpaceInfo)
      preferenceUtil.put(privateSpaceListKey, privateSpaceStr ?? '')
    } else {
      preferenceUtil.delete(privateSpaceListKey)
      TCLogger.info(TAG, 'privatespace is empty')
    }

  }
}

interface FileMockInfo {
  fileId: number,
  parentFileId: number,
  fileName: string,
  fileType: number,
  fileSize?: string,
  resolution?: string,
  createTime: string,
  updateTime?: string,
  path?: string,
  downloadUrl?: string,
  thumbnailUrl?: string,
  duration?: string,
  childFiles?: FileMockInfo[]
}
