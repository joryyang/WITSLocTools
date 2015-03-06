//
//  OtherTools.m
//  LocTools
//
//  Created by admin on 9/10/14.
//  Copyright (c) 2014 admin. All rights reserved.
//

#import "OtherTools.h"

@interface OtherTools ()

@end

@implementation OtherTools

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    _waitingDataBuffer=[[NSMutableData alloc]initWithCapacity:2048];
    _resourcePath = [[NSBundle mainBundle]resourcePath];
    [self setEleState:1 andState2:0 andState3:0];
    [self setShowHidden:YES andFlag2:YES andFlag3:YES andFlag4:NO andFlag5:NO andFlag6:NO andFlag7:YES andFlag8:YES andFlag9:YES];
    _selectProj=@"Compressor";
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

-(void)setEleState:(NSInteger)state1 andState2:(NSInteger)state2 andState3:(NSInteger)state3
{
    _compressorCheck.state=state1;
    _motionCheck.state=state2;
    _proEditorCheck.state=state3;
}

-(void)setShowHidden:(BOOL)flag1 andFlag2:(BOOL)flag2 andFlag3:(BOOL)flag3 andFlag4:(BOOL)flag4 andFlag5:(BOOL)flag5 andFlag6:(BOOL)flag6 andFlag7:(BOOL)flag7 andFlag8:(BOOL)flag8 andFlag9:(BOOL)flag9
{
    [_handlePath setHidden:flag1];
    [_folder8 setHidden:flag2];
    [_btnClick1 setHidden:flag3];
    [_handleTarget1 setHidden:flag4];
    [_folder9 setHidden:flag5];
    [_btnClick2 setHidden:flag6];
    [_handleTarget2 setHidden:flag7];
    [_folder10 setHidden:flag8];
    [_btnClick3 setHidden:flag9];
}


- (IBAction)chooseTools:(id)sender {
    NSPopUpButton *button=(NSPopUpButton *)sender;
    NSInteger tabIndex=[button indexOfItem:[button selectedItem]];
    _index=tabIndex;
    NSString *identifier=[NSString stringWithFormat:@"tabview%ld",tabIndex+1];
    [_toolsTab selectTabViewItemWithIdentifier:identifier];
}

- (IBAction)openFolder1:(id)sender {
    NSOpenPanel *foler1=[NSOpenPanel openPanel];
    [foler1 setCanChooseDirectories:YES];
    [foler1 setCanChooseFiles:YES];
    [foler1 setAllowsMultipleSelection:NO];
    [foler1 setTreatsFilePackagesAsDirectories:NO];
    [foler1 beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        if (result==NSOKButton) {
            NSString *file=[[foler1.URLs objectAtIndex:0] path];
            _compareFolder1.stringValue=file;
        }
    }];
}

- (IBAction)openFolder2:(id)sender {
    NSOpenPanel *foler1=[NSOpenPanel openPanel];
    [foler1 setCanChooseDirectories:YES];
    [foler1 setCanChooseFiles:YES];
    [foler1 setAllowsMultipleSelection:NO];
    [foler1 setTreatsFilePackagesAsDirectories:NO];
    [foler1 beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        if (result==NSOKButton) {
            NSString *file=[[foler1.URLs objectAtIndex:0] path];
            _compareFolder2.stringValue=file;
        }
    }];
}

-(void)createFolder
{
    NSString *folderPath=@"/Volumes/ProjectsHD/CompareFolder";
    BOOL isfile=NO;
    _filemanager=[NSFileManager defaultManager];
    if ([_filemanager fileExistsAtPath:folderPath isDirectory:&isfile]) {
        if (isfile==NO) {
            NSLog(@"1111");
            NSArray *arguments=[NSArray arrayWithObjects:@"isnill", nil];
            [self runingProgress:@"createFolder.sh" andArguments:arguments];
        }
        else{
            NSLog(@"2222");
            NSArray *arguments=[NSArray arrayWithObjects:@"isnill", nil];
            [self runingProgress:@"clearFolder.sh" andArguments:arguments];
            [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(createCompareFolder) userInfo:nil repeats:NO];
        }
    }
    if (![_filemanager fileExistsAtPath:folderPath isDirectory:&isfile]){
        NSArray *arguments=[NSArray arrayWithObjects:@"isnill", nil];
        [self runingProgress:@"createFolder.sh" andArguments:arguments];
    }
}

-(void)createCompareFolder
{
    NSArray *arguments1=[NSArray arrayWithObjects:@"isnill", nil];
    [self runingProgress:@"createCompareFolder.sh" andArguments:arguments1];
}

