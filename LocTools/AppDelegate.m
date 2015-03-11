//
//  AppDelegate.m
//  LocTools
//
//  Created by admin on 5/2/14.
//  Copyright (c) 2014 admin. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    /***************************检查版本**************************/
    NSString *tempResourcePath=[[NSBundle mainBundle]resourcePath];
    NSString *tempCommand=[NSString stringWithFormat:@"%@/firstopen.py",tempResourcePath];
    NSArray *tempArguments=[NSArray arrayWithObjects:@"isnil", nil];
    [self checkVersion:tempCommand andArguments:tempArguments];
    
    
    /***************************公告******************************/
    NSString *tempResourcePath1=[[NSBundle mainBundle]resourcePath];
    NSString *tempCommand1=[NSString stringWithFormat:@"%@/notice.py",tempResourcePath1];
    NSArray *tempArguments1=[NSArray arrayWithObjects:@"isnil", nil];
    [self showNotice:tempCommand1 andArguments:tempArguments1];
    /***********************************************************/
    
    
    /***************************项目主路径*****************************/
    _mainPath=@"/Volumes/ProjectsHD/_LocProj";
    _fileManager=[NSFileManager defaultManager];
    NSArray *items=[_fileManager contentsOfDirectoryAtPath:_mainPath error:nil];
    NSMutableArray *temp=[NSMutableArray array];
    for (NSString *str in items) {
        if ([str isEqualToString:@".DS_Store"]==0 && str.length>14) {
            [temp addObject:str];
        }
    }
    NSArray *items2=[temp copy];
    _items=[items2 sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSDictionary *dict1=[_fileManager attributesOfItemAtPath:[NSString stringWithFormat:@"%@/%@",_mainPath,obj1] error:nil];
        NSDictionary *dict2=[_fileManager attributesOfItemAtPath:[NSString stringWithFormat:@"%@/%@",_mainPath,obj2] error:nil];
        return [[dict2 objectForKey:NSFileCreationDate] compare:[dict1 objectForKey:NSFileCreationDate]];
    }];
    [_MainItem addItemsWithTitles:_items];
    /***********************************************************/
    
    /****************************项目子路径*************************/
    _selectedMainItem=[_MainItem title];
    NSString *mainPath=[NSString stringWithFormat:@"%@/%@",_mainPath,_selectedMainItem];
    _fileManager=[NSFileManager defaultManager];
    NSArray *tempPath=[_fileManager contentsOfDirectoryAtPath:mainPath error:nil];
    NSMutableArray *temp1=[NSMutableArray array];
    for (NSString *str in tempPath) {
        if ([str hasSuffix:@"GlotKit"] ) {
            [temp1 addObject:str];
        }
    }
    NSArray *items1=[temp1 copy];
    [_SubItem addItemsWithTitles:items1];
    /***********************************************************/
    [self copyAutoFtpFile];
    
    /***************************变量初始化************************/
    _myTextView.delegate=self;
    _myTextView.dataSource=self;
    _theSelectedIndex=-1;
    _flag=-1;
    _timeFlagTemp=-1;
    _runTimes=0;
    _waitingDataBuffer=[[NSMutableData alloc]initWithCapacity:2048];
    _resourcePath = [[NSBundle mainBundle]resourcePath];
    _defaultColor=self.window.backgroundColor;
    
    /************************Others**************************/
    _tools=[[OtherTools alloc]initWithWindowNibName:@"OtherTools"];
    _startOrEnd=-1;
    _keyWords=[NSArray arrayWithObjects:@"ERROR",@"Warning",@"WARNING",@"errk",@"ERRK",@"warning",@"error",@"Error",nil];
    
    /*************************************************/
    _AGState=-1;
    [_submissionProgress setHidden:YES];
    _warningWindow.backgroundColor=[NSColor yellowColor];
}

-(void)timerNotice
{
    NSString *tempResourcePath1=[[NSBundle mainBundle]resourcePath];
    NSString *tempCommand1=[NSString stringWithFormat:@"%@/notice.py",tempResourcePath1];
    NSArray *tempArguments1=[NSArray arrayWithObjects:@"isnil", nil];
    [self showNotice:tempCommand1 andArguments:tempArguments1];
}


-(void)showNotice:(NSString *)command andArguments:(NSArray *)arguments
{
    NSTask *task=[[NSTask alloc]init];
    [task setLaunchPath:command];
    [task setArguments:arguments];
    NSPipe *readPipe=[NSPipe pipe];
    [task setStandardOutput:readPipe];
    NSFileHandle *file=[readPipe fileHandleForReading];
    [task launch];
    NSData *data=[file readDataToEndOfFile];
    NSString *message=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    _ShowLogs.string=message;
    _ShowLogs.font=[NSFont fontWithName:@"Helvetica" size:12];
}

-(void)checkVersion:(NSString *)command andArguments:(NSArray *)arguments
{
    NSTask *task=[[NSTask alloc]init];
    [task setLaunchPath:command];
    [task setArguments:arguments];
    NSPipe *readPipe=[NSPipe pipe];
    [task setStandardOutput:readPipe];
    NSFileHandle *file=[readPipe fileHandleForReading];
    [task launch];
    NSData *data=[file readDataToEndOfFile];
    NSString *message=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    if ([message hasPrefix:@"the version is old"]) {
        NSRunAlertPanel(@"发现新版本！", @"LocTools 2.2.2 已经发布，请点击 “确定” 查看更新内容以及下载最新版本的 LocTools。",@"确定",@"", nil);
        system("open http://10.4.2.6/wiki/pages/D1b8Q7B3/LocTools.html");
        exit(1);
    }
    if ([message hasPrefix:@"Network is unreachable"]) {
        NSRunAlertPanel(@"网络错误", @"请使用公司内部网络来启动本程序。",@"确定",@"", nil);
        exit(1);
    }
}

