//
//  CHLAudioRecordView.m
//  CHLAudioRecordingDemo
//
//  Created by DAYOU on 2017/3/24.
//  Copyright © 2017年 DaYou. All rights reserved.
//

#import "CHLAudioRecordView.h"
#import "UIImage+CHLGif.h"
#import "CHLAudioRecordHUD.h"
#import <AVFoundation/AVFoundation.h>
#import "lame.h"
#import "AFNetworking.h"

@interface CHLAudioRecordView ()<UIGestureRecognizerDelegate,AVAudioRecorderDelegate,AVAudioPlayerDelegate>
{
	BOOL isCancel;
    CGFloat timeOut;
}

@property(nonatomic,strong)UIImageView * recordBtn;

@property(nonatomic,strong)AVAudioRecorder * audioRecorder;

@property(nonatomic,strong)AVAudioPlayer * audioPalyer;

@property(nonatomic,strong)NSTimer * recorderTimer;

@property(nonatomic,strong)UILabel * recordTimeLabel;

@property(nonatomic,strong)CHLAudioRecordHUD * hud;

@property(nonatomic,strong)UILongPressGestureRecognizer * longPress;

@property(nonatomic,strong)UILabel * fileNameSizeLabel;

@property(nonatomic,strong)UILabel * timeLabel;

@property(nonatomic,strong)UIProgressView * progressView;

@property(nonatomic,strong)UIButton * playBtn;

@property(nonatomic,strong)UIButton * stopBtn;

@property(nonatomic,strong)NSTimer * playTimer;

@property(nonatomic,assign)BOOL isStopRecorde;


@end

@implementation CHLAudioRecordView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self createUI];
    }
    return self;
}

-(void)createUI{
    
    _hud = [[CHLAudioRecordHUD alloc]initWithView:self];
    
    timeOut = 60;

   
    _recordBtn = [[UIImageView alloc]initWithFrame:CGRectMake(self.center.x - 96/2, self.frame.size.height - 96 - 20, 96, 96)];
    [self normalRecordBtn];
    _recordBtn.userInteractionEnabled = YES;
    [self addSubview:_recordBtn];
    
    _recordTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 300, 30)];
    _recordTimeLabel.center = CGPointMake(_recordBtn.center.x, CGRectGetMinY(_recordBtn.frame) - 30);
    _recordTimeLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_recordTimeLabel];
    _recordTimeLabel.text = @"长按按钮,开启录音";
    
    
    _longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPress:)];
    _longPress.delegate = self;
    _longPress.minimumPressDuration = 0.1;
    [_recordBtn addGestureRecognizer:_longPress];
    
    
    _fileNameSizeLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, 100)];
    _fileNameSizeLabel.text =[NSString stringWithFormat:@"%@\n%@",[self fileSizeAtPath:[self getSavePath]],[self fileSizeAtPath:[self getSaveMp3Path]]];
    _fileNameSizeLabel.center = self.center;
    _fileNameSizeLabel.textAlignment = NSTextAlignmentCenter;
    _fileNameSizeLabel.numberOfLines = 0;
    [self addSubview:_fileNameSizeLabel];
    
    
    _playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:_playBtn];
    _playBtn.frame = CGRectMake(self.frame.size.width/2 - 100/2, 100, 100, 30);
    [_playBtn setTitle:@"播放" forState:UIControlStateNormal];
    [_playBtn addTarget:self action:@selector(playBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [_playBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    
    
    _progressView = [[UIProgressView alloc]initWithFrame:CGRectMake(self.frame.size.width/2 - 260/2, CGRectGetMaxY(_playBtn.frame) + 10, 260, 2)];
    [self addSubview:_progressView];
    
    _progressView.trackTintColor = [UIColor grayColor];
    _progressView.progressTintColor = [UIColor redColor];
    
    _timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_progressView.frame)+8, 260, 30)];
    _timeLabel.center = CGPointMake(_progressView.progress * 260 + self.frame.size.width/2 - 260/2, _timeLabel.center.y);
    _timeLabel.text = @"00:00/00:00";
    _timeLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_timeLabel];
    
    
    [self setAudioSession];
}

-(void)longPress:(UILongPressGestureRecognizer *)longPress{
    
    if (longPress.state ==  UIGestureRecognizerStateBegan) {
        
        [self highLightRecordBtn];
        
        [self starRecording];
    }
    
    if (longPress.state == UIGestureRecognizerStateChanged) {
        CGPoint location = [longPress locationInView:self];
        
        if (location.y < CGRectGetMinY(_recordBtn.frame)) {
            //在上面,提示 松开手势取消发送
            isCancel = YES;
            //改变展示的图片
            [_hud showCancelImageView];
        }else{
            isCancel = NO;
            [_hud showNormalImage];
        }
        
    }
    
    if (longPress.state == UIGestureRecognizerStateEnded) {
        
        [self stopRecording];
        
        [self normalRecordBtn];
    }
    
}

