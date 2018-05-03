//
//  PublicMethods.h
//  NTChat
//
//  Created by 古秀湖 on 16/7/5.
//  Copyright © 2016年 南天. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PublicMethods : NSObject

#pragma mark - 去除tableview多余行
/**
 去除tableview多余行
 
 @param tableView tableView实例
 */
+(void)setExtraCellLineHidden:(UITableView *)tableView;

/**
 将Dictionary转换成字符串
 
 @param dict 要转换的Dic
 @return Dic的字符串
 */
+ (NSString*) convertDictionaryToString:(NSMutableDictionary*) dict;

/**
 警示框，只有一个内容和一个确定按钮

 @param text 提示内容
 */
+ (void)showNormalAlertWithText:(NSString*)text;

#pragma mark - 计算指定字符串宽度
/**
 *  计算指定字符串宽度
 *
 *  @param string 字符串
 *  @param font   字号
 *
 *  @return 宽度
 */
+ (CGFloat)widthWithString:(NSString *)string andTextFont:(UIFont*)font;

#pragma mark - NSUserDefaults
/**
 *  从NSUserDefaults中根据
 *
 *  @param key 键
 *
 *  @return 对象
 */
+(id)getObjFromUserdefaultsWithKey:(NSString*)key;

/**
 *  保存值到NSUserDefaults中
 *
 *  @param key 键
 *  @param obj 值
 */
+(void)saveToUserdefaultsWithKey:(NSString*)key andObj:(id)obj;

/**
 *  从NSUserDefaults中获取bool值
 *
 *  @param key 键
 *
 *  @return 对象
 */
+(BOOL)getBoolFromUserdefaultsWithKey:(NSString*)key;

/**
 *  保存bool值到NSUserDefaults中
 *
 *  @param key 键
 *  @param boolValue bool值
 */
+(void)saveToUserdefaultsWithKey:(NSString*)key andBool:(BOOL)boolValue;

/**
 *  从NSUserDefaults中去除值
 *
 *  @param key 键
 */
+(void)removeValueFromUserdefaultsWithKey:(NSString*)key;

/**
 *  获取Document目录
 *
 *  @return Document目录路径
 */
+ (NSString *)getDirectoryOfDocumentFolder;

/**
 图片指定大小
 
 @param image 图片
 @param reSize 尺寸
 @return 图片
 */
+ (UIImage *)reSizeImage:(UIImage *)image toSize:(CGSize)reSize;

/**
 获取拼音
 
 @param chinese 中文
 @return 拼音
 */
+ (NSString *)transform:(NSString *)chinese;

/**
 获取时间戳
 
 @return 当前时间戳
 */
+(NSString*)getTimeString;

/**
 获取时间戳的数字
 
 @return 当前时间戳
 */
+(double)getTimeDouble;

/**
 计算文字的cgsize
 
 @param string 文字
 @param font 字号
 @param width 指定宽度
 @param height 指定高度
 @param breakMode 换行模式
 @return CGSize
 */
+ (CGSize)cgsizeWithString:(NSString *)string andTextFont:(UIFont*)font andLimitWidth:(CGFloat)width andLimitHeight:(CGFloat)height andLineBreakMode:(NSLineBreakMode)breakMode;

/**
 时间戳比较
 
 @param start 1
 @param end 2
 @return 结果
 */
+ (BOOL)minuteOffSetStart:(NSString *)start end:(NSString *)end;

+ (NSString *)changeTheDateString:(long long)time;

/**
 清空cookies
 */
+(void)cleanAllCookies;

/**
 *  消息提示音
 */
+(void)makeSound;

/**
 *  震动
 */
+(void)makeShake;

+ (NSMutableArray*)detectLinksWithText:(NSString*)text;

+ (UIImage*) getVideoPreViewImageWithPath:(NSURL*)videoPath;

/**
 *  去除字符串空格
 *
 *  @param str 要处理的字符串
 *
 *  @return 去除了空格的字符串
 */
+ (NSString *)trim:(NSString *)str;

/**
 检查应用更新
 */
+(void)checkForAppUpdate;

+(void)createGroupPhotoWithAry:(NSArray*)array andGroupId:(NSString*)groupId andSuccessBlock:(void (^)(UIImage *img))successBlock;

/**
 *  压缩图片质量，返回值为可直接转化成UIImage对象的NSData对象
 *  aimLength: 目标大小，单位：字节（b）
 *  accuracyOfLength: 压缩控制误差范围(+ / -)，本方法虽然给出了误差范围，但实际上很难确定一张图片是否能压缩到误差范围内，无法实现精确压缩。
 */
+ (NSData *)compressImageWithImage:(UIImage *)image aimWidth:(CGFloat)width aimLength:(NSInteger)length accuracyOfLength:(NSInteger)accuracy;
@end
