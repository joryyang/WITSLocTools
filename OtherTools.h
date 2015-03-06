//
//  OtherTools.h
//  LocTools
//
//  Created by admin on 9/10/14.
//  Copyright (c) 2014 admin. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface OtherTools : NSWindowController

@property(nonatomic) NSInteger index;
@property(nonatomic,retain) NSMutableData *waitingDataBuffer;
@property(strong) NSString *resourcePath;
@property(nonatomic,strong)NSFileManager *filemanager;
@property(nonatomic) NSString *selectProj;

- (IBAction)chooseTools:(id)sender;
- (IBAction)openFolder1:(id)sender;
- (IBAction)openFolder2:(id)sender;
- (IBAction)runCompareFolder:(id)sender;
- (IBAction)saveCompareFolder:(id)sender;
- (IBAction)openFolder3:(id)sender;
- (IBAction)openFolder4:(id)sender;
- (IBAction)openFolder5:(id)sender;
- (IBAction)openFolder6:(id)sender;
- (IBAction)openFolder7:(id)sender;
- (IBAction)openFolder8:(id)sender;
- (IBAction)selectCompressor:(id)sender;
- (IBAction)selectMotion:(id)sender;
- (IBAction)selectProEditor:(id)sender;
- (IBAction)openFolder9:(id)sender;
- (IBAction)openFolder10:(id)sender;
- (IBAction)openFolder11:(id)sender;





@property (strong) IBOutlet NSTabView *toolsTab;
@property (strong) IBOutlet NSTextView *showLogs;
@property (strong) IBOutlet NSTextField *compareFolder1;
@property (strong) IBOutlet NSTextField *compareFolder2;
@property (strong) IBOutlet NSTextField *targetPath;
@property (strong) IBOutlet NSTextField *compareFolder3;
@property (strong) IBOutlet NSTextField *compareFolder4;
@property (strong) IBOutlet NSPopUpButton *selectPopBtn;
@property (strong) IBOutlet NSTextField *folder5;
@property (strong) IBOutlet NSTextField *folder6;
@property (strong) IBOutlet NSTextField *folder7;
@property (strong) IBOutlet NSButton *compressorCheck;
@property (strong) IBOutlet NSButton *motionCheck;
@property (strong) IBOutlet NSButton *proEditorCheck;
@property (strong) IBOutlet NSTextField *handlePath;
@property (strong) IBOutlet NSTextField *handleTarget1;
@property (strong) IBOutlet NSTextField *handleTarget2;
@property (strong) IBOutlet NSTextField *folder8;
@property (strong) IBOutlet NSTextField *folder9;
@property (strong) IBOutlet NSTextField *folder10;
@property (strong) IBOutlet NSButton *btnClick1;
@property (strong) IBOutlet NSButton *btnClick2;
@property (strong) IBOutlet NSButton *btnClick3;

@end
