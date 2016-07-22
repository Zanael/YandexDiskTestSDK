/* Лицензионное соглашение на использование набора средств разработки
 * «SDK Яндекс.Диска» доступно по адресу: http://legal.yandex.ru/sdk_agreement
 */


#import "DirectoryViewController.h"
#import "ItemViewController.h"
#import "AppDelegate.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface DirectoryViewController () <ItemViewDelegate, UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@end

@implementation DirectoryViewController

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {

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
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (instancetype)initWithSession:(YDSession*)aSession path:(NSString *)aPath
{
	if (self = [super init]) {
        _session = aSession;
		_path = [aPath copy];
    }

	return self;
}

- (BOOL)isCurrentPathRoot
{
    return [self.path.lastPathComponent isEqualToString:@"/"];
}

// Получаем содержимое директории
-(void) loadDir
{
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
}

- (void) uploadFile {
    
    UIImagePickerController* imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.delegate = self;
    
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:imagePicker animated:YES completion:^{
        
    }];
    
    /*
    // Создание директории
    [self.session createDirectoryAtPath:@"/TestYaSDK" completion:^(NSError *err) {
        if (!err) {

        }
        else {
            // do error handling;
        }
    }];
    */
    
    /*
    // Скачивание файла
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"Добро Пожаловать.pdf"];

    [self.session downloadFileFromPath:@"/Добро Пожаловать.pdf" toFile:filePath completion:^(NSError *err) {

        if (!err) {

        } else {

        }

    }];
    */
}

#pragma mark - UIViewController methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;

    self.title = self.isCurrentPathRoot ? @"Я.Диск SDK example" : self.path.lastPathComponent;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (!self.entries) {
        [self loadDir];
    }
}

#pragma mark - UITableView methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.entries count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];

    YDItemStat *entry = self.entries[indexPath.row];
    cell.textLabel.text = entry.name;
    cell.detailTextLabel.text = entry.mimeType;

    if (entry.isDirectory) {
        cell.imageView.image = [UIImage imageNamed:@"Folder_icon"];
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    }
    else if (entry.isFile) {
        cell.imageView.image = [UIImage imageNamed:@"File_icon"];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    YDItemStat *item = self.entries[indexPath.row];
    NSString *nextpath = [self.path stringByAppendingPathComponent:item.name];

    if (item.isDirectory) {
        DirectoryViewController *nextDirController = [[DirectoryViewController alloc] initWithSession:self.session path:nextpath];
        [self.navigationController pushViewController:nextDirController animated:YES];
    }
    else {
        ItemViewController *fileController = [[ItemViewController alloc] initWithItem:item];
        fileController.delegate = self;
        [self.navigationController pushViewController:fileController animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    YDItemStat *item = self.entries[indexPath.row];
    ItemViewController *itemController = [[ItemViewController alloc] initWithItem:item];
    itemController.delegate = self;
    [self.navigationController pushViewController:itemController animated:YES];
}

- (void)itemsChanged:(id)sender
{
    self.entries = nil;
}

@end

