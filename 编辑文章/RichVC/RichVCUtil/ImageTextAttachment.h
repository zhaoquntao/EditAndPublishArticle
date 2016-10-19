//
//  ImageTextAttachment.h
//  RichTextView
//
//  Created by 赵群涛 on 16/5/2.
//  Copyright © 2016年 愚非愚余. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageTextAttachment : NSTextAttachment
@property(strong, nonatomic) NSString *imageTag;
@property(assign, nonatomic) CGSize imageSize;  //For emoji image size

- (UIImage *)scaleImage:(UIImage *)image withSize:(CGSize)size;
@end
