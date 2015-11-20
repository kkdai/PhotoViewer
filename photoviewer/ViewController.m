//
//  ViewController.m
//


#import "ViewController.h"
#import "QBImagePickerController.h"
#import "IDMPhotoBrowser.h"
#import "AppDelegate.h"

#define ROW_Height 80

unsigned long long totalSize=0;
unsigned long long totalSendSize=0;
int fileCount=0,fileIndex=0,fileStatusIndex=0;
ViewController *currentViewController;

void LogString(char* str){
    NSLog(@"%s", str);
}

@interface ViewController ()< UINavigationControllerDelegate, QBImagePickerControllerDelegate, UITableViewDataSource, UITableViewDelegate, UIDocumentInteractionControllerDelegate, UIAlertViewDelegate>
{
    NSString *DocumentPath;
    NSString *BrowserPath;
    NSMutableArray *files, *fileIcons;
    int nDirectorys;
    UIDocumentInteractionController *documentInteractionController;
    UIAlertView *deleteAlert,*cancelAlert;
}
@property (nonatomic) float totalProgess;
@property (strong, nonatomic) IBOutlet UITextField *TokenInput;
@property (strong, nonatomic) IBOutlet UIProgressView* progressView;
@property (strong, nonatomic) IBOutlet UITableView* filesView;
@end


@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    currentViewController = self;
    files = nil;
    fileIcons = nil;

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    // Print out the path to verify we are in the right place
    DocumentPath = [paths objectAtIndex:0];
    NSLog(@"Directory: %@", DocumentPath);
    BrowserPath = [NSString stringWithString:DocumentPath];

    _filesView.rowHeight = ROW_Height;
    
    deleteAlert = [[UIAlertView alloc] initWithTitle:@"Warring" message:@"" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    cancelAlert = [[UIAlertView alloc] initWithTitle:@"Warring" message:@"Are you really cancle transfer?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];;
    
    
    UITapGestureRecognizer* doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    doubleTap.numberOfTouchesRequired = 1;
    [_filesView addGestureRecognizer:doubleTap];
    
    UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    [singleTap requireGestureRecognizerToFail:doubleTap];
    [_filesView addGestureRecognizer:singleTap];
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    appDelegate.photoBrower = (id)self;

    [self refreshPath];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnRefreshPress:(id)sender {
    [self refreshPath];
}

//When user press cancel in image select view
- (void)qb_imagePickerControllerDidCancel:(QBImagePickerController *)imagePickerController {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)qb_imagePickerController:(QBImagePickerController *)imagePickerController didFinishPickingAssets:(NSArray *)assets {
    
    fileIndex = 0;
    fileCount=(int)assets.count;
    totalSize = 0;
    totalSendSize = 0;
    for (PHAsset *asset in assets) {
        
        
        PHImageRequestOptions * imageRequestOptions = [[PHImageRequestOptions alloc] init];
        imageRequestOptions.synchronous = YES;
        [[PHImageManager defaultManager] requestImageDataForAsset:asset options:imageRequestOptions
                                                    resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info)
         {
             NSString *targetFile;   //target file address for send

             if ([info objectForKey:@"PHImageFileURLKey"]) {
                 // path looks like this -
                 // file:///var/mobile/Media/DCIM/###APPLE/IMG_####.JPG
                 NSURL* fileURL=[info objectForKey:@"PHImageFileURLKey"];
                 NSString *fileName= [[fileURL absoluteString] lastPathComponent];
                 unsigned long long filesize = imageData.length;
                 totalSize += filesize;
//                 targetFile = [TempPath stringByAppendingPathComponent:fileName];
                 if([[NSFileManager defaultManager] fileExistsAtPath:targetFile])
                 {
//                     NSString* templateStr = [NSString stringWithFormat:@"%@/XXXXX.%@", TempPath,[fileName pathExtension] ];
                     char buf[512];
//                     strcpy(buf, [templateStr cStringUsingEncoding:NSASCIIStringEncoding]);
                     char* filename = mktemp(buf);
                     
                     targetFile = [NSString stringWithCString:filename encoding:NSASCIIStringEncoding];
                 }
                 [imageData writeToFile:targetFile atomically:NO];
                 NSLog(@"targetFile = %@ %qi %qi",info ,filesize ,totalSize);
//                 std::string *tarFile = new std::string([targetFile UTF8String]);
                 
//                 inputFile.push_back(*tarFile);
//                 delete tarFile;
                 fileIndex++;
                 if (fileIndex == fileCount) {
                     //All selected files got.
//                     string token;
                     
                     fileStatusIndex=0;
                 }
             }
         }];
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (NSString *)pathToTempFolder:(NSString*) folderName {
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                        NSUserDomainMask,
                                                                        YES) lastObject];
    NSString *patientPhotoFolder = [documentsDirectory stringByAppendingPathComponent:folderName];
    
    // Create the folder if necessary
    BOOL isDir = NO;
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    if (![fileManager fileExistsAtPath:patientPhotoFolder
                           isDirectory:&isDir] && isDir == NO) {
        [fileManager createDirectoryAtPath:patientPhotoFolder
               withIntermediateDirectories:NO
                                attributes:nil
                                     error:nil];
    }
    return patientPhotoFolder;
}

- (void) removeTempSendFolder:(NSString*)tempFolderName {
    NSString *patientPhotoFolder = [self pathToTempFolder:tempFolderName];
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:patientPhotoFolder error:nil];
    for (NSString *filename in contents)  {
        [[NSFileManager defaultManager] removeItemAtPath:[patientPhotoFolder stringByAppendingPathComponent:filename] error:NULL];
    }
}