- (IBAction)ShowMainItem:(id)sender {
    [_SubItem removeAllItems];
    NSPopUpButton *btn=(NSPopUpButton *)sender;
    _selectedMainItem=[btn title];
    NSString *mainPath=[NSString stringWithFormat:@"%@/%@",_mainPath,_selectedMainItem];
    _fileManager=[NSFileManager defaultManager];
    NSArray *tempPath=[_fileManager contentsOfDirectoryAtPath:mainPath error:nil];
    NSMutableArray *temp=[NSMutableArray array];
    for (NSString *str in tempPath) {
        if ([str hasSuffix:@"GlotKit"] ) {
            [temp addObject:str];
        }
    }
    NSArray *items1=[temp copy];
    [_SubItem addItemsWithTitles:items1];
}

- (IBAction)ShowSubItem:(id)sender {
    NSPopUpButton *btn=(NSPopUpButton *)sender;
    _selectedSubItem=[btn title];
}

- (IBAction)RunLocTools:(id)sender {
    _projPath=nil;
    NSString *MainPath=[_MainItem title];
    NSString *SubPath=[_SubItem title];
    _projPath=[NSString stringWithFormat:@"%@/%@/%@/LocEnv",_mainPath,MainPath,SubPath];
    _glotPath=[NSString stringWithFormat:@"%@/%@/%@",_mainPath,MainPath,SubPath];
    if ([SubPath isEqualToString:@""]) {
        NSRunAlertPanel(@"警告:", @"你没有选择项目路径或者项目路径不对！", @"确定",@"",nil);
        _flag=0;
    }
    else{
        _flag=1;
    }
    if (_flag==1) {
        [self LocToolsProgress];
    }
}

- (IBAction)ExitBugFix:(id)sender {
    [NSApp endSheet:_bugFixPanel];
    [_bugFixPanel orderOut:sender];
}


- (IBAction)continueBugFix:(id)sender {
    [NSApp endSheet:_bugFixPanel];
    [_bugFixPanel orderOut:sender];
    NSString *bugfixpath=_projPath;
    NSString *AAdirector = [_AAdirector title];
    NSString *buFixList=[_bugFixList string];
    NSString *command=@"bugfixcomments.py";
    NSArray *arguments=[NSArray arrayWithObjects:bugfixpath,AAdirector,buFixList, nil];
    [self runingProgress:command andArguments:arguments];
    
    NSString *command1=@"client.py";
    NSArray *arguments1=[NSArray arrayWithObjects:_projPath,@"bugfixcomments_UI", nil];
    [self runingProgress:command1 andArguments:arguments1];
    
}


- (IBAction)exitProjSelect:(id)sender {
    [NSApp endSheet:_projSelectPanel];
    [_projSelectPanel orderOut:sender];
}

- (IBAction)continueProjSelect:(id)sender {
    [self startProgress];
    [NSApp endSheet:_projSelectPanel];
    [_projSelectPanel orderOut:sender];
    NSString *command=@"xliffdiffer.py";
    NSString *plugin=nil;
    NSUInteger temp=[_popProjName indexOfItem:[_popProjName selectedItem]];
    if (temp==0) {
        plugin=@"";
    }
    if (temp==1) {
        plugin=@"-g /AppleInternal/Library/EmbeddedFrameworks/ProKit/EmbeddedProKit.ibplugin -g /AppleInternal/Library/EmbeddedFrameworks/ProApps/IBPlugIns/LunaKitEmbedded.ibplugin";
    }
    if (temp==2) {
        plugin=@"-g /AppleInternal/Developer/Plugins/MAToolKitLogicIBPlugIn.ibplugin";
    }
    NSArray *arguments=[NSArray arrayWithObjects:_projPath,plugin, nil];
    [self runingProgress:command andArguments:arguments];
    
    NSString *command1=@"client.py";
    NSArray *arguments1=[NSArray arrayWithObjects:_projPath,@"xliffdiffer_UI", nil];
    [self runingProgress:command1 andArguments:arguments1];
}


- (IBAction)flashProject:(id)sender {
    /*************************************************************/
    [_MainItem removeAllItems];
    /***************************项目主路径*****************************/
    _mainPath=@"/Volumes/ProjectsHD/_LocProj";
    _fileManager=[NSFileManager defaultManager];
    NSArray *items=[_fileManager contentsOfDirectoryAtPath:_mainPath error:nil];
    NSMutableArray *temp=[NSMutableArray array];
    for (NSString *str in items) {
        if ([str isEqualToString:@".DS_Store"]==0 && str.length>14) {
            [temp addObject:str];
        }
    }
    NSArray *items2=[temp copy];
    _items=[items2 sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSDictionary *dict1=[_fileManager attributesOfItemAtPath:[NSString stringWithFormat:@"%@/%@",_mainPath,obj1] error:nil];
        NSDictionary *dict2=[_fileManager attributesOfItemAtPath:[NSString stringWithFormat:@"%@/%@",_mainPath,obj2] error:nil];
        return [[dict2 objectForKey:NSFileCreationDate] compare:[dict1 objectForKey:NSFileCreationDate]];
    }];
    [_MainItem addItemsWithTitles:_items];
    /***********************************************************/
    
    /*************************************************************/
    [_SubItem removeAllItems];
    /****************************项目子路径*************************/
    _selectedMainItem=[_MainItem title];
    NSString *mainPath=[NSString stringWithFormat:@"%@/%@",_mainPath,_selectedMainItem];
    _fileManager=[NSFileManager defaultManager];
    NSArray *tempPath=[_fileManager contentsOfDirectoryAtPath:mainPath error:nil];
    NSMutableArray *temp1=[NSMutableArray array];
    for (NSString *str in tempPath) {
        if ([str hasSuffix:@"GlotKit"] ) {
            [temp1 addObject:str];
        }
    }
    NSArray *items1=[temp1 copy];
    [_SubItem addItemsWithTitles:items1];
}


