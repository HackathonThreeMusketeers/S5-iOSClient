//
//  opencvWrapper.h
//  OpenCVDiff
//
//  Created by 高畑孝輝 on 2018/07/08.
//  Copyright © 2018 高畑孝輝. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface opencvWrapper : NSObject


+(double)flow:(UIImage *)image1 image2:(UIImage *)image2;
+(UIImage *)toGray:(UIImage *)input_img;

@end
