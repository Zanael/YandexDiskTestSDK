# YandexDiskTestSDK

Основные классы 

YDSession - команды API
YDItemStat - информация о файлах

##Протестированные функции

#Аутентификация пользователя и авторизация приложения

За это отвечает YOAuth2Delegate, ViewController для ввода учетных данных из коробки.

#Создание директории

```
[self.session createDirectoryAtPath:@"/TestYaSDK" completion:^(NSError *err) {

}];
```

#Получение содержимого директории

```
[self.session fetchDirectoryContentsAtPath:self.path completion:^(NSError *err, NSArray *list) {
    if (!err) {
        self.entries = list;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }
    else {
        // do error handling;
    }
}];
```

#Получение информации о файле

Эа это отвечает 
```
@interface YDItemStat : NSObject

@property (nonatomic, weak, readonly) YDSession *session;
@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSString *path;
@property (nonatomic, copy, readonly) NSString *mimeType;
@property (nonatomic, copy, readonly) NSString *eTag;
@property (nonatomic, strong, readonly) NSURL *publicURL;
@property (nonatomic, strong, readonly) NSDate *mTime;
@property (nonatomic, assign, readonly) unsigned long long size;
@property (nonatomic, assign, readonly) BOOL isFile;
@property (nonatomic, assign, readonly) BOOL isDirectory;
@property (nonatomic, assign, readonly) BOOL isShare;
@property (nonatomic, assign, readonly) BOOL isReadOnly;
```

#Скачивание файла

Асинхронное скачивание файла, можно отлеживать процесс скачивания.

```
NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
NSString *documentsDirectory = [paths objectAtIndex:0];
NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"Добро Пожаловать.pdf"];

[self.session downloadFileFromPath:@"/Добро Пожаловать.pdf" toFile:filePath completion:^(NSError *err) {

    if (!err) {

    } else {

    }

}];
```

#Загрузка файла на Яндекс.Диск

Асинхронная загрузка файла, можно отлеживать процесс загрузки.

```
UIImage* image = [info objectForKey:UIImagePickerControllerOriginalImage];
if (image != nil) {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString* localPath = [documentsDirectory stringByAppendingPathComponent:@"MyImage.jpg"];
    NSData* data = UIImagePNGRepresentation(image);
    [data writeToFile:localPath atomically:YES];
    
    NSURL* photoURL = [[NSURL alloc] initFileURLWithPath:localPath];
    
    // Загружаем файл на Яндекс.Диск
    
    [self.session uploadFile:[photoURL absoluteString] toPath:@"/TestYaSDK/MyImage.jpg" completion:^(NSError *err) {
        
        if (!err) {
            
        } else {
            
        }
    }];
}
```

#Удаление файлов

```
for (YDItemStat *item in self.files) {
    [item.session removeItemAtPath:item.path
                        completion:^(NSError *err) {
                            if (!err) {
                                [self activityDidFinish:YES];
                            }
                            else {
                                [self activityDidFinish:NO];
                            }
                        }];
}
```

#Создание публичной ссылки на файл

```
for (YDItemStat *item in self.files) {
    [item.session  publishItemAtPath:item.path
                          completion:^(NSError *err, NSURL *url) {
                              if (!err) {
                                  [item setValue:url forKey:@"publicURL"];
                                  [self activityDidFinish:YES];
                              }
                              else {
                                  [self activityDidFinish:NO];
                              }
                          }];
}
```

#Отмена создания публичной ссылки на файл

```
for (YDItemStat *item in self.files) {
    [item.session  unpublishItemAtPath:item.path
                            completion:^(NSError *err) {
                                if (!err) {
                                    [item setValue:nil forKey:@"publicURL"];
                                    [self activityDidFinish:YES];
                                }
                                else {
                                    [self activityDidFinish:NO];
                                }
                            }];
}
```