- (void) cleanupFilesInFolder:(NSString*) folder {
    // Path to the Documents directory
        NSError *error = nil;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        
        // For each file in the directory, create full path and delete the file
        for (NSString *file in [fileManager contentsOfDirectoryAtPath:folder error:&error])
        {
            NSString *filePath = [folder stringByAppendingPathComponent:file];
            NSLog(@"File : %@ ready for delete", filePath);
            
            BOOL fileDeleted = [fileManager removeItemAtPath:filePath error:&error];
            
            if (fileDeleted != YES || error != nil)
            {
                // Deal with the error...
            }
        }
}

- (IBAction)btnCancelPress:(id)sender {
    [cancelAlert show];
}

- (IBAction)btnPreviewFolderPress:(id)sender {
    if (![DocumentPath isEqualToString:BrowserPath]) {
        BrowserPath = [BrowserPath stringByDeletingLastPathComponent];
    }
    [self refreshPath];
}

- (IBAction)btnActionPress:(id)sender {
    if(_filesView.indexPathsForSelectedRows.count>0)
    {
        NSMutableArray *actionfile=[[NSMutableArray alloc] init];
        for(NSIndexPath *indexPath in _filesView.indexPathsForSelectedRows)
        {
            [actionfile addObject:[NSURL fileURLWithPath:[self pathForFile:files[indexPath.row]]]];
        }
        
        UIActivityViewController *avc = [[UIActivityViewController alloc] initWithActivityItems:actionfile applicationActivities:nil];
        if ( [avc respondsToSelector:@selector(popoverPresentationController)] ) {
            // iOS8
            avc.popoverPresentationController.sourceView = self.view;
        }
        [self presentViewController:avc animated:YES completion:nil];
    }
}


- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    switch (buttonIndex) {
        case 0:
            NSLog(@"Cancel Button Pressed");
            break;
        case 1:
            if(alertView == deleteAlert)
            {
                for(NSIndexPath *indexPath in _filesView.indexPathsForSelectedRows)
                {
                    NSError *error;
                    NSString *path = [self pathForFile:files[indexPath.row]];
                    if ([[NSFileManager defaultManager] isDeletableFileAtPath:path]) {
                        BOOL success = [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
                        if (!success) {
                            NSLog(@"Error removing file at path: %@", error.localizedDescription);
                        }
                    }
                }
                [self refreshPath];
            }
            else if(alertView == cancelAlert)

            {
                
            }
        default:
            break;
    }
    
}

- (IBAction)btnDeletePress:(id)sender {
    if(_filesView.indexPathsForSelectedRows.count>0)
    {
        deleteAlert.message = [NSString stringWithFormat:@"Are you really delete %d file(s)?",(int)_filesView.indexPathsForSelectedRows.count];
        [deleteAlert show];
    }

}

- (UIImage *) resizeImage:(UIImage*) srcImg
{
    float oldHeight= srcImg.size.height;
    float scaleFactor = (float)ROW_Height / oldHeight;
    
    float newHeight = oldHeight *scaleFactor;
    float newWidth = srcImg.size.width * scaleFactor;
    
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    [srcImg drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    return UIGraphicsGetImageFromCurrentImageContext();
}

- (void) refreshPath
{
    NSArray *DirList=[[NSFileManager defaultManager] contentsOfDirectoryAtPath:BrowserPath error:nil];
    
    if(files == nil)
        files = [[NSMutableArray alloc] init];
    [files removeAllObjects];
    
    if(fileIcons == nil)
        fileIcons = [[NSMutableArray alloc] init];
    [fileIcons removeAllObjects];
    
    //Add prarent path
    if (![DocumentPath isEqualToString:BrowserPath]) {
        [files addObject:@"../"];
        UIImage *sourceImage = [UIImage imageNamed:@"folder.png"];
        [fileIcons addObject:[self resizeImage:sourceImage]];
    }
    
    for(NSString *file in DirList)
    {
        NSString *path = [self pathForFile:file];
        if(![self fileIsDirectory:file])
        {
            [files addObject:file];
            NSString *ext = [[file pathExtension] lowercaseString];
            if ([ext isEqualToString:@"png"] || [ext isEqualToString:@"jpg"]) {
                UIImage *sourceImage = [UIImage imageWithContentsOfFile:path];
                [fileIcons addObject:[self resizeImage:sourceImage]];
            } else {
                UIDocumentInteractionController *pv=[UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:path]];
                [fileIcons addObject:pv.icons[pv.icons.count-1]];
            }
        } else {
            //Use folder.png to handle folder
            [files addObject:file];
            UIImage *sourceImage = [UIImage imageNamed:@"folder.png"];
            [fileIcons addObject:[self resizeImage:sourceImage]];
        }
    }
    [_filesView reloadData];

}

