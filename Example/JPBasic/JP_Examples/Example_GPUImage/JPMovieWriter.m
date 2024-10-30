//
//  JPMovieWriter.m
//  JPBasic
//
//  Created by aa on 2022/3/10.
//  Copyright © 2022 zhoujianping24@hotmail.com. All rights reserved.
//

#import "JPMovieWriter.h"
#import "GPUImageContext.h"
#import "GLProgram.h"
#import "GPUImageFilter.h"
#import "GPUImageMovieWriter.h"

@interface JPMovieWriter ()
{
    GLuint _movieFramebuffer;
    GLuint _movieRenderbuffer;
    
    GLProgram *_colorSwizzlingProgram;
    GLint _colorSwizzlingPositionAttribute;
    GLint _colorSwizzlingTextureCoordinateAttribute;
    GLint _colorSwizzlingInputTextureUniform;

    GPUImageFramebuffer *_firstInputFramebuffer;
    
    CMTime _startTime;
    CMTime _previousFrameTime;
    CMTime _previousAudioTime;

    dispatch_queue_t _audioQueue;
    dispatch_queue_t _videoQueue;
    
    BOOL _audioEncodingIsFinished;
    BOOL _videoEncodingIsFinished;
    
    BOOL _allowWriteAudio; // jp_用于解决<<视频第一帧会黑屏>>的问题
    
    BOOL _discont;
    CMTime _offsetTime;
}
@end

@implementation JPMovieWriter

#pragma mark - JP_重置AssetWriter
- (BOOL)jp_resetAssetWriter {
    if (_assetWriter != nil) return NO;
    
    _discont = NO;
    _paused = NO;
    _isRecording = NO;
    _allowWriteAudio = NO;
    _alreadyFinishedRecording = NO;
    _videoEncodingIsFinished = NO;
    _audioEncodingIsFinished = NO;
    _startTime = kCMTimeInvalid;
    _offsetTime = kCMTimeInvalid;
    
    NSError *error = nil;
    _assetWriter = [[AVAssetWriter alloc] initWithURL:_movieURL fileType:_fileType error:&error];
    if (error) {
        NSLog(@"Reset AssetWriter Error: %@", error);
        if (_failureBlock) {
            _failureBlock(error);
        } else if(self.delegate && [self.delegate respondsToSelector:@selector(movieRecordingFailedWithError:)]) {
            [self.delegate movieRecordingFailedWithError:error];
        }
        return NO;
    }

    // Set this to make sure that a functional movie is produced, even if the recording is cut off mid-stream. Only the last second should be lost in that case.
//    assetWriter.movieFragmentInterval = CMTimeMakeWithSeconds(1.0, 1000);
    _assetWriter.movieFragmentInterval = kCMTimeInvalid; // MP4格式需要设置这个

    if (_assetWriterVideoInput && [_assetWriter canAddInput:_assetWriterVideoInput]) {
        [_assetWriter addInput:_assetWriterVideoInput];
    }

    if (_assetWriterAudioInput && [_assetWriter canAddInput:_assetWriterAudioInput]) {
        [_assetWriter addInput:_assetWriterAudioInput];
    }
    
    return YES;
}

- (void)jp_removeAssetWriter {
    _isRecording = NO;
    _paused = NO;
    _assetWriter = nil;
}

#pragma mark - Initialization and teardown

- (id)initWithMovieURL:(NSURL *)newMovieURL size:(CGSize)newSize;
{
    return [self initWithMovieURL:newMovieURL size:newSize fileType:AVFileTypeQuickTimeMovie outputSettings:nil];
}

