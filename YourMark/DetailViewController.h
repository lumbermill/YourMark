//
//  DetailViewController.h
//  YourMark
//
//  Created by Ito Yosei on 4/29/14.
//  Copyright (c) 2014 LumberMill, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
