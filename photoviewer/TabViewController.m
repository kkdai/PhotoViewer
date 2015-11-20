//
//  TabViewController.m
//  photoviewer
//
//  Created by Evan Lin on 2015/11/20.
//  Copyright © 2015年 chicony. All rights reserved.
//

#import "TabViewController.h"
#import "PhotoViewController.h"
#import "AppDelegate.h"

@interface TabViewController ()<UITabBarControllerDelegate>

@end

@implementation TabViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController;
{

    if (tabBarController.selectedIndex == 0)
    {
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        PhotoViewController *photoView = (PhotoViewController*)appDelegate.photoBrower;
        [photoView refreshPath];
    }
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