- (id)initWithMovieURL:(NSURL *)newMovieURL size:(CGSize)newSize fileType:(NSString *)newFileType outputSettings:(NSMutableDictionary *)outputSettings;
{
    if (!(self = [super init])) return nil;

    _shouldInvalidateAudioSampleWhenDone = NO;
    
    _enabled = YES;
    _alreadyFinishedRecording = NO;
    _videoEncodingIsFinished = NO;
    _audioEncodingIsFinished = NO;

    _videoSize = newSize;
    _movieURL = newMovieURL;
    _fileType = newFileType;
    _startTime = kCMTimeInvalid;
    _encodingLiveVideo = [[outputSettings objectForKey:@"EncodingLiveVideo"] isKindOfClass:[NSNumber class]] ? [[outputSettings objectForKey:@"EncodingLiveVideo"] boolValue] : YES;
    _previousFrameTime = kCMTimeNegativeInfinity;
    _previousAudioTime = kCMTimeNegativeInfinity;
    _inputRotation = kGPUImageNoRotation;
    
    _movieWriterContext = [[GPUImageContext alloc] init];
    [_movieWriterContext useSharegroup:[[[GPUImageContext sharedImageProcessingContext] context] sharegroup]];

    __weak typeof(self) wSelf = self;
    runSynchronouslyOnContextQueue(_movieWriterContext, ^{
        __strong typeof(wSelf) sSelf = wSelf;
        if (!sSelf) return;
        
        [sSelf->_movieWriterContext useAsCurrentContext];
        
        if ([GPUImageContext supportsFastTextureUpload]) {
            sSelf->_colorSwizzlingProgram = [sSelf->_movieWriterContext programForVertexShaderString:kGPUImageVertexShaderString fragmentShaderString:kGPUImagePassthroughFragmentShaderString];
        } else {
            sSelf->_colorSwizzlingProgram = [sSelf->_movieWriterContext programForVertexShaderString:kGPUImageVertexShaderString fragmentShaderString:kGPUImageColorSwizzlingFragmentShaderString];
        }
        
        if (!sSelf->_colorSwizzlingProgram.initialized) {
            [sSelf->_colorSwizzlingProgram addAttribute:@"position"];
            [sSelf->_colorSwizzlingProgram addAttribute:@"inputTextureCoordinate"];
            
            if (![sSelf->_colorSwizzlingProgram link]) {
                NSString *progLog = [sSelf->_colorSwizzlingProgram programLog];
                NSLog(@"Program link log: %@", progLog);
                NSString *fragLog = [sSelf->_colorSwizzlingProgram fragmentShaderLog];
                NSLog(@"Fragment shader compile log: %@", fragLog);
                NSString *vertLog = [sSelf->_colorSwizzlingProgram vertexShaderLog];
                NSLog(@"Vertex shader compile log: %@", vertLog);
                sSelf->_colorSwizzlingProgram = nil;
                NSAssert(NO, @"Filter shader link failed");
            }
        }
        
        sSelf->_colorSwizzlingPositionAttribute = [sSelf->_colorSwizzlingProgram attributeIndex:@"position"];
        sSelf->_colorSwizzlingTextureCoordinateAttribute = [sSelf->_colorSwizzlingProgram attributeIndex:@"inputTextureCoordinate"];
        sSelf->_colorSwizzlingInputTextureUniform = [sSelf->_colorSwizzlingProgram uniformIndex:@"inputImageTexture"];
        
        [sSelf->_movieWriterContext setContextShaderProgram:sSelf->_colorSwizzlingProgram];
        
        glEnableVertexAttribArray(sSelf->_colorSwizzlingPositionAttribute);
        glEnableVertexAttribArray(sSelf->_colorSwizzlingTextureCoordinateAttribute);
    });
        
    [self initializeMovieWithOutputSettings:outputSettings];

    return self;
}

- (void)dealloc {
    [self destroyDataFBO];

#if !OS_OBJECT_USE_OBJC
    if (audioQueue != NULL) {
        dispatch_release(audioQueue);
    }
    if (videoQueue != NULL) {
        dispatch_release(videoQueue);
    }
#endif
}

#pragma mark - Movie recording

- (void)initializeMovieWithOutputSettings:(NSDictionary *)outputSettings {
    // use default output settings if none specified
    if (outputSettings == nil) {
        NSMutableDictionary *settings = [[NSMutableDictionary alloc] init];
        if (@available(iOS 11.0, *)) {
            [settings setObject:AVVideoCodecTypeH264 forKey:AVVideoCodecKey];
        } else {
            [settings setObject:AVVideoCodecH264 forKey:AVVideoCodecKey];
        }
        [settings setObject:[NSNumber numberWithInt:_videoSize.width] forKey:AVVideoWidthKey];
        [settings setObject:[NSNumber numberWithInt:_videoSize.height] forKey:AVVideoHeightKey];
        outputSettings = settings;
    } else {
        // custom output settings specified
        __unused NSString *videoCodec = [outputSettings objectForKey:AVVideoCodecKey];
        __unused NSNumber *width = [outputSettings objectForKey:AVVideoWidthKey];
        __unused NSNumber *height = [outputSettings objectForKey:AVVideoHeightKey];
        
        NSAssert(videoCodec && width && height, @"OutputSettings is missing required parameters.");
        
        if ([outputSettings objectForKey:@"EncodingLiveVideo"]) {
            NSMutableDictionary *tmp = [outputSettings mutableCopy];
            [tmp removeObjectForKey:@"EncodingLiveVideo"];
            outputSettings = tmp;
        }
    }
    
    /*
    NSDictionary *videoCleanApertureSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                                [NSNumber numberWithInt:videoSize.width], AVVideoCleanApertureWidthKey,
                                                [NSNumber numberWithInt:videoSize.height], AVVideoCleanApertureHeightKey,
                                                [NSNumber numberWithInt:0], AVVideoCleanApertureHorizontalOffsetKey,
                                                [NSNumber numberWithInt:0], AVVideoCleanApertureVerticalOffsetKey,
                                                nil];

    NSDictionary *videoAspectRatioSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                              [NSNumber numberWithInt:3], AVVideoPixelAspectRatioHorizontalSpacingKey,
                                              [NSNumber numberWithInt:3], AVVideoPixelAspectRatioVerticalSpacingKey,
                                              nil];

    NSMutableDictionary * compressionProperties = [[NSMutableDictionary alloc] init];
    [compressionProperties setObject:videoCleanApertureSettings forKey:AVVideoCleanApertureKey];
    [compressionProperties setObject:videoAspectRatioSettings forKey:AVVideoPixelAspectRatioKey];
    [compressionProperties setObject:[NSNumber numberWithInt: 2000000] forKey:AVVideoAverageBitRateKey];
    [compressionProperties setObject:[NSNumber numberWithInt: 16] forKey:AVVideoMaxKeyFrameIntervalKey];
    [compressionProperties setObject:AVVideoProfileLevelH264Main31 forKey:AVVideoProfileLevelKey];
    
    [outputSettings setObject:compressionProperties forKey:AVVideoCompressionPropertiesKey];
    */
     
    _assetWriterVideoInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:outputSettings];
    _assetWriterVideoInput.expectsMediaDataInRealTime = _encodingLiveVideo;
    
    // You need to use BGRA for the video in order to get realtime encoding. I use a color-swizzling shader to line up glReadPixels' normal RGBA output with the movie input's BGRA.
    NSDictionary *sourcePixelBufferAttributesDictionary =
        [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithInt:kCVPixelFormatType_32BGRA], kCVPixelBufferPixelFormatTypeKey,
            [NSNumber numberWithInt:_videoSize.width], kCVPixelBufferWidthKey,
            [NSNumber numberWithInt:_videoSize.height], kCVPixelBufferHeightKey,
            nil
        ];
    
    _assetWriterPixelBufferInput = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:_assetWriterVideoInput sourcePixelBufferAttributes:sourcePixelBufferAttributesDictionary];
}