- (IBAction)canISubmit:(id)sender {
    _reportLog.string=@"";
    NSArray *langs=[NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"countrySelect" ofType:@"plist"]];
    NSString *reportPath=nil;
    NSString *projPathTemp=[NSString stringWithFormat:@"%@/%@/%@/LocEnv",_mainPath,[_MainItem title],[_SubItem title]];
    _fileManager=[NSFileManager defaultManager];
    NSArray *array=[_fileManager contentsOfDirectoryAtPath:projPathTemp error:nil];
    for(NSString *str in array){
        for(NSString *lang in langs){
            NSString *temp=[NSString stringWithFormat:@"Reports_%@",lang];
            if ([str isEqualToString:temp]) {
                reportPath=[NSString stringWithFormat:@"%@/%@/%@/LocEnv/%@",_mainPath,[_MainItem title],[_SubItem title],str];
                break;
            }
        }
    }
    
    NSArray *arguments=[NSArray arrayWithObjects:reportPath, nil];
    NSString *message=[self getResultStringsByTask:@"ScanReports.py" andArgument:arguments];
    NSInteger count=0;
    count=[self CountNumberStrings:message andtarget:@"No problem found"];
    if (count>=3) {
        NSString *result=[self getResultStringsByTask:@"ftpDir.py" andArgument:[NSArray arrayWithObjects:projPathTemp, nil]];
        NSArray *items=[result componentsSeparatedByString:@"\n"];
        NSMutableArray *projs=[NSMutableArray array];
        for(NSString *str in items){
            if (![str isEqualToString:@""]) {
                [projs addObject:str];
            }
        }
        [_submitPop removeAllItems];
        [_submitPop addItemsWithTitles:projs];
        NSString *selectProj=[_submitPop title];
        NSArray *aa=[selectProj componentsSeparatedByString:@" "];
        NSString *final=@"";
        for(NSString *bb in aa){
            if ([final isEqualToString:@""]) {
                final=bb;
            }
            else{
                final=[NSString stringWithFormat:@"%@%@%@",final,@"%",bb];
            }
        }
        NSArray *arguments=[NSArray arrayWithObjects:final, nil];
        NSString *subItems=[self getResultStringsByTask:@"ftpDir.py" andArgument:arguments];
        NSArray *cc1=[subItems componentsSeparatedByString:@"\n"];
        NSMutableArray *cc2=[NSMutableArray array];
        for(NSString *cc3 in cc1){
            if (![cc3 isEqualToString:@""] && ![cc3 isEqualToString:@"time out"]) {
                [cc2 addObject:cc3];
            }
        }
        [_prePop removeAllItems];
        [_prePop addItemsWithTitles:cc2];
        [NSApp runModalForWindow:_submitWindow];
    }
    else{
        _canISubmitPanel.isVisible=YES;
        _reportLog.string=message;
    }
}

-(NSString *)getResultStringsByTask:(NSString *)command andArgument:(NSArray *)argument
{
    NSString *resourcePath=[[NSBundle mainBundle]resourcePath];
    NSString *command1=[NSString stringWithFormat:@"%@/%@",resourcePath,command];
    NSTask *task=[[NSTask alloc]init];
    [task setLaunchPath:command1];
    [task setArguments:argument];
    NSPipe *readPipe=[NSPipe pipe];
    [task setStandardOutput:readPipe];
    NSFileHandle *file=[readPipe fileHandleForReading];
    [task launch];
    NSData *data=[file readDataToEndOfFile];
    return [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
}

-(NSInteger)CountNumberStrings:(NSString *)source andtarget:(NSString *)target
{
    if ([source isEqualToString:@""]) {
        return 0;
    }
    else{
        NSRegularExpression *regular=[NSRegularExpression regularExpressionWithPattern:target options:0 error:nil];
        NSArray *mathes=[NSArray array];
        mathes=[regular matchesInString:source options:0 range:NSMakeRange(0, source.length)];
        return mathes.count;
    }
}

-(void)AutoFtpProgress
{
    _timeFlagTemp=-1;
    _fileManager=[NSFileManager defaultManager];
    NSString *logPath=[NSString stringWithFormat:@"%@/%@/_Logs",_mainPath,_selectedMainItem];
    NSArray *timeList=[_fileManager contentsOfDirectoryAtPath:logPath error:nil];
    for(NSString *temp in timeList)
    {
        if ([temp hasSuffix:@"checkLocFilesForLocDir.txt"]) {
            _timeFlagTemp=1;
        }
    }
    /********************************************************************/
    if(_timeFlagTemp==1){
        if (_AGState==0) {
            NSString *command2=@"Temp_AutoFtp.py";
            NSArray *arguments2=[NSArray arrayWithObjects:[NSString stringWithFormat:@"%@/%@",_resourcePath,@"autoFtp.py"],[NSString stringWithFormat:@"%@/%@",_resourcePath,@"Envtester_new.py"],[NSString stringWithFormat:@"%@/%@",_resourcePath,@"finaltest.py"],_projPath,@"off",nil];
            [self runingProgress:command2 andArguments:arguments2];
        }
        if (_AGState==1) {
            NSString *command2=@"Temp_AutoFtp.py";
            NSArray *arguments2=[NSArray arrayWithObjects:[NSString stringWithFormat:@"%@/%@",_resourcePath,@"autoFtp.py"],[NSString stringWithFormat:@"%@/%@",_resourcePath,@"Envtester_new.py"],[NSString stringWithFormat:@"%@/%@",_resourcePath,@"finaltest.py"],_projPath,@"on",nil];
            [self runingProgress:command2 andArguments:arguments2];
        }
        NSString *command5=@"client.py";
        NSArray *arguments5=[NSArray arrayWithObjects:_projPath,@"autoFtp_UI", nil];
        [self runingProgress:command5 andArguments:arguments5];
    }
    else{
        NSRunAlertPanel(@"提示信息", @"请先执行check loc files", @"确定", @"", nil);
    }
}


-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSTableCellView *cellView=[tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    if ([tableColumn.identifier isEqualToString:@"tools"]) {
        if (row==0) {
            cellView.textField.stringValue=@"Check Loc Env";
        }
        if (row==1) {
            cellView.textField.stringValue=@"比对 xliffdiffer";
        }
        if (row==2) {
            cellView.textField.stringValue=@"执行 Envtester";
        }
        if (row==3) {
            cellView.textField.stringValue=@"执行 iTunes_itxib_tool";
        }
        if (row==4) {
            cellView.textField.stringValue=@"Check All";
        }
        if (row==5) {
            cellView.textField.stringValue=@"Check All Pro";
        }
        if (row==6) {
            cellView.textField.stringValue=@"写入 BugFixComment";
        }
        if (row==7) {
            cellView.textField.stringValue=@"CheckTarballs";
        }
        if (row==8) {
            cellView.textField.stringValue=@"Autoftp";
        }
    }
    if ([tableColumn.identifier isEqualToString:@"description"]) {
        if (row==0) {
            cellView.textField.stringValue=@"check Loc Env";
        }
        if (row==1) {
            cellView.textField.stringValue=@"核对带翻结果, 请仔细查阅稍后生成的 report";
        }
        if (row==2) {
            cellView.textField.stringValue=@"备份相关 Folder, 删除 .marking, 环境检查";
        }
        if (row==3) {
            cellView.textField.stringValue=@"iTunes 专用, 生成某些 nib 对应的 itxib";
        }
        if (row==4) {
            cellView.textField.stringValue=@"Run AAcheckLocFiles,CheckUpdatedNib Files,AAfiverifier";
        }
        if (row==5) {
            cellView.textField.stringValue=@"Run AAcheckLocFiles_Pro,CheckUpdatedNib Files,AAfiverifier_Pro";
        }
        if (row==6) {
            cellView.textField.stringValue=@"根据环境以及输入的 bug ID 生成 BugFixComment 文件";
        }
        if (row==7) {
            cellView.textField.stringValue=@"Check Tarballs";
        }
        if (row==8) {
            cellView.textField.stringValue=@"还原 Info & Project, 本地化文件最终检查";
        }
    }
    return cellView;
}

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return 9;
}

