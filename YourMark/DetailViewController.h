//
//  DetailViewController.h
//  YourMark
//
//  Created by Ito Yosei on 4/29/14.
//  Copyright (c) 2014 LumberMill, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CameraManager.h"

@interface DetailViewController : UIViewController <CameraManagerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property NSString *name;
@property (nonatomic) NSString *classifier;

@end
