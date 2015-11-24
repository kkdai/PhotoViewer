//
//  PTTViewController.m
//  photoviewer
//
//  Created by Evan Lin on 2015/11/20.
//  Copyright © 2015年 chicony. All rights reserved.
//

#import "CK101ViewController.h"
#import "photomgr/Photomgr.h"
#import "UIView+Toast.h"
#import "MBProgressHUD.h"

@interface CK101ViewController ()
{
    int currentPageNumber;
    int currentPagePostCount;
    GoPhotomgrCK101 *ck101;
}
@end


@implementation CK101ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    UIBarButtonItem *nextButton = [[UIBarButtonItem alloc] initWithTitle:@"下一頁" style:UIBarButtonItemStylePlain target:self action:@selector(showNextPage:)];

    UIBarButtonItem *prevButton = [[UIBarButtonItem alloc] initWithTitle:@"上一頁" style:UIBarButtonItemStylePlain target:self action:@selector(showPrevPage:)];
    
    self.navigationItem.leftBarButtonItem = prevButton;
    self.navigationItem.rightBarButtonItem = nextButton;
    
    //PTT get info
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);

    ck101 = GoPhotomgrNewCK101();
    currentPageNumber = 0;
    currentPagePostCount = 0;
    [ck101 setBaseDir:[paths objectAtIndex:0]];
    currentPagePostCount= [ck101 parseCK101PageByIndex:currentPageNumber];
}

- (void)showNextPage:(id)sender {
    currentPageNumber = currentPageNumber+1;
    currentPagePostCount= [ck101 parseCK101PageByIndex:currentPageNumber];
    [self.tableView reloadData];
}

- (void)showPrevPage:(id)sender {
    if (currentPageNumber >=0)
        currentPageNumber = currentPageNumber-1;
    
    currentPagePostCount= [ck101 parseCK101PageByIndex:currentPageNumber];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return currentPagePostCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"postCell" forIndexPath:indexPath];
    
    //Configure the cell...
    int index= (int)indexPath.row;
    int starCount = [ck101 getPostStarByIndex:index];
    NSString * title = [ck101 getPostTitleByIndex:index];
    NSString *cellString = [[NSString alloc]initWithFormat:@"[%d]%@", starCount, title];
    cell.textLabel.text = cellString;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int index= (int)indexPath.row;
    NSString *parseURL = [ck101 getPostUrlByIndex:index];
    
    [self.view makeToast:@"Start downloading ..."];
    [ck101 crawler:parseURL workerNum:10];
    
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