- (NSString *)pathForFile:(NSString *)file {
    return [BrowserPath stringByAppendingPathComponent:file];
}

- (BOOL)fileIsDirectory:(NSString *)file {
    BOOL isdir = NO;
    NSString *path = [self pathForFile:file];
    [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isdir];
    return isdir;
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [files count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.font = [UIFont systemFontOfSize:16.0];
    }
    
    NSString *file = [files objectAtIndex:indexPath.row];
    
    cell.textLabel.text = file;

    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
    cell.imageView.image = [fileIcons objectAtIndex:indexPath.row];
    return cell;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
    NSString *file = [files objectAtIndex:indexPath.row];
    NSString *path = [self pathForFile:file];
    //	BOOL matchesAppPattern = NO;
    //	if ([file length] > 23) {
    //		if ([file characterAtIndex:8] == 45 && [file characterAtIndex:13] == 45 && [file characterAtIndex:18] == 45 && [file characterAtIndex:23] == 45) {
    //			matchesAppPattern = YES;
    //		}
    ////		unichar u = [file characterAtIndex:8];
    ////		NSLog(@"%d", u);
    //	}
    //	// 8 13 18 23
    // matching app pattern doesn't work, because the dir contents you cd into is always blank... must be the sandbox protection
    if ([self fileIsDirectory:file]) {
     //   DirectoryBrowserTableViewController *dbtvc = [self.storyboard instantiateViewControllerWithIdentifier:@"DirectoryBrowserTableViewController"];
     //   dbtvc.path = path;
     //   [self.navigationController pushViewController:dbtvc animated:YES];
        	//} else {
            //    [self performSegueWithIdentifier:@"EditTextFileSegue" sender:file];
    } else {
        NSURL *url = [NSURL fileURLWithPath:path];
        
        UIActivityViewController *avc = [[UIActivityViewController alloc] initWithActivityItems:@[url] applicationActivities:nil];
        if ( [avc respondsToSelector:@selector(popoverPresentationController)] ) {
            // iOS8
            avc.popoverPresentationController.sourceView = self.view;
        }
        [self presentViewController:avc animated:YES completion:nil];
    }
     */
    /*
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    } else {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
     */
    BOOL isFolder = NO;
    
    NSString *filePath;

    if (indexPath.row==0 && [files[indexPath.row] isEqualToString:@"../"])
        filePath = [BrowserPath stringByDeletingLastPathComponent];
    else
        filePath = [self pathForFile:files[indexPath.row]];
    [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isFolder];
    if ( isFolder) {
        BrowserPath = filePath;
        [self refreshPath];
    } else {
        //If touch file start image browser
        [self launchImageBrowser];
    }
}

-(void)launchImageBrowser {
    NSArray *DirList=[[NSFileManager defaultManager] contentsOfDirectoryAtPath:BrowserPath error:nil];
    NSMutableArray *photos = [NSMutableArray new];
    
    for(NSString *file in DirList)
    {
        NSString *path = [self pathForFile:file];
        if(![self fileIsDirectory:file])
        {
            NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:path];
            IDMPhoto *photo = [IDMPhoto photoWithURL:fileURL];
            [photos addObject:photo];
        }
        
    }
    IDMPhotoBrowser *browser = [[IDMPhotoBrowser alloc] initWithPhotos:photos];
    [self presentViewController:browser animated:YES completion:nil];
}
-(void)singleTap:(UISwipeGestureRecognizer*)tap
{
    if (UIGestureRecognizerStateEnded == tap.state)
    {
      //  CGPoint p = [tap locationInView:tap.view];
      //  NSIndexPath* indexPath = [_filesView indexPathForRowAtPoint:p];
      //  UITableViewCell* cell = [_filesView cellForRowAtIndexPath:indexPath];
        // Do your stuff
    }
}

-(void)doubleTap:(UISwipeGestureRecognizer*)tap
{
    if (UIGestureRecognizerStateEnded == tap.state)
    {
        CGPoint p = [tap locationInView:tap.view];
        NSIndexPath* indexPath = [_filesView indexPathForRowAtPoint:p];
        [_filesView deselectRowAtIndexPath:indexPath animated:NO];
            // Initialize Document Interaction Controller
            documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:[self pathForFile:files[indexPath.row]]]];
            
            // Configure Document Interaction Controller
            [documentInteractionController setDelegate:self];
            
            // Preview PDF
            [documentInteractionController presentPreviewAnimated:YES];

    }
}
- (UIViewController *) documentInteractionControllerViewControllerForPreview: (UIDocumentInteractionController *) controller {
    return self;
}
@end