- (void)setEncodingLiveVideo:(BOOL)value {
    _encodingLiveVideo = value;
    if (_isRecording) {
        NSAssert(NO, @"Can not change Encoding Live Video while recording");
    } else {
        _assetWriterVideoInput.expectsMediaDataInRealTime = _encodingLiveVideo;
        _assetWriterAudioInput.expectsMediaDataInRealTime = _encodingLiveVideo;
    }
}

- (void)startRecording {
    // jp_重置assetWriter
    if (![self jp_resetAssetWriter]) return;
    
    __weak typeof(self) wSelf = self;
    runSynchronouslyOnContextQueue(_movieWriterContext, ^{
        __strong typeof(wSelf) sSelf = wSelf;
        if (!sSelf) return;
        
        if (sSelf->_audioInputReadyCallback == nil) {
            [sSelf->_assetWriter startWriting];
        }
    });
    
    _isRecording = YES;
}

- (void)startRecordingInOrientation:(CGAffineTransform)orientationTransform {
    _assetWriterVideoInput.transform = orientationTransform;
    [self startRecording];
}

- (void)cancelRecording {
    if (_assetWriter && _assetWriter.status == AVAssetWriterStatusCompleted) {
        // jp_移除assetWriter
        [self jp_removeAssetWriter];
        return;
    }
    
    _isRecording = NO;
    
    __weak typeof(self) wSelf = self;
    runSynchronouslyOnContextQueue(_movieWriterContext, ^{
        __strong typeof(wSelf) sSelf = wSelf;
        if (!sSelf) return;
        
        sSelf->_alreadyFinishedRecording = YES;

        if (sSelf->_assetWriter.status == AVAssetWriterStatusWriting && !sSelf->_videoEncodingIsFinished) {
            sSelf->_videoEncodingIsFinished = YES;
            [sSelf->_assetWriterVideoInput markAsFinished];
        }
        
        if (sSelf->_assetWriter.status == AVAssetWriterStatusWriting && !sSelf->_audioEncodingIsFinished) {
            sSelf->_audioEncodingIsFinished = YES;
            [sSelf->_assetWriterAudioInput markAsFinished];
        }
        
        [sSelf->_assetWriter cancelWriting];
        // jp_移除assetWriter
        [sSelf jp_removeAssetWriter];
    });
}

- (void)finishRecording {
    [self finishRecordingWithCompletionHandler:nil];
}

- (void)finishRecordingWithCompletionHandler:(void (^)(void))handler {
    _isRecording = NO;
    __weak typeof(self) wSelf = self;
    runSynchronouslyOnContextQueue(_movieWriterContext, ^{
        __strong typeof(wSelf) sSelf = wSelf;
        if (!sSelf) return;
        
        sSelf->_alreadyFinishedRecording = YES;
        
        if (sSelf->_assetWriter.status == AVAssetWriterStatusCompleted ||
            sSelf->_assetWriter.status == AVAssetWriterStatusCancelled ||
            sSelf->_assetWriter.status == AVAssetWriterStatusUnknown) {
            if (handler) runAsynchronouslyOnContextQueue(sSelf->_movieWriterContext, handler);
            // jp_移除assetWriter
            [sSelf jp_removeAssetWriter];
            return;
        }
        
        if (sSelf->_assetWriter.status == AVAssetWriterStatusWriting && !sSelf->_videoEncodingIsFinished) {
            sSelf->_videoEncodingIsFinished = YES;
            [sSelf->_assetWriterVideoInput markAsFinished];
        }
        
        if (sSelf->_assetWriter.status == AVAssetWriterStatusWriting && !sSelf->_audioEncodingIsFinished) {
            sSelf->_audioEncodingIsFinished = YES;
            [sSelf->_assetWriterAudioInput markAsFinished];
        }
        
#if (!defined(__IPHONE_6_0) || (__IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_6_0))
        // Not iOS 6 SDK
        [sSelf->_assetWriter finishWriting];
        if (handler) runAsynchronouslyOnContextQueue(self->_movieWriterContext, handler);
#else
        // iOS 6 SDK
        if ([sSelf->_assetWriter respondsToSelector:@selector(finishWritingWithCompletionHandler:)]) {
            // Running iOS 6
            [sSelf->_assetWriter finishWritingWithCompletionHandler:handler];
        } else {
            // Not running iOS 6
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            [sSelf->_assetWriter finishWriting];
#pragma clang diagnostic pop
            if (handler) runAsynchronouslyOnContextQueue(sSelf->_movieWriterContext, handler);
        }
#endif
        // jp_移除assetWriter
        [sSelf jp_removeAssetWriter];
    });
}

