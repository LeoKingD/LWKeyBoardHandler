# LWKeyBoardHandler

对于编辑页面推键盘控制

用法:

@property (nonatomic, strong) LWKeyBoardHandler *keyboardHandler;


self.keyboardHandler = [[LWKeyBoardHandler alloc] init];

在viewController的两个事件中添加或移除观察者
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.keyboardHandler addKeyBoardObserver];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.keyboardHandler removeKeyBoardObserver];
}

