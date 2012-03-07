//
//  GameMenuViewController.m
//  Pokemon
//
//  Created by Kaijie Yu on 2/26/12.
//  Copyright (c) 2012 Kjuly. All rights reserved.
//

#import "GameMenuViewController.h"

#import "GlobalConstants.h"
#import "GlobalRender.h"
#import "GlobalNotificationConstants.h"
#import "GameStatus.h"
#import "GameTopViewController.h"
#import "GamePokemonStatusAdvancedViewController.h"
#import "GameMenuMoveViewController.h"
#import "GameMenuBagViewController.h"


typedef enum {
  kGameMenuKeyViewNone            = 0,
  kGameMenuKeyViewSixPokemonsView = 1,
  kGameMenuKeyViewMoveView        = 2,
  kGameMenuKeyViewBagView         = 3
}GameMenuKeyView;

@interface GameMenuViewController () {
 @private
  GameTopViewController           * gameTopViewController_;
  GamePokemonStatusViewController         * wildPokemonStatusViewController_;
  GamePokemonStatusAdvancedViewController * myPokemonStatusViewController_;
  
  GameMenuKeyView              gameMenuKeyView_;
  GameMenuMoveViewController * gameMenuMoveViewController_;
  GameMenuBagViewController  * gameMenuBagViewController_;
  UIView * menuArea_;
  UITextView * messageView_;
}

@property (nonatomic, retain) GameTopViewController           * gameTopViewController;
@property (nonatomic, retain) GamePokemonStatusViewController         * wildPokemonStatusViewController;
@property (nonatomic, retain) GamePokemonStatusAdvancedViewController * myPokemonStatusViewController;

@property (nonatomic, assign) GameMenuKeyView              gameMenuKeyView;
@property (nonatomic, retain) GameMenuMoveViewController * gameMenuMoveViewController;
@property (nonatomic, retain) GameMenuBagViewController  * gameMenuBagViewController;
@property (nonatomic, retain) UIView * menuArea;
@property (nonatomic, retain) UITextView * messageView;

// Button Actions
- (void)openMoveView;
- (void)openBagView;
- (void)openRunConfirmView;
- (void)toggleSixPokemonsView:(NSNotification *)notification;
- (void)updateMessage:(NSNotification *)notification;

@end

@implementation GameMenuViewController

@synthesize delegate    = delegate_;
@synthesize buttonFight = buttonFight_;
@synthesize buttonBag   = buttonBag_;
@synthesize buttonRun   = buttonRun_;

@synthesize gameTopViewController           = gameTopViewController_;
@synthesize wildPokemonStatusViewController = wildPokemonStatusViewController_;
@synthesize myPokemonStatusViewController   = myPokemonStatusViewController_;

@synthesize gameMenuKeyView            = gameMenuKeyView_;
@synthesize gameMenuMoveViewController = gameMenuMoveViewController_;
@synthesize gameMenuBagViewController  = gameMenuBagViewController_;
@synthesize menuArea = menuArea_;
@synthesize messageView = messageView_;

