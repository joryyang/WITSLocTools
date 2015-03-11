//
//  AppDelegate.h
//  LocTools
//
//  Created by admin on 5/2/14.
//  Copyright (c) 2014 admin. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AVFoundation/AVFoundation.h>
#import "OtherTools.h"

@class ChatViewController,RoomViewController;

@interface AppDelegate : NSObject <NSApplicationDelegate,NSTableViewDataSource,NSTableViewDelegate>

/*变量定义*/
@property(nonatomic,retain) NSString *mainPath;
@property(nonatomic,retain) NSFileManager *fileManager;
@property(strong) NSArray *items;
@property(strong) NSString *selectedMainItem;
@property(strong) NSString *selectedSubItem;
@property(strong) NSString *projPath;
@property(strong) NSString *glotPath;
@property(assign) int theSelectedIndex;
@property(assign) int flag;
@property(nonatomic,retain) NSMutableData *waitingDataBuffer;
@property(strong) NSString *resourcePath;
@property(nonatomic,assign) NSColor *defaultColor;
@property(assign) int timeFlagTemp;
@property(assign) int runTimes;
@property (nonatomic) int startOrEnd;
@property(nonatomic,retain) NSTask *task;
@property (nonatomic,strong)NSArray *keyWords;
@property (nonatomic ,assign) int AGState;
/***************************************************/

/*IBOutlet*/
@property (strong) IBOutlet NSPopUpButton *MainItem;
@property (strong) IBOutlet NSPopUpButton *SubItem;
@property (strong) IBOutlet NSTableView *myTextView;
@property (assign) IBOutlet NSWindow *window;
@property (strong) IBOutlet NSTextView *ShowLogs;
@property (strong) IBOutlet NSPanel *bugFixPanel;
@property (strong) IBOutlet NSPanel *projSelectPanel;
@property (strong) IBOutlet NSPanel *isOrNotAGPanel;
@property (strong) IBOutlet NSWindow *canISubmitPanel;
@property (strong) IBOutlet NSWindow *alertWindow;
@property (strong) IBOutlet NSWindow *clippingResult;

@property (strong) IBOutlet NSWindow *submitWindow;
@property (strong) IBOutlet NSWindow *warningWindow;

@property (strong) IBOutlet NSPopUpButton *AAdirector;
@property (strong) IBOutlet NSTextView *bugFixList;

@property (strong) IBOutlet NSPopUpButton *popProjName;

@property (strong) IBOutlet NSTextView *reportLog;
@property (strong) IBOutlet NSTextField *alertTitle;
@property (strong) IBOutlet NSTextField *alertDetail;
@property (strong) IBOutlet NSButton *canBeAvailable;
@property (strong) IBOutlet NSButton *OKButton;
@property (strong) IBOutlet NSButton *CancelButton;
@property (strong) IBOutlet NSTextView *clippingLog;

@property (strong) IBOutlet NSButton *AGCheckBox;
@property (strong) IBOutlet NSPopUpButton *submitPop;
@property (weak) IBOutlet NSPopUpButton *prePop;
@property (strong) IBOutlet NSTextField *folderField;
@property (strong) IBOutlet NSTextField *warningLog;
@property (strong) IBOutlet NSProgressIndicator *submissionProgress;


/*Action*/
- (IBAction)ShowMainItem:(id)sender;
- (IBAction)ShowSubItem:(id)sender;
- (IBAction)RunLocTools:(id)sender;
- (IBAction)ExitBugFix:(id)sender;
- (IBAction)continueBugFix:(id)sender;
- (IBAction)exitProjSelect:(id)sender;
- (IBAction)continueProjSelect:(id)sender;
- (IBAction)flashProject:(id)sender;
- (IBAction)canISubmit:(id)sender;
- (IBAction)openReports:(id)sender;
- (IBAction)exitAlertWindow:(id)sender;
- (IBAction)continueAlertWindow:(id)sender;
- (IBAction)okBtnClick:(id)sender;
- (IBAction)beforeRunPcx:(id)sender;
- (IBAction)AGCancelAction:(id)sender;
- (IBAction)AGContinueAction:(id)sender;
- (IBAction)checkClipping:(id)sender;
- (IBAction)cancelSubmit:(id)sender;
- (IBAction)conitnueSubmit:(id)sender;
- (IBAction)warningCancel:(id)sender;
- (IBAction)warningContinue:(id)sender;
- (IBAction)selectSubmitPop:(id)sender;



/***********************Others**************************/
@property (nonatomic,strong)OtherTools *tools;

/*************************MainMenu**********************/
- (IBAction)showWindow:(id)sender;
- (IBAction)hiddenWindow:(id)sender;
- (IBAction)OtherTools:(id)sender;
- (IBAction)hiddenTools:(id)sender;


@end