-(void)normalRecordBtn{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"timg" ofType:@"jpeg"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    _recordBtn.image = [UIImage CHLImageWithSmallGIFData:data scale:1];
}

-(void)highLightRecordBtn{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"1" ofType:@"gif"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    _recordBtn.image = [UIImage CHLImageWithSmallGIFData:data scale:1];
}


/**
 *  设置音频会话
 */
-(void)setAudioSession{
    AVAudioSession *audioSession=[AVAudioSession sharedInstance];
    //设置为播放和录音状态，以便可以在录制完之后播放录音
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    [audioSession setActive:YES error:nil];
    
    //设置录音声音
    NSError *audioError =nil;
    BOOL success = [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&audioError];
    if(!success){
        NSLog(@"error doing outputaudioportoverride - %@", [audioError localizedDescription]);
    }
}


/**
 *  录音声波监控定制器
 *
 *  @return 定时器
 */
-(NSTimer *)recorderTimer{
    if (!_recorderTimer) {
        _recorderTimer=[NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(audioPowerChange) userInfo:nil repeats:YES];
    }
    return _recorderTimer;
}

/**
 *  录音声波状态设置
 */
-(void)audioPowerChange{
    
    timeOut  = timeOut - 0.1;
    //计算录制的时间
    _recordTimeLabel.text = [self stringWithSecond:60-timeOut];
    
    if (timeOut <=0) {
        [self stopRecording];
        timeOut = 60;
        [self normalRecordBtn];
        _recordTimeLabel.text = @"长按按钮,开启录音";
    }
    
    
    
    [self.audioRecorder updateMeters];//更新测量值
//    float power= [self.audioRecorder averagePowerForChannel:0];//取得第一个通道的音频，注意音频强度范围时-160到0
//    CGFloat progress=(1.0/160.0)*(power+160.0);
//    //显示动画(0 -- 1)
    
    float avg = [_audioRecorder averagePowerForChannel:0];
    float minValue = -60;
    float range = 60;
    float outRange = 100;
    if (avg < minValue) {
        avg = minValue;
    }
    float decibels = (avg + range) / range * outRange;
    
    [_hud showDB:decibels];
}

-(AVAudioRecorder *)audioRecorder{
    if (!_audioRecorder) {
        //创建录音文件保存路径
        NSURL *url=[NSURL URLWithString:[self getSavePath]];
        //创建录音格式设置
        NSDictionary *setting=[self getAudioSetting];
        //创建录音机
        NSError *error=nil;
        
        _audioRecorder=[[AVAudioRecorder alloc]initWithURL:url settings:setting error:&error];
        _audioRecorder.delegate=self;
        _audioRecorder.meteringEnabled=YES;//如果要监控声波则必须设置为YES
        
        if (error) {
            NSLog(@"创建录音机对象时发生错误，错误信息：%@",error.localizedDescription);
            return nil;
        }
    }
    return _audioRecorder;
}

/**
 *  取得录音文件保存路径
 *
 *  @return 录音文件路径
 */
-(NSString *)getSavePath{
    NSString *urlStr=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    urlStr=[urlStr stringByAppendingPathComponent:@"myRecord.caf"];
    NSLog(@"file path:%@",urlStr);
    return urlStr;
}

-(NSString *)getSaveMp3Path{
    NSString *urlStr=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    urlStr=[urlStr stringByAppendingPathComponent:@"myRecordMP3.mp3"];
    NSLog(@"file path:%@",urlStr);
    return urlStr;
}

/**
 *  取得录音文件设置
 *
 *  @return 录音设置
 */
-(NSDictionary *)getAudioSetting{
    NSMutableDictionary *dicM=[NSMutableDictionary dictionary];
    //设置录音格式
//    [dicM setObject:@(kAudioFormatMPEG4AAC) forKey:AVFormatIDKey];
    //设置录音采样率，8000是电话采样率，对于一般录音已经够了
    [dicM setObject:@(44100.0) forKey:AVSampleRateKey];//11025.0
    //设置通道,这里采用双声道
    [dicM setObject:@(2) forKey:AVNumberOfChannelsKey];
    //每个采样点位数,分为8、16、24、32
    [dicM setObject:@(16) forKey:AVEncoderBitRateKey];
    //是否使用浮点数采样
//    [dicM setObject:@(YES) forKey:AVLinearPCMIsFloatKey];
    //音频质量
    [dicM setObject:@(AVAudioQualityMin) forKey:AVEncoderAudioQualityKey];
    //....其他设置等
    return dicM;
}

