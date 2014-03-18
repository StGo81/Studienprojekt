//
//  ViewController.m
//  Studienprojekt
//
// Verwendeter Code aus:
// http://www.raywenderlich.com/3932/networking-tutorial-for-ios-how-to-create-a-socket-based-iphone-app-and-server


#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize inputStream, outputStream;
@synthesize txtFieldIpAddress;
@synthesize txtFieldPort;
@synthesize messages;
@synthesize tView;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    messages = [[NSMutableArray alloc] init];
	
	self.tView.delegate = self;
	self.tView.dataSource = self;


}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

- (void) initNetworkCommunication: (NSString*) ip :(NSInteger) port{
	
	CFReadStreamRef readStream;
	CFWriteStreamRef writeStream;
    
    //Variablen ersetzen siehe IBAction btnConnect
	CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)@"localhost" , port, &readStream, &writeStream);
	inputStream = (__bridge NSInputStream *)readStream;
	outputStream = (__bridge NSOutputStream *)writeStream;
    
	[inputStream setDelegate:self];
	[outputStream setDelegate:self];
	[inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[inputStream open];
	[outputStream open];
	
}


- (IBAction)btnConnect:(id)sender {
    NSString *ipAddress = @"localhost"; //txtFieldIpAddress.text;
    NSInteger eingegebenerPort = 8889; //txtFieldPort.text;
    
    //initNetworkConnection aufrufen und IP sowie Port übergeben
    [self initNetworkCommunication :ipAddress :eingegebenerPort];
    
}

- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent {
    
	NSLog(@"stream event %i", streamEvent);
	
	switch (streamEvent) {
			
		case NSStreamEventOpenCompleted:
			NSLog(@"Stream opened");
			break;
		case NSStreamEventHasBytesAvailable:
            
			if (theStream == inputStream) {
				
				uint8_t buffer[1024];
				int len;
				
				while ([inputStream hasBytesAvailable]) {
					len = [inputStream read:buffer maxLength:sizeof(buffer)];
					if (len > 0) {
						
						NSString *output = [[NSString alloc] initWithBytes:buffer length:len encoding:NSASCIIStringEncoding];
						
						if (nil != output) {
                            
							NSLog(@"server said: %@", output);
							[self messageReceived:output];
							
						}
					}
				}
			}
			break;
            
			
		case NSStreamEventErrorOccurred:
			
			NSLog(@"Can not connect to the host!");
			break;
			
		case NSStreamEventEndEncountered:
            
            [theStream close];
            [theStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            [theStream release];
            theStream = nil;
			
			break;
		default:
			NSLog(@"Unknown event");
	}
    
}

- (void) messageReceived:(NSString *)message {
	
	[self.messages addObject:message];
	[self.tView reloadData];
	NSIndexPath *topIndexPath = [NSIndexPath indexPathForRow:messages.count-1
												   inSection:0];
	[self.tView scrollToRowAtIndexPath:topIndexPath
					  atScrollPosition:UITableViewScrollPositionMiddle
							  animated:YES];
    
}


#pragma mark -
#pragma mark Table delegates

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSString *s = (NSString *) [messages objectAtIndex:indexPath.row];
	
    static NSString *CellIdentifier = @"ChatCellIdentifier";
    
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	
	cell.textLabel.text = s;
	
	return cell;
	
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return messages.count;
}

- (void)dealloc {
    
	[inputStream release];
	[outputStream release];
	[txtFieldIpAddress release];
	[txtFieldPort release];
	[tView release];
    [super dealloc];
	
}

@end
