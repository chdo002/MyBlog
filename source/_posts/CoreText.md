---
title: CoreText
date: 2018-04-26 11:14:30
tags:
---

在CDChatList为了达到页面流畅的效果，用到了coretext，关键点记录如下

聊天页面卡顿点主要有，计算聊天气泡高度、富文本渲染时的性能消耗太大，这两个可以异步操作，并缓存

气泡高度的计算一般都是用NSString的boundingRectWithSize: options: attributes: context:方法计算，算出来的结果可以放在消息Model中缓存并可以本地化，这样就只需计算一次。

富文本渲染有两种方法，UILabel中的attributedText可以复值富文本，但是boundingRectWithSize就不太好用了，而且要考虑到带表情的富文本，所以就得用另一个方法

⬇️

# CoreText

<div style="display:inline">首先需要注意的是，<h3 style="display:inline" >Coretext只有C的接口</h3>，所以得手动管理一些c的内存，同时还得了解字体字形相关信息。</div>

UILabel对coretext进行了封装，我们这里直接调用coretext，可以获得不错的性能表现。

coretext可以实现文本尺寸的计算，文本在子线程绘制，绘制完成后再赋值给view，这样耗时操作都可以不在主线程操作，不影响页面流畅。

上代码

```
/*
 *   首先创建需要显示的富文本，这里可能包含表情，
 *   形如: @"呵呵哒，然后来个表情[微笑][骷髅]", 
 *   这里的[微笑][骷髅]就是需要被替换成表情图片，先用正则换成空字符占位，等后续图片绘制，绘制部分具体代码可见CDChatList的CDLabel实现
 */ 
NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:data.msgString attributes:dic];


// 先创建framesetter
CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attString);

/*
*  这步计算文本内容范围，猜测boundingRectWithSize也是用的这个方法，入参很像
*  这里的size就是需要缓存的
*/ 
CGSize caSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0,attString.length), nil, size, nil);

// 这两步获得需要绘制文本的CGPath和CTFrame
CGPathRef path = CGPathCreateWithRect(CGRectMake(0, 0, caSize.width, caSize.height), NULL);
CTFrameRef frame = CTFramesetterCreateFrame(framesetter,CFRangeMake(0, [attString length]), path, NULL);

// 注意需要释放内存
CFRelease(framesetter);
CFRelease(path);


// 渲染展示内容
UIGraphicsBeginImageContextWithOptions(caSize, NO, 0);
CGContextRef context = UIGraphicsGetCurrentContext();
CGContextSetTextMatrix(context, CGAffineTransformIdentity);
CGContextTranslateCTM(context, 0, caSize.height);
CGContextScaleCTM(context, 1.0, -1.0); // coretext坐标系翻转
CTFrameDraw(frame, context);

//.....将上面正则出来的表情图片也绘制在这个context上


// 最终我们得到这个需要展示的图片内容
UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
UIGraphicsEndImageContext();


// 在展示上面的图片时，将他赋给layer的contents
self.layer.contents = (__bridge id)data.contents.CGImage;

```

最终效果在GitHub见[CDChatList](https://github.com/chdo002/cdchatlist)
