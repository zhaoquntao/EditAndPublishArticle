//
//  PublickViewController.m
//  编辑文章
//
//  Created by 赵群涛 on 16/5/2.
//  Copyright © 2016年 愚非愚余. All rights reserved.
//

#import "PublickViewController.h"
#import "UIImage+SLImage.h"
#import "PlaceholderTextView.h"
#import "ImageTextAttachment.h"
#import "NSAttributedString+RichText.h"
#import "UIView+TYAlertView.h"
#define ImageTag (@"[UIImageView]")
#define MaxLength (2000)
#define BARandomData arc4random_uniform(100)
#define WIDTH ([UIScreen  mainScreen].bounds.size.width)
#define HEIGHT ([UIScreen mainScreen].bounds.size.height)
//RGB的颜色转换
#define kUIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
@interface PublickViewController ()<UITextViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    NSInteger keyBoardHeight;
    UIView *_toolView;
    
    UIButton *cancleBtn;
    float image_h;
    NSString *_imageBizno;
    NSString *bizNosStr;
    
    
}

@property (nonatomic, copy)NSString *imageName;//图片名
@property (nonatomic, strong)NSData   *imageData;//图片流
@property (nonatomic, strong) PlaceholderTextView *messageInputView;
@property (nonatomic,assign) NSUInteger location;  //纪录变化的起始位置
@property (nonatomic,strong) NSMutableAttributedString * locationStr;

@property (nonatomic,assign) CGFloat lineSapce;    //行间距

@end

@implementation PublickViewController
+(instancetype)ViewController
{
    
    PublickViewController * ctrl = [[PublickViewController alloc] initWithNibName:@"RichText" bundle:nil];
    
    return ctrl;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.extendedLayoutIncludesOpaqueBars = NO;
    self.modalPresentationCapturesStatusBarAppearance = NO;
    image_h = 0;
    bizNosStr = @"";
    
    self.location=0;
    self.lineSapce=5;
    [self setNav];
    [self createView];
}