- (void)processAudioBuffer:(CMSampleBufferRef)audioBuffer {
    // jp_修改GPUImage：解决<<视频第一帧会黑屏>>的问题
    if (!_allowWriteAudio) return;
    
    if (!_isRecording || _paused) return;
    if (!_hasAudioTrack) return;

    CFRetain(audioBuffer);
    CMTime currentSampleTime = CMSampleBufferGetOutputPresentationTimeStamp(audioBuffer);
    
    if (CMTIME_IS_INVALID(_startTime)) {
        __weak typeof(self) wSelf = self;
        runSynchronouslyOnContextQueue(_movieWriterContext, ^{
            __strong typeof(wSelf) sSelf = wSelf;
            if (!sSelf) return;
            
            if ((sSelf->_audioInputReadyCallback == nil) &&
                (sSelf->_assetWriter.status != AVAssetWriterStatusWriting)) {
                [sSelf->_assetWriter startWriting];
            }
            [sSelf->_assetWriter startSessionAtSourceTime:currentSampleTime];
            sSelf->_startTime = currentSampleTime;
        });
    }

    if (!_assetWriterAudioInput.readyForMoreMediaData && _encodingLiveVideo) {
        NSLog(@"1: Had to drop an audio frame: %@", CFBridgingRelease(CMTimeCopyDescription(kCFAllocatorDefault, currentSampleTime)));
        if (_shouldInvalidateAudioSampleWhenDone) {
            CMSampleBufferInvalidate(audioBuffer);
        }
        CFRelease(audioBuffer);
        return;
    }
    
    if (_discont) {
        _discont = NO;
        
        CMTime current;
        if (_offsetTime.value > 0) {
            current = CMTimeSubtract(currentSampleTime, _offsetTime);
        } else {
            current = currentSampleTime;
        }
        
        CMTime offset = CMTimeSubtract(current, _previousAudioTime);
        
        if (_offsetTime.value == 0) {
            _offsetTime = offset;
        } else {
            _offsetTime = CMTimeAdd(_offsetTime, offset);
        }
    }
    
    if (_offsetTime.value > 0) {
        CFRelease(audioBuffer);
        audioBuffer = [self adjustTime:audioBuffer by:_offsetTime];
        CFRetain(audioBuffer);
    }
    
    // record most recent time so we know the length of the pause
    currentSampleTime = CMSampleBufferGetPresentationTimeStamp(audioBuffer);

    _previousAudioTime = currentSampleTime;
    
    //if the consumer wants to do something with the audio samples before writing, let him.
    if (self.audioProcessingCallback) {
        //need to introspect into the opaque CMBlockBuffer structure to find its raw sample buffers.
        CMBlockBufferRef buffer = CMSampleBufferGetDataBuffer(audioBuffer);
        CMItemCount numSamplesInBuffer = CMSampleBufferGetNumSamples(audioBuffer);
        AudioBufferList audioBufferList;
        
        CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(audioBuffer,
                                                                NULL,
                                                                &audioBufferList,
                                                                sizeof(audioBufferList),
                                                                NULL,
                                                                NULL,
                                                                kCMSampleBufferFlag_AudioBufferList_Assure16ByteAlignment,
                                                                &buffer);
        
        //passing a live pointer to the audio buffers, try to process them in-place or we might have syncing issues.
        for (int bufferCount=0; bufferCount < audioBufferList.mNumberBuffers; bufferCount++) {
            SInt16 *samples = (SInt16 *)audioBufferList.mBuffers[bufferCount].mData;
            self.audioProcessingCallback(&samples, numSamplesInBuffer);
        }
    }
    
    __weak typeof(self) wSelf = self;
    void(^write)(void) = ^() {
        __strong typeof(wSelf) sSelf = wSelf;
        if (!sSelf) return;
        
        while (!sSelf->_assetWriterAudioInput.readyForMoreMediaData &&
               !sSelf->_encodingLiveVideo &&
               !sSelf->_audioEncodingIsFinished) {
            NSDate *maxDate = [NSDate dateWithTimeIntervalSinceNow:0.5];
            [[NSRunLoop currentRunLoop] runUntilDate:maxDate];
        }
        
        if (!sSelf->_assetWriterAudioInput.readyForMoreMediaData) {
            NSLog(@"2: Had to drop an audio frame %@", CFBridgingRelease(CMTimeCopyDescription(kCFAllocatorDefault, currentSampleTime)));
            
        } else if (sSelf->_assetWriter.status == AVAssetWriterStatusWriting) {
            if (![sSelf->_assetWriterAudioInput appendSampleBuffer:audioBuffer]) {
                NSLog(@"Problem appending audio buffer at time: %@", CFBridgingRelease(CMTimeCopyDescription(kCFAllocatorDefault, currentSampleTime)));
            }
        } else {
            NSLog(@"Wrote an audio frame %@", CFBridgingRelease(CMTimeCopyDescription(kCFAllocatorDefault, currentSampleTime)));
        }

        if (sSelf->_shouldInvalidateAudioSampleWhenDone) {
            CMSampleBufferInvalidate(audioBuffer);
        }
        CFRelease(audioBuffer);
    };
    
    if (_encodingLiveVideo) {
        runAsynchronouslyOnContextQueue(_movieWriterContext, write);
    } else {
        write();
    }
}

