//
//  ImageTextAttachment.m
//  RichTextView
//
//  Created by 赵群涛 on 16/5/2.
//  Copyright © 2016年 愚非愚余. All rights reserved.
//

#import "ImageTextAttachment.h"

@implementation ImageTextAttachment
- (CGRect)attachmentBoundsForTextContainer:(NSTextContainer *)textContainer proposedLineFragment:(CGRect)lineFrag glyphPosition:(CGPoint)position characterIndex:(NSUInteger)charIndex {
        return CGRectMake(0, 0, _imageSize.width, _imageSize.height);
    
//    //调整图片大小
//    return CGRectMake( 0 , 0 , [[UIScreen mainScreen] bounds].size.width , 80);
   
}
- (UIImage *)scaleImage:(UIImage *)image withSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}
@end