-(void)compareFile
{
    NSString *file1=_compareFolder1.stringValue;
    NSString *file2=_compareFolder2.stringValue;
    if ([file1 hasSuffix:@".xliff"]) {
        NSArray *arguments=[NSArray arrayWithObjects:@"-compareXliffFile",@"-file",file1,@"-file2",file2, nil];
        [self runingProgress:@"AALocCommand_Org" andArguments:arguments];
    }
    else{
        [self createFolder];
        [NSTimer scheduledTimerWithTimeInterval:1.2 target:self selector:@selector(compareTempFolder) userInfo:nil repeats:NO];
    }
}

-(void)compareTempFolder
{
    NSString *file1=_compareFolder1.stringValue;
    NSString *file2=_compareFolder2.stringValue;
    NSString *path1=@"/Volumes/ProjectsHD/CompareFolder/folder1";
    NSString *path2=@"/Volumes/ProjectsHD/CompareFolder/folder2";
    NSString *temp1=[NSString stringWithFormat:@"cp %@ %@",file1,path1];
    NSString *temp2=[NSString stringWithFormat:@"cp %@ %@",file2,path2];
    const char *command1=[temp1 UTF8String];
    const char *command2=[temp2 UTF8String];
    system(command1);
    system(command2);
    NSArray *arguments=[NSArray arrayWithObjects:@"-comparefolder",@"-folder",path1,@"-folder2",path2, nil];
    [self runingProgress:@"AALocCommand_Org" andArguments:arguments];
}

-(void)compareFolder
{
    NSString *foler3=_compareFolder3.stringValue;
    NSString *foler4=_compareFolder4.stringValue;
    NSArray *arguments=[NSArray arrayWithObjects:@"-comparefolder",@"-folder",foler3,@"-folder2",foler4, nil];
    [self runingProgress:@"AALocCommand_Org" andArguments:arguments];
}

-(void)runCheckVariables
{
    NSString *tarPath=_targetPath.stringValue;
    NSString *command=@"parameterstester.py";
    NSArray *arguments=[NSArray arrayWithObjects:tarPath, nil];
    [self runingProgress:command andArguments:arguments];
}

-(void)runCompareXliff
{
    NSString *path1=_folder5.stringValue;
    NSString *path2=_folder6.stringValue;
    NSString *command=@"xliffdiffer_lite.py";
    NSArray *arguments=[NSArray arrayWithObjects:path1,path2, nil];
    [self runingProgress:command andArguments:arguments];
}

- (IBAction)runCompareFolder:(id)sender {
    _showLogs.string=@"";
    NSInteger tabIndex=[_selectPopBtn indexOfItem:[_selectPopBtn selectedItem]];
    if (tabIndex==0) {
        [self compareFile];
    }
    if (tabIndex==1) {
        [self compareFolder];
    }
    if (tabIndex==2) {
        [self runCheckVariables];
    }
    if (tabIndex==3) {
        [self runCompareXliff];
    }
    if (tabIndex==4) {
        [self runCheckXliffState];
    }
    if (tabIndex==5) {
        if ([_selectProj isEqualToString:@"Compressor"]) {
            [self runCompressor];
        }
        if ([_selectProj isEqualToString:@"Motion"]) {
            [self runMotion];
        }
        if ([_selectProj isEqualToString:@"ProEditor"]) {
            [self runProEditor];
        }
    }
}

-(void)runCompressor
{
    if ([_folder9.stringValue isEqualToString:@""]) {
        NSRunAlertPanel(@"提示信息", @"请填写NewLocFolder的路径", @"确定", @"", nil);
    }
    else{
        NSString *command=@"ProAppDitto.py";
        NSString *path=_folder9.stringValue;
        NSArray *arguments=[NSArray arrayWithObjects:path, nil];
        [self runingProgress:command andArguments:arguments];
    }
}

-(void)runMotion
{
    if ([_folder8.stringValue isEqualToString:@""] || [_folder10.stringValue isEqualToString:@""]) {
        NSRunAlertPanel(@"提示信息", @"请填写Tarball或NewLocFolder的路径", @"确定", @"", nil);
    }
    else{
        NSString *command=@"ProAppDitto.py";
        NSString *path=_folder8.stringValue;
        NSString *path1=_folder10.stringValue;
        NSArray *arguments=[NSArray arrayWithObjects:path,path1, nil];
        [self runingProgress:command andArguments:arguments];
    }
}

