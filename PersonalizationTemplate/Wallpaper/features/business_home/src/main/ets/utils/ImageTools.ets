import { image } from '@kit.ImageKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { fileIo, ReadOptions } from '@kit.CoreFileKit';
import { util } from '@kit.ArkTS';
import { http } from '@kit.NetworkKit';
import { promptAction } from '@kit.ArkUI';


export type ImageType = fileIo.File | string | ArrayBuffer;

export class ImageTools {
  protected file: fileIo.File
  protected name: string
  protected format: string
  private context: Context = getContext()
  private dir: string = this.context.cacheDir + '/'
  private base64 = new util.Base64Helper();

  constructor(name: string = 'temporarily', format: string = 'image/png') {
    this.format = format
    this.name = name + '.png'
    this.file = this.createFile(name)
  }

  getPath(): string {
    return this.dir + this.name
  }

  createFile(name: string = this.name): fileIo.File {
    const path: string = this.dir + name;
    if (fileIo.accessSync(path)) {
      fileIo.unlinkSync(path)
    }
    let file = fileIo.openSync(path, fileIo.OpenMode.CREATE | fileIo.OpenMode.READ_WRITE);
    return file
  }

  getStat(): fileIo.Stat {
    return fileIo.statSync(this.file.fd)
  }

  clear() {
    this.close()
    this.file = this.createFile()
  }

  close() {
    fileIo.unlinkSync(this.file.path)
    fileIo.closeSync(this.file);
  }

  toSource(): image.ImageSource {
    try {
      return image.createImageSource(this.file.path)
    } catch (error) {
      throw error instanceof Error ? error : new Error(`转换资源失败: ${String(error)}`);
    }
  }

  setPixelMap(data: image.PixelMap): Promise<void> {
    let packer = image.createImagePacker()
    promptAction.showToast({ message: '成功' })
    return packer.packToFile(data, this.file.fd, { format: this.format, quality: 100 })
  }

  toPixelMap(options: image.DecodingOptions | undefined = undefined): image.PixelMap {
    return this.toSource().createPixelMapSync(options)
  }

  setBuffer(buf: ArrayBuffer) {
    fileIo.writeSync(this.file.fd, buf)
  }

  getBuffer(options: ReadOptions | undefined = undefined): ArrayBuffer {
    let stat = this.getStat()
    let buf = new ArrayBuffer(stat.size)
    fileIo.readSync(this.file.fd, buf, options)
    return buf
  }


  encodeBase64(options: util.Type | undefined = undefined): string {
    return this.base64.encodeToStringSync(new Uint8Array(this.getBuffer()), options);
  }

  decodeBase64(base64: string, options: util.Type | undefined = undefined) {
    let uArr = this.base64.decodeSync(base64, options)
    let buf: ArrayBuffer = uArr.buffer.slice(0)
    this.setBuffer(buf)
  }

  setBase64Header(base64: string, format: string | undefined = undefined): string {
    let headStr = `data:${format ?? this.format};base64,`;
    if (format === undefined) {
      if (base64.startsWith(headStr)) {
        const reg = new RegExp(headStr);
        base64 = base64.replace(reg, '');
      }
      return base64;
    } else {
      headStr = `data:${format};base64,`;
      return headStr + base64;
    }
  }

  readHttp(url: string): Promise<fileIo.File> {
    return new Promise<fileIo.File>((res, rej) => {
      http.createHttp().request(url).then((data) => {
        if (data.result !== undefined && data.result instanceof ArrayBuffer) {
          this.setBuffer(data.result)
          res(this.file)
        } else {
          rej(new Error(`文件下载失败:'${url}'文件`))
        }
      }).catch((err: Error) => {
        rej(err)
      })
    })
  }

  readUri(uri: string) {
    if (uri.startsWith('data/')) {
      fileIo.copyFileSync(uri, this.file.fd)
    } else if (uri.startsWith('file://')) {
      let file: fileIo.File | null = null;
      try {
        file = fileIo.openSync(uri, fileIo.OpenMode.READ_ONLY)
        let stat = fileIo.statSync(file.fd)
        let buf = new ArrayBuffer(stat.size)
        fileIo.readSync(file.fd, buf)
        this.setBuffer(buf)
      } finally {
        if (file) {
          fileIo.closeSync(file.fd)
        }
      }
    }
    return this.file
  }

  read(src: ImageType): Promise<fileIo.File> {
    return new Promise(async (res, rej) => {
      if (typeof src === 'string') {
        if (src.startsWith('http')) {
          this.readHttp(src).then(() => {
            res(this.file)
          }).catch((err: Error) => {
            rej(err)
          })
        } else if (src.startsWith('data/') || src.startsWith('file://')) {
          this.readUri(src)
          res(this.file)
        } else if (src.startsWith('data:')) {
          this.decodeBase64(this.setBase64Header(src))
          res(this.file)
        } else {
          rej(new Error(`暂不支持打开:'${src}'文件`))
        }
      } else if (src instanceof ArrayBuffer) {
        this.setBuffer(src)
        res(this.file)
      } else {
        fileIo.copyFileSync(src.fd, this.file.fd)
        res(this.file)
      }
    })
  }

  zip(quality: number = 98, mb: number | undefined = undefined,
    byte: number | undefined = undefined): Promise<fileIo.File> {
    let packOpts: image.PackingOption = { format: 'image/jpeg', quality: quality }
    return new Promise<fileIo.File>((res, rej) => {
      let packer: image.ImagePacker = image.createImagePacker()
      packer.packing(this.toSource(), packOpts, async (err: BusinessError, data: ArrayBuffer) => {
        packer.release()
        if (err) {
          rej(err)
        } else {
          if (mb !== undefined && data.byteLength >= 1024 * 1024 * mb) {
            if (byte !== undefined && byte <= data.byteLength) {
              this.clear()
              this.setBuffer(data)
              res(this.file)
            } else {
              let file = await this.zip(quality * 0.9, mb, data.byteLength)
              res(file)
            }
          } else {
            this.clear()
            this.setBuffer(data)
            res(this.file)
          }
        }
      })
    })
  }

  readZip(src: ImageType, quality: number = 98, mb: number | undefined = undefined): Promise<fileIo.File> {
    return new Promise<fileIo.File>((res, rej) => {
      this.read(src).then(() => {
        this.zip(quality, mb).then(() => {
          res(this.file)
        }).catch((err: Error) => {
          rej(err)
        })
      }).catch((err: Error) => {
        rej(err)
      })
    });
  }
}
