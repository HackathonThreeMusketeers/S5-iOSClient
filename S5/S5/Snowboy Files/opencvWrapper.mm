//
//  opencvWrapper.m
//  OpenCVDiff
//
//  Created by 高畑孝輝 on 2018/07/08.
//  Copyright © 2018 高畑孝輝. All rights reserved.
//

#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>
#import "opencvWrapper.h"

@implementation opencvWrapper
+(UIImage *)toGray:(UIImage *)input_img {
    // 変換用Matの宣言
    cv::Mat gray_img;
    UIImageToMat(input_img, gray_img);
    cv::cvtColor(gray_img, gray_img, CV_BGR2GRAY);
    return input_img;
}

+(double)flow:(UIImage *)image1 image2:(UIImage *)image2 {
    // convert image to mat
    cv::Mat mat1, mat2;
    UIImageToMat(image1, mat1);
    UIImageToMat(image2, mat2);
    
    if (mat1.rows != mat2.rows) {
        mat2 = mat2.t();
    }
    
    // convert mat to gray scale
    cv::Mat gray1, gray2;
    cv::cvtColor(mat1, gray1, CV_BGR2GRAY);
    cv::cvtColor(mat2, gray2, CV_BGR2GRAY);
    
    cv::Mat diffmat;
    cv::absdiff(gray1, gray2, diffmat);
    
    cv::Mat result;
    cv::threshold(diffmat, result, 96, 255, cv::THRESH_BINARY);
    
    std::vector<std::vector<cv::Point> > contours;
    findContours(result, contours, CV_RETR_EXTERNAL, CV_CHAIN_APPROX_NONE);
    
    double max_area=0;
    int max_area_contour=-1;
    
    if(contours.size() <= 0) {
        return 100.0;
    }
    
    for(int j=0;j<contours.size();j++){
        double area=cv::contourArea(contours.at(j));
        if(max_area<area){
            max_area=area;
            max_area_contour=j;
        }
    }
    
    if(max_area_contour <= 0) {
        return 100.0;
    }
    
    int count=contours.at(max_area_contour).size();
    
    if(count <= 0 ) {
        return 100.0;
    }
    
    double x=0;
    
    for(int k=0;k<count;k++){
        x += contours.at(max_area_contour).at(k).x;
    }
    x /= count;
    
    return x;
}
@end
