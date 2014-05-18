//
//  MasterViewController.m
//  YourMark
//
//  Created by Ito Yosei on 4/29/14.
//  Copyright (c) 2014 LumberMill, Inc. All rights reserved.
//

#import "MasterViewController.h"

#import "DetailViewController.h"

#define BASE_URL @"http://dev.lumber-mill.co.jp/sandbox/opencv/cascade_classifiers.php"

@interface MasterViewController ()
@end

@implementation MasterViewController{
    NSArray *data;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void) refresh
{
    data = [NSArray array];

    // JSONを受け取る
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Connecting" message:@"Fetching menu..." delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
    // 失敗したら？
    
    NSURL *url = [NSURL URLWithString:BASE_URL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *d, NSError *error) {
        
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:d options:0 error:nil];
        
        data = [json objectForKey:@"data"];
        
        [av dismissWithClickedButtonIndex:0 animated:YES];
        [self.tableView reloadData];
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self refresh];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    NSArray *d = data[indexPath.row];
    // 0:filename 1:title 2:timestamp
    
    cell.textLabel.text = d[1];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %@",d[0],d[2]];
    if (d[3]) {
        // this id has an image.
        NSString *png = [d[0] stringByReplacingOccurrencesOfString:@".xml" withString:@".png"];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?name=%@",BASE_URL,png]];

        NSData *imageData = [NSData dataWithContentsOfURL:url];
        cell.imageView.image = [UIImage imageWithData:imageData];
    }
    
    return cell;
}

- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"";
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSString *xml = data[indexPath.row][0];
        NSString *name = data[indexPath.row][1];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?name=%@",BASE_URL,xml]];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [[segue destinationViewController] setClassifier:nil];
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *d, NSError *error) {
            NSString *dir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
            NSString *path = [NSString stringWithFormat:@"%@/%@",dir,xml];
            [d writeToFile:path atomically:YES];
            [[segue destinationViewController] setClassifier:path];
            [[segue destinationViewController] setName:name];
            NSLog(@"classifier=%@",path);
        }];
    }
}

- (IBAction) refreshPushed:(id)sender
{
    [self refresh];
}


@end
