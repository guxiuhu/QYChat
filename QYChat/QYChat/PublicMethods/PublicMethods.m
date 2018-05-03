//
//  PublicMethods.m
//  NTChat
//
//  Created by 古秀湖 on 16/7/5.
//  Copyright © 2016年 南天. All rights reserved.
//

#import "PublicMethods.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@implementation PublicMethods

#pragma mark - 去除tableview多余行
/**
 去除tableview多余行

 @param tableView tableView实例
 */
+(void)setExtraCellLineHidden:(UITableView *)tableView{
    
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
}

/**
 将Dictionary转换成字符串

 @param dict 要转换的Dic
 @return Dic的字符串
 */
+ (NSString*) convertDictionaryToString:(NSMutableDictionary*) dict{
    
    if (!dict) {
        return @"";
    }
    
    NSError* error;
    NSDictionary* tempDict = [dict copy]; // get Dictionary from mutable Dictionary
    //giving error as it takes dic, array,etc only. not custom object.
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:tempDict
                                                       options:NSJSONWritingPrettyPrinted error:&error];
    NSString* nsJson=  [[NSString alloc] initWithData:jsonData
                                             encoding:NSUTF8StringEncoding];
    return nsJson;
}

/**
 警示框，只有一个内容和一个确定按钮
 
 @param text 提示内容
 */
+ (void)showNormalAlertWithText:(NSString*)text{
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:text delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil ];
    [alert show];
}

#pragma mark - 计算指定字符串宽度
/**
 *  计算指定字符串宽度
 *
 *  @param string 字符串
 *  @param font   字号
 *
 *  @return 宽度
 */
+ (CGFloat)widthWithString:(NSString *)string andTextFont:(UIFont*)font{
    
    CGRect rect = [string boundingRectWithSize:CGSizeMake(MAXFLOAT,MAXFLOAT)
                                       options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesFontLeading  |NSStringDrawingUsesLineFragmentOrigin//采用换行模式
                                    attributes:@{NSFontAttributeName:font}//传人的字体字典
                                       context:nil];
    
    return rect.size.width;
}

/**
 计算文字的cgsize

 @param string 文字
 @param font 字号
 @param width 指定宽度
 @param height 指定高度
 @param breakMode 换行模式
 @return CGSize
 */
+ (CGSize)cgsizeWithString:(NSString *)string andTextFont:(UIFont*)font andLimitWidth:(CGFloat)width andLimitHeight:(CGFloat)height andLineBreakMode:(NSLineBreakMode)breakMode{
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.lineBreakMode = breakMode;
    NSDictionary *attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle.copy};
    
    CGRect rect = [string boundingRectWithSize:CGSizeMake(width,height)
                                       options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesFontLeading  |NSStringDrawingUsesLineFragmentOrigin//采用换行模式
                                    attributes:attributes//传人的字体字典
                                       context:nil];
    
    return rect.size;
}

#pragma mark - NSUserDefaults
/**
 *  从NSUserDefaults中获取值
 *
 *  @param key 键
 *
 *  @return 对象
 */
+(id)getObjFromUserdefaultsWithKey:(NSString*)key{
    
    id value = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if (value == nil) {
        value = @"";
    }
    return value;
}

/**
 *  保存值到NSUserDefaults中
 *
 *  @param key 键
 *  @param obj 值
 */
+(void)saveToUserdefaultsWithKey:(NSString*)key andObj:(id)obj{
    
    if ([obj isKindOfClass:[NSDictionary class]]) {
        
        NSMutableDictionary *tempDic = [[NSMutableDictionary alloc]initWithDictionary:obj];
        
        for (NSString *key in [tempDic allKeys]) {
            id value = [tempDic valueForKey:key];
            
            if (value == nil || value == [NSNull null]) {

                [tempDic setObject:@"" forKey:key];
            }
        }
        
        [[NSUserDefaults standardUserDefaults]setObject:tempDic forKey:key];
        [[NSUserDefaults standardUserDefaults]synchronize];

    }else{
        [[NSUserDefaults standardUserDefaults]setObject:obj forKey:key];
        [[NSUserDefaults standardUserDefaults]synchronize];
        
    }
}