-(void)starRecording{
    
    if ([self.audioPalyer isPlaying]) {
        [self.audioPalyer stop];
    }
    
    if ([self.audioRecorder isRecording]) {
        [self.audioRecorder stop];
    }
    
    [self deleteOldRecordFile];  //如果不删掉，会在原文件基础上录制；虽然不会播放原来的声音，但是音频长度会是录制的最大长度。

    if (![self.audioRecorder isRecording]) {
        
        [_hud showHUD];
        
        [self.audioRecorder record];//首次使用应用时如果调用record方法会询问用户是否允许使用麦克风
        
        [self.audioRecorder prepareToRecord];
        
        self.isStopRecorde = NO;
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self toMp3];
        });
        
        //开始计时
        self.recorderTimer.fireDate=[NSDate distantPast];
    }
    
}

-(void)stopRecording{
    
    [_hud dismiss];
    
    [self.audioRecorder stop];

    self.recorderTimer.fireDate=[NSDate distantFuture];
	
    self.isStopRecorde = YES;
}



-(void)deleteOldRecordFile{
    
   	NSString * urlStr = [self getSavePath];
    
    NSFileManager* fileManager=[NSFileManager defaultManager];
    
    BOOL bRet = [fileManager fileExistsAtPath:urlStr];
    
    if (bRet) {
        
        [fileManager removeItemAtPath:urlStr error:nil];
    }
    
}

-(void)deleteOldMp3File{
    
   	NSString * urlStr = [self getSaveMp3Path];
    
    NSFileManager* fileManager=[NSFileManager defaultManager];
    
    BOOL bRet = [fileManager fileExistsAtPath:urlStr];
    
    if (bRet) {
        
        [fileManager removeItemAtPath:urlStr error:nil];
        NSLog(@"删除成功");
    }
}

-(AVAudioPlayer *)audioPalyer{
    if (!_audioPalyer) {
        NSString * path = [[NSBundle mainBundle] pathForResource:@"2017_04_10_064054" ofType:@"mp3"];
        
        _audioPalyer = [[AVAudioPlayer alloc]initWithContentsOfURL:[NSURL URLWithString:path] error:nil];

        _audioPalyer.delegate = self;
        
        [_audioPalyer prepareToPlay];
    }
    return _audioPalyer;
}


-(void)playBtnClick{
    
    if (self.audioPalyer.isPlaying) {
        return;
    }
    
    NSLog(@"开始播放了哦");
   
    _playTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(playTimeChange) userInfo:nil repeats:YES];
    
    [self.audioPalyer play];
}

-(void)playTimeChange{
    
    _timeLabel.text = [NSString stringWithFormat:@"%@/%@",[self stringWithSecond:self.audioPalyer.currentTime],[self stringWithSecond:self.audioPalyer.duration]];
    CGFloat progress = self.audioPalyer.currentTime/self.audioPalyer.duration;
    [_progressView setProgress:progress animated:YES];
    _timeLabel.center = CGPointMake(_progressView.progress * 260 + self.frame.size.width/2 - 260/2, _timeLabel.center.y);
}

#pragma mark - AVAudioPlayerDelegate
- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [_playTimer invalidate];
    _playTimer = nil;
    
    _timeLabel.text = [NSString stringWithFormat:@"%@/%@",[self stringWithSecond:0],[self stringWithSecond:_audioPalyer.duration]];
}


-(NSString *)stringWithSecond:(NSInteger)second{
    
    if (second > 60) {
        NSString * m = [NSString stringWithFormat:@"%.2zd",second/60];
        NSString * s = [NSString stringWithFormat:@"%.2zd",second%60];
        NSString * dateStr = [NSString stringWithFormat:@"%@:%@",m,s];
        return dateStr;
    }else{
    	NSString * dateStr = [NSString stringWithFormat:@"00:%.2zd",second];
        return dateStr;
    }

}

- (NSString * )fileSizeAtPath:(NSString *)filePath
{
    NSArray * array = [filePath componentsSeparatedByString:@"/"];
    NSString * fileName = [array lastObject];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:filePath])
    {
        return @"文件不存在或已被删除";
    }
    else
    {
        CGFloat fileSize = [[fileManager attributesOfItemAtPath:filePath error:nil] fileSize]/1024.0;
        
        if (fileSize >= 1000) {
            fileSize = fileSize/1024;
            
            NSString * fileSizeStr = [NSString stringWithFormat:@"%@-->%.2lfM",fileName,fileSize];
            return fileSizeStr;
        }else{
            NSString * fileSizeStr = [NSString stringWithFormat:@"%@-->%.2lfK",fileName,fileSize];
            return fileSizeStr;
        }
    }
}