- (void)enableSynchronizationCallbacks {
    if (_videoInputReadyCallback != nil) {
        if (_assetWriter.status != AVAssetWriterStatusWriting) {
            [_assetWriter startWriting];
        }
        
        _videoQueue = dispatch_queue_create("com.sunsetlakesoftware.GPUImage.videoReadingQueue", NULL);
        
        __weak typeof(self) wSelf = self;
        [_assetWriterVideoInput requestMediaDataWhenReadyOnQueue:_videoQueue usingBlock:^{
            __strong typeof(wSelf) sSelf = wSelf;
            if (!sSelf) return;
            
            if (sSelf->_paused) {
                NSLog(@"video requestMediaDataWhenReadyOnQueue paused");
                // if we don't sleep, we'll get called back almost immediately, chewing up CPU
                usleep(10000);
                return;
            }
            
            NSLog(@"video requestMediaDataWhenReadyOnQueue begin");
            while (sSelf->_assetWriterVideoInput.readyForMoreMediaData && !sSelf->_paused) {
                if (sSelf->_videoInputReadyCallback &&
                    !sSelf->_videoInputReadyCallback() &&
                    !sSelf->_videoEncodingIsFinished) {
                    runAsynchronouslyOnContextQueue(sSelf->_movieWriterContext, ^{
                        if(sSelf->_assetWriter.status == AVAssetWriterStatusWriting && !sSelf->_videoEncodingIsFinished) {
                            sSelf->_videoEncodingIsFinished = YES;
                            [sSelf->_assetWriterVideoInput markAsFinished];
                        }
                    });
                }
            }
            NSLog(@"video requestMediaDataWhenReadyOnQueue end");
        }];
    }
    
    if (_audioInputReadyCallback) {
        _audioQueue = dispatch_queue_create("com.sunsetlakesoftware.GPUImage.audioReadingQueue", NULL);
        
        __weak typeof(self) wSelf = self;
        [_assetWriterAudioInput requestMediaDataWhenReadyOnQueue:_audioQueue usingBlock:^{
            __strong typeof(wSelf) sSelf = wSelf;
            if (!sSelf) return;
            
            if (sSelf->_paused) {
                NSLog(@"audio requestMediaDataWhenReadyOnQueue paused");
                // if we don't sleep, we'll get called back almost immediately, chewing up CPU
                usleep(10000);
                return;
            }
            
            NSLog(@"audio requestMediaDataWhenReadyOnQueue begin");
            while (sSelf->_assetWriterAudioInput.readyForMoreMediaData && !sSelf->_paused) {
                if (sSelf->_audioInputReadyCallback &&
                    !sSelf->_audioInputReadyCallback() &&
                    !sSelf->_audioEncodingIsFinished) {
                    runAsynchronouslyOnContextQueue(sSelf->_movieWriterContext, ^{
                        if(sSelf->_assetWriter.status == AVAssetWriterStatusWriting && !sSelf->_audioEncodingIsFinished) {
                            sSelf->_audioEncodingIsFinished = YES;
                            [sSelf->_assetWriterAudioInput markAsFinished];
                        }
                    });
                }
            }
            NSLog(@"audio requestMediaDataWhenReadyOnQueue end");
        }];
    }
    
}

#pragma mark - Frame rendering