- (void)dealloc
{
  self.delegate = nil;
  
  [buttonFight_ release];
  [buttonBag_   release];
  [buttonRun_   release];
  
  [gameTopViewController_           release];
  [wildPokemonStatusViewController_ release];
  [myPokemonStatusViewController_   release];
  
  [gameMenuMoveViewController_ release];
  [gameMenuBagViewController_  release];
  [menuArea_ release];
  [messageView_ release];
  
  // Rmove observer for notification
  [[NSNotificationCenter defaultCenter] removeObserver:self name:kPMNToggleSixPokemons object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:kPMNUpdateGameBattleMessage object:nil];
  [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (void)didReceiveMemoryWarning
{
  // Releases the view if it doesn't have a superview.
  [super didReceiveMemoryWarning];
  
  // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
//  [super loadView];
  UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, kViewWidth, kViewHeight)];
  self.view = view;
  [view release];
  [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"GameBattleViewMainMenuBackground.png"]]];
  [self.view setOpaque:NO];
  
  // Constants
  CGRect menuAreaFrame    = CGRectMake(0.f, 250.f, 320.f, 45.f);
  CGRect buttonBagFrame   = CGRectMake(50.f, 5.f, 32.f, 32.f);
  CGRect buttonRunFrame   = CGRectMake(320.f - 50.f - 32.f, 5.f, 32.f, 32.f);
  CGRect buttonFightFrame = CGRectMake((320.f - 64.f) / 2.f, -10.f, 64.f, 64.f);
  CGRect messageViewFrame = CGRectMake(10.f, 310.f, 300.f, 120.f);
  
  // Wild Pokemon Status View
  CGRect wildPokemonStatusViewFrame = CGRectMake(0.f, 80.f, 180.f, 65.f);
  CGRect myPokemonStatusViewFrame   = CGRectMake(40.f, 180.f, 280.f, 65.f);
  wildPokemonStatusViewController_ = [[GamePokemonStatusViewController alloc] init];
  [wildPokemonStatusViewController_.view setFrame:wildPokemonStatusViewFrame];
  [self.view addSubview:wildPokemonStatusViewController_.view];
  // My Pokemon Status Viwe
  myPokemonStatusViewController_ = [[GamePokemonStatusAdvancedViewController alloc] init];
  [myPokemonStatusViewController_.view setFrame:myPokemonStatusViewFrame];
  [self.view addSubview:myPokemonStatusViewController_.view];
  
  // Top Bar
  gameTopViewController_ = [[GameTopViewController alloc] init];
  [self.view addSubview:gameTopViewController_.view];
  
  // Menu Area
  UIView * menuArea = [[UIView alloc] initWithFrame:menuAreaFrame];
  self.menuArea = menuArea;
  [menuArea release];
  [self.view addSubview:self.menuArea];
  
  // Create Menu Buttons
  buttonBag_ = [[UIButton alloc] initWithFrame:buttonBagFrame];
  [buttonBag_ setImage:[UIImage imageNamed:@"GameBattleViewMainMenuButtonBagIcon.png"]
              forState:UIControlStateNormal];
  [buttonBag_ addTarget:self action:@selector(openBagView) forControlEvents:UIControlEventTouchUpInside];
  [self.menuArea addSubview:buttonBag_];
  
  buttonRun_ = [[UIButton alloc] initWithFrame:buttonRunFrame];
  [buttonRun_ setImage:[UIImage imageNamed:@"GameBattleViewMainMenuButtonRunIcon.png"]
              forState:UIControlStateNormal];
  [buttonRun_ addTarget:self action:@selector(openRunConfirmView) forControlEvents:UIControlEventTouchUpInside];
  [self.menuArea addSubview:buttonRun_];
  
  buttonFight_ = [[UIButton alloc] initWithFrame:buttonFightFrame];
  [buttonFight_ setImage:[UIImage imageNamed:@"GameBattleViewMainMenuButtonFightIcon.png"]
                forState:UIControlStateNormal];
  [buttonFight_ addTarget:self action:@selector(openMoveView) forControlEvents:UIControlEventTouchUpInside];
  [self.menuArea addSubview:buttonFight_];
  
  // Message View
  UITextView * messageView = [[UITextView alloc] initWithFrame:messageViewFrame];
  self.messageView = messageView;
  [messageView release];
  [self.messageView setBackgroundColor:[UIColor clearColor]];
  [self.messageView setFont:[GlobalRender textFontNormalInSizeOf:16.f]];
  [self.messageView setTextColor:[GlobalRender textColorNormal]];
  [self.view addSubview:self.messageView];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
  [super viewDidLoad];
  
  // Base Settings
  gameMenuKeyView_ = kGameMenuKeyViewNone;
  
  // Add observer for notfication from |centerMainButton_|
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(toggleSixPokemonsView:)
                                               name:kPMNToggleSixPokemons
                                             object:nil];
  // Add observer for notification from |GameMenuMoveViewController| & |GameWildPokemon|
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(updateMessage:)
                                               name:kPMNUpdateGameBattleMessage
                                             object:nil];
}

