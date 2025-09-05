import { harTasks } from '@ohos/hvigor-ohos-plugin';
import { exec } from 'node:child_process';
import util from 'node:util';

const scriptPath = 'shell.bat';
const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

export function tinymceNpm(str?: string) {
  return {
    pluginId: 'tinymceNpmID1',
    apply(pluginContext) {
      console.log('pluginContext', pluginContext.nodeDir.filePath);
      let targetDir = `${pluginContext.nodeDir.filePath}/src/main/resources/rawfile/easy_tinymce`;
      // 解析为绝对路径
      const projectRoot = path.resolve(targetDir);

      // 递归复制文件夹的函数
      function copyFolderRecursiveSync(source, target) {
        // 检查源文件夹是否存在
        if (!fs.existsSync(source)) {
          throw new Error(`源文件夹不存在: ${source}`);
        }

        // 确保目标文件夹存在
        if (!fs.existsSync(target)) {
          fs.mkdirSync(target, { recursive: true });
        }

        // 读取源文件夹内容
        const files = fs.readdirSync(source);

        files.forEach(file => {
          const sourcePath = path.join(source, file);
          const targetPath = path.join(target, file);

          // 检查是文件还是文件夹
          const stat = fs.statSync(sourcePath);
          if (stat.isFile()) {
            // 复制文件
            fs.copyFileSync(sourcePath, targetPath);
          } else if (stat.isDirectory()) {
            // 递归复制子文件夹
            copyFolderRecursiveSync(sourcePath, targetPath);
          }
        });
      }

      try {
        console.log(`目标工作目录: ${projectRoot}`);

        // 检查基础目录是否存在
        if (!fs.existsSync(projectRoot)) {
          throw new Error(`指定的目录不存在: ${projectRoot}`);
        }

        // 检查package.json是否存在
        const packageJsonPath = path.join(projectRoot, 'package.json');
        if (!fs.existsSync(packageJsonPath)) {
          throw new Error(`在指定目录中未找到package.json: ${projectRoot}`);
        }

        // 定义node_modules目录路径
        const nodeModulesDir = path.join(projectRoot, 'node_modules');
        const nodeModulesTinymceDir = path.join(nodeModulesDir, 'tinymce');

        // 检查node_modules是否存在，存在则退出
        if (fs.existsSync(nodeModulesDir)) {
          console.log('node_modules目录已存在，无需执行操作');
          return;
        }

        // 定义文件路径
        const sourceDtsPath = path.join(nodeModulesTinymceDir, 'tinymce.d.ts');
        const sourceMinJsPath = path.join(nodeModulesTinymceDir, 'tinymce.min.js');

        const targetDtsPath = path.join(projectRoot, 'tinymce.d.ts');
        const targetMinJsPath = path.join(projectRoot, 'tinymce.min.js');

        // 定义需要复制的文件夹
        const foldersToCopy = ['plugins', 'models', 'themes'];

        console.log('开始执行 npm install...');

        // 执行npm install，指定cwd参数为目标目录
        execSync('npm install', { stdio: 'inherit', cwd: projectRoot });

        console.log('npm install 完成，开始检查文件...');

        // 检查源文件是否存在
        if (!fs.existsSync(sourceDtsPath)) {
          throw new Error(`未找到文件: ${sourceDtsPath}`);
        }

        if (!fs.existsSync(sourceMinJsPath)) {
          throw new Error(`未找到文件: ${sourceMinJsPath}`);
        }

        console.log('找到源文件，开始复制替换...');

        // 复制文件
        fs.copyFileSync(sourceDtsPath, targetDtsPath);
        console.log(`已替换: ${targetDtsPath}`);

        fs.copyFileSync(sourceMinJsPath, targetMinJsPath);
        console.log(`已替换: ${targetMinJsPath}`);

        // 复制文件夹
        foldersToCopy.forEach(folder => {
          const sourceFolder = path.join(nodeModulesTinymceDir, folder);
          const targetFolder = path.join(projectRoot, folder);

          // 如果目标文件夹已存在，先删除
          if (fs.existsSync(targetFolder)) {
            // 先删除目标文件夹及其内容
            function deleteFolderRecursive(path) {
              if (fs.existsSync(path)) {
                fs.readdirSync(path).forEach((file) => {
                  const curPath = path.join(path, file);
                  if (fs.lstatSync(curPath).isDirectory()) {
                    deleteFolderRecursive(curPath);
                  } else {
                    fs.unlinkSync(curPath);
                  }
                });
                fs.rmdirSync(path);
              }
            }
            deleteFolderRecursive(targetFolder);
          }

          // 复制文件夹
          copyFolderRecursiveSync(sourceFolder, targetFolder);
          console.log(`已复制文件夹: ${sourceFolder} 到 ${targetFolder}`);
        });

        console.log('所有操作完成！');
      } catch (error) {
        console.error('操作失败:', error.message);
      }
    }
  }
}

export default {
  system: harTasks, /* Built-in plugin of Hvigor. It cannot be modified. */
  plugins: [tinymceNpm()]       /* Custom plugin to extend the functionality of Hvigor. */
}