- (void)createDataFBO {
    glActiveTexture(GL_TEXTURE1);
    glGenFramebuffers(1, &_movieFramebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _movieFramebuffer);
    
    if ([GPUImageContext supportsFastTextureUpload]) {
        // Code originally sourced from http://allmybrain.com/2011/12/08/rendering-to-a-texture-with-ios-5-texture-cache-api/
        CVPixelBufferPoolCreatePixelBuffer (NULL,
                                            [_assetWriterPixelBufferInput pixelBufferPool],
                                            &_renderTarget);

        /* AVAssetWriter will use BT.601 conversion matrix for RGB to YCbCr conversion
         * regardless of the kCVImageBufferYCbCrMatrixKey value.
         * Tagging the resulting video file as BT.601, is the best option right now.
         * Creating a proper BT.709 video is not possible at the moment.
         */
        CVBufferSetAttachment(_renderTarget,
                              kCVImageBufferColorPrimariesKey,
                              kCVImageBufferColorPrimaries_ITU_R_709_2,
                              kCVAttachmentMode_ShouldPropagate);
        CVBufferSetAttachment(_renderTarget,
                              kCVImageBufferYCbCrMatrixKey,
                              kCVImageBufferYCbCrMatrix_ITU_R_601_4,
                              kCVAttachmentMode_ShouldPropagate);
        CVBufferSetAttachment(_renderTarget,
                              kCVImageBufferTransferFunctionKey,
                              kCVImageBufferTransferFunction_ITU_R_709_2,
                              kCVAttachmentMode_ShouldPropagate);
        
        CVOpenGLESTextureCacheCreateTextureFromImage (kCFAllocatorDefault,
                                                      [_movieWriterContext coreVideoTextureCache],
                                                      _renderTarget,
                                                      NULL, // texture attributes
                                                      GL_TEXTURE_2D,
                                                      GL_RGBA, // opengl format
                                                      (int)_videoSize.width,
                                                      (int)_videoSize.height,
                                                      GL_BGRA, // native iOS format
                                                      GL_UNSIGNED_BYTE,
                                                      0,
                                                      &_renderTexture);
        
        glBindTexture(CVOpenGLESTextureGetTarget(_renderTexture), CVOpenGLESTextureGetName(_renderTexture));
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        
        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, CVOpenGLESTextureGetName(_renderTexture), 0);
        
    } else {
        glGenRenderbuffers(1, &_movieRenderbuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, _movieRenderbuffer);
        glRenderbufferStorage(GL_RENDERBUFFER, GL_RGBA8_OES, (int)_videoSize.width, (int)_videoSize.height);
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _movieRenderbuffer);
    }
    
    __unused GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    NSAssert(status == GL_FRAMEBUFFER_COMPLETE, @"Incomplete filter FBO: %d", status);
}

- (void)destroyDataFBO {
    runSynchronouslyOnContextQueue(_movieWriterContext, ^{
        [self->_movieWriterContext useAsCurrentContext];

        if (self->_movieFramebuffer) {
            glDeleteFramebuffers(1, &self->_movieFramebuffer);
            self->_movieFramebuffer = 0;
        }
        
        if (self->_movieRenderbuffer) {
            glDeleteRenderbuffers(1, &self->_movieRenderbuffer);
            self->_movieRenderbuffer = 0;
        }
        
        if ([GPUImageContext supportsFastTextureUpload]) {
            if (self->_renderTexture) {
                CFRelease(self->_renderTexture);
            }
            if (self->_renderTarget) {
                CVPixelBufferRelease(self->_renderTarget);
            }
        }
        
        NSLog(@"JPMovieWriter is destroy.");
    });
}

- (void)setFilterFBO {
    if (!_movieFramebuffer) {
        [self createDataFBO];
    }
    glBindFramebuffer(GL_FRAMEBUFFER, _movieFramebuffer);
    glViewport(0, 0, (int)_videoSize.width, (int)_videoSize.height);
}

