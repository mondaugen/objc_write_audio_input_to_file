#include <Foundation/Foundation.h>
#include <AVFoundation/AVFoundation.h>
#include <unistd.h> 

int main (void)
{
    AVAudioEngine *aengine = [[AVAudioEngine alloc] init];
    AVAudioFormat *aformat = [[aengine inputNode] outputFormatForBus: 0];
    NSDictionary *afile_settings = [NSDictionary dictionaryWithObjectsAndKeys:
       [NSNumber numberWithInt:kAudioFormatLinearPCM], AVFormatIDKey,
     [NSNumber numberWithFloat: 44100], AVSampleRateKey,
       [NSNumber numberWithInt:2],AVNumberOfChannelsKey,
        nil
    ];
    NSError *anyerr;
   /* It doesn't seem like it works with WAV */ 
    __block AVAudioFile *afile = [[AVAudioFile alloc]
        initForWriting:[NSURL fileURLWithPath:@("/tmp/objy_5.aif")]
              settings:afile_settings commonFormat:aformat.commonFormat interleaved:NO error:&anyerr];
    if (anyerr) {
        NSLog(@"error opening file: %@",[anyerr localizedDescription]);
    }
    [aengine.inputNode installTapOnBus:0 
                            bufferSize:8192 
                                format:aformat
                                 block:^(AVAudioPCMBuffer *buffer, AVAudioTime *when) {
                NSError *locerr = NULL;
                BOOL stat;
                stat = [afile writeFromBuffer:buffer error:&locerr];
                if (stat && locerr) {
                    NSLog(@"error writing to file: %@",[locerr localizedDescription]);
                }
                                 }];
    [aengine startAndReturnError:nil];
    sleep(5);
    [aengine stop];
    afile = nil;
    return 0;
}