-(BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row
{
    _theSelectedIndex=0;
    _theSelectedIndex=(int)row;
    return true;
}

-(NSArray *)compareDict:(NSDictionary *)source inArr:(NSArray *)target
{
    NSMutableArray *result=[NSMutableArray array];
    NSArray *arr=[source allKeys];
    for(NSString *str in target){
        for(NSString *ss in arr){
            if ([str hasPrefix:ss]) {
                [result addObject:ss];
            }
        }
    }
    return result;
}

-(void)RunCheckLocEnv
{
    NSDictionary *warnings=[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"warning" ofType:@"plist"]];
    NSString *componentPath=[NSString stringWithFormat:@"%@/%@/GlotEnvKit_Archive",_mainPath,[_MainItem title]];
    NSArray *components=[_fileManager contentsOfDirectoryAtPath:componentPath error:nil];
    NSArray *result=[self compareDict:warnings inArr:components];
    if (result.count!=0) {
        NSString *tt=@"";
        for(NSString *str in result){
            NSString *temp=[NSString stringWithFormat:@"%@\n\n",[warnings objectForKey:str]];
            tt=[NSString stringWithFormat:@"%@%@",tt,temp];
        }
        _warningLog.stringValue=tt;
        [NSApp runModalForWindow:_warningWindow];
    }
    else{
        NSString *command=@"Temp_LocEnv.py";
        NSArray *arguments=[NSArray arrayWithObjects:[NSString stringWithFormat:@"%@/%@",_resourcePath,@"AALocCommand"],@"-checkConductorLocEnv",@"-locenv",_glotPath, nil];
        [self runingProgress:command andArguments:arguments];
        
        NSString *command1=@"client.py";
        NSArray *arguments1=[NSArray arrayWithObjects:_projPath,@"CheckLocEnv_UI", nil];
        [self runingProgress:command1 andArguments:arguments1];
    }
}

-(void)RunXliffDiffer
{
    [NSApp beginSheet:_projSelectPanel modalForWindow:self.window modalDelegate:nil didEndSelector:NULL contextInfo:NULL];
}

-(void)RunEnvtester
{
    NSString *command=@"Temp_Envtester.py";
    NSArray *arguments=[NSArray arrayWithObjects:[NSString stringWithFormat:@"%@/%@",_resourcePath,@"Envtester.py"],[NSString stringWithFormat:@"%@/%@",_resourcePath,@"ComponentData.py"],_projPath, nil];
    [self runingProgress:command andArguments:arguments];
    
    NSString *command1=@"client.py";
    NSArray *arguments1=[NSArray arrayWithObjects:_projPath,@"Envtester_UI", nil];
    [self runingProgress:command1 andArguments:arguments1];
}

-(int)getXcodePath
{
    NSString *command=[NSString stringWithFormat:@"%@/%@",_resourcePath,@"printXcodePath.sh"];
    NSArray *arguments=[NSArray arrayWithObjects:@"isnil", nil];
    NSTask *task=[[NSTask alloc]init];
    [task setLaunchPath:command];
    [task setArguments:arguments];
    NSPipe *readPipe=[NSPipe pipe];
    [task setStandardOutput:readPipe];
    NSFileHandle *file=[readPipe fileHandleForReading];
    [task launch];
    NSData *data=[file readDataToEndOfFile];
    NSString *message=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    if ([message hasPrefix:@"/Applications/Xcode.app/Contents/Developer"]) {
        return 1;
    }
    else
        return 0;
}

