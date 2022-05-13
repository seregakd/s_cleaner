import 'dart:io';

import 'package:file_manager/file_manager.dart';
import 'package:flutter/material.dart';

class FileManagerPage extends StatelessWidget {
  final FileManagerController controller = FileManagerController();
  int fileCount = 0;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (await controller.isRootDirectory()) {
          return true;
        } else {
          controller.goToParentDirectory();
          return false;
        }
      },
      child: Scaffold(
          appBar: AppBar(
            actions: [
              IconButton(
                onPressed: () => addFile(context),
                icon: const Icon(Icons.add_circle_outline_outlined),
              ),
              IconButton(
                onPressed: () => createFolder(context),
                icon: const Icon(Icons.create_new_folder_outlined),
              ),
              IconButton(
                onPressed: () => sort(context),
                icon: const Icon(Icons.sort_rounded),
              ),
              IconButton(
                onPressed: () => selectStorage(context),
                icon: const Icon(Icons.sd_storage_rounded),
              )
            ],
            title: ValueListenableBuilder<String>(
              valueListenable: controller.titleNotifier,
              builder: (context, title, _) => Text(title),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () async {
                await controller.goToParentDirectory();
              },
            ),
          ),
          body: Container(
            margin: EdgeInsets.all(10),
            child: FileManager(
              controller: controller,
              hideHiddenEntity: false,
              builder: (context, snapshot) {
                final List<FileSystemEntity> entities = snapshot;
                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: entities.length,
                        itemBuilder: (context, index) {
                          FileSystemEntity entity = entities[index];
                          return Card(
                            child: ListTile(
                              leading: FileManager.isFile(entity)
                                  ? const Icon(Icons.feed_outlined)
                                  : const Icon(Icons.folder),
                              title: Text(FileManager.basename(entity)),
                              subtitle: subtitle(entity),
                              onTap: () async {
                                if (FileManager.isDirectory(entity)) {
                                  // open the folder
                                  controller.openDirectory(entity);

                                  // delete a folder
                                  // await entity.delete(recursive: true);

                                  // rename a folder
                                  // await entity.rename("newPath");

                                  // Check weather folder exists
                                  // entity.exists();

                                  // get date of file
                                  // DateTime date = (await entity.stat()).modified;
                                } else {
                                  // delete a file
                                  //  await entity.delete();

                                  // rename a file
                                  // await entity.rename("newPath");

                                  // Check weather file exists
                                  // entity.exists();

                                  // get date of file
                                  // DateTime date = (await entity.stat()).modified;

                                  // get the size of the file
                                  // int size = (await entity.stat()).size;
                                }
                              },
                              onLongPress: () async {
                                // delete a folder
                                // await entity.delete();

                            },
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: TextButton(
                        style: TextButton.styleFrom(
                          textStyle: const TextStyle(fontSize: 20),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          backgroundColor: Colors.red,
                        ),
                        onPressed: () => _delAll(context, entities),
                        child: const Text(
                          "Dell all files here",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),

                    ),
                  ],
                );
              },
            ),
          )),
    );
  }

  Widget subtitle(FileSystemEntity entity) {
    return FutureBuilder<FileStat>(
      future: entity.stat(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (entity is File) {
            int size = snapshot.data!.size;

            return Text(
              FileManager.formatBytes(size),
            );
          }
          return Text(
            "${snapshot.data!.modified}",
          );
        } else {
          return Text('');
        }
      },
    );
  }

  void selectStorage(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: FutureBuilder<List<Directory>>(
          future: FileManager.getStorageList(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final List<FileSystemEntity> storageList = snapshot.data!;
              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: storageList
                        .map((e) => ListTile(
                      title: Text(
                        "${FileManager.basename(e)}",
                      ),
                      onTap: () {
                        controller.openDirectory(e);
                        Navigator.pop(context);
                      },
                    ))
                        .toList()),
              );
            }
            return Dialog(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }

  void sort(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                  title: Text("Name"),
                  onTap: () {
                    controller.sortedBy = SortBy.name;
                    Navigator.pop(context);
                  }),
              ListTile(
                  title: Text("Size"),
                  onTap: () {
                    controller.sortedBy = SortBy.size;
                    Navigator.pop(context);
                  }),
              ListTile(
                  title: Text("Date"),
                  onTap: () {
                    controller.sortedBy = SortBy.date;
                    Navigator.pop(context);
                  }),
              ListTile(
                  title: Text("type"),
                  onTap: () {
                    controller.sortedBy = SortBy.type;
                    Navigator.pop(context);
                  }),
            ],
          ),
        ),
      ),
    );
  }

  void createFolder(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController folderName = TextEditingController();
        return Dialog(
          child: Container(
            padding: EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: TextField(
                    controller: folderName,
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      // Create Folder
                      await FileManager.createFolder(
                          controller.getCurrentPath, folderName.text);
                      // Open Created Folder
                      controller.setCurrentPath =
                          controller.getCurrentPath + "/" + folderName.text;
                    } catch (e) {}

                    Navigator.pop(context);
                  },
                  child: Text('Create Folder'),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void addFile(BuildContext context) async {
//    String path = '/storage/emulated/0/Download';
    final file = File('${controller.getCurrentPath}/file_$fileCount.txt');
    file.writeAsString('text');

    fileCount++;
  }

  void _delAllFiles(BuildContext context, List<FileSystemEntity> entities) async {
    try {
      for (int i = 0; i < entities.length; i++) {
        await entities[i].delete();
      }

      fileCount = 0;
    } catch (e) {}
  }

  void _delAll(BuildContext context, List<FileSystemEntity> entities) async {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
            padding: EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const ListTile(
                  title: Text('Del all files in this folder?')
                ),
                Row(
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () {
                        _delAllFiles(context, entities);
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Del all',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Cancel'),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

}