#pragma mark - 录音机代理方法
/**
 *  录音完成
 *
 *  @param recorder 录音机对象
 *  @param flag     是否成功
 */
-(void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
    if (![self.audioPalyer isPlaying]) {

        NSLog(@"录音完成!");
        
         _fileNameSizeLabel.text = [NSString stringWithFormat:@"%@\n%@",[self fileSizeAtPath:[self getSavePath]],[self fileSizeAtPath:[self getSaveMp3Path]]];
        timeOut = 60;
    }
   
}



- (void) toMp3
{
    NSString *cafFilePath = [self getSavePath];
    
    [self deleteOldMp3File];
    
    NSString *mp3FilePath =[self getSaveMp3Path];
    
    @try {
        int read, write;
        
        FILE *pcm = fopen([cafFilePath cStringUsingEncoding:1], "rb");  //source 被转换的音频文件位置
        								                                 //skip file header
        FILE *mp3 = fopen([mp3FilePath cStringUsingEncoding:1], "wb");  //output 输出生成的Mp3文件位置
        
        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE*2];
        unsigned char mp3_buffer[MP3_SIZE];
        
        lame_t lame = lame_init();
        lame_set_num_channels(lame,2);//设置1为单通道，默认为2双通道
        lame_set_in_samplerate(lame, 44100.0);
        lame_set_VBR(lame, vbr_default);
        
        lame_set_brate(lame,8);
        
        lame_set_mode(lame,1);
        
        lame_set_quality(lame,7);
        
        lame_init_params(lame);
        
        lame_set_scale(lame, 0.1);
        
        long curpos;
        BOOL isSkipPCMHeader = NO;
        
        do {
            
            curpos = ftell(pcm);
            
            long startPos = ftell(pcm);
            
            fseek(pcm, 0, SEEK_END);
            long endPos = ftell(pcm);
            
            long length = endPos - startPos;
            
            fseek(pcm, curpos, SEEK_SET);
            
            
            if (length > PCM_SIZE * 2 * sizeof(short int)) {
                
                if (!isSkipPCMHeader) {
                    //Uump audio file header, If you do not skip file header
                    //you will heard some noise at the beginning!!!
                    fseek(pcm, 4 * 1024, SEEK_SET);
                    isSkipPCMHeader = YES;
           
                }
                
                read = (int)fread(pcm_buffer, 2 * sizeof(short int), PCM_SIZE, pcm);
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
                fwrite(mp3_buffer, write, 1, mp3);
                
                NSLog(@"read %d bytes", write);
            }
            else {
                [NSThread sleepForTimeInterval:0.05];
            }
            
        } while (!self.isStopRecorde);
        
        read = (int)fread(pcm_buffer, 2 * sizeof(short int), PCM_SIZE, pcm);
        write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
        NSLog(@"read %d bytes and flush to mp3 file", write);
        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception description]);
    } 
    @finally {
        [self convertMp3Finish];
    }

    
}
- (void) convertMp3Finish
{
 	//发送
    NSLog(@"转换成功");
    
    NSURL * url = [NSURL URLWithString:@"xxxx"];
    
    if (!isCancel) {
        AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
        
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];

        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html;charset=utf-8",@"text/html",@"application/json",@"application/x-javascript",@"application/json; charset=utf-8",@"application/xml",@"application/javascript",@"text/json",@"text/javascript",@"text/plain",@"image/png",@"image/gif",@"text/xml; charset=utf-8", nil];

//        @"accessory":(__bridge id)((__bridge FILE*)(data))
        
        
        NSData * data = [NSData dataWithContentsOfFile:[self getSaveMp3Path]];
        
        [manager POST:url.absoluteString parameters:@{@"uid":@"3484893",@"sid":@"4366f853fc706d756646e2c5269f4dfbddfbef6a"} constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            // 设置时间格式
            formatter.dateFormat = @"yyyyMMddHHmmss";
            NSString *str = [formatter stringFromDate:[NSDate date]];
            NSString *fileName = [NSString stringWithFormat:@"iOS_%@.mp3", str];
            
            [formData appendPartWithFileData:data name:@"file" fileName:fileName mimeType:@"mp3"];
            
        } progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
           
            NSString * rel = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
           
            NSLog(@"%@",rel);
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"%@",error);
        }];
    }
    
    _fileNameSizeLabel.text = [NSString stringWithFormat:@"%@\n%@",[self fileSizeAtPath:[self getSavePath]],[self fileSizeAtPath:[self getSaveMp3Path]]];
    
    self.audioPalyer = nil;
}

@end
