# EditAndPublishArticle
##发表文章
## 删除之前的版本,从新新建一个库,适配iOS10
##主要代码
### image=[imageTextAttachment scaleImage:image withSize:CGSizeMake(WIDTH - 30,image_h)];
    //Set tag and image
    imageTextAttachment.image =image;

    imageTextAttachment.imageSize = CGSizeMake(WIDTH - 30,image_h);

    NSMutableAttributedString * string = [[NSMutableAttributedString alloc] initWithAttributedString:self.messageInputView.attributedText];
    NSAttributedString  *textAttachmentString = [NSAttributedString attributedStringWithAttachment:imageTextAttachment];

    NSAttributedString *nString = [[NSAttributedString alloc] initWithString:@"\n" attributes:nil];
    [string insertAttributedString:nString atIndex:self.messageInputView.selectedRange.location];
    [string insertAttributedString:textAttachmentString atIndex:self.messageInputView.selectedRange.location + 1];
    [string insertAttributedString:nString atIndex:self.messageInputView.selectedRange.location + 2];
##选择好的照片保存到沙盒
##保存图片至沙盒
###   - (void)saveImage:(UIImage *)tempImage WithName:(NSString *)imaName
   {
     //压缩图片
    self.imageData = UIImageJPEGRepresentation(tempImage, 0.5);
    
    //从沙盒中获取文件路径
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsDirectory = [paths objectAtIndex:0];
    NSString* fullPathToFile = [documentsDirectory stringByAppendingPathComponent:imaName];
    //图片流写入沙盒
    BOOL flag =[self.imageData writeToFile:fullPathToFile atomically:YES];
    if (flag) {
        NSLog(@"图片保存到沙盒成功");
      }
    
    }
    
## 每次输入完处理输入的内容和图片
### -(void)setStyle
   {
    //每次后拼装
      if (self.messageInputView.textStorage.length<self.location) {
        [self setInitLocation];
        return;
    }
    NSString * str=[self.messageInputView.text substringFromIndex:self.location];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = self.lineSapce;// 字体的行间距
    NSDictionary *attributes=nil;
    attributes = @{
                   NSFontAttributeName:[UIFont systemFontOfSize:14],
                   NSForegroundColorAttributeName:kUIColorFromRGB(0x666666),
                   NSParagraphStyleAttributeName:paragraphStyle
                   };
    
    NSAttributedString * appendStr=[[NSAttributedString alloc] initWithString:str attributes:attributes];
    [self.locationStr appendAttributedString:appendStr];
    self.messageInputView.attributedText =self.locationStr;
    
    //重新设置位置
    self.location=self.messageInputView.textStorage.length;
   }
   
   
 ##每次插入图片后，重新计算光标位置
 ###   -(void)setInitLocation
   {
    self.locationStr=nil;
    self.locationStr=[[NSMutableAttributedString alloc]initWithAttributedString:self.messageInputView.attributedText];
    self.messageInputView.font = [UIFont systemFontOfSize:20];
    self.messageInputView.textColor = [UIColor redColor];
    //重新设置位置
    self.location=self.messageInputView.textStorage.length; 
    }
