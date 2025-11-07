export enum FileType {
  FILE = 1,
  FOLDER = 2,
  ZIP = 3,
}

export enum CompressedFormat {
  ZIP = 'zip',
  RAR = 'rar',
  WAR = 'war'
}

export const compressedFormat: string[] = ['zip', 'rar', 'war']