- (void)createView {
    
    self.messageInputView = [[PlaceholderTextView alloc] initWithFrame:CGRectMake(15, 15, WIDTH - 32, 75)];
    self.messageInputView.placeholder = @"请输入文章内容";
    self.messageInputView.placeholderColor = kUIColorFromRGB(0xCCCCCC);
    self.messageInputView.textColor = [UIColor redColor];
    self.messageInputView.delegate = self;
    self.messageInputView.font = [UIFont systemFontOfSize:20];
    self.messageInputView.editable = YES;
    [self.messageInputView becomeFirstResponder];
    
    [self.view addSubview:self.messageInputView];
    
    NSRange wholeRange = NSMakeRange(0, self.messageInputView.textStorage.length);
    [self.messageInputView.textStorage removeAttribute:NSFontAttributeName range:wholeRange];
    [self.messageInputView.textStorage removeAttribute:NSForegroundColorAttributeName range:wholeRange];
    //字体颜色
    [self.messageInputView.textStorage addAttribute:NSForegroundColorAttributeName value:kUIColorFromRGB(0x999555) range:wholeRange];
    
    //字体
    [self.messageInputView.textStorage addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:20] range:wholeRange];
    
    
    //增加监听，当键盘出现或改变时收出消息
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    //增加监听，当键退出时收出消息
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
    _toolView  = [[UIView alloc]init];
    _toolView.backgroundColor = kUIColorFromRGB(0xf0f0f0);
    _toolView.frame = CGRectMake(0, HEIGHT - 64, WIDTH, 50);
    
    [self.view addSubview:_toolView];
    
    UIButton *losebtn = [UIButton buttonWithType:UIButtonTypeCustom];
    losebtn.frame = CGRectMake(WIDTH - 50, 0, 50, 50);
    //[btn setBackgroundColor:[UIColor whiteColor]];
    [losebtn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    [losebtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [losebtn setTitle:@"完成" forState:UIControlStateNormal];
    [_toolView addSubview:losebtn];
    
    UIButton *imageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [imageBtn setTitle:@"图片" forState:UIControlStateNormal];
    imageBtn.frame = CGRectMake(15, 0, 50, 50);
    [imageBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [imageBtn addTarget:self action:@selector(imageBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [_toolView addSubview:imageBtn];
    
    UIButton *cameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cameraBtn setTitle:@"相机" forState:UIControlStateNormal];
    cameraBtn.frame = CGRectMake(65, 0, 50, 50);
    [cameraBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [cameraBtn addTarget:self action:@selector(cameraBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [_toolView addSubview:cameraBtn];
    
}

#pragma mark 取消
-(void)canclebtnBtnClick{
    self.messageInputView.text = @"";
}
#pragma mark 相册
-(void)imageBtnClick
{
    
    UIImagePickerController *photo = [[UIImagePickerController alloc] init];
    photo.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    photo.delegate = self;
    photo.allowsEditing = YES;
    [self presentViewController:photo animated:YES completion:nil];
    
}
#pragma mark 相机
-(void)cameraBtnClick
{
    
    //判断是否可以打开相机，模拟器此功能无法使用
    if (![UIImagePickerController isSourceTypeAvailable:
          
          UIImagePickerControllerSourceTypeCamera]) {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"错误" message:@"没有摄像头" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"返回" style:UIAlertActionStyleDefault handler:nil];
        
        [alertController addAction:okAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
        
        return;
    }
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    
    //    imagePicker.allowsEditing = YES;
    
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:imagePicker animated:YES completion:nil];
    
}

#pragma mark 弹下
-(void)btnClick
{
    [self.messageInputView resignFirstResponder];
}

#pragma mark -相册代理
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    
    //图片保存时每一张图片都要由一个名字，而相册和拍照中返回的info是不同的，但不管如何，都要想办法给每张图片一个唯一的名字
    if (picker.sourceType ==UIImagePickerControllerSourceTypePhotoLibrary) {
        //获取每张图片的id，用来作为保存在沙盒中的文件名
        NSString *getsrc=[NSString stringWithFormat:@"%@",(NSString *)[info objectForKey:@"UIImagePickerControllerReferenceURL"]];
        NSRange range={33,47};
        self.imageName=[NSString stringWithFormat:@"%@.jpg",[getsrc substringWithRange:range]];
    }
    if (picker.sourceType ==UIImagePickerControllerSourceTypeCamera) {
        self.imageName=[NSString stringWithFormat:@"%@.jpg",[[[info objectForKey:@"UIImagePickerControllerMediaMetadata"] objectForKey:@"{Exif}"] objectForKey:@"DateTimeDigitized"]];
        self.imageName = [self.imageName stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        
    }
    NSString *identifierForVendor = [[UIDevice currentDevice].identifierForVendor UUIDString];
    self.imageName = [NSString stringWithFormat:@"%@%u.jpg",identifierForVendor,BARandomData];
    [self saveImage:image WithName:self.imageName];
    //适配屏幕宽度
    UIImage *image1 = [image scaleToSize:CGSizeMake(WIDTH, image.size.height*WIDTH/image.size.width)];
    image = [self compressImage:image toMaxFileSize:0.2];
    image_h = image1.size.height;
    ImageTextAttachment *imageTextAttachment = [ImageTextAttachment new];
    
    image=[imageTextAttachment scaleImage:image withSize:CGSizeMake(WIDTH - 30,image_h)];
    //Set tag and image
    imageTextAttachment.image =image;
    
    
    //Set image size
    imageTextAttachment.imageSize = CGSizeMake(WIDTH - 30,image_h);
    
    //Insert image image
    [self.messageInputView.textStorage insertAttributedString:[NSAttributedString attributedStringWithAttachment:imageTextAttachment]
                                                      atIndex:self.messageInputView.selectedRange.location];
    //Move selection location
    self.messageInputView.selectedRange = NSMakeRange(self.messageInputView.selectedRange.location + 1, self.messageInputView.selectedRange.length);
    
    
    //设置字的设置
    [self setInitLocation];
  
    
    
    imageTextAttachment.imageTag = ImageTag;
    
    
    //适配屏幕宽度
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    [self.messageInputView becomeFirstResponder];
    
}

//保存图片至沙盒
- (void)saveImage:(UIImage *)tempImage WithName:(NSString *)imaName
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
#pragma mark 当键盘出现或改变时调用
- (void)keyboardWillShow:(NSNotification *)aNotification
{
    //获取键盘的高度
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    keyBoardHeight = keyboardRect.size.height;
    [UIView animateWithDuration:0.1 animations:^{
        self.messageInputView.frame = CGRectMake(15,  15 , WIDTH -32, HEIGHT-keyBoardHeight - 15- 50- 64);
        _toolView.frame = CGRectMake(0, HEIGHT-keyBoardHeight-50 - 64, WIDTH, 50);
    }];
    
}

#pragma mark 当键退出时调用
- (void)keyboardWillHide:(NSNotification *)aNotification
{
    [UIView animateWithDuration:0.1 animations:^{
        self.messageInputView.frame = CGRectMake(15, 15, WIDTH -32, HEIGHT - 15 - 64);
        _toolView.frame = CGRectMake(10, HEIGHT+50, WIDTH, 50);
    }];
}
#pragma mark textViewDelegate
/**
 *  点击图片触发代理事件
 */
- (BOOL)textView:(UITextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange
{
    //    NSLog(@"%@", textAttachment);
    return NO;
}

/**
 *  点击链接，触发代理事件
 */
- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange
{
    [[UIApplication sharedApplication] openURL:URL];
    return YES;
}
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    
    return YES;
}

-(void)textViewDidChange:(UITextView *)textView
{
    
    
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    
}

-(void)setStyle
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

-(void)setInitLocation
{
    
    
    self.locationStr=nil;
    self.locationStr=[[NSMutableAttributedString alloc]initWithAttributedString:self.messageInputView.attributedText];
    self.messageInputView.font = [UIFont systemFontOfSize:20];
    self.messageInputView.textColor = [UIColor redColor];
    //重新设置位置
    self.location=self.messageInputView.textStorage.length;
    
}


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    
    return YES;
}

//导航条设置
-(void)setNav
{
    
    self.title = @"填写文章内容";
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17],NSForegroundColorAttributeName:[UIColor whiteColor]}];
    UIButton *goBack = [[UIButton alloc] init];//左边的返回按钮
    [goBack setBackgroundImage:[UIImage imageNamed:@"newback"] forState:UIControlStateNormal];
    [goBack addTarget:self action:@selector(goBackClick) forControlEvents:UIControlEventTouchUpInside];
    goBack.frame = CGRectMake(0, 0, 12, 20);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:goBack];
    
    self.view.backgroundColor = kUIColorFromRGB(0xffffff);
    
    
    UIButton *finishBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    finishBtn.frame = CGRectMake(0, 0, 50, 25);
    [finishBtn setTitle:@"提交" forState:UIControlStateNormal];
    [finishBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [finishBtn addTarget:self action:@selector(submitButton) forControlEvents:UIControlEventTouchUpInside];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:finishBtn];
    
}