- (void)renderAtInternalSizeUsingFramebuffer:(GPUImageFramebuffer *)inputFramebufferToUse {
    [_movieWriterContext useAsCurrentContext];
    [self setFilterFBO];
    
    [_movieWriterContext setContextShaderProgram:_colorSwizzlingProgram];
    
    glClearColor(1.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    // This needs to be flipped to write out to video correctly
    static const GLfloat squareVertices[] = {
        -1.0f, -1.0f,
        1.0f, -1.0f,
        -1.0f,  1.0f,
        1.0f,  1.0f,
    };
    
    const GLfloat *textureCoordinates = [GPUImageFilter textureCoordinatesForRotation:_inputRotation];
    
    glActiveTexture(GL_TEXTURE4);
    glBindTexture(GL_TEXTURE_2D, [inputFramebufferToUse texture]);
    glUniform1i(_colorSwizzlingInputTextureUniform, 4);
    
//    NSLog(@"Movie writer framebuffer: %@", inputFramebufferToUse);
    
    glVertexAttribPointer(_colorSwizzlingPositionAttribute, 2, GL_FLOAT, 0, 0, squareVertices);
    glVertexAttribPointer(_colorSwizzlingTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    glFinish();
}

#pragma mark - GPUImageInput protocol

- (void)newFrameReadyAtTime:(CMTime)frameTime atIndex:(NSInteger)textureIndex {
    if (!_isRecording || _paused) {
        [_firstInputFramebuffer unlock];
        return;
    }
    
    if (_discont) {
        _discont = NO;
        CMTime current;
        
        if (_offsetTime.value > 0) {
            current = CMTimeSubtract(frameTime, _offsetTime);
        } else {
            current = frameTime;
        }
        
        CMTime offset  = CMTimeSubtract(current, _previousFrameTime);
        
        if (_offsetTime.value == 0) {
            _offsetTime = offset;
        } else {
            _offsetTime = CMTimeAdd(_offsetTime, offset);
        }
    }
    
    if (_offsetTime.value > 0) {
        frameTime = CMTimeSubtract(frameTime, _offsetTime);
    }

    // Drop frames forced by images and other things with no time constants
    // Also, if two consecutive times with the same value are added to the movie, it aborts recording, so I bail on that case
    if ((CMTIME_IS_INVALID(frameTime)) ||
        (CMTIME_COMPARE_INLINE(frameTime, ==, _previousFrameTime)) ||
        (CMTIME_IS_INDEFINITE(frameTime))) {
        [_firstInputFramebuffer unlock];
        return;
    }

    if (CMTIME_IS_INVALID(_startTime)) {
        __weak typeof(self) wSelf = self;
        runSynchronouslyOnContextQueue(_movieWriterContext, ^{
            __strong typeof(wSelf) sSelf = wSelf;
            if (!sSelf) return;
            
            if ((sSelf->_videoInputReadyCallback == nil) &&
                (sSelf->_assetWriter.status != AVAssetWriterStatusWriting)) {
                [sSelf->_assetWriter startWriting];
            }
            
            [sSelf->_assetWriter startSessionAtSourceTime:frameTime];
            sSelf->_startTime = frameTime;
        });
    }

    GPUImageFramebuffer *inputFramebufferForBlock = _firstInputFramebuffer;
    glFinish();

    __weak typeof(self) wSelf = self;
    runAsynchronouslyOnContextQueue(_movieWriterContext, ^{
        __strong typeof(wSelf) sSelf = wSelf;
        if (!sSelf) return;
        
        if (!sSelf->_assetWriterVideoInput.readyForMoreMediaData && sSelf->_encodingLiveVideo) {
            [inputFramebufferForBlock unlock];
            NSLog(@"1: Had to drop a video frame: %@", CFBridgingRelease(CMTimeCopyDescription(kCFAllocatorDefault, frameTime)));
            return;
        }
        
        // Render the frame with swizzled colors, so that they can be uploaded quickly as BGRA frames
        [sSelf->_movieWriterContext useAsCurrentContext];
        [sSelf renderAtInternalSizeUsingFramebuffer:inputFramebufferForBlock];
        
        CVPixelBufferRef pixel_buffer = NULL;
        
        if ([GPUImageContext supportsFastTextureUpload]) {
            pixel_buffer = sSelf->_renderTarget;
            CVPixelBufferLockBaseAddress(pixel_buffer, 0);
        } else {
            CVReturn status = CVPixelBufferPoolCreatePixelBuffer (NULL, [sSelf->_assetWriterPixelBufferInput pixelBufferPool], &pixel_buffer);
            if ((pixel_buffer == NULL) || (status != kCVReturnSuccess)) {
                CVPixelBufferRelease(pixel_buffer);
                return;
            } else {
                CVPixelBufferLockBaseAddress(pixel_buffer, 0);
                GLubyte *pixelBufferData = (GLubyte *)CVPixelBufferGetBaseAddress(pixel_buffer);
                glReadPixels(0, 0, sSelf->_videoSize.width, sSelf->_videoSize.height, GL_RGBA, GL_UNSIGNED_BYTE, pixelBufferData);
            }
        }
        
        while (!sSelf->_assetWriterVideoInput.readyForMoreMediaData &&
               !sSelf->_encodingLiveVideo &&
               !sSelf->_videoEncodingIsFinished) {
            NSDate *maxDate = [NSDate dateWithTimeIntervalSinceNow:0.1];
            // NSLog(@"video waiting...");
            [[NSRunLoop currentRunLoop] runUntilDate:maxDate];
        }
        
        if (!sSelf->_assetWriterVideoInput.readyForMoreMediaData) {
            NSLog(@"2: Had to drop a video frame: %@", CFBridgingRelease(CMTimeCopyDescription(kCFAllocatorDefault, frameTime)));
        
        } else if(sSelf->_assetWriter.status == AVAssetWriterStatusWriting) {
            if (![sSelf->_assetWriterPixelBufferInput appendPixelBuffer:pixel_buffer withPresentationTime:frameTime]) {
                NSLog(@"Problem appending pixel buffer at time: %@", CFBridgingRelease(CMTimeCopyDescription(kCFAllocatorDefault, frameTime)));
            }
            
            // jp_修改GPUImage：解决<<视频第一帧会黑屏>>的问题
            sSelf->_allowWriteAudio = YES;
        } else {
            NSLog(@"Couldn't write a frame");
            //NSLog(@"Wrote a video frame: %@", CFBridgingRelease(CMTimeCopyDescription(kCFAllocatorDefault, frameTime)));
        }
        
        CVPixelBufferUnlockBaseAddress(pixel_buffer, 0);
        
        sSelf->_previousFrameTime = frameTime;
        
        if (![GPUImageContext supportsFastTextureUpload]) {
            CVPixelBufferRelease(pixel_buffer);
        }
        
        [inputFramebufferForBlock unlock];
    });
}

- (NSInteger)nextAvailableTextureIndex {
    return 0;
}

- (void)setInputFramebuffer:(GPUImageFramebuffer *)newInputFramebuffer atIndex:(NSInteger)textureIndex {
    [newInputFramebuffer lock];
    _firstInputFramebuffer = newInputFramebuffer;
}

- (void)setInputRotation:(GPUImageRotationMode)newInputRotation atIndex:(NSInteger)textureIndex {
    _inputRotation = newInputRotation;
}

- (void)setInputSize:(CGSize)newSize atIndex:(NSInteger)textureIndex {}

- (CGSize)maximumOutputSize {
    return _videoSize;
}

- (void)endProcessing {
    if (_completionBlock) {
        if (!_alreadyFinishedRecording) {
            _alreadyFinishedRecording = YES;
            _completionBlock();
        }
    } else {
        if (_delegate && [_delegate respondsToSelector:@selector(movieRecordingCompleted)]) {
            [_delegate movieRecordingCompleted];
        }
    }
}

- (BOOL)shouldIgnoreUpdatesToThisTarget {
    return NO;
}

- (BOOL)wantsMonochromeInput {
    return NO;
}

- (void)setCurrentlyReceivingMonochromeInput:(BOOL)newValue {}

#pragma mark - Accessors

- (void)setHasAudioTrack:(BOOL)newValue {
    [self setHasAudioTrack:newValue audioSettings:nil];
}

- (void)setHasAudioTrack:(BOOL)newValue audioSettings:(NSDictionary *)audioOutputSettings {
    _hasAudioTrack = newValue;
    
    if (!_hasAudioTrack) {
        // Remove audio track if it exists
        return;
    }
    
    if (_shouldPassthroughAudio) {
        // Do not set any settings so audio will be the same as passthrough
        audioOutputSettings = nil;
        
    } else if (audioOutputSettings == nil) {
        AVAudioSession *sharedAudioSession = [AVAudioSession sharedInstance];
        double preferredHardwareSampleRate;
        
        if ([sharedAudioSession respondsToSelector:@selector(sampleRate)]) {
            preferredHardwareSampleRate = [sharedAudioSession sampleRate];
        } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            preferredHardwareSampleRate = [[AVAudioSession sharedInstance] currentHardwareSampleRate];
#pragma clang diagnostic pop
        }
        
        AudioChannelLayout acl;
        bzero( &acl, sizeof(acl));
        acl.mChannelLayoutTag = kAudioChannelLayoutTag_Mono;
        
        audioOutputSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithInt:kAudioFormatMPEG4AAC], AVFormatIDKey,
                                     [NSNumber numberWithInt:1], AVNumberOfChannelsKey,
                                     [NSNumber numberWithFloat:preferredHardwareSampleRate], AVSampleRateKey,
                                     [NSData dataWithBytes:&acl length:sizeof(acl)], AVChannelLayoutKey,
                                     //[NSNumber numberWithInt:AVAudioQualityLow], AVEncoderAudioQualityKey,
                                     [NSNumber numberWithInt:64000], AVEncoderBitRateKey,
                                     nil];
/*
        AudioChannelLayout acl;
        bzero( &acl, sizeof(acl));
        acl.mChannelLayoutTag = kAudioChannelLayoutTag_Mono;
        
        audioOutputSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                               [ NSNumber numberWithInt: kAudioFormatMPEG4AAC ], AVFormatIDKey,
                               [ NSNumber numberWithInt: 1 ], AVNumberOfChannelsKey,
                               [ NSNumber numberWithFloat: 44100.0 ], AVSampleRateKey,
                               [ NSNumber numberWithInt: 64000 ], AVEncoderBitRateKey,
                               [ NSData dataWithBytes: &acl length: sizeof( acl ) ], AVChannelLayoutKey,
                               nil];*/
    }
    
    _assetWriterAudioInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:audioOutputSettings];
    _assetWriterAudioInput.expectsMediaDataInRealTime = _encodingLiveVideo;
}