/**
 *  从NSUserDefaults中获取bool值
 *
 *  @param key 键
 *
 *  @return 对象
 */
+(BOOL)getBoolFromUserdefaultsWithKey:(NSString*)key{
    
    return [[NSUserDefaults standardUserDefaults] boolForKey:key];
}

/**
 *  保存bool值到NSUserDefaults中
 *
 *  @param key 键
 *  @param boolValue bool值
 */
+(void)saveToUserdefaultsWithKey:(NSString*)key andBool:(BOOL)boolValue{
    
    [[NSUserDefaults standardUserDefaults]setBool:boolValue forKey:key];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

/**
 *  从NSUserDefaults中去除值
 *
 *  @param key 键
 */
+(void)removeValueFromUserdefaultsWithKey:(NSString*)key{
    
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:key];
    [[NSUserDefaults standardUserDefaults]synchronize];
}


/**
 *  获取Document目录
 *
 *  @return Document目录路径
 */
+ (NSString *)getDirectoryOfDocumentFolder {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); // 获取所有Document文件夹路径
    NSString *documentsPath = paths[0]; // 搜索目标文件所在Document文件夹的路径，通常为第一个
    
    if (!documentsPath) {
        NSLog(@"Documents目录不存在");
    }
    
    return documentsPath;
}

/**
 图片指定大小

 @param image 图片
 @param reSize 尺寸
 @return 图片
 */
+ (UIImage *)reSizeImage:(UIImage *)image toSize:(CGSize)reSize{
    
    UIGraphicsBeginImageContext(CGSizeMake(reSize.width, reSize.height));
    [image drawInRect:CGRectMake(0, 0, reSize.width, reSize.height)];
    UIImage *reSizeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return reSizeImage;
}

/**
 获取拼音

 @param chinese 中文
 @return 拼音
 */
+ (NSString *)transform:(NSString *)chinese{
    //将NSString装换成NSMutableString
    NSMutableString *pinyin = [chinese mutableCopy];
    
    //将汉字转换为拼音(带音标)
    CFStringTransform((__bridge CFMutableStringRef)pinyin, NULL, kCFStringTransformMandarinLatin, NO);
    
    //去掉拼音的音标
    CFStringTransform((__bridge CFMutableStringRef)pinyin, NULL, kCFStringTransformStripCombiningMarks, NO);
    
    //返回最近结果
    return [pinyin uppercaseString];
}

/**
 获取时间戳

 @return 当前时间戳
 */
+(NSString*)getTimeString{
    
    //时间戳
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a = [dat timeIntervalSince1970];
    NSString *timeString = [NSString stringWithFormat:@"%.0f", a];

    double time = [timeString doubleValue]*1000;
    
    return [NSString stringWithFormat:@"%.0f",time];
}

/**
 获取时间戳的数字
 
 @return 当前时间戳
 */
+(double)getTimeDouble{
    
    //时间戳
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a = [dat timeIntervalSince1970];
    NSString *timeString = [NSString stringWithFormat:@"%.0f", a];
    
    double time = [timeString doubleValue];
    return time;
}

/**
 时间戳比较

 @param start 1
 @param end 2
 @return 结果
 */
+ (BOOL)minuteOffSetStart:(NSString *)start end:(NSString *)end{
    
    NSTimeInterval tempMilli = start.longLongValue/1000;
    NSTimeInterval seconds = tempMilli;
    NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:seconds];
    
    NSTimeInterval tempMilli1 = end.longLongValue/1000;
    NSTimeInterval seconds1 = tempMilli1;
    NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:seconds1];
    
    //这个是相隔的秒数
    NSTimeInterval timeInterval = [startDate timeIntervalSinceDate:endDate];
    
    //相距1分钟
    if (fabs (timeInterval) > 60) {
        
        return YES;
    }else{
        return NO;
    }
    
}


/**
 时间处理工具类

 @param time 时间戳13位
 @return 处理的字符串
 */
