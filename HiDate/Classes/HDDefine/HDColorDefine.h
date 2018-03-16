//
//  HDColorDefine.h
//  HiParty
//
//  Created by lzh on 15/10/21.
//  Copyright © 2015年 lzh. All rights reserved.
//

#ifndef HDColorDefine_h
#define HDColorDefine_h


#define UIColorRGBA(R, G, B, A)  [UIColor colorWithRed:R / 255.0f green:G / 255.0f blue:B / 255.0f alpha:A]

#pragma mark - BackGroundColor

#define HDColor_EAC180          UIColorRGBA(234, 193, 128, 1)  //EAC180
#define HDColor_464754          UIColorRGBA(70, 71, 84, 1)  //464754

/* 主色调 */
#define HDColorMainColor        UIColorRGBA(38, 236, 171, 1)  //26ECAB

/* 标题栏黑色 */
#define HDColorTitleBarColor    UIColorRGBA(0, 0, 0, 1)       //000000

/* 内容显示区 */
#define HDColorContentColor     UIColorRGBA(24, 24, 30, 1)    //18181E

/* 操作栏, 大部分点击色 */
#define HDColorHoverColor       UIColorRGBA(16, 16, 20, 1)    //101014

/* 列表内容色 */
#define HDColorListContentColor UIColorRGBA(21, 21, 26, 1)    //15151A

/* 卡片类，列表间隔色 */
#define HDColorListLineColor    UIColorRGBA(35, 35, 44, 1)    //23232C

/* 文本提示框颜色 */
#define HDColorTextPlaceHolder    UIColorRGBA(54, 54, 61, 1)    //36363D

/* 文本输入颜色 */
#define HDColorTextColor    UIColorRGBA(187, 187, 204, 1)    //BBBBCC

/* 文本Hi币颜色 */
#define HDColorHiCoinColor    UIColorRGBA(255, 248, 71, 1)    //fff847

/* 文本Hi币颜色 */
#define HDSwitchBorderColor    UIColorRGBA(48, 48, 55, 1)    //303037

/* 喜欢我的人数颜色 红色*/
#define HDLikedMeCountColor    UIColorRGBA(255, 46, 90, 1)    //ff2e5a

#pragma mark - TextColor

/* 导航栏标题颜色 */
#define HDColorBarTitleColor UIColorRGBA(255, 255, 255, 1)   //FFFFFF

/* 时间，次要信息，白色点击反馈色 */
#define HDColorSubTitleColor UIColorRGBA(84, 84, 96, 1)      //545460

/* 列表类主文字颜色 */
#define HDColorMainListTitleColor UIColorRGBA(152, 152, 168, 1) //9898A8

/* 列表类附属颜色，提示性文字颜色*/
#define HDColorSubListTitleColor UIColorRGBA(113, 113, 127, 1)  //71717F

/* 好友列表颜色 */
#define HDColorFriendListColor UIColorRGBA(204, 204, 220, 1) //ccccdc

#define HDColor_C1995C UIColorRGBA(193, 153, 92, 1)

#define HDColor_CE4242 UIColorRGBA(206, 66, 66, 1)

#endif /* HDColorDefine_h */
