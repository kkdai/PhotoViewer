//
//  PTTViewController.m
//  photoviewer
//
//  Created by Evan Lin on 2015/11/20.
//  Copyright © 2015年 chicony. All rights reserved.
//

#import "PTTViewController.h"
#import "photomgr/Photomgr.h"
#import "UIView+Toast.h"
#import "MBProgressHUD.h"

@interface PTTViewController ()

@end

int currentPageNumber = 0;
int currentPagePostCount = 0;
GoPhotomgrPTT *ptt;

@implementation PTTViewController

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

    ptt = GoPhotomgrNewPTT();
    [ptt setBaseDir:[paths objectAtIndex:0]];
    currentPagePostCount= [ptt parsePttPageByIndex:currentPageNumber];
}

- (void)showNextPage:(id)sender {
    currentPageNumber = currentPageNumber+1;
    currentPagePostCount= [ptt parsePttPageByIndex:currentPageNumber];
    [self.tableView reloadData];
}

- (void)showPrevPage:(id)sender {
    if (currentPageNumber >=0)
        currentPageNumber = currentPageNumber-1;
    
    currentPagePostCount= [ptt parsePttPageByIndex:currentPageNumber];
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
    int starCount = [ptt getPostStarByIndex:index];
    NSString * title = [ptt getPostTitleByIndex:index];
    NSString *cellString = [[NSString alloc]initWithFormat:@"[%d]%@", starCount, title];
    cell.textLabel.text = cellString;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int index= (int)indexPath.row;
    NSString *parseURL = [ptt getPostUrlByIndex:index];
    
    [self.view makeToast:@"Start downloading ..."];
    [ptt crawler:parseURL workerNum:10];
    
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
