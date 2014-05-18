//
//  DetailViewController.m
//  YourMark
//
//  Created by Ito Yosei on 4/29/14.
//  Copyright (c) 2014 LumberMill, Inc. All rights reserved.
//

#import "DetailViewController.h"
#import "UIImage+OpenCV.h"

@interface DetailViewController ()
@end

static cv::CascadeClassifier *cascade1;//, *cascade2;

@implementation DetailViewController{
    CameraManager *cameraManager;
}

@synthesize classifier;

#pragma mark - Managing the detail item


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    cameraManager = [[CameraManager alloc] init];
    cameraManager.delegate = self;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [cameraManager disableCamera];
}

- (void) setClassifier:(NSString *)_classifier
{
    classifier = _classifier;
    if (classifier == nil) {
        return;
    }
    
    cascade1 = new cv::CascadeClassifier();
    cascade1->load([classifier UTF8String]);

    [cameraManager enableCamera];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - delegate
-(void)videoFrameUpdate:(CGImageRef)cgImage from:(CameraManager*)manager{
    
    double scale = 2.0;
    
    //ビデオからの出力を２７０度変更
    UIImage* imageRotate = [CameraManager rotateImage:[UIImage imageWithCGImage:cgImage] angle:270];
    
    //opencvで扱う形式に変更
    cv::Mat mat , gray;
    
    mat = [imageRotate CVMat];
    //グレースケール化
    gray = [imageRotate CVGrayscaleMat];
    imageRotate = nil;
    
    // 処理効率のため半分に 320X240
    cv::resize(gray, gray, cv::Size(), 0.5f, 0.5f, cv::INTER_LINEAR);
    
    
    std::vector<cv::Rect> cans1, cans2;
    
    //検出処理
    cascade1->detectMultiScale(gray, cans1, 1.1, 2, cv::CASCADE_DO_CANNY_PRUNING, cv::Size(80, 80));
    
    BOOL d1 = NO,d2 = NO;
    CGPoint point1,point2;
    //検出した缶を処理する
    for (int i = 0; i < cans1.size(); i++) {
        //リサイズしたスケールを元に戻す
        cans1[i].x *= scale;
        cans1[i].y *= scale;
        cans1[i].width *= scale;
        cans1[i].height *= scale;
        
        //検出した缶の範囲を描画
        cv::rectangle(mat, cans1[i], cv::Scalar( 0, 255, 255 ));
        point1 = CGPointMake(cans1[i].x, cans1[i].y);
        d1 = YES;
    }
    
    UIImage *image = [UIImage imageWithCVMat:mat];
    if (d1 || d2) {
        UIGraphicsBeginImageContext(image.size);
        [image drawAtPoint:CGPointMake(0, 0)];
        if(d1){
            NSDictionary *attrs= @{ NSForegroundColorAttributeName : [UIColor cyanColor],
                                    NSFontAttributeName : [UIFont systemFontOfSize:20.0f] };
            [self.name drawAtPoint:point1 withAttributes:attrs];
        }
        if(d2){
            NSDictionary *attrs= @{ NSForegroundColorAttributeName : [UIColor yellowColor],
                                    NSFontAttributeName : [UIFont systemFontOfSize:20.0f] };
            [@"Object2" drawAtPoint:point2 withAttributes:attrs];
        }
        self.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }else{
        self.imageView.image = image;
    }
}


@end