- (void)viewDidUnload
{
  [super viewDidUnload];
  
  self.buttonFight = nil;
  self.buttonBag   = nil;
  self.buttonRun   = nil;
  
  self.gameTopViewController           = nil;
  self.wildPokemonStatusViewController = nil;
  self.myPokemonStatusViewController   = nil;
  
  self.gameMenuMoveViewController = nil;
  self.gameMenuBagViewController  = nil;
  self.menuArea = nil;
  self.messageView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  // Return YES for supported orientations
  return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Private Methods

// Button actions
// Action for |buttonFight_|
- (void)openMoveView {
  if ([[GameStatus sharedInstance] isTrainerTurn]) {
    if (! self.gameMenuMoveViewController) {
      GameMenuMoveViewController * gameMenuMoveViewController = [[GameMenuMoveViewController alloc] init];
      self.gameMenuMoveViewController = gameMenuMoveViewController;
      [gameMenuMoveViewController release];
    }
    [self.view addSubview:self.gameMenuMoveViewController.view];
    [self.gameMenuMoveViewController loadViewWithAnimation];
    self.gameMenuKeyView = kGameMenuKeyViewMoveView;
  }
}

// Action for |buttonBag_|
- (void)openBagView {
  if ([[GameStatus sharedInstance] isTrainerTurn]) {
    if (! self.gameMenuBagViewController) {
      GameMenuBagViewController * gameMenuBagViewController = [[GameMenuBagViewController alloc] init];
      self.gameMenuBagViewController = gameMenuBagViewController;
      [gameMenuBagViewController release];
    }
    [self.view addSubview:self.gameMenuBagViewController.view];
    [self.gameMenuBagViewController loadViewWithAnimation];
    self.gameMenuKeyView = kGameMenuKeyViewBagView;
  }
}

// Action for |buttonRun_|
- (void)openRunConfirmView {
  if ([[GameStatus sharedInstance] isTrainerTurn]) {
    NSLog(@"Open Run Confirm View..");
    [delegate_ unloadBattleScene];
  }
}

// Notification for |centerMainButton_| at view bottom
- (void)toggleSixPokemonsView:(NSNotification *)notification
{
  switch (self.gameMenuKeyView) {
    case kGameMenuKeyViewSixPokemonsView:
      //
      // TODO:
      //   Six Pokemons' List View
      //   Throw PokeBall!!!
      //
      break;
      
    case kGameMenuKeyViewMoveView:
      [self.gameMenuMoveViewController unloadViewWithAnimation];
      break;
      
    case kGameMenuKeyViewBagView:
      if (self.gameMenuBagViewController.isSelectedItemViewOpening)
        [self.gameMenuBagViewController unloadSelcetedItemTalbeView:nil];
      [self.gameMenuBagViewController unloadViewWithAnimation];
      break;
      
    case kGameMenuKeyViewNone:
    default:
      break;
  }
}

// Update message for game battle
- (void)updateMessage:(NSNotification *)notification
{
  NSDictionary * userInfo = notification.userInfo;
  [UIView animateWithDuration:.2f
                        delay:0.f
                      options:UIViewAnimationCurveEaseOut
                   animations:^{
                     [self.messageView setAlpha:0.f];
                   }
                   completion:^(BOOL finished) {
                     [self.messageView setText:[userInfo objectForKey:@"message"]];
                     [UIView animateWithDuration:.3f
                                           delay:0.f
                                         options:UIViewAnimationCurveEaseIn
                                      animations:^{
                                        [self.messageView setAlpha:1.f];
                                      }
                                      completion:nil];
                   }];
}

@end