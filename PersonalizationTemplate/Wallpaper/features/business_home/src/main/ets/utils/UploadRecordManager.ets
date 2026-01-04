import { preferences } from '@kit.ArkData';
import { Context } from '@kit.AbilityKit';
import fs from '@ohos.file.fs';
import { UploadRecipeData } from 'upload_recipe';

export class UploadRecordManager {
  private static readonly RECORD_KEY: string = 'upload_records';
  private static readonly PREFERENCES_NAME: string = 'upload_records_prefs';

  static async getAllRecords(context: Context): Promise<UploadRecipeData[]> {
    try {
      const prefs = await preferences.getPreferences(context, {
        name: UploadRecordManager.PREFERENCES_NAME
      });
      const value = await prefs.get(UploadRecordManager.RECORD_KEY, '[]');
      return JSON.parse(value as string) as UploadRecipeData[];
    } catch (error) {
      return [];
    }
  }

  static async addRecord(context: Context, record: UploadRecipeData): Promise<void> {
    try {
      const allRecords: UploadRecipeData[] = await UploadRecordManager.getAllRecords(context);
      const recordWithTime: UploadRecipeData = {
        mainImg: record.mainImg,
        category: record.category,
        keywords: record.keywords,
        uploadTime: new Date().toISOString()
      };
      allRecords.unshift(recordWithTime);
      const prefs = await preferences.getPreferences(context, {
        name: UploadRecordManager.PREFERENCES_NAME
      });
      await prefs.put(UploadRecordManager.RECORD_KEY, JSON.stringify(allRecords));
      await prefs.flush();
    } catch (error) {
    }
  }

  static async clearAllRecords(context: Context): Promise<void> {
    try {
      const prefs = await preferences.getPreferences(context, {
        name: UploadRecordManager.PREFERENCES_NAME
      });
      await prefs.put(UploadRecordManager.RECORD_KEY, '[]');
      await prefs.flush();

      await UploadRecordManager.clearUploadedImages(context);
    } catch (error) {
    }
  }

  static async deleteRecord(context: Context, index: number): Promise<void> {
    try {
      const allRecords: UploadRecipeData[] = await UploadRecordManager.getAllRecords(context);
      if (index >= 0 && index < allRecords.length) {
        const recordToDelete = allRecords[index];
        await UploadRecordManager.deleteImageFile(context, recordToDelete.mainImg);
        allRecords.splice(index, 1);
        const prefs = await preferences.getPreferences(context, {
          name: UploadRecordManager.PREFERENCES_NAME
        });
        await prefs.put(UploadRecordManager.RECORD_KEY, JSON.stringify(allRecords));
        await prefs.flush();
      }
    } catch (error) {
    }
  }

  private static async clearUploadedImages(context: Context): Promise<void> {
    try {
      const uploadsDir = context.filesDir + '/uploads';
      try {
        if (fs.accessSync(uploadsDir)) {
          const files: string[] = fs.listFileSync(uploadsDir);
          for (let i = 0; i < files.length; i++) {
            const file = files[i];
            const filePath = uploadsDir + '/' + file;
            if (fs.accessSync(filePath)) {
              fs.unlinkSync(filePath);
            }
          }
        }
      } catch (error) {
      }
    } catch (error) {
    }
  }

  private static async deleteImageFile(context: Context, imagePath: string): Promise<void> {
    try {
      const filePath = imagePath.replace('file://', '');
      if (fs.accessSync(filePath)) {
        fs.unlinkSync(filePath);
      }
    } catch (error) {
    }
  }
}