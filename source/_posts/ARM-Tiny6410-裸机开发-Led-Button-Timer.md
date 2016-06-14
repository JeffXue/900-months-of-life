---
title: ARM-Tiny6410-裸机开发-Led_Button_Timer
tags:
  - linux
date: 2012-12-24 17:32
categories: 嵌入式
---

# Overview

本文针对tiny6410裸机程序中的Led、Button、Timer、Interrupt 等控制程序进行分析，部分代码由国嵌相关代码修改得到。
（PS:需安装好jlink和rvds2.2，对于代码中所有include到的文件可以在Reference中找到）

<!-- more -->

# Led

## 电路图
Tiny6410核心板的LED1、LED2、LED3、LED4分别连接到了GPK4、GPK5、GPK6、GPK7。电路图如下：
![LED电路图](http://www.jeffxue.cn/img/001.png)

## led.h 
使用 #ifndef __LED__ 来避免重复的包含文件（每个头文件都建议加上）
module_cfg.h 里进行了模块名的定义 #define LED 
使用#ifdef LED判断是否已经定义模块，已经定义则使宏定义和函数声明有效（配合module_cfg.h可以方便的关闭对应的模块，减少不必要的编译）
```c
#ifndef __LED__
#define __LED__
#include "module_cfg.h"
#ifdef LED

/**************Macro Definition**********/
#define LED1_ON   ~(1<<4)
#define LED2_ON   ~(1<<5)
#define LED3_ON   ~(1<<6)
#define LED4_ON   ~(1<<7)

#define LED1_OFF   (1<<4)
#define LED2_OFF   (1<<5)
#define LED3_OFF   (1<<6)
#define LED4_OFF   (1<<7)
#define LEDALL_OFF (0xf<<4)

/**************Declare Function**********/
void LedDelay(int times);
void LedPortInit(void);
void LedRun(void);



#endif

#endif
```

## led.c
LedDelay 只为简单的延时函数，需要准确的计时可查看Timer章节
LedPortInit 为初始化对应的GPIO为输出模式（翻查s3c6410芯片手册的GPK寄存器可知）
LedRun 为流水灯程序，根据LED电路图可知：IO输出为低电平时，LED点亮；IO输出为高电平时，LED熄灭
```c
#include "module_cfg.h"
#ifdef LED
#include "def.h"
#include "led.h"
#include "gpio.h"
/*************************************************************************
 * ***************************延时函数************************************
 * ***********************************************************************/
void LedDelay(int times)
{
    int i;
    for(;times>0;times--)
      for(i=0;i<3000;i++);
}

/*************************************************************************
 **********************初始化连接LED灯的管脚资源**************************
 * @ 通过将GPIO_BASE强制转化为(volatile oGPIO_REGS*)型的指针可以很方便
 * 的访问各个GPIO寄存器的值，这种方法比通过使用寄存器地址的宏定义访问
 * 寄存器单元更加规范和科学。
 * ***********************************************************************/  
void LedPortInit(void)
{
    u32 uConValue;
    uConValue = GPIO->rGPIOKCON0;
    uConValue &= ~(0xffff<<16);
    uConValue |= 0x1111<<16;
    GPIO->rGPIOKCON0 = uConValue;
    GPIO->rGPIOKDAT|=LEDALL_OFF;            
}

/*************************************************************************
 * ************************跑马灯的实现函数*******************************
 * @ 通过控制连接LED的管脚的输出电平点亮和熄灭各个LED。
 * @ 逐个循环点亮各个LED。在每点亮一个后保持一定时间再熄灭它，接着
 * 点亮下一个LED，这样就形成了一个跑马灯的效果。
 * @ 这是一个需要改善的跑马灯程序，想想怎么优化这段代码。
 * ***********************************************************************/
void LedRun(void)
{
    GPIO->rGPIOKDAT |= LEDALL_OFF;
    while(1)
    {
        GPIO->rGPIOKDAT &= LED1_ON;
        LedDelay(1000);
        GPIO->rGPIOKDAT |= LEDALL_OFF;

        GPIO->rGPIOKDAT &= LED2_ON;
        LedDelay(1000);
        GPIO->rGPIOKDAT |= LEDALL_OFF;

        GPIO->rGPIOKDAT &= LED3_ON;
        LedDelay(1000);
        GPIO->rGPIOKDAT |= LEDALL_OFF;

        GPIO->rGPIOKDAT &= LED4_ON;
        LedDelay(1000);
        GPIO->rGPIOKDAT |= LEDALL_OFF;
    }
}

#endif
```

# Button

## 电路图
Tiny6410底板按键button1~8 分别连接到GPN0~5、GPL11、GPL12，电路图如下：
![Button电路图](http://www.jeffxue.cn/img/002.png)


## 使用轮循方式实现按键识别
设置GPN0~3 为输入
轮循GPNDAT判断按键是否按下
GPN0~3 对应LED1~4,按键按下时，对应的LED会被点亮


led_io.h
```c
#ifndef __KEY_IO__
#define __KEY_IO__
#include "module_cfg.h"
#ifdef KEY_IO

/**************Macro Definition**********/
#define LED1_ON   ~(1<<4)
#define LED2_ON   ~(1<<5)
#define LED3_ON   ~(1<<6)
#define LED4_ON   ~(1<<7)

#define LEDALL_OFF (0xf<<4)


/**************Declare Function**********/
void KeyIoPortInit(void);
unsigned int CheckKeyStat(void);
void KeyIoTest(void);

#endif

#endif
```

led_io.c
```c
#include "module_cfg.h"
#ifdef KEY_IO
#include "def.h"
#include "key_io.h"
#include "gpio.h"
/*************************************************************************
 * ***************************按键IO初始化********************************
 * ***********************************************************************/
void KeyIoPortInit(void)
{
    GPIO->rGPIONCON&=0xffffff00;    
}
/*************************************************************************
 * ***************************检测按键状态********************************
 * ***********************************************************************/
unsigned int CheckKeyStat(void)
 {
    if((GPIO->rGPIONDAT&0x1)==0)return 1;
        else if((GPIO->rGPIONDAT&0x2)==0)return 2;
            else if((GPIO->rGPIONDAT&0x4)==0)return 3;
                else if((GPIO->rGPIONDAT&0x8)==0)return 4;
    return 0;

 }
 
 /*************************************************************************
 * ***************************按键测试程序*********************************
 * ***********************************************************************/
 void KeyIoTest(void)
 {
    unsigned int j;
    while(1)
    {
        j=0;
        j=CheckKeyStat();
        switch(j)
        {
        case 1:GPIO->rGPIOKDAT |= LEDALL_OFF;GPIO->rGPIOKDAT &= LED1_ON;break;
        case 2:GPIO->rGPIOKDAT |= LEDALL_OFF;GPIO->rGPIOKDAT &= LED2_ON;break;
        case 3:GPIO->rGPIOKDAT |= LEDALL_OFF;GPIO->rGPIOKDAT &= LED3_ON;break;
        case 4:GPIO->rGPIOKDAT |= LEDALL_OFF;GPIO->rGPIOKDAT &= LED4_ON;break;
        default :break;
        }
    }
 }
#endif
```

## 使用中断方式识别按键

The interrupt controller in the S3C6410X is composed of  2 VIC’s (Vectored Interrupt Controller, ARM PrimeCell PL192) and 2 TZIC’s (TrustZone Interrupt Controller, SP890). 
Two TZIC’s and VIC’s are daisy-chained to support up to 64 interrupt sources.   （可以查看s3c6410芯片手册看到对应的64个中断源）
![interrupt](http://www.jeffxue.cn/img/003.png)
  
GPN0~3对应中断源为INT_EINT0，该中断源对应了三个中断信号（External interrupt 0 ~ 3 ）
程序入口需要Enable VIC、Enable IRQ、Disable All INT（可查看Reference里面的main.c）
主要配置流程如下
设置GPN0~3为外部中断模式（GPNCON），禁止上拉下拉电阻（GPNPUD），配置中断方式为GPN0、1为低电平触发，GPN2、3为上升沿触发（EINT0CON0）
清除对应的中断悬起位（EINT0PEND）
配置中断服务地址程序（VIC0VECTADDR）
使能中断源（VIC0INTENABLE）
清除中断屏蔽位（EINT0MASK）
具体代码如下：

key_int.h
```c
#ifndef __KEY_INT__
#define __KEY_INT__
#include "module_cfg.h"
#ifdef KEY_INT

/**************Macro Definition**********/
#define LED1_ON   ~(1<<4)
#define LED2_ON   ~(1<<5)
#define LED3_ON   ~(1<<6)
#define LED4_ON   ~(1<<7)
#define LEDALL_OFF (0xf<<4)

/**************Declare Function**********/
void KeyIntPortInit(void);
void __irq Key_Eint(void);
void KeyEintInit(void);
void EINT0ClrPend(u32 uEINT_No);
void EINT0DisMask(u32 uEINT_No);


#endif

#endif
```

key_int.c
```c
#include "module_cfg.h"
#ifdef KEY_INT
#include "def.h"
#include "key_int.h"
#include "gpio.h"
#include "library.h"
/*************************************************************************
 ****************************按键IO初始化*********************************
 *************************************************************************/
void KeyIntPortInit(void)
{
    u32 i;
    
    //设置IO口为外部中断模式
    i=GPIO->rGPIONCON;
    i&=0xffffff00;  
    i|=0x000000AA;  
    GPIO->rGPIONCON=i;
    
    //禁止上拉下拉电阻
    GPIO->rGPIONPUD&=0Xfff0;
    
    //设置对应EINT的中断类型,EINT0/1为low level,EINT2/3为rising edge tiggered 
    i=GPIO->rEINT0CON0;
    i&=0xffffff00;
    i|=0x00000040;
    GPIO->rEINT0CON0=i;
    
}
/*************************************************************************
 ***************************清除中断悬起位********************************
 *************************************************************************/
void EINT0ClrPend(u32 uEINT_No)
{
    GPIO->rEINT0PEND|=0x1<<uEINT_No;    //each bit is cleared by writing 1
}

/*************************************************************************
 ***************************清除中断屏蔽位********************************
 *************************************************************************/
void EINT0DisMask(u32 uEINT_No)
{
    GPIO->rEINT0MASK&=~(0x1<<uEINT_No); //write 0 to enable interrupt
}
/*************************************************************************
 **************************按键中断处理函数*******************************
 *************************************************************************/
void __irq Key_Eint(void)
{
    u32 i;
    
    //判断根据不同的按键引起的中断进行不同的处理,先清除对应中断悬起位，再点亮对应的LED
    i=GPIO->rEINT0PEND;
    if((i&0x1)!=0){EINT0ClrPend(0);GPIO->rGPIOKDAT |= LEDALL_OFF;GPIO->rGPIOKDAT &= LED1_ON;}
        else if((i&0x2)!=0){EINT0ClrPend(1);GPIO->rGPIOKDAT |= LEDALL_OFF;GPIO->rGPIOKDAT &= LED2_ON;}
            else if((i&0x4)!=0){EINT0ClrPend(2);GPIO->rGPIOKDAT |= LEDALL_OFF;GPIO->rGPIOKDAT &= LED3_ON;}
                else if((i&0x8)!=0){EINT0ClrPend(3);GPIO->rGPIOKDAT |= LEDALL_OFF;GPIO->rGPIOKDAT &= LED4_ON;}
    
    //清除rVIC0ADDR，该寄存器记录当前中断服务地址程序
    Outp32(rVIC0ADDR,0);
}
/*************************************************************************
 ****************************EINT初始化函数*******************************
 *************************************************************************/
void KeyEintInit(void)
{
    u32 i;
    KeyIntPortInit();
    EINT0ClrPend(0);
    EINT0ClrPend(1);
    EINT0ClrPend(2);
    EINT0ClrPend(3);
    
    //向 rVIC0VECTADDR 中写入对应的中断服务程序地址
    Outp32(rVIC0VECTADDR,(unsigned)Key_Eint);
    
    //使能中断源
    i=Inp32(rVIC0INTENABLE);
    i|=0x0000001;
    Outp32(rVIC0INTENABLE,i);
    
    EINT0DisMask(0);
    EINT0DisMask(1);
    EINT0DisMask(2);
    EINT0DisMask(3);
}
#endif
```

# Timer

## s3c6410定时器概述
The S3C6410X RISC microprocessor comprises of five 32-bit timers. These timers are used to generate internal interrupts to the ARM subsystem. In addition, Timers  0 and 1 include a PWM function (Pulse Width Modulation), which can drive an external I/O signal. The PWM for timer 0 and 1 have an optional dead-zone generator capability, which can be utilized to support a large current device. Timer 2, 3 and 4 are internal timers with no output pins. 
![Timer](http://www.jeffxue.cn/img/004.png)
  
一般的配置流程如下：
- 程序入口需要Enable VIC、Enable IRQ、Disable All INT（可查看Reference里面的main.c）
- 停止所有的定时器（TCON）
- 配置定时器：获取g_PCLK，设置Prescaler（TCFG0），设置MUX（TCFG1），设置TCNTBn。（主要配置了定时器产生中断间隔，如果需要输出PWM，需要配置TCMPBn，同时使能PWM输出）
- 清除中断悬起位（TINT_CSTAT）
- 配置中断服务程序地址（VIC0VECTADDR+NUM_TIMERn*4）
- 使能对应中断源（VIC0INTENABLE）
- 清除中断屏蔽位（TINT_CSTAT）
- 启动定时器（TCON）

## timer.h
```c
#ifndef __KEY_IO__
#define __KEY_IO__
#include "module_cfg.h"
#ifdef TIMER
#include "sfr6410.h"

/**************Macro Definition**********/
#define LED1_ON   ~(1<<4)
#define LED2_ON   ~(1<<5)
#define LED3_ON   ~(1<<6)
#define LED4_ON   ~(1<<7)
#define LED1_OFF   (1<<4)
#define LED2_OFF   (1<<5)
#define LED3_OFF   (1<<6)
#define LED4_OFF   (1<<7)
#define LEDALL_OFF (0xf<<4)

/**************Declare Function**********/
void __irq Timer_Eint(void);
void TimerStart(u32 uTimer_No);
void TimerClkInit(u32 uTimer_No,u32 ms);
void TimerInit(void);
void TimerClrPend(u32 uTimer_No);
void TimerDisMask(u32 uTimer_No);


/**************Enum TIMER ADDER**********/

#define     rTCFG0      (PWMTIMER_BASE+0x00)
#define     rTCFG1      (PWMTIMER_BASE+0x04)
#define     rTCON       (PWMTIMER_BASE+0x08)
#define     rTCNTB0     (PWMTIMER_BASE+0x0C)
#define     rTCMPB0     (PWMTIMER_BASE+0x10)
#define     rTCNTO0     (PWMTIMER_BASE+0x14)
#define     rTCNTB1     (PWMTIMER_BASE+0x18)
#define     rTCMPB1     (PWMTIMER_BASE+0x1C)
#define     rTCNTO1     (PWMTIMER_BASE+0x20)
#define     rTCNTB2     (PWMTIMER_BASE+0x24)
#define     rTCMPB2     (PWMTIMER_BASE+0x28)
#define     rTCNTO2     (PWMTIMER_BASE+0x2C)
#define     rTCNTB3     (PWMTIMER_BASE+0x30)
#define     rTCMPB3     (PWMTIMER_BASE+0x34)
#define     rTCNTO3     (PWMTIMER_BASE+0x38)
#define     rTCNTB4     (PWMTIMER_BASE+0x3C)
#define     rTCNTO4     (PWMTIMER_BASE+0x40)
#define     rTINT_CSTAT (PWMTIMER_BASE+0x44)    


#endif

#endif
```

## timer.c
```c
#include "module_cfg.h"
#ifdef TIMER
#include "def.h"
#include "timer.h"
#include "gpio.h"
#include "library.h"
#include "sysc.h"

/*************************************************************************
 **************************TIMER中断处理函数******************************
 *************************************************************************/
static u32 Timer0Counter=1;
static u32 Timer1Counter=1;
void __irq Timer_Eint(void)
{
    u32 i;
    i = Inp32(rTINT_CSTAT);  
    if (i&(1<<5))           //Timer0中断
    {
        TimerClrPend(0);
        if(Timer0Counter==1){GPIO->rGPIOKDAT&=LED1_ON;Timer0Counter=2;}
            else if(Timer0Counter==2){GPIO->rGPIOKDAT|=LED1_OFF;Timer0Counter=1;}
    }
    else if (i&(1<<6))      //Timer1中断
    {
        TimerClrPend(1);
        if(Timer1Counter==1){GPIO->rGPIOKDAT&=LED2_ON;Timer1Counter=2;}
            else if(Timer1Counter==2){GPIO->rGPIOKDAT|=LED2_OFF;Timer1Counter=1;}
    }
    
    //清除rVIC0ADDR，该寄存器按位记录哪个VIC0中断源曾发生了中断
    Outp32(rVIC0ADDR, 0);   
}
/*************************************************************************
 ***************************清除中断悬起位********************************
 *************************************************************************/
void TimerClrPend(u32 uTimer_No)
{
    u32 i;
    i = Inp32(rTINT_CSTAT);
    i |= (0x1<<(5+uTimer_No));
    Outp32(rTINT_CSTAT,i);              
}
/*************************************************************************
 ***************************清除中断屏蔽位********************************
 *************************************************************************/
void TimerDisMask(u32 uTimer_No)
{
    u32 i;
    i = Inp32(rTINT_CSTAT);
    i |= (0x1<<uTimer_No);      //write 1 to enable interrupt
    Outp32(rTINT_CSTAT,i);              
}
/*************************************************************************
 ******************************TIMER启动********************************
 *************************************************************************/
void TimerStart(u32 uTimer_No)
{
    u32 i;
    //设置Timer控制寄存器为 自动装载、手动更新(第一次装载时需要)
    //然后开启定时器(同时清手动更新位)
    i = Inp32(rTCON);   
    if (uTimer_No==0)
    {
        i = (i & ~0x1f) | 0xa;  //0b01010
        Outp32(rTCON,i);        
        
        i = (i & ~0x1f) | 0x9;  //ob01001   
        Outp32(rTCON,i); 
    }
    else if(uTimer_No!=4)
        {
            uTimer_No++;
            i = (i & ~(0xf<<(uTimer_No*4))) | (0xa<<(uTimer_No*4));             
            Outp32(rTCON,i); 

            i = (i & ~(0xf<<(uTimer_No*4))) | (0x9<<(uTimer_No*4));             
            Outp32(rTCON,i);
        }
        else if(uTimer_No==4)
            {
                uTimer_No++;
                i = (i & ~(0xf<<(uTimer_No*4))) | (0x6<<(uTimer_No*4));             
                Outp32(rTCON,i); 

                i = (i & ~(0xf<<(uTimer_No*4))) | (0x5<<(uTimer_No*4));             
                Outp32(rTCON,i);
            }   
}

/*************************************************************************
 ****************************配置TIMER时钟********************************
 *************************************************************************/
 void TimerClkInit(u32 uTimer_No,u32 ms)
 {
    u32 i;
    
    //用这个函数主要是获得g_PCLK的值
    SYSC_GetClkInform();
    
    //设置Prescaler为128
    i = Inp32(rTCFG0);
    if (uTimer_No<2)
        i = (i & 0xffffff00 )| 0x0000007f;
    else
        i = (i & 0xffff00ff )| 0x00007f00;
    Outp32(rTCFG0,i);
        
    //设置MUX为16，总共2048分频
    i = Inp32(rTCFG1);
    i = (i & ~(0xf<<(uTimer_No*4))) | (0x4<<(uTimer_No*4));
    Outp32(rTCFG1,i); 
    
    //设置rTCNTBn，(g_PCLK>>11)/1000 算得的值是2048分频时1ms的计数值
    Outp32(rTCNTB0+0xc*uTimer_No, ((g_PCLK>>11)/1000)*ms);  
 }

/*************************************************************************
 ******************************TIMER初始化********************************
 *************************************************************************/
 void TimerInit(void)
 {
    u32 i;
    
    //停止所有Timer
    Outp32(rTCON, 0);
    
    //配置定时器时钟
    TimerClkInit(0, 500);
    TimerClkInit(1, 1000);
        
    //清除中断悬起位
    TimerClrPend(0);
    TimerClrPend(1);
            
    //向rVIC0VECTADDR中写入对应中断服务程序的地址
    Outp32(rVIC0VECTADDR+NUM_TIMER0*4, (unsigned)Timer_Eint);
    Outp32(rVIC0VECTADDR+NUM_TIMER1*4, (unsigned)Timer_Eint);
    
    //使能对应中断源:
    i = Inp32(rVIC0INTENABLE);
    i |= (1<<NUM_TIMER0)|(1<<NUM_TIMER1);
    Outp32(rVIC0INTENABLE, i);
    
    //接触屏蔽
    TimerDisMask(0);        
    TimerDisMask(1);
    
    //开启定时器
    TimerStart(0);
    TimerStart(1);
 }
 
 
#endif
```

# Reference

该章节包含如下文件（描述可能比较模糊，大部分在s3c6410官方裸机测试代码里均可找到）：
main.c -- 程序入口
inc.h -- 包含的头文件
module_cfg.h -- 模块配置
def.h  -- 类型定义
gpio.h -- gpio地址
library.h -- 地址操作宏定义
intc.h -- 中断寄存器地址 
intc.c -- 屏蔽所有中断操作函数
sfr6410.h -- SFR地址
sysc.h -- 系统控制函数头文件
sysc.c -- 系统控制函数
system.h
option.h
 
## main.c
```c
#include "inc.h"
int main(void)
{   
    SYSTEM_EnableVIC();
    SYSTEM_EnableIRQ();
    INTC_Init();
    
    LedPortInit();
#if 0
    LedRun();
#endif
    
#if 0
    KeyIoPortInit();
    KeyIoTest();
#endif
    
#if 0
    KeyIntPortInit();
    KeyEintInit();
    while(1);
#endif

#if 1
    TimerInit();
    while(1);
#endif
    
}
```

## inc.h
```c
#ifndef __INC__
#define __INC__
/****************Including File*****************/
#include "module_cfg.h"
#include "system.h"

#ifdef LED
#include "led.h"
#endif

#ifdef KEY_IO
#include "key_io.h"
#endif

#ifdef KEY_INT
#include "key_int.h"
#endif

#ifdef TIMER
#include "timer.h"
#endif

#endif
```

## module_cfg.h
```c
#ifndef __MODULE_CFG__
#define __MOUDLE_CFG__
/****************Module Config*******************
if you open the define then the module is useful 
and including .h file 
*************************************************/
#define LED
#define KEY_IO
#define KEY_INT
#define TIMER


#endif
```

## def.h
```c
/**************************************************************************************
*   File Description : This file defines some types used commonly. 
**************************************************************************************/

#ifndef __DEF_H__
#define __DEF_H__


// Type defines 
typedef unsigned long           u32;
typedef unsigned short          u16;
typedef unsigned char           u8;

typedef signed long         s32;
typedef signed short            s16;
typedef signed char         s8;

#define FALSE               (0)
#define TRUE                (1)
#define false               (0)
#define true                (1)

#endif
```

## gpio.h
```c
/**************************************************************************************
*   File Description : This file declares prototypes of GPIO API funcions.
**************************************************************************************/

#ifndef __GPIO_H__
#define __GPIO_H__

#include "def.h"

typedef struct tag_GPIO_REGS
{
    u32 rGPIOACON;          //0x7F008000
    u32 rGPIOADAT;
    u32 rGPIOAPUD;
    u32 rGPIOACONSLP;
    u32 rGPIOAPUDSLP;
    u32 reserved1[3];
    
    u32 rGPIOBCON;          //0x7F008020
    u32 rGPIOBDAT;
    u32 rGPIOBPUD;
    u32 rGPIOBCONSLP;
    u32 rGPIOBPUDSLP;   
    u32 reserved2[3];
        
    u32 rGPIOCCON;          //0x7F008040
    u32 rGPIOCDAT;
    u32 rGPIOCPUD;
    u32 rGPIOCCONSLP;
    u32 rGPIOCPUDSLP;   
    u32 reserved3[3];
        
    u32 rGPIODCON;          //0x7F008060
    u32 rGPIODDAT;
    u32 rGPIODPUD;
    u32 rGPIODCONSLP;
    u32 rGPIODPUDSLP;   
    u32 reserved4[3];
        
    u32 rGPIOECON;          //0x7F008080
    u32 rGPIOEDAT;
    u32 rGPIOEPUD;
    u32 rGPIOECONSLP;
    u32 rGPIOEPUDSLP;   
    u32 reserved5[3];
        
    u32 rGPIOFCON;          //0x7F0080A0
    u32 rGPIOFDAT;
    u32 rGPIOFPUD;
    u32 rGPIOFCONSLP;
    u32 rGPIOFPUDSLP;   
    u32 reserved6[3];
        
    u32 rGPIOGCON;          //0x7F0080C0
    u32 rGPIOGDAT;
    u32 rGPIOGPUD;
    u32 rGPIOGCONSLP;
    u32 rGPIOGPUDSLP;   
    u32 reserved7[3];
    
    u32 rGPIOHCON0;         //0x7F0080E0
    u32 rGPIOHCON1;
    u32 rGPIOHDAT;
    u32 rGPIOHPUD;
    u32 rGPIOHCONSLP;
    u32 rGPIOHPUDSLP;   
    u32 reserved8[2];

    u32 rGPIOICON;          //0x7F008100
    u32 rGPIOIDAT;
    u32 rGPIOIPUD;
    u32 rGPIOICONSLP;
    u32 rGPIOIPUDSLP;   
    u32 reserved9[3];

    u32 rGPIOJCON;          //0x7F008120
    u32 rGPIOJDAT;
    u32 rGPIOJPUD;
    u32 rGPIOJCONSLP;
    u32 rGPIOJPUDSLP;   
    u32 reserved10[3];
    
    u32 rGPIOOCON;          //0x7F008140
    u32 rGPIOODAT;
    u32 rGPIOOPUD;
    u32 rGPIOOCONSLP;
    u32 rGPIOOPUDSLP;   
    u32 reserved11[3];  

    u32 rGPIOPCON;          //0x7F008160
    u32 rGPIOPDAT;
    u32 rGPIOPPUD;
    u32 rGPIOPCONSLP;
    u32 rGPIOPPUDSLP;   
    u32 reserved12[3];

    u32 rGPIOQCON;          //0x7F008180
    u32 rGPIOQDAT;
    u32 rGPIOQPUD;
    u32 rGPIOQCONSLP;
    u32 rGPIOQPUDSLP;   
    u32 reserved13[3];  

    u32 rSPCON;         //0x7F0081A0
    u32 reserved14[3];
    u32 rMEM0CONSTOP;       //0x7F0081B0
    u32 rMEM1CONSTOP;       //0x7F0081B4
    u32 reserved15[2];
    u32 rMEM0CONSLP0;       //0x7F0081C0
    u32 rMEM0CONSLP1;       //0x7F0081C4
    u32 rMEM1CONSLP;        //0x7F0081C8
    u32 reserved;
    u32 rMEM0DRVCON;        //0x7F0081D0
    u32 rMEM1DRVCON;        //0x7F0081D4
    u32 reserved16[10];

    u32 rEINT12CON;         //0x7f008200
    u32 rEINT34CON;         //0x7f008204
    u32 rEINT56CON;         //0x7f008208
    u32 rEINT78CON;         //0x7f00820C
    u32 rEINT9CON;          //0x7f008210
    u32 reserved17[3];

    u32 rEINT12FLTCON;      //0x7f008220
    u32 rEINT34FLTCON;      //0x7f008224
    u32 rEINT56FLTCON;      //0x7f008228
    u32 rEINT78FLTCON;      //0x7f00822C
    u32 rEINT9FLTCON;       //0x7f008230
    u32 reserved18[3];

    u32 rEINT12MASK;        //0x7f008240
    u32 rEINT34MASK;        //0x7f008244
    u32 rEINT56MASK;        //0x7f008248
    u32 rEINT78MASK;        //0x7f00824C
    u32 rEINT9MASK;         //0x7f008250
    u32 reserved19[3];  

    u32 rEINT12PEND;        //0x7f008260
    u32 rEINT34PEND;        //0x7f008264
    u32 rEINT56PEND;        //0x7f008268
    u32 rEINT78PEND;        //0x7f00826C
    u32 rEINT9PEND;         //0x7f008270
    u32 reserved20[3];          

    u32 rPRIORITY;          //0x7f008280
    u32 rSERVICE;           //0x7f008284
    u32 rSERVICEPEND;       //0x7f008288
    u32 reserved21;

    u32 reserved22[348];
    
    u32 rGPIOKCON0;         //0x7f008800
    u32 rGPIOKCON1;         //0x7f008804
    u32 rGPIOKDAT;          //0x7f008808
    u32 rGPIOKPUD;          //0x7f00880c

    u32 rGPIOLCON0;         //0x7f008810
    u32 rGPIOLCON1;         //0x7f008814
    u32 rGPIOLDAT;          //0x7f008818
    u32 rGPIOLPUD;          //0x7f00881c

    u32 rGPIOMCON;          //0x7f008820
    u32 rGPIOMDAT;          //0x7f008824
    u32 rGPIOMPUD;          //0x7f008828    
    u32 reserved23;

    u32 rGPIONCON;          //0x7f008830
    u32 rGPIONDAT;          //0x7f008834
    u32 rGPIONPUD;          //0x7f008838    
    u32 reserved24;

    u32 reserved25[16];

    u32 rSPCONSLP;          //0x7f008880

    u32 reserved26[31];     

    u32 rEINT0CON0;         //0x7f008900
    u32 rEINT0CON1;         //0x7f008904
    u32 reserved27[2];

    u32 rEINT0FLTCON0;      //0x7f008910
    u32 rEINT0FLTCON1;      //0x7f008914
    u32 rEINT0FLTCON2;      //0x7f008918
    u32 rEINT0FLTCON3;      //0x7f00891c
    u32 rEINT0MASK;         //0x7f008920
    u32 rEINT0PEND;         //0x7f008924
    u32 reserved28[2];
    u32 rSLPEN;         //0x7f008930

} 
oGPIO_REGS;

#ifndef GPIO_BASE
#define GPIO_BASE           (0x7F008000)
#endif

#ifndef GPIO
#define GPIO                (( volatile oGPIO_REGS *)GPIO_BASE)
#endif

#endif 
```

## library.h
```c
/**************************************************************************************  
*   File Description : This file defines the register access function
*                       and declares prototypes of library funcions  
**************************************************************************************/
#ifndef __LIBRARY_H__
#define __LIBRARY_H__

#include "def.h"

#define Outp32(addr, data)  (*(volatile u32 *)(addr) = (data))
#define Outp16(addr, data)  (*(volatile u16 *)(addr) = (data))
#define Outp8(addr, data)   (*(volatile u8 *)(addr) = (data))
#define Inp32(addr)         (*(volatile u32 *)(addr))
#define Inp16(addr)         (*(volatile u16 *)(addr))
#define Inp8(addr)          (*(volatile u8 *)(addr))



#endif /*__LIBRARY_H__*/
```

## intc.h
```c
/************************************************************************************** 
*   File Description : This file declares prototypes of interrupt controller API funcions.
**************************************************************************************/

#ifndef __INTC_H__
#define __INTC_H__

#include "def.h"
#include "sfr6410.h"

void INTC_Init(void);
void INTC_ClearVectAddr(void);

#define INT_LIMIT               (64)

//INT NUM - VIC0
#define NUM_EINT0               (0)
#define NUM_EINT1               (1)
#define NUM_RTC_TIC             (2)
#define NUM_CAMIF_C             (3)
#define NUM_CAMIF_P             (4)
#define NUM_I2C1                (5)
#define NUM_I2S                 (6)

#define NUM_3D                  (8)
#define NUM_POST0               (9)
#define NUM_ROTATOR             (10)
#define NUM_2D                  (11)
#define NUM_TVENC               (12)
#define NUM_SCALER              (13)
#define NUM_BATF                (14)
#define NUM_JPEG                (15)
#define NUM_MFC                 (16)
#define NUM_SDMA0               (17)
#define NUM_SDMA1               (18)
#define NUM_ARM_DMAERR              (19)
#define NUM_ARM_DMA             (20)
#define NUM_ARM_DMAS                (21)
#define NUM_KEYPAD              (22)
#define NUM_TIMER0              (23)
#define NUM_TIMER1              (24)
#define NUM_TIMER2              (25)
#define NUM_WDT                 (26)
#define NUM_TIMER3              (27)
#define NUM_TIMER4              (28)
#define NUM_LCD0                (29)
#define NUM_LCD1                (30)
#define NUM_LCD2                (31)

//INT NUM - VIC1
#define NUM_EINT2               (32+0)
#define NUM_EINT3               (32+1)
#define NUM_PCM0                (32+2)
#define NUM_PCM1                (32+3)
#define NUM_AC97                (32+4)
#define NUM_UART0               (32+5)
#define NUM_UART1               (32+6)
#define NUM_UART2               (32+7)
#define NUM_UART3               (32+8)
#define NUM_DMA0                (32+9)
#define NUM_DMA1                (32+10)
#define NUM_ONENAND0                (32+11)
#define NUM_ONENAND1                (32+12)
#define NUM_NFC                 (32+13)
#define NUM_CFC                 (32+14)
#define NUM_UHOST               (32+15)
#define NUM_SPI0                (32+16)
#define NUM_SPI1                (32+17)
#define NUM_IIC                 (32+18)
#define NUM_HSItx               (32+19)
#define NUM_HSIrx               (32+20)
#define NUM_EINTGroup               (32+21)
#define NUM_MSM                 (32+22)
#define NUM_HOSTIF              (32+23)
#define NUM_HSMMC0              (32+24)
#define NUM_HSMMC1              (32+25)
#define NUM_OTG                 (32+26)
#define NUM_IRDA                (32+27)
#define NUM_RTC_ALARM               (32+28)
#define NUM_SEC                 (32+29)
#define NUM_PENDNUP             (32+30)
#define NUM_ADC                 (32+31)
#define NUM_PMU                 (32+32)

// VIC0
#define rVIC0IRQSTATUS          (VIC0_BASE + 0x00)
#define rVIC0FIQSTATUS          (VIC0_BASE + 0x04)
#define rVIC0RAWINTR            (VIC0_BASE + 0x08)
#define rVIC0INTSELECT          (VIC0_BASE + 0x0c)
#define rVIC0INTENABLE          (VIC0_BASE + 0x10)
#define rVIC0INTENCLEAR         (VIC0_BASE + 0x14)
#define rVIC0SOFTINT            (VIC0_BASE + 0x18)
#define rVIC0SOFTINTCLEAR       (VIC0_BASE + 0x1c)
#define rVIC0PROTECTION         (VIC0_BASE + 0x20)
#define rVIC0SWPRIORITYMASK     (VIC0_BASE + 0x24)
#define rVIC0PRIORITYDAISY      (VIC0_BASE + 0x28)

#define rVIC0VECTADDR           (VIC0_BASE + 0x100)

#define rVIC0VECPRIORITY        (VIC0_BASE + 0x200)

#define rVIC0ADDR           (VIC0_BASE + 0xf00)
#define rVIC0PERID0         (VIC0_BASE + 0xfe0)
#define rVIC0PERID1         (VIC0_BASE + 0xfe4)
#define rVIC0PERID2         (VIC0_BASE + 0xfe8)
#define rVIC0PERID3         (VIC0_BASE + 0xfec)
#define rVIC0PCELLID0           (VIC0_BASE + 0xff0)
#define rVIC0PCELLID1           (VIC0_BASE + 0xff4)
#define rVIC0PCELLID2           (VIC0_BASE + 0xff8)
#define rVIC0PCELLID3           (VIC0_BASE + 0xffc)

// VIC1
#define rVIC1IRQSTATUS          (VIC1_BASE + 0x00)
#define rVIC1FIQSTATUS          (VIC1_BASE + 0x04)
#define rVIC1RAWINTR            (VIC1_BASE + 0x08)
#define rVIC1INTSELECT          (VIC1_BASE + 0x0c)
#define rVIC1INTENABLE          (VIC1_BASE + 0x10)
#define rVIC1INTENCLEAR         (VIC1_BASE + 0x14)
#define rVIC1SOFTINT            (VIC1_BASE + 0x18)
#define rVIC1SOFTINTCLEAR       (VIC1_BASE + 0x1c)
#define rVIC1PROTECTION         (VIC1_BASE + 0x20)
#define rVIC1SWPRIORITYMASK     (VIC1_BASE + 0x24)
#define rVIC1PRIORITYDAISY      (VIC1_BASE + 0x28)

#define rVIC1VECTADDR           (VIC1_BASE + 0x100)

#define rVIC1VECPRIORITY        (VIC1_BASE + 0x200)

#define rVIC1ADDR           (VIC1_BASE + 0xf00)
#define rVIC1PERID0         (VIC1_BASE + 0xfe0)
#define rVIC1PERID1         (VIC1_BASE + 0xfe4)
#define rVIC1PERID2         (VIC1_BASE + 0xfe8)
#define rVIC1PERID3         (VIC1_BASE + 0xfec)
#define rVIC1PCELLID0           (VIC1_BASE + 0xff0)
#define rVIC1PCELLID1           (VIC1_BASE + 0xff4)
#define rVIC1PCELLID2           (VIC1_BASE + 0xff8)
#define rVIC1PCELLID3           (VIC1_BASE + 0xffc)



#endif 
```

## intc.c
```c
/**************************************************************************************
*   File Description : This file implements the API functons for interrupt controller.
**************************************************************************************/

#include "library.h"
#include "intc.h"

// Function Description : This function initializes interrupt controller 
void INTC_Init(void)
{
#if (VIC_MODE==0)   
    u32 i;
    
    for(i=0;i<32;i++)
        Outp32(rVIC0VECTADDR+4*i, i);
    
    for(i=0;i<32;i++)
        Outp32(rVIC1VECTADDR+4*i, i+32);
#endif
    Outp32(rVIC0INTENCLEAR, 0xffffffff);
    Outp32(rVIC1INTENCLEAR, 0xffffffff);

    Outp32(rVIC0INTSELECT, 0x0);
    Outp32(rVIC1INTSELECT, 0x0);

    INTC_ClearVectAddr();

    return;
}


// Function Description : This function clears the vector address register
void INTC_ClearVectAddr(void)
{
    Outp32(rVIC0ADDR, 0);
    Outp32(rVIC1ADDR, 0);
    
    return;
}
```


## sfr6410.h
```c
/**************************************************************************************
*   File Description : This file defines SFR base addresses.
**************************************************************************************/


#ifndef __sfr6410_H__
#define __sfr6410_H__

#include "def.h"

////
//AHB_SMC
//
//SMC
#define SROM_BASE               (0x70000000)    //SROM
#define ONENAND0_BASE               (0x70100000)    //OneNAND
#define ONENAND1_BASE               (0x70180000)    //OneNAND
#define NFCON_BASE              (0x70200000)    //Nand Flash
#define CFCON_BASE              (0x70300000)    //CF


////
//TZIC
//
//TZIC
#define TZIC0_BASE              (0x71000000)
#define TZIC1_BASE              (0x71100000)


////
//VIC
//
//VIC
#define VIC0_BASE               (0x71200000)
#define VIC1_BASE               (0x71300000)


////
//3D
//
//3D
#define FIMG_BASE                   (0x72000000)




////
//AHB_ETB
//
//ETB
#define ETBMEM_BASE             (0x73000000)
#define ETBSFR_BASE             (0x73100000)


////
//AHB_T
//
//HOST i/f
#define HOSTIF_SFR_BASE             (0x74000000)
#define DPSRAM_BASE             (0x74100000)
#define MODEMIF_BASE                (0x74108000)
//USB HOST
#define USBHOST_BASE                (0x74300000)
#define MDPIF_BASE              (0x74400000)


////
//AHB_M
//
//DMA
#define DMA0_BASE               (0x75000000)
#define DMA1_BASE               (0x75100000)


////
//AHB_P
//
// 2D
#define G2D_BASE                (0x76100000)
//TV
#define TVENC_BASE              (0x76200000)
#define TVSCALER_BASE               (0X76300000)


////
//AHB_F
//
//POST
#define POST0_BASE              (0x77000000)
//LCD
#define LCD_BASE                (0x77100000)
//ROTATOR
#define ROTATOR_BASE                (0x77200000)


////
//AHB_I
//
//CAMERA I/F
#define CAMERA_BASE             (0x78000000)
//JPEG
#define JPEG_BASE               (0x78800000)


////
//AHB_X
//
//USB OTG
#define USBOTG_LINK_BASE            (0x7C000000)
#define USBOTG_PHY_BASE             (0x7C100000)
//HS MMC
#define HSMMC0_BASE             (0x7C200000)
#define HSMMC1_BASE             (0x7C300000)
#define HSMMC2_BASE             (0x7C400000)


////
//AHB_S
//
//D&I Security Sub System Base
#define DnI_BASE                (0x7D000000)
#define AES_RX_BASE             (0x7D100000)
#define DES_RX_BASE             (0x7D200000)
#define HASH_RX_BASE                (0x7D300000)
#define RX_SFR_BASE             (0x7D400000)
#define AES_TX_BASE             (0x7D500000)
#define DES_TX_BASE             (0x7D600000)
#define HASH_TX_BASE                (0x7D700000)
#define TX_SFR_BASE             (0x7D800000)
#define RX_FIFO_BASE                (0x7D900000)
#define TX_FIFO_BASE                (0x7DA00000)
// SDMA Controller
#define SDMA0_BASE              (0x7DB00000)
#define SDMA1_BASE              (0x7DC00000)


////
//APB0
//
//DMC
#define DMC0_BASE               (0x7E000000)
#define DMC1_BASE               (0x7E001000)
//MFC
#define MFC_BASE                (0x7E002000)
//WDT
#define WDT_BASE                (0x7E004000)
//RTC
#define RTC_BASE                (0x7E005000)
//HSI
#define HSITX_BASE              (0x7E006000)
#define HSIRX_BASE              (0x7E007000)
//KEYPAD I/F
#define KEYPADIF_BASE               (0x7E00A000)
//ADC TS
#define ADCTS_BASE              (0x7E00B000)
//ETM
#define ETM_BASE                (0x7E00C000)
//KEY
#define KEY_BASE                (0x7E00D000)
//Chip ID
#define CHIPID_BASE             (0x7E00E000)
//SYSCON
#define SYSCON_BASE             (0x7E00F000)


////
//APB1
//
//TZPC
#define TZPC_BASE               (0x7F000000)
//AC97
#define AC97_BASE               (0x7F001000)
//I2S
#define I2S0_BASE               (0x7F002000)
#define I2S1_BASE               (0x7F003000)
//I2C (Channel0, 1 Added by SOP on 2008.03.01)
#define I2C0_BASE               (0x7F004000)
#define I2C1_BASE               (0x7F00F000)
//UART
#define UART_BASE               (0x7F005000)
//PWM TIMER
#define PWMTIMER_BASE               (0x7F006000)
//IRDA
#define IRDA_BASE               (0x7F007000)
//GPIO
#define GPIO_BASE               (0x7F008000)
//PCM
#define PCM0_BASE               (0x7F009000)
#define PCM1_BASE               (0x7F00A000)
//SPI
#define SPI0_BASE               (0x7F00B000)
#define SPI1_BASE               (0x7F00C000)
//I2S MULTI
#define I2SMULTI_BASE               (0X7F00D00)

//GIB
#define GIB_BASE                (0x7F00E000)



#endif 
```

## sysc.h
```c
/**************************************************************************************
*   File Description : This file declares prototypes of system funcions. 
**************************************************************************************/

#ifndef __SYSTEM_H__
#define __SYSTEM_H__

#include "def.h"

extern u8   g_System_Revision, g_System_Pass;
extern u32  g_APLL, g_MPLL, g_ARMCLK, g_HCLKx2, g_HCLK, g_PCLK;

// Camera module define by jungil 01.31
#define CAM_OV7620          1
#define CAM_S5X433          2
#define CAM_AU70H           3
#define CAM_S5X3A1          4
#define CAM_S5K3AA          5
#define CAM_S5K3BA          6
#define CAM_S5K4AAF         7
#define CAM_LCD_INTERLACE   8
#define CAM_LCD_PROGRESSIVE 9
#define CAM_A3AFX_VGA       10

#define CAM_MODEL           CAM_S5K3BA
//----------------------------------------

void SYSTEM_EnableVIC(void);
void SYSTEM_DisableVIC(void);
void SYSTEM_EnableIRQ(void);
void SYSTEM_DisableIRQ(void);
void SYSTEM_EnableFIQ(void);
void SYSTEM_DisableFIQ(void);

void SYSTEM_InitException( void);
void MMU_WaitForInterrupt(void);
void Stop_WFI_Test(void);
void Stop_WFI_Test1(void);

void SYSTEM_EnableBP(void);
void SYSTEM_EnableICache(void);
void SYSTEM_DisableICache(void);
void SYSTEM_EnableDCache(void);
void SYSTEM_DisableDCache(void);
void SYSTEM_InvalidateEntireICache(void);
void SYSTEM_InvalidateEntireDCache(void);
void SYSTEM_InvalidateBothCache(void);
void SYSTEM_CleanEntireDCache(void);
void SYSTEM_CleanInvalidateEntireDCache(void);
void SYSTEM_EnableMMU(void);
void SYSTEM_DisableMMU(void);
void SYSTEM_InvalidateTLB(void);
void SYSTEM_SetTTBase(u32);
void SYSTEM_SetDomain(u32);
void SYSTEM_SetFCSEPID(u32);
void SYSTEM_EnableAlignFault(void);
void SYSTEM_DisableAlignFault(void);
u32 SYSTEM_ReadDFSR(void);
u32 SYSTEM_ReadIFSR(void);
u32 SYSTEM_ReadFAR(void);
void SYSTEM_InitMmu(void);

void MEMCOPY_TEST(void);
void MEMCOPY_TEST0(void);
void MEMCOPY8 (u32,u32, u32 );
void MEMWRITE4 (u32, u32, u32 , u32); // addr, size, data1, data2


#endif 
```


## sysc.c
```c
/**************************************************************************************
* 
*   Project Name : S3C6410 Validation
*
*   Copyright 2006 by Samsung Electronics, Inc.
*   All rights reserved.
*
*   Project Description :
*       This software is only for validating functions of the S3C6410.
*       Anybody can use this software without our permission.
*  
*--------------------------------------------------------------------------------------
* 
*   File Name : sysc.c
*  
*   File Description : This file implements the API functons for system controller.
*
*   Author : Haksoo,Kim
*   Dept. : AP Development Team
*   Created Date : 2006/11/08
*   Version : 0.1 
* 
*   History
*   - Created(Haksoo,Kim 2006/11/08)
*   - Added sfr (Wonjoon.Jang 2007/01/08)
*  
**************************************************************************************/

#include "library.h"
#include "sfr6410.h"
#include "system.h"
#include "option.h"

#include "gpio.h"
#include "sysc.h"
#include "intc.h"

#define dprintf UART_Printf
//#define dprintf


//
#define rAPLL_LOCK          (SYSCON_BASE+0x000)
#define rMPLL_LOCK          (SYSCON_BASE+0x004)
#define rEPLL_LOCK          (SYSCON_BASE+0x008)
#define rAPLL_CON           (SYSCON_BASE+0x00c)
#define rMPLL_CON           (SYSCON_BASE+0x010)
#define rEPLL_CON0          (SYSCON_BASE+0x014)
#define rEPLL_CON1          (SYSCON_BASE+0x018)
#define rCLK_SRC            (SYSCON_BASE+0x01c)
#define rCLK_SRC2           (SYSCON_BASE+0x10c)
#define rCLK_DIV0           (SYSCON_BASE+0x020)
#define rCLK_DIV1           (SYSCON_BASE+0x024)
#define rCLK_DIV2           (SYSCON_BASE+0x028)
#define rCLK_OUT            (SYSCON_BASE+0x02c)
#define rHCLK_GATE          (SYSCON_BASE+0x030)
#define rPCLK_GATE          (SYSCON_BASE+0x034)
#define rSCLK_GATE          (SYSCON_BASE+0x038)
#define rMEM0_CLK_GATE          (SYSCON_BASE+0x03c)

//
#define rAHB_CON0           (SYSCON_BASE+0x100)
#define rAHB_CON1           (SYSCON_BASE+0x104)
#define rAHB_CON2           (SYSCON_BASE+0x108)
#define rSDMA_SEL           (SYSCON_BASE+0x110)
#define rSW_RST             (SYSCON_BASE+0x114)
#define rSYS_ID             (SYSCON_BASE+0x118)
#define rMEM_SYS_CFG            (SYSCON_BASE+0x120)
#define rQOS_OVERRIDE0          (SYSCON_BASE+0x124)
#define rQOS_OVERRIDE1          (SYSCON_BASE+0x128)
#define rMEM_CFG_STAT           (SYSCON_BASE+0x12c)
//
#define rPWR_CFG            (SYSCON_BASE+0x804)
#define rEINT_MASK          (SYSCON_BASE+0x808)
#define rNORMAL_CFG         (SYSCON_BASE+0x810)
#define rSTOP_CFG           (SYSCON_BASE+0x814)
#define rSLEEP_CFG          (SYSCON_BASE+0x818)
#define rSTOP_MEM_CFG           (SYSCON_BASE+0x81C)
#define rOSC_FREQ           (SYSCON_BASE+0x820)
#define rOSC_STABLE         (SYSCON_BASE+0x824)
#define rPWR_STABLE         (SYSCON_BASE+0x828)
#define rFPC_STABLE         (SYSCON_BASE+0x82c)
#define rMTC_STABLE         (SYSCON_BASE+0x830)
#define rBUS_CACHEABLE_CON      (SYSCON_BASE+0x838)

// 
#define rOTHERS             (SYSCON_BASE+0x900)
#define rRST_STAT           (SYSCON_BASE+0x904)
#define rWAKEUP_STAT            (SYSCON_BASE+0x908)
#define rBLK_PWR_STAT           (SYSCON_BASE+0x90c)
#define rINFORM0            (SYSCON_BASE+0xA00)
#define rINFORM1            (SYSCON_BASE+0xA04)
#define rINFORM2            (SYSCON_BASE+0xA08)
#define rINFORM3            (SYSCON_BASE+0xA0c)
#define rINFORM4            (SYSCON_BASE+0xA10)
#define rINFORM5            (SYSCON_BASE+0xA14)
#define rINFORM6            (SYSCON_BASE+0xA18)
#define rINFORM7            (SYSCON_BASE+0xA1c)


u8  g_System_Revision, g_System_Pass, g_SYNCACK;
u32 g_APLL, g_MPLL, g_ARMCLK, g_HCLKx2, g_HCLK, g_PCLK;

//////////
// Function Name : SYSC_GetClkInform
// Function Description : This function gets common clock information
// Input : NONE 
// Output : NONE
// Version : 
void SYSC_GetClkInform( void)
{
    u8 muxApll, muxMpll, muxSync;
    u8 divApll, divHclkx2, divHclk, divPclk;
    u16 pllM, pllP, pllS;
    u32 temp;
    
    ////
    // clock division ratio 
    temp = Inp32(rCLK_DIV0);
    divApll = temp & 0xf;
    divHclkx2 = (temp>>9) & 0x7;
    divHclk = (temp>>8) & 0x1;
    divPclk = (temp>>12) & 0xf;

    ////
    // Operating Mode
    temp = Inp32(rOTHERS);
    temp = (temp>>8)&0xf;
    if(temp)
    {
        g_SYNCACK = 1;
    }
    else
    {
        g_SYNCACK = 0;
    }
    
    ////
    // ARMCLK
    muxApll = Inp32(rCLK_SRC) & 0x1;
    if(muxApll) //FOUT
    {           
        temp = Inp32(rAPLL_CON);
        pllM = (temp>>16)&0x3ff;
        pllP = (temp>>8)&0x3f;
        pllS = (temp&0x7);

        g_APLL = ((FIN>>pllS)/pllP)*pllM;
    }
    else    //FIN
    {
        g_APLL = FIN;
    }
    
    g_ARMCLK = g_APLL/(divApll+1);
    
    ////
    // HCLK
    muxSync = (Inp32(rOTHERS)>>7) & 0x1;
    if(muxSync) //synchronous mode
    {
        g_HCLKx2 = g_APLL/(divHclkx2+1);
        
        temp = Inp32(rMPLL_CON);
        pllM = (temp>>16)&0x3ff;
        pllP = (temp>>8)&0x3f;
        pllS = (temp&0x7);

        g_MPLL = ((FIN>>pllS)/pllP)*pllM;
    }
    else
    {
        muxMpll = (Inp32(rCLK_SRC)>>1) & 0x1;
        if(muxMpll) //FOUT
        {                       
            temp = Inp32(rMPLL_CON);
            pllM = (temp>>16)&0x3ff;
            pllP = (temp>>8)&0x3f;
            pllS = (temp&0x7);

            g_MPLL = ((FIN>>pllS)/pllP)*pllM;
        }
        else    //FIN
        {
            g_MPLL = FIN;
        }
        g_HCLKx2 = g_MPLL/(divHclkx2+1);        
    }
    
    g_HCLK = g_HCLKx2/(divHclk+1);
    
    ////
    // PCLK
    g_PCLK = g_HCLKx2/(divPclk+1);

    return;
    
}
```





## system.h
```c
/**************************************************************************************
*   File Description : This file declares prototypes of system funcions. 
**************************************************************************************/

#ifndef __SYSTEM_H__
#define __SYSTEM_H__

#include "def.h"

extern u8   g_System_Revision, g_System_Pass;
extern u32  g_APLL, g_MPLL, g_ARMCLK, g_HCLKx2, g_HCLK, g_PCLK;

// Camera module define by jungil 01.31
#define CAM_OV7620          1
#define CAM_S5X433          2
#define CAM_AU70H           3
#define CAM_S5X3A1          4
#define CAM_S5K3AA          5
#define CAM_S5K3BA          6
#define CAM_S5K4AAF         7
#define CAM_LCD_INTERLACE       8
#define CAM_LCD_PROGRESSIVE     9
#define CAM_A3AFX_VGA           10

#define CAM_MODEL           CAM_S5K3BA
//----------------------------------------

void SYSTEM_EnableVIC(void);
void SYSTEM_DisableVIC(void);
void SYSTEM_EnableIRQ(void);
void SYSTEM_DisableIRQ(void);
void SYSTEM_EnableFIQ(void);
void SYSTEM_DisableFIQ(void);

void SYSTEM_InitException( void);
void MMU_WaitForInterrupt(void);
void Stop_WFI_Test(void);
void Stop_WFI_Test1(void);

void SYSTEM_EnableBP(void);
void SYSTEM_EnableICache(void);
void SYSTEM_DisableICache(void);
void SYSTEM_EnableDCache(void);
void SYSTEM_DisableDCache(void);
void SYSTEM_InvalidateEntireICache(void);
void SYSTEM_InvalidateEntireDCache(void);
void SYSTEM_InvalidateBothCache(void);
void SYSTEM_CleanEntireDCache(void);
void SYSTEM_CleanInvalidateEntireDCache(void);
void SYSTEM_EnableMMU(void);
void SYSTEM_DisableMMU(void);
void SYSTEM_InvalidateTLB(void);
void SYSTEM_SetTTBase(u32);
void SYSTEM_SetDomain(u32);
void SYSTEM_SetFCSEPID(u32);
void SYSTEM_EnableAlignFault(void);
void SYSTEM_DisableAlignFault(void);
u32 SYSTEM_ReadDFSR(void);
u32 SYSTEM_ReadIFSR(void);
u32 SYSTEM_ReadFAR(void);
void SYSTEM_InitMmu(void);

void MEMCOPY_TEST(void);
void MEMCOPY_TEST0(void);
void MEMCOPY8 (u32,u32, u32 );
void MEMWRITE4 (u32, u32, u32 , u32); // addr, size, data1, data2


#endif 
```


## option.h
```c
/**************************************************************************************
* 
*   Project Name : S3C6410 Validation
*
*   Copyright 2006 by Samsung Electronics, Inc.
*   All rights reserved.
*
*   Project Description :
*       This software is only for validating functions of the S3C6410.
*       Anybody can use this software without our permission.
*  
*--------------------------------------------------------------------------------------
* 
*   File Name : option.h
*  
*   File Description : This file defines basic setting and configuration.
*
*   Author : Haksoo,Kim
*   Dept. : AP Development Team
*   Created Date : 2006/11/08
*   Version : 0.1 
* 
*   History
*   - Created(Haksoo,Kim 2006/11/08)
*  
**************************************************************************************/

#ifndef __OPTION_H__
#define __OPTION_H__

#ifdef __cplusplus
extern "C" {
#endif

#include "def.h"

// semi-hosting
#define SEMIHOSTING                 (false)

#define FIN                     12000000

#define DMC0                        (FALSE)
#define DMC1                        (!(DMC0))
#if (DMC0)
#define _DRAM_BaseAddress           0x40000000
#elif (DMC1)
#define _DRAM_BaseAddress           0x50000000
#endif

#define _DRAM0_BaseAddress          0x40000000

#define _SMC_BaseAddress            0x10000000

#define _Exception_Vector           (_DRAM_BaseAddress+0x07ffff00)
#define _MMUTT_BaseAddress          (_DRAM_BaseAddress+0x07ff8000)
#define DefaultDownloadAddress          (_DRAM_BaseAddress+0x00200000)

//rb1004
#define     CODEC_MEM_ST            (_DRAM_BaseAddress+0x01000000)
#define     CODEC_MEM_LMT           (_DRAM_BaseAddress+0x02000000)  

// Derrick
#define SMDK_MODE               0
#define ASB_MODE                1
#define TEST_CODE_MODE              ASB_MODE

#define ASB_ONBL_ADDRESS        (_DRAM_BaseAddress+0x01000000)
#define ASB_BL2_ADDRESS         (_DRAM_BaseAddress+0x01000800)
#define ASB_FW_ADDRESS          (_DRAM_BaseAddress+0x01040000)
#define ASB_MFC1_ADDRESS        (_DRAM_BaseAddress+0x01A00000)
#define ASB_MFC2_ADDRESS        (_DRAM_BaseAddress+0x01A20000)
#define ASB_MFC3_ADDRESS        (_DRAM_BaseAddress+0x01D20000)
#define ASB_BIN1_ADDRESS        (_DRAM_BaseAddress+0x02120000)
#define ASB_BIN2_ADDRESS        (_DRAM_BaseAddress+0x05000000)
#ifdef __cplusplus
}
#endif

#endif /*__OPTION_H__*/
```
