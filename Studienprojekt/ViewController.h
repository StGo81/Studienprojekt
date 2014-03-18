//
//  ViewController.h
//  Studienprojekt
//
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <NSStreamDelegate, UITableViewDelegate>
{
    NSInputStream	*inputStream;
	NSOutputStream	*outputStream;
    UITableView		*tView;
	NSMutableArray	*messages;
}

@property (nonatomic, retain) NSInputStream *inputStream;
@property (nonatomic, retain) NSOutputStream *outputStream;
@property (nonatomic, retain) NSMutableArray *messages;

@property (weak, nonatomic) IBOutlet UITextField *txtFieldIpAddress;
@property (weak, nonatomic) IBOutlet UITextField *txtFieldPort;
@property (weak, nonatomic) IBOutlet UITableView *tView;

- (IBAction)btnConnect:(id)sender;
- (void) initNetworkCommunication: (NSString*) ip :(NSInteger) port;
- (void) messageReceived:(NSString *)message;
@end