+ (NSString *)changeTheDateString:(long long)time{
    
    //如果传过来的时间是0，返回去个空给你
    if (time == 0) {
        return @"";
    }
    
    //时间戳
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:time/1000];
    
    NSCalendar * calendar=[[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSInteger unitFlags = NSCalendarUnitMonth | NSCalendarUnitDay| NSCalendarUnitYear | NSCalendarUnitHour | NSCalendarUnitMinute |NSCalendarUnitSecond|NSCalendarUnitWeekOfMonth|NSCalendarUnitWeekday;
    NSDateComponents * component=[calendar components:unitFlags fromDate:date];
    
    int year=[component year];
    int month=[component month];
    int day=[component day];
    
    int hour=[component hour];
    int minute=[component minute];
    
    NSDate * today=[NSDate date];
    component=[calendar components:unitFlags fromDate:today];
    
    int t_year=[component year];
    
    NSString*string=nil;
    if (t_year == year) {
        string=[NSString stringWithFormat:@"%02d-%02d %d:%02d",month,day,hour,minute];
    }else{
        string=[NSString stringWithFormat:@"%d-%d-%d",year,month,day];
    }
    
//
//    
//    long long now=[today timeIntervalSince1970];
//    
//    long long distance=now-time/1000;
//    if(distance<60)
//        string=@"刚刚";
//    else if(distance<60*60)
//        string=[NSString stringWithFormat:@"%lld分钟前",distance/60];
//    else if(distance<60*60*24)
//        string=[NSString stringWithFormat:@"%lld小时前",distance/60/60];
//    else if(distance<60*60*24*7)
//        string=[NSString stringWithFormat:@"%lld天前",distance/60/60/24];
//    else if(year==t_year)
//        string=[NSString stringWithFormat:@"%02d-%02d %d:%02d",month,day,hour,minute];
//    else
//        string=[NSString stringWithFormat:@"%d-%d-%d",year,month,day];
    
    return string;
    
}


/**
 清空cookies
 */
+(void)cleanAllCookies{
    
    NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [cookieJar cookies]) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
    }
}

static double lastAlertTime = 0;

/**
 *  消息提示音
 */
+(void)makeSound{
    
    double nowTime = [PublicMethods getTimeDouble];
    if (fabs(nowTime - lastAlertTime) > 1) {

        lastAlertTime = [self getTimeDouble];
     
        //    AudioServicesPlaySystemSound(1000);

        NSURL *url=[[NSBundle mainBundle]URLForResource:@"message.wav" withExtension:nil];
        //2.加载音效文件，创建音效ID（SoundID,一个ID对应一个音效文件）
        SystemSoundID soundID=0;
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &soundID);
        //把需要销毁的音效文件的ID传递给它既可销毁
        //下面的两个函数都可以用来播放音效文件，第一个函数伴随有震动效果
        AudioServicesPlaySystemSound(soundID);

    }
}

static double lastShakeTime = 0;


/**
 *  震动
 */
+(void)makeShake{
    
    double nowTime = [PublicMethods getTimeDouble];
    if (fabs(nowTime - lastShakeTime) > 1) {
        
        lastShakeTime = [self getTimeDouble];

        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
}

+ (NSMutableArray*)detectLinksWithText:(NSString*)text{
    
    //	NSMutableArray *tempLinks = [_links mutableCopy];
    NSMutableArray *machName = [[NSMutableArray alloc]init];

    if (![text length])
    {
        return machName;
    }
    
    NSArray *expressions = [[NSArray alloc] initWithObjects:@"(@[\u4e00-\u9fa5a-zA-Z0-9_-]{1,30})",nil];
    //get #hashtags and @usernames
    for (NSString *expression in expressions)
    {
        NSError *error = NULL;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:expression
                                                                               options:NSRegularExpressionCaseInsensitive
                                                                                 error:&error];
        NSArray *matches = [regex matchesInString:text
                                          options:0
                                            range:NSMakeRange(0, [text length])];
        
        NSString *matchedString = nil;
        for (NSTextCheckingResult *match in matches)
        {
            matchedString = [[text substringWithRange:[match range]] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            
            if ([matchedString hasPrefix:@"@"]) // usernames
            {
                
                NSString *str = [text substringWithRange:[match range]];
                if ([str hasPrefix:@"@"]) {
                    str = [str substringFromIndex:1];
                }
                
                [machName addObject:str];
                NSLog(@"++++++++%@",str);
            }
        }
    }
    
    return machName;
}

+ (UIImage*) getVideoPreViewImageWithPath:(NSURL*)videoPath{
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoPath options:nil];
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    gen.requestedTimeToleranceAfter = kCMTimeZero;
    gen.requestedTimeToleranceBefore = kCMTimeZero;
    
    gen.appliesPreferredTrackTransform = YES;
    
    Float64 seconds = 1;
    int32_t preferredTimeScale = 600;
    CMTime inTime = CMTimeMakeWithSeconds(seconds, preferredTimeScale);
    
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef image = [gen copyCGImageAtTime:inTime
                                   actualTime:&actualTime
                                        error:&error];
    UIImage *img = [[UIImage alloc] initWithCGImage:image];
    CGImageRelease(image);
    
    if (!img) {
        
        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoPath options:nil];
        AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        gen.appliesPreferredTrackTransform = YES;
        CMTime time = CMTimeMakeWithSeconds(0.0, 600);
        NSError *error = nil;
        CMTime actualTime;
        CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
        
        img = [[UIImage alloc] initWithCGImage:image];
        CGImageRelease(image);
    }
    
    return img;
}