-(void)RunItxib
{
    if ([self getXcodePath]==0) {
        NSRunAlertPanel(@"警告信息", @"请先终端执行指令:sudo /usr/bin/xcode-select --switch /Applications/Xcode.app。",@"确定",@"", nil);
    }
    if ([self getXcodePath]==1) {
        [self startProgress];
        NSString *command=@"Temp_Itxib.py";
//        NSString *glotPath=[NSString stringWithFormat:@"%@/%@/%@/LocEnv/GlotEnv",_mainPath,[_MainItem title],[_SubItem title]];
//        NSString *xcodePath=@"/Applications/Xcode.app";
//        NSArray *arguments=[NSArray arrayWithObjects:[NSString stringWithFormat:@"%@/%@",_resourcePath,@"iTunes_itxib_tool.pl"],@"-g",glotPath,@"-x",xcodePath, nil];
        NSArray *arguments=[NSArray arrayWithObjects:[NSString stringWithFormat:@"%@/%@",_resourcePath,@"iTunes_itxib_tool.py"],_projPath, nil];
        [self runingProgress:command andArguments:arguments];
        
        NSString *command1=@"client.py";
        NSArray *arguments1=[NSArray arrayWithObjects:_projPath,@"iTunes_itxib_tool_UI", nil];
        [self runingProgress:command1 andArguments:arguments1];
    }
}

-(void)RunCheckAll
{
    NSString *command=@"Temp_CheckAll.py";
    NSArray *arguments=[NSArray arrayWithObjects:[NSString stringWithFormat:@"%@/%@",_resourcePath,@"AALocCommand"],@"-aaCheckAll",@"-locenv",_glotPath, nil];
    [self runingProgress:command andArguments:arguments];
    
    NSString *command1=@"client.py";
    NSArray *arguments1=[NSArray arrayWithObjects:_projPath,@"CheckAll_UI", nil];
    [self runingProgress:command1 andArguments:arguments1];
}

-(void)RunCheckAllPro
{
    NSString *command=@"Temp_CheckAllPro.py";
    NSArray *arguments=[NSArray arrayWithObjects:[NSString stringWithFormat:@"%@/%@",_resourcePath,@"AALocCommand"],@"-aaCheckAll_Pro",@"-locenv",_glotPath, nil];
    [self runingProgress:command andArguments:arguments];
    
    NSString *command1=@"client.py";
    NSArray *arguments1=[NSArray arrayWithObjects:_projPath,@"CheckAllPro_UI", nil];
    [self runingProgress:command1 andArguments:arguments1];
}

-(int)whetherToRunCheckTar
{
    int sum=0;
    int sum1=0;
    int sum2=0;
    int sum3=0;
    NSString *tarballPath=@"";
    NSMutableArray *mArray=[NSMutableArray array];
    NSArray *finalArray=[NSArray array];
    NSString *projPathTemp=[NSString stringWithFormat:@"%@/%@/%@/LocEnv",_mainPath,[_MainItem title],[_SubItem title]];
    NSArray *array=[_fileManager contentsOfDirectoryAtPath:projPathTemp error:nil];
    for(NSString *str in array){
        if ([str hasPrefix:@"TarOut"]) {
            tarballPath=[NSString stringWithFormat:@"%@/%@/%@/LocEnv/%@",_mainPath,[_MainItem title],[_SubItem title],str];
        }
    }
    if (tarballPath!=nil) {
        NSArray *array1=[_fileManager contentsOfDirectoryAtPath:tarballPath error:nil];
        for(NSString *ss in array1){
            if (![ss isEqualToString:@".DS_Store"]) {
                [mArray addObject:ss];
            }
        }
        finalArray=[mArray copy];
        for(NSString *str1 in finalArray){
            NSRange range1=[str1 rangeOfString:@".01_"];
            NSRange range2=[str1 rangeOfString:@"_1.tgz"];
            NSRange range3=[str1 rangeOfString:@".02_"];
            NSRange range4=[str1 rangeOfString:@"_2.tgz"];
            if (range1.location!=NSNotFound &&range2.location!=NSNotFound) {
                sum++;
            }
            if (range3.location!=NSNotFound &&range4.location!=NSNotFound) {
                sum1++;
            }
            if (range1.location!=NSNotFound &&range4.location!=NSNotFound) {
                sum2++;
            }
            if (range3.location!=NSNotFound &&range2.location!=NSNotFound) {
                sum3++;
            }
        }
        if (sum==finalArray.count && sum>0) {
            return 1;
        }
        if (sum1>0) {
            return 2;
        }
        if (sum2>0 || sum3>0) {
            return 3;
        }
        if (sum==0 &&sum1==0) {
            return 4;
        }
    }
    return 0;
}
    
-(void)toRunWhich:(int)sum
{
    if (sum==1) {
        [self RunCheckTar];
    }
    if (sum==2) {
//        _alertWindow.isVisible=YES;
        [_OKButton setHidden:YES];
        [_CancelButton setHidden:NO];
        [_canBeAvailable setHidden:NO];
        [_alertWindow setFrameOrigin:NSMakePoint(self.window.frame.origin.x+self.window.frame.size.width/4, self.window.frame.origin.y+self.window.frame.size.height/2)];
        _alertWindow.backgroundColor=[NSColor yellowColor];
        _alertTitle.stringValue=@"警告信息:";
        _alertTitle.font=[NSFont systemFontOfSize:20];
        _alertDetail.stringValue=@"存在022的tarball,请检查是否需要压022的tarball,若需要,请继续执行。";
        [NSApp runModalForWindow:_alertWindow];
    }
    if (sum==3) {
//        _alertWindow.isVisible=YES;
        [_OKButton setHidden:NO];
        [_CancelButton setHidden:YES];
        [_canBeAvailable setHidden:YES];
        [_alertWindow setFrameOrigin:NSMakePoint(self.window.frame.origin.x+self.window.frame.size.width/4, self.window.frame.origin.y+self.window.frame.size.height/2)];
        _alertWindow.backgroundColor=[NSColor redColor];
        _alertTitle.stringValue=@"错误:";
        _alertTitle.font=[NSFont systemFontOfSize:20];
        _alertDetail.stringValue=@"存在不合法的tarball,例如021,012,请重新压tarball。";
        [NSApp runModalForWindow:_alertWindow];
    }
    if (sum==4) {
//        _alertWindow.isVisible=YES;
        [_OKButton setHidden:NO];
        [_CancelButton setHidden:YES];
        [_canBeAvailable setHidden:YES];
        [_alertWindow setFrameOrigin:NSMakePoint(self.window.frame.origin.x+self.window.frame.size.width/4, self.window.frame.origin.y+self.window.frame.size.height/2)];
        _alertWindow.backgroundColor=[NSColor yellowColor];
        _alertTitle.stringValue=@"警告信息:";
        _alertTitle.font=[NSFont systemFontOfSize:20];
        _alertDetail.stringValue=@"请先压tarball,再选择执行check tar。";
        [NSApp runModalForWindow:_alertWindow];
    }
}