-(void)runProEditor
{
    if ([_folder8.stringValue isEqualToString:@""] || [_folder10.stringValue isEqualToString:@""]) {
        NSRunAlertPanel(@"提示信息", @"请填写TarballFolder或NewLocFolder的路径", @"确定", @"", nil);
    }
    else{
        NSString *command=@"ProAppDitto.py";
        NSString *path=_folder8.stringValue;
        NSString *path1=_folder10.stringValue;
        NSArray *arguments=[NSArray arrayWithObjects:path,path1, nil];
        [self runingProgress:command andArguments:arguments];
    }
}

-(void)runCheckXliffState
{
    NSString *path1=_folder7.stringValue;
    NSString *command=@"xliffState.py";
    NSArray *arguments=[NSArray arrayWithObjects:path1, nil];
    [self runingProgress:command andArguments:arguments];
}

- (IBAction)saveCompareFolder:(id)sender {
    NSSavePanel *folder=[NSSavePanel savePanel];
    [folder setCanCreateDirectories:YES];
    [folder setCanSelectHiddenExtension:YES];
    [folder setNameFieldStringValue:@"未命名.txt"];
    [folder setDirectoryURL:[NSURL URLWithString:@"/Users/admin/Desktop/"]];
    [folder beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        if (result==NSFileHandlingPanelOKButton) {
            NSString *path=[[folder URL]path];
            NSString *tmp=_showLogs.string;
            [tmp writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
        }
    }];
}

- (IBAction)openFolder3:(id)sender {
    NSOpenPanel *foler3=[NSOpenPanel openPanel];
    [foler3 setCanChooseDirectories:YES];
    [foler3 setCanChooseFiles:YES];
    [foler3 setAllowsMultipleSelection:NO];
    [foler3 setTreatsFilePackagesAsDirectories:NO];
    [foler3 beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        if (result==NSOKButton) {
            NSString *file=[[foler3.URLs objectAtIndex:0] path];
            _compareFolder3.stringValue=file;
        }
    }];
}

- (IBAction)openFolder4:(id)sender {
    NSOpenPanel *foler4=[NSOpenPanel openPanel];
    [foler4 setCanChooseDirectories:YES];
    [foler4 setCanChooseFiles:YES];
    [foler4 setAllowsMultipleSelection:NO];
    [foler4 setTreatsFilePackagesAsDirectories:NO];
    [foler4 beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        if (result==NSOKButton) {
            NSString *file=[[foler4.URLs objectAtIndex:0] path];
            _compareFolder4.stringValue=file;
        }
    }];
}

- (IBAction)openFolder5:(id)sender {
    NSOpenPanel *foler5=[NSOpenPanel openPanel];
    [foler5 setCanChooseDirectories:YES];
    [foler5 setCanChooseFiles:YES];
    [foler5 setAllowsMultipleSelection:NO];
    [foler5 setTreatsFilePackagesAsDirectories:NO];
    [foler5 beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        if (result==NSOKButton) {
            NSString *file=[[foler5.URLs objectAtIndex:0] path];
            _targetPath.stringValue=file;
        }
    }];
}

- (IBAction)openFolder6:(id)sender {
    NSOpenPanel *foler6=[NSOpenPanel openPanel];
    [foler6 setCanChooseDirectories:YES];
    [foler6 setCanChooseFiles:YES];
    [foler6 setAllowsMultipleSelection:NO];
    [foler6 setTreatsFilePackagesAsDirectories:NO];
    [foler6 beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        if (result==NSOKButton) {
            NSString *file=[[foler6.URLs objectAtIndex:0] path];
            _folder5.stringValue=file;
        }
    }];
}

- (IBAction)openFolder7:(id)sender {
    NSOpenPanel *foler7=[NSOpenPanel openPanel];
    [foler7 setCanChooseDirectories:YES];
    [foler7 setCanChooseFiles:YES];
    [foler7 setAllowsMultipleSelection:NO];
    [foler7 setTreatsFilePackagesAsDirectories:NO];
    [foler7 beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        if (result==NSOKButton) {
            NSString *file=[[foler7.URLs objectAtIndex:0] path];
            _folder6.stringValue=file;
        }
    }];
}

- (IBAction)openFolder8:(id)sender {
    NSOpenPanel *foler8=[NSOpenPanel openPanel];
    [foler8 setCanChooseDirectories:YES];
    [foler8 setCanChooseFiles:YES];
    [foler8 setAllowsMultipleSelection:NO];
    [foler8 setTreatsFilePackagesAsDirectories:NO];
    [foler8 beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        if (result==NSOKButton) {
            NSString *file=[[foler8.URLs objectAtIndex:0] path];
            _folder7.stringValue=file;
        }
    }];
}

