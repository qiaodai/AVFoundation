//
//  BMDemoListController.m
//  MediaDemo
//
//  Created by admin on 2018/6/6.
//  Copyright © 2018年 dai. All rights reserved.
//

#import "BMDemoListController.h"
#import "BMDemoTableViewCell.h"
@interface BMDemoListController ()

@end

@implementation BMDemoListController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSString *)classNameOfViewControllerAtIndex:(NSInteger)index {
    return [NSString stringWithFormat:@"BMDemo%dViewController", (int)index];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return 5;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BMDemoTableViewCell *cell = (BMDemoTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"BMDemoTableViewCell" forIndexPath:indexPath];
    if(indexPath.row == 0){
        cell.textLabel.text = @"AVCaptureSession 会话的使用";
    }else if(indexPath.row == 1){
        cell.textLabel.text =  @"音视频录制 输出";//AVCaptureMovieFileOutput
    }else if(indexPath.row == 2){
        cell.textLabel.text =  @"给带音频的视频陪背景音乐";
    }else if(indexPath.row == 3){
        cell.textLabel.text =  @"多段视频拼接";
    }else if(indexPath.row == 4){
        cell.textLabel.text =  @"AVFoundation解码  不带音频";
    }else{
        cell.textLabel.text = [self classNameOfViewControllerAtIndex:indexPath.row];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *className = [self classNameOfViewControllerAtIndex:indexPath.row];
    Class class = NSClassFromString(className);
    UIViewController *vc = (UIViewController *)[[class alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
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