-(void)RunCheckTar
{
    NSString *command=@"Temp_CheckTar.py";
    NSArray *arguments=[NSArray arrayWithObjects:[NSString stringWithFormat:@"%@/%@",_resourcePath,@"AALocCommand"],@"-checkConductorTar",@"-locenv",_glotPath, nil];
    [self runingProgress:command andArguments:arguments];
        
    NSString *command1=@"client.py";
    NSArray *arguments1=[NSArray arrayWithObjects:_projPath,@"CheckTar_UI", nil];
    [self runingProgress:command1 andArguments:arguments1];
 
}

-(void)RunAutoFtp
{
    [NSApp beginSheet:_isOrNotAGPanel modalForWindow:self.window modalDelegate:nil didEndSelector:NULL contextInfo:NULL];
}

-(void)RunBugFix
{
    [NSApp beginSheet:_bugFixPanel modalForWindow:self.window modalDelegate:nil didEndSelector:NULL contextInfo:NULL];
}


-(void)LocToolsProgress
{
    if (_theSelectedIndex==-1) {
        NSRunAlertPanel(@"警告:", @"请选择要执行的步骤", @"确定", @"", nil);
    }
    if (_theSelectedIndex==0) {
        _ShowLogs.string=@"";
        [self RunCheckLocEnv];
    }
    
    if (_theSelectedIndex==1) {
        _ShowLogs.string=@"";
        [self RunXliffDiffer];
    }
    if (_theSelectedIndex==2) {
        _ShowLogs.string=@"";
        [self RunEnvtester];
    }
    if (_theSelectedIndex==3) {
        _ShowLogs.string=@"";
        [self RunItxib];
    }
    if (_theSelectedIndex==4) {
        _ShowLogs.string=@"";
        [self RunCheckAll];
    }
    if (_theSelectedIndex==5) {
        _ShowLogs.string=@"";
        [self RunCheckAllPro];
    }
    if (_theSelectedIndex==6) {
        _ShowLogs.string=@"";
        [self RunBugFix];
    }
    if (_theSelectedIndex==7) {
        _ShowLogs.string=@"";
        [self toRunWhich:[self whetherToRunCheckTar]];
    }
    if (_theSelectedIndex==8) {
        _ShowLogs.string=@"";
        [self RunAutoFtp];
    }
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
            [_ShowLogs insertText:stringFromPlugin];
            [_waitingDataBuffer setLength:0];
        }
        [[aNotification object] readInBackgroundAndNotify];
    }
    for(NSString *str in _keyWords)
    {
        [self highLightAllStrings:str withString:_ShowLogs.string];
    }
}

-(void)runingProgress:(NSString *)command andArguments:(NSArray *)arguments
{
    _task=[[NSTask alloc]init];
    [_task setStandardOutput:[[NSPipe alloc]init]];
    [_task setStandardInput:[[NSPipe alloc]init]];
    [_task setStandardError: [_task standardOutput]];
    NSString *commandPath=[NSString stringWithFormat:@"%@/%@",_resourcePath,command];
    [_task setLaunchPath:commandPath];
    [_task setArguments:arguments];
    [[NSNotificationCenter defaultCenter]addObserver: self
                                            selector: @selector(getData:)
                                                name: NSFileHandleReadCompletionNotification
                                              object: [[_task standardOutput] fileHandleForReading]];
    [[[_task standardOutput] fileHandleForReading] readInBackgroundAndNotify];
    [_task launch];
}

- (void) getDataOne: (NSNotification *)aNotification
{
    NSData *data = [[aNotification userInfo] objectForKey:NSFileHandleNotificationDataItem];
    if ([data length])
    {
		[_waitingDataBuffer appendData:data];
        NSString *stringFromPlugin = [[NSString alloc] initWithData:_waitingDataBuffer encoding:NSUTF8StringEncoding];
        if ((stringFromPlugin != nil) && (![stringFromPlugin isEqualToString:@""]))
        {
            [_reportLog insertText:stringFromPlugin];
            [_waitingDataBuffer setLength:0];
        }
        
        [[aNotification object] readInBackgroundAndNotify];
    }
}

-(void)runingProgressOne:(NSString *)command andArguments:(NSArray *)arguments
{
    _task=[[NSTask alloc]init];
    [_task setStandardOutput:[[NSPipe alloc]init]];
    [_task setStandardInput:[[NSPipe alloc]init]];
    [_task setStandardError: [_task standardOutput]];
    NSString *commandPath=[NSString stringWithFormat:@"%@/%@",_resourcePath,command];
    [_task setLaunchPath:commandPath];
    [_task setArguments:arguments];
    [[NSNotificationCenter defaultCenter]addObserver: self
                                            selector: @selector(getDataOne:)
                                                name: NSFileHandleReadCompletionNotification
                                              object: [[_task standardOutput] fileHandleForReading]];
    [[[_task standardOutput] fileHandleForReading] readInBackgroundAndNotify];
    [_task launch];
    [_task waitUntilExit];
}