/**
 *  去除字符串空格
 *
 *  @param str 要处理的字符串
 *
 *  @return 去除了空格的字符串
 */
+ (NSString *)trim:(NSString *)str{
    
    NSString *resultStr = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    return resultStr;
}

+(void)getRects:(NSMutableArray *)array padding:(CGFloat)padding width:(CGFloat)eachWidth count:(int)count {
    
    for (int i=0; i<count; i++) {
        int sqrtInt = (int)sqrt(count);
        int line = i%sqrtInt;
        int row = i/sqrtInt;
        CGRect rect = CGRectMake(padding * (line+1) + eachWidth * line, padding * (row+1) + eachWidth * row, eachWidth, eachWidth);
        [array addObject:NSStringFromCGRect(rect)];
    }
}

/**
 *  压缩图片质量，返回值为可直接转化成UIImage对象的NSData对象
 *  aimLength: 目标大小，单位：字节（b）
 *  accuracyOfLength: 压缩控制误差范围(+ / -)，本方法虽然给出了误差范围，但实际上很难确定一张图片是否能压缩到误差范围内，无法实现精确压缩。
 */
+ (NSData *)compressImageWithImage:(UIImage *)image aimWidth:(CGFloat)width aimLength:(NSInteger)length accuracyOfLength:(NSInteger)accuracy{
    UIImage * newImage = [self imageWithImage:image scaledToSize:CGSizeMake(width, width * image.size.height / image.size.width)];
    
    NSData  * data = UIImageJPEGRepresentation(newImage, 1);
    NSInteger imageDataLen = [data length];
    
    if (imageDataLen <= length + accuracy) {
        return data;
    }else{
        NSData * imageData = UIImageJPEGRepresentation( newImage, 0.99);
        if (imageData.length < length + accuracy) {
            return imageData;
        }
        
        CGFloat maxQuality = 1.0;
        CGFloat minQuality = 0.0;
        int flag = 0;
        
        while (1) {
            CGFloat midQuality = (maxQuality + minQuality)/2;
            
            if (flag == 6) {
                NSLog(@"************* %ld ******** %f *************",UIImageJPEGRepresentation(newImage, minQuality).length,minQuality);
                return UIImageJPEGRepresentation(newImage, minQuality);
            }
            flag ++;
            
            NSData * imageData = UIImageJPEGRepresentation(newImage, midQuality);
            NSInteger len = imageData.length;
            
            if (len > length+accuracy) {
                NSLog(@"-----%d------%f------%ld-----",flag,midQuality,len);
                maxQuality = midQuality;
                continue;
            }else if (len < length-accuracy){
                NSLog(@"-----%d------%f------%ld-----",flag,midQuality,len);
                minQuality = midQuality;
                continue;
            }else{
                NSLog(@"-----%d------%f------%ld--end",flag,midQuality,len);
                return imageData;
                break;
            }
        }
    }
}

//对图片尺寸进行压缩--
+(UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
@end