- (NSArray*)metaData {
    return _assetWriter.metadata;
}

- (void)setMetaData:(NSArray*)metaData {
    _assetWriter.metadata = metaData;
}
 
- (CMTime)duration {
    if(!CMTIME_IS_VALID(_startTime)) return kCMTimeZero;
    if(!CMTIME_IS_NEGATIVE_INFINITY(_previousFrameTime)) return CMTimeSubtract(_previousFrameTime, _startTime);
    if(!CMTIME_IS_NEGATIVE_INFINITY(_previousAudioTime)) return CMTimeSubtract(_previousAudioTime, _startTime);
    return kCMTimeZero;
}

- (CGAffineTransform)transform {
    return _assetWriterVideoInput.transform;
}

- (void)setTransform:(CGAffineTransform)transform {
    _assetWriterVideoInput.transform = transform;
}

- (void)setPaused:(BOOL)paused {
    if (_paused == paused) return;
    _paused = paused;
    if (paused) _discont = YES;
}

- (CMSampleBufferRef)adjustTime:(CMSampleBufferRef)sample by:(CMTime)offset {
    CMItemCount count;
    CMSampleBufferGetSampleTimingInfoArray(sample, 0, nil, &count);
    CMSampleTimingInfo* pInfo = malloc(sizeof(CMSampleTimingInfo) * count);
    CMSampleBufferGetSampleTimingInfoArray(sample, count, pInfo, &count);
    
    for (CMItemCount i = 0; i < count; i++) {
        pInfo[i].decodeTimeStamp = CMTimeSubtract(pInfo[i].decodeTimeStamp, offset);
        pInfo[i].presentationTimeStamp = CMTimeSubtract(pInfo[i].presentationTimeStamp, offset);
    }
    
    CMSampleBufferRef sout;
    CMSampleBufferCreateCopyWithNewTiming(nil, sample, count, pInfo, &sout);
    free(pInfo);
    
    return sout;
}

@end

