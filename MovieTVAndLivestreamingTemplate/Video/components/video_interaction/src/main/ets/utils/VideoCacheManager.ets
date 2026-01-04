import fs from '@ohos.file.fs'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { BusinessError, request } from '@kit.BasicServicesKit'

const TAG = 'VideoCacheManager'

/**
 * 视频缓存管理器，负责视频的下载、缓存和持久化
 */
export class VideoCacheManager {
  // 缓存目录名称
  private static readonly CACHE_DIR = 'video_cache'
  // 最大缓存大小(500MB)
  private static readonly MAX_CACHE_SIZE = 500 * 1024 * 1024
  // 应用缓存目录路径
  private cacheDirPath: string = ''
  // 上下文对象
  private context: Context

  /**
   * 构造函数
   * @param context 应用上下文
   */
  constructor(context: Context) {
    this.context = context
    this.initCacheDir()
  }

  /**
   * 下载视频并缓存
   * @param url 视频URL
   * @param progressCallback 进度回调函数
   * @returns 缓存文件路径
   */
  async downloadAndCacheVideo(
    url: string,
    progressCallback?: (receivedSize: number, totalSize: number) => void,
    completeCallback?: () => void,
    failCallback?: (error: number) => void,
  ) {
    // 检查是否已缓存
    const cachedPath = this.getCachedVideoPath(url)
    if (fs.accessSync(cachedPath)) {
      hilog.info(0x0000, TAG, `视频已缓存: ${cachedPath}`)
    } else {
      try {
        // 文件下载
        request.downloadFile(this.context, {
          url: url,
          filePath: cachedPath
        }).then((downloadTask: request.DownloadTask) => {
          // 下载进度
          downloadTask.on('progress', (receivedSize: number, totalSize: number) => {
            hilog.info(0x0000, TAG, '%{public}s', 'download receivedSize:' + receivedSize + ' totalSize:' + totalSize)
            progressCallback(receivedSize, totalSize)
          })
          //下载完成
          downloadTask.on('complete', () => {
            hilog.info(0x0000, TAG, 'download complete receivedSize: %{public}s', fs.lstatSync(cachedPath).size)
            completeCallback()
          })
          downloadTask.on('fail', (error: number) => {
            failCallback(error)
          })
        }).catch((err: BusinessError) => {
          hilog.error(0x0000, TAG, `downloadTask failed, code is ${err.code}, message is ${err.message}`)
        })

      } catch (error) {
        hilog.error(0x0000, TAG, `下载视频失败: ${(error as BusinessError).message}`)
        // 清理可能的不完整文件
        if (fs.accessSync(cachedPath)) {
          fs.unlinkSync(cachedPath)
        }
        throw error
      }
    }
  }


  /**
   * 获取缓存的视频路径
   * @param url 视频URL
   * @returns 缓存文件路径
   */
  getCachedVideoPath(url: string): string {
    // 使用URL的哈希值作为文件名，避免特殊字符问题
    const hash = this.hashUrl(url)
    // 提取文件扩展名
    const ext = this.getFileExtension(url) || 'mp4'
    return `${this.cacheDirPath}/${hash}.${ext}`
  }

  /**
   * 计算URL的哈希值
   * @param url 视频URL
   * @returns 哈希字符串
   */
  private hashUrl(url: string): string {
    let hash = 0
    for (let i = 0; i < url.length; i++) {
      const char = url.charCodeAt(i)
      hash = ((hash << 5) - hash) + char
      hash = hash & hash // 转换为32位整数
    }
    return Math.abs(hash).toString(16)
  }