- (IBAction)selectCompressor:(id)sender {
    [self setEleState:1 andState2:0 andState3:0];
    [self setShowHidden:YES andFlag2:YES andFlag3:YES andFlag4:NO andFlag5:NO andFlag6:NO andFlag7:YES andFlag8:YES andFlag9:YES];
    _selectProj=@"Compressor";
}

- (IBAction)selectMotion:(id)sender {
    [self setEleState:0 andState2:1 andState3:0];
    [self setShowHidden:NO andFlag2:NO andFlag3:NO andFlag4:YES andFlag5:YES andFlag6:YES andFlag7:NO andFlag8:NO andFlag9:NO];
    _handlePath.stringValue=@"Tarball路径:";
    _selectProj=@"Motion";
}

- (IBAction)selectProEditor:(id)sender {
    [self setEleState:0 andState2:0 andState3:1];
    [self setShowHidden:NO andFlag2:NO andFlag3:NO andFlag4:YES andFlag5:YES andFlag6:YES andFlag7:NO andFlag8:NO andFlag9:NO];
    _handlePath.stringValue=@"TarballFolder:";
    _selectProj=@"ProEditor";
}

- (IBAction)openFolder9:(id)sender {
    NSOpenPanel *foler8=[NSOpenPanel openPanel];
    [foler8 setCanChooseDirectories:YES];
    [foler8 setCanChooseFiles:YES];
    [foler8 setAllowsMultipleSelection:NO];
    [foler8 setTreatsFilePackagesAsDirectories:NO];
    [foler8 beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        if (result==NSOKButton) {
            NSString *file=[[foler8.URLs objectAtIndex:0] path];
            _folder8.stringValue=file;
        }
    }];
}

- (IBAction)openFolder10:(id)sender {
    NSOpenPanel *foler8=[NSOpenPanel openPanel];
    [foler8 setCanChooseDirectories:YES];
    [foler8 setCanChooseFiles:YES];
    [foler8 setAllowsMultipleSelection:NO];
    [foler8 setTreatsFilePackagesAsDirectories:NO];
    [foler8 beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        if (result==NSOKButton) {
            NSString *file=[[foler8.URLs objectAtIndex:0] path];
            _folder9.stringValue=file;
        }
    }];
}

- (IBAction)openFolder11:(id)sender {
    NSOpenPanel *foler8=[NSOpenPanel openPanel];
    [foler8 setCanChooseDirectories:YES];
    [foler8 setCanChooseFiles:YES];
    [foler8 setAllowsMultipleSelection:NO];
    [foler8 setTreatsFilePackagesAsDirectories:NO];
    [foler8 beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        if (result==NSOKButton) {
            NSString *file=[[foler8.URLs objectAtIndex:0] path];
            _folder10.stringValue=file;
        }
    }];
}

-(void)runingProgress:(NSString *)command andArguments:(NSArray *)arguments
{
    NSTask *task=[[NSTask alloc]init];
    [task setStandardOutput:[[NSPipe alloc]init]];
    [task setStandardInput:[[NSPipe alloc]init]];
    [task setStandardError: [task standardOutput]];
    NSString *commandPath=[NSString stringWithFormat:@"%@/%@",_resourcePath,command];
    [task setLaunchPath:commandPath];
    [task setArguments:arguments];
    [[NSNotificationCenter defaultCenter]addObserver: self
                                            selector: @selector(getData:)
                                                name: NSFileHandleReadCompletionNotification
                                              object: [[task standardOutput] fileHandleForReading]];
    [[[task standardOutput] fileHandleForReading] readInBackgroundAndNotify];
    [task launch];
}

- (void) getData: (NSNotification *)aNotification
{
    NSData *data = [[aNotification userInfo] objectForKey:NSFileHandleNotificationDataItem];
    if ([data length])
    {
		[_waitingDataBuffer appendData:data];
        NSString *stringFromPlugin = [[NSString alloc] initWithData:_waitingDataBuffer encoding:NSUTF8StringEncoding];
        if ((stringFromPlugin != nil) && (![stringFromPlugin isEqualToString:@""]))
        {
            [_showLogs insertText:stringFromPlugin];
            [_waitingDataBuffer setLength:0];
        }
        
        [[aNotification object] readInBackgroundAndNotify];
    }
}

@end