-(void)startProgress
{
    [_ShowLogs insertText:@"# progress started\n\n"];
}

-(void)endProgress
{
    [_ShowLogs insertText:@"\n# progress ended\n"];
}


- (IBAction)openReports:(id)sender {
    NSString *reportPath=nil;
    NSString *projPathTemp=[NSString stringWithFormat:@"%@/%@/%@/LocEnv",_mainPath,[_MainItem title],[_SubItem title]];
    _fileManager=[NSFileManager defaultManager];
    NSArray *array=[_fileManager contentsOfDirectoryAtPath:projPathTemp error:nil];
    for(NSString *str in array){
        if ([str hasPrefix:@"Reports_"] && ![str hasSuffix:@".zip"]) {
            reportPath=[NSString stringWithFormat:@"%@/%@/%@/LocEnv/%@",_mainPath,[_MainItem title],[_SubItem title],str];
        }
    }
    if (reportPath!=nil) {
        NSWorkspace *ws=[NSWorkspace sharedWorkspace];
        [ws selectFile:reportPath inFileViewerRootedAtPath:nil];
    }
}
    
- (IBAction)exitAlertWindow:(id)sender {
//    _alertWindow.isVisible=NO;
    [NSApp stopModal];
    [_alertWindow orderOut:sender];
}
    
- (IBAction)continueAlertWindow:(id)sender {
//    _alertWindow.isVisible=NO;
    [NSApp stopModal];
    [_alertWindow orderOut:sender];
    [self RunCheckTar];
}

- (IBAction)okBtnClick:(id)sender {
//    _alertWindow.isVisible=NO;
    [NSApp stopModal];
    [_alertWindow orderOut:sender];
}

- (IBAction)beforeRunPcx:(id)sender {
    _ShowLogs.string=@"";
    NSString *command=@"PCXPlugins.py";
    NSString *path=[NSString stringWithFormat:@"%@/%@/%@/LocEnv/GlotEnv/_EnvLog/flidentifier_result",_mainPath,[_MainItem title],[_SubItem title]];
    NSArray *arguments=[NSArray arrayWithObjects:path, nil];
    [self runingProgress:command andArguments:arguments];
    NSString *command1=@"client.py";
    NSString *projPath=[NSString stringWithFormat:@"%@/%@/%@/LocEnv",_mainPath,[_MainItem title],[_SubItem title]];
    NSArray *arguments1=[NSArray arrayWithObjects:projPath,@"PCXPlugins_UI", nil];
    [self runingProgress:command1 andArguments:arguments1];
}

- (IBAction)AGCancelAction:(id)sender {
    [NSApp endSheet:_isOrNotAGPanel];
    [_isOrNotAGPanel orderOut:sender];
}

- (IBAction)AGContinueAction:(id)sender {
    [NSApp endSheet:_isOrNotAGPanel];
    [_isOrNotAGPanel orderOut:sender];
    if (_AGCheckBox.state==0) {
        _AGState=0;
        [self AutoFtpProgress];
    }
    if (_AGCheckBox.state==1) {
        _AGState=1;
        [self AutoFtpProgress];
    }
}

- (IBAction)checkClipping:(id)sender {
    _clippingResult.isVisible=YES;
    _clippingLog.string=@"";
    NSMutableArray *final=[NSMutableArray array];
    NSString *tempResourcePath=[[NSBundle mainBundle]resourcePath];
    NSString *command=[NSString stringWithFormat:@"%@/findIDAndRect.py",tempResourcePath];
    NSTask *task=[[NSTask alloc]init];
    [task setLaunchPath:command];
    NSString *argument=[NSString stringWithFormat:@"%@/%@/%@/LocEnv/GlotEnv/_NewLoc",_mainPath,_MainItem.title,_SubItem.title];
    NSArray *arguments=[NSArray arrayWithObjects:argument, nil];
    [task setArguments:arguments];
    NSPipe *readPipe=[NSPipe pipe];
    [task setStandardOutput:readPipe];
    NSFileHandle *file=[readPipe fileHandleForReading];
    [task launch];
    NSData *data=[file readDataToEndOfFile];
    NSString *message=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSArray *result=[message componentsSeparatedByString:@"\n"];
    for(NSString *temp in result){
        if (![temp isEqualToString:@""]) {
            NSArray *details=[temp componentsSeparatedByString:@"\t"];
            NSString *ss=[self checkIfIsClipping:details];
            if (![ss isEqualToString:@""]) {
                NSMutableArray *temp1=[NSMutableArray array];
                [temp1 addObject:[details objectAtIndex:0]];
                [temp1 addObject:ss];
                [final addObject:temp1];
            }
        }
    }
    for(NSArray *arr in final){
        [_clippingLog insertText:[arr objectAtIndex:0]];
        [_clippingLog insertText:@"\n"];
        [_clippingLog insertText:[arr objectAtIndex:1]];
        [_clippingLog insertText:@"\n"];
        [_clippingLog insertText:@"\n"];
    }
}

- (IBAction)cancelSubmit:(id)sender {
    [_submissionProgress setHidden:YES];
    [NSApp stopModal];
    [_submitWindow orderOut:sender];
}