  /**
   * 从URL获取文件扩展名
   * @param url 视频URL
   * @returns 文件扩展名
   */
  private getFileExtension(url: string): string | null {
    const match = url.match(/\.([0-9a-z]+)(?:[\?#]|$)/i)
    return match && match[1] ? match[1] : null
  }


  /**
   * 初始化缓存目录
   */
  private async initCacheDir() {
    try {
      // 获取应用缓存目录
      const cacheDir = this.context.filesDir
      this.cacheDirPath = `${cacheDir}/${VideoCacheManager.CACHE_DIR}`

      try {
        if (!fs.accessSync(this.cacheDirPath)) {
          fs.mkdirSync(this.cacheDirPath)
        }
      } catch (err) {
        hilog.error(0x0000, TAG, 'mkdirSync error %{public}s', JSON.stringify(err))
      }
      // 检查缓存大小，超过限制则清理
      try {
        const totalSize = await this.calculateCacheSize()
        hilog.info(0x0000, TAG, 'check current totalSize %{public}d', totalSize)
        if (totalSize > VideoCacheManager.MAX_CACHE_SIZE) {
          hilog.info(0x0000, TAG, '缓存超过最大限制，开始清理...')
          await this.cleanOldestCache(totalSize - VideoCacheManager.MAX_CACHE_SIZE)
        }
      } catch (error) {
        hilog.error(0x0000, TAG, 'checkAndCleanCache error %{public}d', (error as BusinessError).message)
      }
    } catch (error) {
      hilog.error(0x0000, TAG, 'initCacheDir error %{public}s', (error as BusinessError).message)
    }
  }

  /**
   * 计算缓存总大小
   * @returns 缓存总大小(字节)
   */
  private async calculateCacheSize(): Promise<number> {
    return new Promise((resolve, reject) => {
      let totalSize = 0
      try {
        const files = fs.listFileSync(this.cacheDirPath)
        files.forEach(file => {
          const filePath = `${this.cacheDirPath}/${file}`
          const stat = fs.statSync(filePath)
          if (stat.isFile()) {
            totalSize += stat.size
          }
        })
        resolve(totalSize)
      } catch (error) {
        reject(error)
      }
    })
  }

  /**
   * 清理最旧的缓存，直到释放指定的空间
   * @param spaceToFree 需要释放的空间(字节)
   */
  private async cleanOldestCache(spaceToFree: number): Promise<void> {
    return new Promise((resolve, reject) => {
      try {
        // 获取所有缓存文件并按修改时间排序
        const files = fs.listFileSync(this.cacheDirPath)
          .map(file => {
            const filePath = `${this.cacheDirPath}/${file}`
            const stat = fs.statSync(filePath)
            return {
              path: filePath,
              mtime: stat.mtime,
              size: stat.size
            }
          })
          .filter(file => !file.path.endsWith('/')) // 排除目录
          .sort((a, b) => a.mtime - b.mtime) // 按修改时间升序排序(最旧的在前)

        let freedSpace = 0

        // 逐个删除最旧的文件，直到释放足够的空间
        for (const file of files) {
          if (freedSpace >= spaceToFree) {
            break
          }

          fs.unlinkSync(file.path)
          freedSpace += file.size

          hilog.info(0x0000, TAG, `删除缓存文件: ${file.path}, 释放空间: ${file.size} bytes`)
        }
        hilog.info(0x0000, TAG, `缓存清理完成，共释放空间: ${freedSpace} bytes`)
        resolve()
      } catch (error) {
        reject(error)
      }
    })
  }

  /**
   * 清理所有缓存
   */
  async clearAllCache(): Promise<void> {
    return new Promise((resolve, reject) => {
      try {
        const files = fs.listFileSync(this.cacheDirPath)
        files.forEach(file => {
          const filePath = `${this.cacheDirPath}/${file}`
          const stat = fs.statSync(filePath)
          if (stat.isFile()) {
            fs.unlinkSync(filePath)
            hilog.info(0x0000, TAG, `删除缓存文件: ${filePath}`)
          } else if (stat.isDirectory()) {
            fs.rmdirSync(filePath)
            hilog.info(0x0000, TAG, `删除缓存目录: ${filePath}`)
          }
        })
        hilog.info(0x0000, TAG, '所有缓存已清理')
        resolve()
      } catch (error) {
        reject(error)
      }
    })
  }
}