- (void)goBackClick
{
    [self.navigationController  popViewControllerAnimated:YES];
}

#pragma mark 下一步
- (void)submitButton {
    
    NSString *url =@"";
    NSArray * arr=[self.messageInputView.attributedText getArrayWithAttributed];
    if (arr.count>0) {
        
        for (NSDictionary * dict in arr) {
            NSString *str = [NSString stringWithFormat:@"connent%@:",[dict objectForKey:@"title"]];
            //            NSLog(@"title---%@",[dict objectForKey:@"title"]);
            
            url = [url stringByAppendingString:str];
        }
        NSString *temp2 = [url substringToIndex:[url length]-1];
         NSLog(@"文章内容:%@",temp2);
    }
    
    
}

- (UIImage *)compressImage:(UIImage *)image toMaxFileSize:(NSInteger)maxFileSize {
    CGFloat compression = 0.9f;
    CGFloat maxCompression = 0.1f;
    NSData *imageData = UIImageJPEGRepresentation(image, compression);
    while ([imageData length] > maxFileSize && compression > maxCompression) {
        compression -= 0.1;
        imageData = UIImageJPEGRepresentation(image, compression);
    }
    
    UIImage *compressedImage = [UIImage imageWithData:imageData];
    return compressedImage;
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}



@end