- (IBAction)conitnueSubmit:(id)sender {
    [_submissionProgress setHidden:NO];
    [_submissionProgress startAnimation:sender];
    NSString *locPath=[NSString stringWithFormat:@"%@/%@/%@/LocEnv",_mainPath,[_MainItem title],[_SubItem title]];
    NSString *subPath=[NSString stringWithFormat:@"//SoftwareDev/%@/%@",[_submitPop title],[_prePop title]];
    NSArray *argument=[NSArray array];
    if ([_folderField.stringValue isEqualToString:@""]) {
        argument=[NSArray arrayWithObjects:locPath,subPath, nil];
    }
    else{
        argument=[NSArray arrayWithObjects:locPath,subPath,_folderField.stringValue, nil];
    }
    NSString *result=[self getResultStringsByTask:@"ftpSubmitter.py" andArgument:argument];
    NSRange range=[result rangeOfString:@"## Done"];
    if (range.location!=NSNotFound) {
        [_submissionProgress stopAnimation:sender];
        [_submissionProgress setHidden:YES];
        [NSApp stopModal];
        [_submitWindow orderOut:sender];
        NSRunAlertPanel(@"提示信息", @"提交成功", @"确定", @"", nil);
    }
    else{
        [_submissionProgress stopAnimation:sender];
        [_submissionProgress setHidden:YES];
        [NSApp stopModal];
        [_submitWindow orderOut:sender];
        NSRunAlertPanel(@"提示信息", @"提交失败", @"确定", @"", nil);
    }
}

-(void)complementSubmition
{
    
}

- (IBAction)warningCancel:(id)sender {
    [NSApp stopModal];
    [_warningWindow orderOut:sender];
}

- (IBAction)warningContinue:(id)sender {
    [NSApp stopModal];
    [_warningWindow orderOut:sender];
    NSString *command=@"Temp_LocEnv.py";
    NSArray *arguments=[NSArray arrayWithObjects:[NSString stringWithFormat:@"%@/%@",_resourcePath,@"AALocCommand"],@"-checkConductorLocEnv",@"-locenv",_glotPath, nil];
    [self runingProgress:command andArguments:arguments];
    
    NSString *command1=@"client.py";
    NSArray *arguments1=[NSArray arrayWithObjects:_projPath,@"CheckLocEnv_UI", nil];
    [self runingProgress:command1 andArguments:arguments1];
}

- (IBAction)selectSubmitPop:(id)sender {
    NSString *item=[_submitPop title];
    NSString *str=[self getResultStringsByTask:@"ftpDir.py" andArgument:[NSArray arrayWithObjects:item, nil]];
    NSArray *arr=[str componentsSeparatedByString:@"\n"];
    NSMutableArray *arr1=[NSMutableArray array];
    for(NSString *temp in arr){
        if (![temp isEqualToString:@""] &&![temp isEqualToString:@"time out"]) {
            [arr1 addObject:temp];
        }
    }
    [_prePop removeAllItems];
    [_prePop addItemsWithTitles:arr1];
}

-(NSString *)checkIfIsClipping:(NSArray *)arr
{
    NSString *result=@"";
    NSString *string=[arr lastObject];
    NSString *type=[arr objectAtIndex:1];
    CGFloat w=[[arr objectAtIndex:4]floatValue];
    CGFloat h=[[arr objectAtIndex:5]floatValue];
    
    if ([type isEqualToString:@"textfield"]) {
        CGFloat height=[self heightOfStrings:string andWidth:w];
        if (height-2 > h) {
            result=[NSString stringWithFormat:@"\"%@\"is clipping",string];
        }
    }
    return result;
}

-(CGFloat)heightOfStrings:(NSString *)str andWidth:(CGFloat)width
{
    CGSize size=CGSizeMake(width, MAXFLOAT);
    NSStringDrawingOptions option=NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin;
    NSDictionary *attr=@{NSFontAttributeName:[NSFont systemFontOfSize:13]};
    CGRect rect=[str boundingRectWithSize:size options:option attributes:attr];
    return rect.size.height;
}

-(void)copyAutoFtpFile
{
    NSString *targetPath=@"/Developer/WistronITS_Files";
    NSString *target1=@"/Developer/WistronITS_Files/makeautoFtp_plus.pl";
    NSFileManager *file=[NSFileManager defaultManager];
    if ([file fileExistsAtPath:target1]) {
        NSString *removeFile=[NSString stringWithFormat:@"rm %@",target1];
        const char *command2=[removeFile UTF8String];
        system(command2);
        /***************************************/
        NSString *str=[[NSBundle mainBundle]resourcePath];
        NSString *resourcePath=[NSString stringWithFormat:@"%@/%@",str,@"makeautoFtp_plus.pl"];
        NSString *command1=[NSString stringWithFormat:@"cp %@ %@",resourcePath,targetPath];
        const char *cmd=[command1 UTF8String];
        system(cmd);
    }
    else{
        NSString *str=[[NSBundle mainBundle]resourcePath];
        NSString *resourcePath=[NSString stringWithFormat:@"%@/%@",str,@"makeautoFtp_plus.pl"];
        NSString *command1=[NSString stringWithFormat:@"cp %@ %@",resourcePath,targetPath];
        const char *cmd=[command1 UTF8String];
        system(cmd);
    }
}

- (IBAction)showWindow:(id)sender {
    self.window.isVisible=YES;
}

- (IBAction)hiddenWindow:(id)sender {
    self.window.isVisible=NO;
}

- (IBAction)OtherTools:(id)sender {
    _tools.window.isVisible=YES;
}

- (IBAction)hiddenTools:(id)sender {
    _tools.window.isVisible=NO;
}

-(void)highLightAllStrings:(NSString *)str withString:(NSString *)theAll
{
    NSLayoutManager *manager=[_ShowLogs layoutManager];
    NSRegularExpression *regular=[NSRegularExpression regularExpressionWithPattern:str options:0 error:nil];
    NSArray *mathes=[regular matchesInString:theAll options:0 range:NSMakeRange(0, theAll.length)];
    for(NSTextCheckingResult *result in [mathes objectEnumerator]){
        NSRange range=[result range];
        [manager addTemporaryAttribute:NSForegroundColorAttributeName value:[NSColor redColor] forCharacterRange:range];
    }
}

@end
