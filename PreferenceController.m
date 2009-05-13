//
//  PreferenceController.m
//  Telephone
//
//  Copyright (c) 2008-2009 Alexei Kuznetsov. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//  1. Redistributions of source code must retain the above copyright notice,
//     this list of conditions and the following disclaimer.
//  2. Redistributions in binary form must reproduce the above copyright notice,
//     this list of conditions and the following disclaimer in the documentation
//     and/or other materials provided with the distribution.
//  3. The name of the author may not be used to endorse or promote products
//     derived from this software without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY ALEXEI KUZNETSOV "AS IS" AND ANY EXPRESS
//  OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
//  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
//  IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
//  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
//  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
//  OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
//  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
//  OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
//  EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "PreferenceController.h"

#import "AKKeychain.h"
#import "AKNSWindow+Resizing.h"
#import "AKTelephone.h"
#import "AKTelephoneAccount.h"

#import "AppController.h"


NSString * const kAKTelephoneAccountPboardType = @"AKTelephoneAccountPboardType";

@interface PreferenceController ()

- (BOOL)checkForNetworkSettingsChanges:(id)sender;
- (void)networkSettingsChangeAlertDidEnd:(NSAlert *)alert
                              returnCode:(int)returnCode
                             contextInfo:(void *)contextInfo;

@end

NSString * const kAccounts = @"Accounts";
NSString * const kSTUNServerHost = @"STUNServerHost";
NSString * const kSTUNServerPort = @"STUNServerPort";
NSString * const kSTUNDomain = @"STUNDomain";
NSString * const kLogFileName = @"LogFileName";
NSString * const kLogLevel = @"LogLevel";
NSString * const kConsoleLogLevel = @"ConsoleLogLevel";
NSString * const kVoiceActivityDetection = @"VoiceActivityDetection";
NSString * const kTransportPort = @"TransportPort";
NSString * const kSoundInput = @"SoundInput";
NSString * const kSoundOutput = @"SoundOutput";
NSString * const kRingtoneOutput = @"RingtoneOutput";
NSString * const kRingingSound = @"RingingSound";
NSString * const kFormatTelephoneNumbers = @"FormatTelephoneNumbers";
NSString * const kTelephoneNumberFormatterSplitsLastFourDigits
  = @"TelephoneNumberFormatterSplitsLastFourDigits";
NSString * const kOutboundProxyHost = @"OutboundProxyHost";
NSString * const kOutboundProxyPort = @"OutboundProxyPort";
NSString * const kUseICE = @"UseICE";
NSString * const kUseDNSSRV = @"UseDNSSRV";
NSString * const kSignificantPhoneNumberLength = @"SignificantPhoneNumberLength";
NSString * const kPauseITunes = @"PauseITunes";

NSString * const kFullName = @"FullName";
NSString * const kSIPAddress = @"SIPAddress";
NSString * const kRegistrar = @"Registrar";
NSString * const kRealm = @"Realm";
NSString * const kUsername = @"Username";
NSString * const kAccountIndex = @"AccountIndex";
NSString * const kAccountEnabled = @"AccountEnabled";
NSString * const kReregistrationTime = @"ReregistrationTime";
NSString * const kSubstitutePlusCharacter = @"SubstitutePlusCharacter";
NSString * const kPlusCharacterSubstitutionString
  = @"PlusCharacterSubstitutionString";
NSString * const kUseProxy = @"UseProxy";
NSString * const kProxyHost = @"ProxyHost";
NSString * const kProxyPort = @"ProxyPort";

NSString * const kSourceIndex = @"SourceIndex";
NSString * const kDestinationIndex = @"DestinationIndex";

NSString * const AKPreferenceControllerDidAddAccountNotification
  = @"AKPreferenceControllerDidAddAccount";
NSString * const AKPreferenceControllerDidRemoveAccountNotification
  = @"AKPreferenceControllerDidRemoveAccount";
NSString * const AKPreferenceControllerDidChangeAccountEnabledNotification
  = @"AKPreferenceControllerDidChangeAccountEnabled";
NSString * const AKPreferenceControllerDidSwapAccountsNotification
  = @"AKPreferenceControllerDidSwapAccounts";
NSString * const AKPreferenceControllerDidChangeNetworkSettingsNotification
  = @"AKPreferenceControllerDidChangeNetworkSettings";

@implementation PreferenceController

@dynamic delegate;

@synthesize toolbar = toolbar_;
@synthesize generalToolbarItem = generalToolbarItem_;
@synthesize accountsToolbarItem = accountsToolbarItem_;
@synthesize soundToolbarItem = soundToolbarItem_;
@synthesize networkToolbarItem = networkToolbarItem_;
@synthesize generalView = generalView_;
@synthesize accountsView = accountsView_;
@synthesize soundView = soundView_;
@synthesize networkView = networkView_;

@synthesize soundInputPopUp = soundInputPopUp_;
@synthesize soundOutputPopUp = soundOutputPopUp_;
@synthesize ringtoneOutputPopUp = ringtoneOutputPopUp_;
@synthesize ringtonePopUp = ringtonePopUp_;

@synthesize transportPortField = transportPortField_;
@synthesize transportPortCell = transportPortCell_;
@synthesize STUNServerHostField = STUNServerHostField_;
@synthesize STUNServerPortField = STUNServerPortField_;
@synthesize useICECheckBox = useICECheckBox_;
@synthesize outboundProxyHostField = outboundProxyHostField_;
@synthesize outboundProxyPortField = outboundProxyPortField_;

@synthesize accountsTable = accountsTable_;
@synthesize accountEnabledCheckBox = accountEnabledCheckBox_;
@synthesize fullNameField = fullNameField_;
@synthesize SIPAddressField = SIPAddressField_;
@synthesize registrarField = registrarField_;
@synthesize usernameField = usernameField_;
@synthesize passwordField = passwordField_;
@synthesize reregistrationTimeField = reregistrationTimeField_;
@synthesize substitutePlusCharacterCheckBox = substitutePlusCharacterCheckBox_;
@synthesize plusCharacterSubstitutionField = plusCharacterSubstitutionField_;
@synthesize useProxyCheckBox = useProxyCheckBox_;
@synthesize proxyHostField = proxyHostField_;
@synthesize proxyPortField = proxyPortField_;

@synthesize addAccountWindow = addAccountWindow_;
@synthesize setupFullNameField = setupFullNameField_;
@synthesize setupSIPAddressField = setupSIPAddressField_;
@synthesize setupRegistrarField = setupRegistrarField_;
@synthesize setupUsernameField = setupUsernameField_;
@synthesize setupPasswordField = setupPasswordField_;
@synthesize addAccountWindowDefaultButton = addAccountWindowDefaultButton_;
@synthesize addAccountWindowOtherButton = addAccountWindowOtherButton_;

- (id)delegate {
  return delegate_;
}

- (void)setDelegate:(id)aDelegate {
  if (delegate_ == aDelegate)
    return;
  
  NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
  
  if (delegate_ != nil)
    [notificationCenter removeObserver:delegate_ name:nil object:self];
  
  if (aDelegate != nil) {
    if ([aDelegate respondsToSelector:@selector(preferenceControllerDidAddAccount:)])
      [notificationCenter addObserver:aDelegate
                             selector:@selector(preferenceControllerDidAddAccount:)
                                 name:AKPreferenceControllerDidAddAccountNotification
                               object:self];
    
    if ([aDelegate respondsToSelector:@selector(preferenceControllerDidRemoveAccount:)])
      [notificationCenter addObserver:aDelegate
                             selector:@selector(preferenceControllerDidRemoveAccount:)
                                 name:AKPreferenceControllerDidRemoveAccountNotification
                               object:self];
    
    if ([aDelegate respondsToSelector:@selector(preferenceControllerDidChangeAccountEnabled:)])
      [notificationCenter addObserver:aDelegate
                             selector:@selector(preferenceControllerDidChangeAccountEnabled:)
                                 name:AKPreferenceControllerDidChangeAccountEnabledNotification
                               object:self];
    
    if ([aDelegate respondsToSelector:@selector(preferenceControllerDidSwapAccounts:)])
      [notificationCenter addObserver:aDelegate
                             selector:@selector(preferenceControllerDidSwapAccounts:)
                                 name:AKPreferenceControllerDidSwapAccountsNotification
                               object:self];
    
    if ([aDelegate respondsToSelector:@selector(preferenceControllerDidChangeNetworkSettings:)])
      [notificationCenter addObserver:aDelegate
                             selector:@selector(preferenceControllerDidChangeNetworkSettings:)
                                 name:AKPreferenceControllerDidChangeNetworkSettingsNotification
                               object:self];
  }
  
  delegate_ = aDelegate;
}

- (id)init {
  self = [super initWithWindowNibName:@"Preferences"];
  
  NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
  
  // Subscribe on mouse-down event of the ringing sound selection.
  [notificationCenter addObserver:self
                         selector:@selector(popUpButtonWillPopUp:)
                             name:NSPopUpButtonWillPopUpNotification
                           object:[self ringtonePopUp]];
  
  // Subscribe to User Agent start events.
  [notificationCenter addObserver:self
                         selector:@selector(telephoneUserAgentDidFinishStarting:)
                             name:AKTelephoneUserAgentDidFinishStartingNotification
                           object:nil];
  
  return self;
}

- (void)dealloc {
  [self setDelegate:nil];
  
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  
  [toolbar_ release];
  [generalToolbarItem_ release];
  [accountsToolbarItem_ release];
  [soundToolbarItem_ release];
  [networkToolbarItem_ release];
  [generalView_ release];
  [accountsView_ release];
  [soundView_ release];
  [networkView_ release];
  
  [soundInputPopUp_ release];
  [soundOutputPopUp_ release];
  [ringtoneOutputPopUp_ release];
  [ringtonePopUp_ release];
  
  [transportPortField_ release];
  [transportPortCell_ release];
  [STUNServerHostField_ release];
  [STUNServerPortField_ release];
  [useICECheckBox_ release];
  [outboundProxyHostField_ release];
  [outboundProxyPortField_ release];
  
  [accountsTable_ release];
  [accountEnabledCheckBox_ release];
  [fullNameField_ release];
  [SIPAddressField_ release];
  [registrarField_ release];
  [usernameField_ release];
  [passwordField_ release];
  [reregistrationTimeField_ release];
  [substitutePlusCharacterCheckBox_ release];
  [plusCharacterSubstitutionField_ release];
  [useProxyCheckBox_ release];
  [proxyHostField_ release];
  [proxyPortField_ release];
  
  [addAccountWindow_ release];
  [setupFullNameField_ release];
  [setupSIPAddressField_ release];
  [setupRegistrarField_ release];
  [setupUsernameField_ release];
  [setupPasswordField_ release];
  [addAccountWindowDefaultButton_ release];
  [addAccountWindowOtherButton_ release];
  
  [super dealloc];
}

- (void)awakeFromNib {
  // Register a pasteboard type to rearrange accounts with drag and drop.
  [[self accountsTable] registerForDraggedTypes:
   [NSArray arrayWithObject:kAKTelephoneAccountPboardType]];
}

- (void)windowDidLoad {
  [self updateAvailableSounds];
  
  [[self toolbar] setSelectedItemIdentifier:[[self generalToolbarItem]
                                             itemIdentifier]];
  [[self window] ak_resizeAndSwapToContentView:[self generalView]];
  [[self window] setTitle:
   NSLocalizedString(@"General", @"General preferences window title.")];
  
  [self updateAudioDevices];
  
  // Show transport port in the network preferences as a placeholder string.
  if ([[[NSApp delegate] telephone] userAgentStarted]) {
    [[self transportPortCell] setPlaceholderString:
     [[NSNumber numberWithUnsignedInteger:
       [[[NSApp delegate] telephone] transportPort]] stringValue]];
  }
  
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  
  if ([[defaults objectForKey:kTransportPort] integerValue] > 0) {
    [[self transportPortField] setIntegerValue:
     [[defaults objectForKey:kTransportPort] integerValue]];
  }
  
  [[self STUNServerHostField] setStringValue:
   [defaults stringForKey:kSTUNServerHost]];
  
  if ([[defaults objectForKey:kSTUNServerPort] integerValue] > 0) {
    [[self STUNServerPortField] setIntegerValue:
     [[defaults objectForKey:kSTUNServerPort] integerValue]];
  }
  
  [[self useICECheckBox] setState:
   [[defaults objectForKey:kUseICE] integerValue]];
  
  [[self outboundProxyHostField] setStringValue:
   [defaults stringForKey:kOutboundProxyHost]];
  
  if ([[defaults objectForKey:kOutboundProxyPort] integerValue] > 0) {
    [[self outboundProxyPortField] setIntegerValue:
     [[defaults objectForKey:kOutboundProxyPort] integerValue]];
  }
  
  NSInteger row = [[self accountsTable] selectedRow];
  if (row != -1)
    [self populateFieldsForAccountAtIndex:row];
}

- (IBAction)changeView:(id)sender {
  // If the user switches from Network to some other view, check for network
  // settings changes.
  if ([[[self window] contentView] isEqual:[self networkView]] &&
      [sender tag] != kNetworkPreferencesTag) {
    if ([self checkForNetworkSettingsChanges:sender])
      return;
  }
  
  NSView *view;
  NSString *title;
  NSView *firstResponderView;
  
  switch ([sender tag]) {
      case kGeneralPreferencesTag:
        view = [self generalView];
        title = NSLocalizedString(@"General",
                                  @"General preferences window title.");
        firstResponderView = nil;
        break;
      case kAccountsPreferencesTag:
        view = [self accountsView];
        title = NSLocalizedString(@"Accounts",
                                  @"Accounts preferences window title.");
        firstResponderView = [self accountsTable];
        break;
      case kSoundPreferencesTag:
        view = [self soundView];
        title = NSLocalizedString(@"Sound", @"Sound preferences window title.");
        firstResponderView = nil;
        break;
      case kNetworkPreferencesTag:
        view = [self networkView];
        title = NSLocalizedString(@"Network",
                                  @"Network preferences window title.");
        firstResponderView = nil;
        break;
      default:
        view = nil;
        title = NSLocalizedString(@"Telephone Preferences",
                                  @"Preferences default window title.");
        firstResponderView = nil;
        break;
  }
  
  [[self window] ak_resizeAndSwapToContentView:view animate:YES];
  [[self window] setTitle:title];
  if ([firstResponderView acceptsFirstResponder])
    [[self window] makeFirstResponder:firstResponderView];
}

- (IBAction)showAddAccountSheet:(id)sender {
  if ([self addAccountWindow] == nil)
    [NSBundle loadNibNamed:@"AddAccount" owner:self];
  
  [[self setupFullNameField] setStringValue:@""];
  [[self setupSIPAddressField] setStringValue:@""];
  [[self setupRegistrarField] setStringValue:@""];
  [[self setupUsernameField] setStringValue:@""];
  [[self setupPasswordField] setStringValue:@""];
  [[self addAccountWindow] makeFirstResponder:[self setupFullNameField]];
  
  [NSApp beginSheet:[self addAccountWindow]
     modalForWindow:[[self accountsView] window]
      modalDelegate:nil
     didEndSelector:NULL
        contextInfo:NULL];
}

- (IBAction)closeSheet:(id)sender {
  [NSApp endSheet:[sender window]];
  [[sender window] orderOut:sender];
}

- (IBAction)addAccount:(id)sender {
  if ([[[self setupFullNameField] stringValue] isEqual:@""] ||
      [[[self setupSIPAddressField] stringValue] isEqual:@""] ||
      [[[self setupRegistrarField] stringValue] isEqual:@""] ||
      [[[self setupUsernameField] stringValue] isEqual:@""]) {
    
    return;
  }
  
  NSMutableDictionary *accountDict = [NSMutableDictionary dictionary];
  [accountDict setObject:[NSNumber numberWithBool:YES] forKey:kAccountEnabled];
  [accountDict setObject:[[self setupFullNameField] stringValue] forKey:kFullName];
  [accountDict setObject:[[self setupSIPAddressField] stringValue] forKey:kSIPAddress];
  [accountDict setObject:[[self setupRegistrarField] stringValue] forKey:kRegistrar];
  [accountDict setObject:@"*" forKey:kRealm];
  [accountDict setObject:[[self setupUsernameField] stringValue] forKey:kUsername];
  [accountDict setObject:[NSNumber numberWithInteger:0] forKey:kReregistrationTime];
  [accountDict setObject:[NSNumber numberWithBool:NO] forKey:kSubstitutePlusCharacter];
  [accountDict setObject:@"00" forKey:kPlusCharacterSubstitutionString];
  [accountDict setObject:[NSNumber numberWithBool:NO] forKey:kUseProxy];
  [accountDict setObject:@"" forKey:kProxyHost];
  [accountDict setObject:[NSNumber numberWithInteger:0] forKey:kProxyPort];
  
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSMutableArray *savedAccounts
    = [NSMutableArray arrayWithArray:[defaults arrayForKey:kAccounts]];
  [savedAccounts addObject:accountDict];
  [defaults setObject:savedAccounts forKey:kAccounts];
  [defaults synchronize];
  
  // Inform accounts table about update
  [[self accountsTable] reloadData];
  
  BOOL success
    = [AKKeychain addItemWithServiceName:[NSString stringWithFormat:@"SIP: %@",
                                          [[self setupRegistrarField] stringValue]]
                             accountName:[[self setupUsernameField] stringValue]
                                password:[[self setupPasswordField] stringValue]];
  
  [self closeSheet:sender];
  
  if (success) {
    // Post notification with account just added
    [[NSNotificationCenter defaultCenter]
     postNotificationName:AKPreferenceControllerDidAddAccountNotification
                   object:self
                 userInfo:accountDict];
  }
  
  // Set the selection to the new account
  NSUInteger index = [[defaults arrayForKey:kAccounts] count] - 1;
  if (index != 0) {
    [[self accountsTable] selectRowIndexes:[NSIndexSet indexSetWithIndex:index]
                      byExtendingSelection:NO];
  }
}

- (IBAction)showRemoveAccountSheet:(id)sender {
  NSInteger index = [[self accountsTable] selectedRow];
  if (index == -1) {
    NSBeep();
    return;
  }
  
  NSTableColumn *theColumn
    = [[[NSTableColumn alloc] initWithIdentifier:@"SIPAddress"] autorelease];
  NSString *selectedAccount
    = [[[self accountsTable] dataSource] tableView:[self accountsTable]
                         objectValueForTableColumn:theColumn row:index];
  
  NSAlert *alert = [[[NSAlert alloc] init] autorelease];
  [alert addButtonWithTitle:NSLocalizedString(@"Delete", @"Delete button.")];
  [alert addButtonWithTitle:NSLocalizedString(@"Cancel", @"Cancel button.")];
  [[[alert buttons] objectAtIndex:1] setKeyEquivalent:@"\033"];
  [alert setMessageText:[NSString stringWithFormat:
                         NSLocalizedString(@"Delete \\U201C%@\\U201D?",
                                           @"Account removal confirmation."),
                         selectedAccount]];
  [alert setInformativeText:
   [NSString stringWithFormat:
    NSLocalizedString(@"This will delete your currently set up account \\U201C%@\\U201D.",
                      @"Account removal confirmation informative text."),
                             selectedAccount]];
  [alert setAlertStyle:NSWarningAlertStyle];
  [alert beginSheetModalForWindow:[[self accountsTable] window]
                    modalDelegate:self
                   didEndSelector:@selector(removeAccountAlertDidEnd:returnCode:contextInfo:)
                      contextInfo:NULL];
}

- (void)removeAccountAlertDidEnd:(NSAlert *)alert
                      returnCode:(int)returnCode
                     contextInfo:(void *)contextInfo {
  if (returnCode == NSAlertFirstButtonReturn)
    [self removeAccountAtIndex:[[self accountsTable] selectedRow]];
}

- (void)removeAccountAtIndex:(NSInteger)index {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSMutableArray *savedAccounts
    = [NSMutableArray arrayWithArray:[defaults arrayForKey:kAccounts]];
  [savedAccounts removeObjectAtIndex:index];
  [defaults setObject:savedAccounts forKey:kAccounts];
  [defaults synchronize];
  
  [[NSNotificationCenter defaultCenter]
   postNotificationName:AKPreferenceControllerDidRemoveAccountNotification
                 object:self
               userInfo:[NSDictionary
                         dictionaryWithObject:[NSNumber numberWithInteger:index]
                                       forKey:kAccountIndex]];
  [[self accountsTable] reloadData];
  
  // Select none, last or previous account.
  if ([savedAccounts count] == 0) {
    return;
    
  } else if (index >= ([savedAccounts count] - 1)) {
    [[self accountsTable] selectRowIndexes:
     [NSIndexSet indexSetWithIndex:([savedAccounts count] - 1)]
                      byExtendingSelection:NO];
    
    [self populateFieldsForAccountAtIndex:([savedAccounts count] - 1)];
    
  } else {
    [[self accountsTable] selectRowIndexes:
     [NSIndexSet indexSetWithIndex:index] byExtendingSelection:NO];
    
    [self populateFieldsForAccountAtIndex:index];
  }
}

- (void)populateFieldsForAccountAtIndex:(NSInteger)index {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSArray *savedAccounts = [defaults arrayForKey:kAccounts];
  
  if (index >= 0) {
    NSDictionary *accountDict = [savedAccounts objectAtIndex:index];
    
    [[self accountEnabledCheckBox] setEnabled:YES];
    
    // Conditionally enable fields and set checkboxes state.
    if ([[accountDict objectForKey:kAccountEnabled] boolValue]) {
      [[self accountEnabledCheckBox] setState:NSOnState];
      [[self fullNameField] setEnabled:NO];
      [[self SIPAddressField] setEnabled:NO];
      [[self registrarField] setEnabled:NO];
      [[self usernameField] setEnabled:NO];
      [[self passwordField] setEnabled:NO];
      [[self reregistrationTimeField] setEnabled:NO];
      [[self substitutePlusCharacterCheckBox] setEnabled:NO];
      [[self substitutePlusCharacterCheckBox] setState:
       [[accountDict objectForKey:kSubstitutePlusCharacter] integerValue]];
      [[self plusCharacterSubstitutionField] setEnabled:NO];
      [[self useProxyCheckBox] setState:[[accountDict objectForKey:kUseProxy]
                                         integerValue]];
      [[self useProxyCheckBox] setEnabled:NO];
      [[self proxyHostField] setEnabled:NO];
      [[self proxyPortField] setEnabled:NO];
      
    } else {
      [[self accountEnabledCheckBox] setState:NSOffState];
      [[self fullNameField] setEnabled:YES];
      [[self SIPAddressField] setEnabled:YES];
      [[self registrarField] setEnabled:YES];
      [[self usernameField] setEnabled:YES];
      [[self passwordField] setEnabled:YES];
      
      [[self reregistrationTimeField] setEnabled:YES];
      [[self substitutePlusCharacterCheckBox] setEnabled:YES];
      [[self substitutePlusCharacterCheckBox] setState:
       [[accountDict objectForKey:kSubstitutePlusCharacter] integerValue]];
      if ([[self substitutePlusCharacterCheckBox] state] == NSOnState)
        [[self plusCharacterSubstitutionField] setEnabled:YES];
      else
        [[self plusCharacterSubstitutionField] setEnabled:NO];
      
      [[self useProxyCheckBox] setEnabled:YES];
      [[self useProxyCheckBox] setState:[[accountDict objectForKey:kUseProxy]
                                         integerValue]];
      if ([[self useProxyCheckBox] state] == NSOnState) {
        [[self proxyHostField] setEnabled:YES];
        [[self proxyPortField] setEnabled:YES];
      } else {
        [[self proxyHostField] setEnabled:NO];
        [[self proxyPortField] setEnabled:NO];
      }
    }
    
    // Populate fields.
    [[self fullNameField] setStringValue:[accountDict objectForKey:kFullName]];
    [[self SIPAddressField] setStringValue:[accountDict objectForKey:kSIPAddress]];
    [[self registrarField] setStringValue:[accountDict objectForKey:kRegistrar]];
    [[self usernameField] setStringValue:[accountDict objectForKey:kUsername]];
    
    [[self passwordField] setStringValue:
     [AKKeychain passwordForServiceName:[NSString stringWithFormat:@"SIP: %@",
                                         [accountDict objectForKey:kRegistrar]]
                            accountName:[accountDict objectForKey:kUsername]]];
    
    if ([[accountDict objectForKey:kReregistrationTime] integerValue] > 0) {
      [[self reregistrationTimeField] setIntegerValue:
       [[accountDict objectForKey:kReregistrationTime] integerValue]];
    } else {
      [[self reregistrationTimeField] setStringValue:@""];
    }
    
    if ([accountDict objectForKey:kPlusCharacterSubstitutionString] != nil) {
      [[self plusCharacterSubstitutionField] setStringValue:
       [accountDict objectForKey:kPlusCharacterSubstitutionString]];
    } else {
      [[self plusCharacterSubstitutionField] setStringValue:@"00"];
    }
    
    if ([accountDict objectForKey:kProxyHost] != nil) {
      [[self proxyHostField] setStringValue:
       [accountDict objectForKey:kProxyHost]];
    } else {
      [[self proxyHostField] setStringValue:@""];
    }
    
    if ([[accountDict objectForKey:kProxyPort] integerValue] > 0) {
      [[self proxyPortField] setIntegerValue:
       [[accountDict objectForKey:kProxyPort] integerValue]];
    } else {
      [[self proxyPortField] setStringValue:@""];
    }
    
  } else {
    [[self accountEnabledCheckBox] setState:NSOffState];
    [[self fullNameField] setStringValue:@""];
    [[self SIPAddressField] setStringValue:@""];
    [[self registrarField] setStringValue:@""];
    [[self usernameField] setStringValue:@""];
    [[self passwordField] setStringValue:@""];
    [[self reregistrationTimeField] setStringValue:@""];
    [[self substitutePlusCharacterCheckBox] setState:NSOffState];
    [[self plusCharacterSubstitutionField] setStringValue:@"00"];
    [[self useProxyCheckBox] setState:NSOffState];
    [[self proxyHostField] setStringValue:@""];
    [[self proxyPortField] setStringValue:@""];
    
    [[self accountEnabledCheckBox] setEnabled:NO];
    [[self fullNameField] setEnabled:NO];
    [[self SIPAddressField] setEnabled:NO];
    [[self registrarField] setEnabled:NO];
    [[self usernameField] setEnabled:NO];
    [[self passwordField] setEnabled:NO];
    [[self reregistrationTimeField] setEnabled:NO];
    [[self substitutePlusCharacterCheckBox] setEnabled:NO];
    [[self plusCharacterSubstitutionField] setEnabled:NO];
    [[self useProxyCheckBox] setEnabled:NO];
    [[self proxyHostField] setEnabled:NO];
    [[self proxyPortField] setEnabled:NO];
  }
}

- (IBAction)changeAccountEnabled:(id)sender {
  NSInteger index = [[self accountsTable] selectedRow];
  if (index == -1)
    return;
  
  NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
  
  [userInfo setObject:[NSNumber numberWithInteger:index] forKey:kAccountIndex];
  
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  
  NSMutableArray *savedAccounts
    = [NSMutableArray arrayWithArray:[defaults arrayForKey:kAccounts]];
  
  NSMutableDictionary *accountDict
    = [NSMutableDictionary dictionaryWithDictionary:
       [savedAccounts objectAtIndex:index]];
  
  BOOL isChecked = ([[self accountEnabledCheckBox] state] == NSOnState) ? YES : NO;
  [accountDict setObject:[NSNumber numberWithBool:isChecked]
                  forKey:kAccountEnabled];
  
  if (isChecked) {
    // User enabled the account.
    // Account fields could be edited, save them.
    [accountDict setObject:[[self fullNameField] stringValue]
                    forKey:kFullName];
    [accountDict setObject:[[self SIPAddressField] stringValue]
                    forKey:kSIPAddress];
    [accountDict setObject:[[self registrarField] stringValue]
                    forKey:kRegistrar];
    [accountDict setObject:[[self usernameField] stringValue]
                    forKey:kUsername];
    
    NSString *keychainServiceName = [NSString stringWithFormat:@"SIP: %@",
                                     [[self registrarField] stringValue]];
    
    NSString *keychainAccountName = [[self usernameField] stringValue];
    
    NSString *keychainPassword
      = [AKKeychain passwordForServiceName:keychainServiceName
                               accountName:keychainAccountName];
    
    NSString *currentPassword = [[self passwordField] stringValue];
    
    // Save password only if it's been changed.
    if (![keychainPassword isEqualToString:currentPassword]) {
      [AKKeychain addItemWithServiceName:keychainServiceName
                             accountName:keychainAccountName
                                password:currentPassword];
    }
    
    [accountDict setObject:[NSNumber numberWithInteger:
                            [[self reregistrationTimeField] integerValue]]
                    forKey:kReregistrationTime];
    
    if ([[self substitutePlusCharacterCheckBox] state] == NSOnState) {
      [accountDict setObject:[NSNumber numberWithBool:YES]
                      forKey:kSubstitutePlusCharacter];
    } else {
      [accountDict setObject:[NSNumber numberWithBool:NO]
                      forKey:kSubstitutePlusCharacter];
    }
    
    [accountDict setObject:[[self plusCharacterSubstitutionField] stringValue]
                    forKey:kPlusCharacterSubstitutionString];
    
    if ([[self useProxyCheckBox] state] == NSOnState) {
      [accountDict setObject:[NSNumber numberWithBool:YES] forKey:kUseProxy];
    } else {
      [accountDict setObject:[NSNumber numberWithBool:NO] forKey:kUseProxy];
    }
    
    [accountDict setObject:[[self proxyHostField] stringValue]
                    forKey:kProxyHost];
    [accountDict setObject:[NSNumber numberWithInteger:[[self proxyPortField]
                                                        integerValue]]
                    forKey:kProxyPort];
    
    // Disable account fields.
    [[self fullNameField] setEnabled:NO];
    [[self SIPAddressField] setEnabled:NO];
    [[self registrarField] setEnabled:NO];
    [[self usernameField] setEnabled:NO];
    [[self passwordField] setEnabled:NO];
    
    [[self reregistrationTimeField] setEnabled:NO];
    [[self substitutePlusCharacterCheckBox] setEnabled:NO];
    [[self plusCharacterSubstitutionField] setEnabled:NO];
    [[self useProxyCheckBox] setEnabled:NO];
    [[self proxyHostField] setEnabled:NO];
    [[self proxyPortField] setEnabled:NO];
    
    // Mark accounts table as needing redisplay.
    [[self accountsTable] reloadData];
    
  } else {
    // User disabled the account - enable account fields, set checkboxes state.
    [[self fullNameField] setEnabled:YES];
    [[self SIPAddressField] setEnabled:YES];
    [[self registrarField] setEnabled:YES];
    [[self usernameField] setEnabled:YES];
    [[self passwordField] setEnabled:YES];
    
    [[self reregistrationTimeField] setEnabled:YES];
    [[self substitutePlusCharacterCheckBox] setEnabled:YES];
    [[self substitutePlusCharacterCheckBox] setState:
     [[accountDict objectForKey:kSubstitutePlusCharacter] integerValue]];
    if ([[self substitutePlusCharacterCheckBox] state] == NSOnState)
      [[self plusCharacterSubstitutionField] setEnabled:YES];
    
    [[self useProxyCheckBox] setEnabled:YES];
    [[self useProxyCheckBox] setState:[[accountDict objectForKey:kUseProxy]
                                       integerValue]];
    if ([[self useProxyCheckBox] state] == NSOnState) {
      [[self proxyHostField] setEnabled:YES];
      [[self proxyPortField] setEnabled:YES];
    }
  }
  
  [savedAccounts replaceObjectAtIndex:index withObject:accountDict];
  
  // Save to defaults
  [defaults setObject:savedAccounts forKey:kAccounts];
  [defaults synchronize];
  
  [[NSNotificationCenter defaultCenter]
   postNotificationName:AKPreferenceControllerDidChangeAccountEnabledNotification
                 object:self
               userInfo:userInfo];
}

- (IBAction)changeSubstitutePlusCharacter:(id)sender {
  [[self plusCharacterSubstitutionField] setEnabled:
   ([[self substitutePlusCharacterCheckBox] state] == NSOnState)];
}

- (IBAction)changeUseProxy:(id)sender {
  BOOL isChecked = ([[self useProxyCheckBox] state] == NSOnState) ? YES : NO;
  [[self proxyHostField] setEnabled:isChecked];
  [[self proxyPortField] setEnabled:isChecked];
}

- (IBAction)changeSoundIO:(id)sender {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [defaults setObject:[[self soundInputPopUp] titleOfSelectedItem]
               forKey:kSoundInput];
  [defaults setObject:[[self soundOutputPopUp] titleOfSelectedItem]
               forKey:kSoundOutput];
  [defaults setObject:[[self ringtoneOutputPopUp] titleOfSelectedItem]
               forKey:kRingtoneOutput];
  
  [[NSApp delegate] selectSoundIO];
}

- (void)updateAudioDevices {
  // Populate sound IO pop-up buttons
  NSArray *audioDevices = [[NSApp delegate] audioDevices];
  NSMenu *soundInputMenu = [[[NSMenu alloc] init] autorelease];
  NSMenu *soundOutputMenu = [[[NSMenu alloc] init] autorelease];
  NSMenu *ringtoneOutputMenu = [[[NSMenu alloc] init] autorelease];
  
  for (NSUInteger i = 0; i < [audioDevices count]; ++i) {
    NSDictionary *deviceDict = [audioDevices objectAtIndex:i];
    
    NSMenuItem *aMenuItem = [[NSMenuItem alloc] init];
    [aMenuItem setTitle:[deviceDict objectForKey:kAudioDeviceName]];
    [aMenuItem setTag:i];
    
    if ([[deviceDict objectForKey:kAudioDeviceInputsCount] integerValue] > 0)
      [soundInputMenu addItem:[[aMenuItem copy] autorelease]];
    
    if ([[deviceDict objectForKey:kAudioDeviceOutputsCount] integerValue] > 0) {
      [soundOutputMenu addItem:[[aMenuItem copy] autorelease]];
      [ringtoneOutputMenu addItem:[[aMenuItem copy] autorelease]];
    }
    
    [aMenuItem release];
  }
  
  [[self soundInputPopUp] setMenu:soundInputMenu];
  [[self soundOutputPopUp] setMenu:soundOutputMenu];
  [[self ringtoneOutputPopUp] setMenu:ringtoneOutputMenu];
  
  // Select saved sound devices
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  
  NSString *lastSoundInput = [defaults stringForKey:kSoundInput];
  if (lastSoundInput != nil &&
      [[self soundInputPopUp] itemWithTitle:lastSoundInput] != nil) {
    [[self soundInputPopUp] selectItemWithTitle:lastSoundInput];
  }
  
  NSString *lastSoundOutput = [defaults stringForKey:kSoundOutput];
  if (lastSoundOutput != nil &&
      [[self soundOutputPopUp] itemWithTitle:lastSoundOutput] != nil) {
    [[self soundOutputPopUp] selectItemWithTitle:lastSoundOutput];
  }
  
  NSString *lastRingtoneOutput = [defaults stringForKey:kRingtoneOutput];
  if (lastRingtoneOutput != nil &&
      [[self ringtoneOutputPopUp] itemWithTitle:lastRingtoneOutput] != nil) {
    [[self ringtoneOutputPopUp] selectItemWithTitle:lastRingtoneOutput];
  }
}

- (void)updateAvailableSounds {
  NSArray *libraryPaths
    = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,
                                          NSAllDomainsMask,
                                          YES);
  if ([libraryPaths count] <= 0)
    return;
  
  NSMenu *soundsMenu = [[[NSMenu alloc] init] autorelease];
  NSFileManager *fileManager = [NSFileManager defaultManager];
  NSSet *allowedSoundFileExtensions
    = [NSSet setWithObjects:@"aiff", @"aif", @"aifc",
       @"mp3", @"wav", @"sd2", @"au", @"snd", @"m4a", @"m4p", nil];
  
  for (NSUInteger i = 0; i < [libraryPaths count]; ++i) {
    NSString *aPath = [libraryPaths objectAtIndex:i];
    NSString *soundPath = [aPath stringByAppendingPathComponent:@"Sounds"];
    NSArray *soundFiles = [fileManager contentsOfDirectoryAtPath:soundPath
                                                           error:NULL];
    
    BOOL shouldAddSeparator = ([soundsMenu numberOfItems] > 0) ? YES : NO;
    
    for (NSUInteger j = 0; j < [soundFiles count]; ++j) {
      NSString *aFile = [soundFiles objectAtIndex:j];
      if (![allowedSoundFileExtensions containsObject:[aFile pathExtension]])
        continue;
      
      NSString *aSound = [aFile stringByDeletingPathExtension];
      if ([soundsMenu itemWithTitle:aSound] == nil) {
        if (shouldAddSeparator) {
          [soundsMenu addItem:[NSMenuItem separatorItem]];
          shouldAddSeparator = NO;
        }
        
        NSMenuItem *aMenuItem = [[[NSMenuItem alloc] init] autorelease];
        [aMenuItem setTitle:aSound];
        [soundsMenu addItem:aMenuItem];
      }
    }
  }
    
  [[self ringtonePopUp] setMenu:soundsMenu];
  
  NSString *savedSound
    = [[NSUserDefaults standardUserDefaults] stringForKey:kRingingSound];
  
  if ([soundsMenu itemWithTitle:savedSound] != nil)
    [[self ringtonePopUp] selectItemWithTitle:savedSound];
}

- (IBAction)changeRingtone:(id)sender {
  // Stop currently playing ringtone.
  [[[NSApp delegate] ringtone] stop];
  
  NSString *soundName = [sender title];
  [[NSUserDefaults standardUserDefaults] setObject:soundName
                                            forKey:kRingingSound];
  [[NSApp delegate] setRingtone:[NSSound soundNamed:soundName]];
  
  // Play selected ringtone once.
  [[[NSApp delegate] ringtone] play];
}

// Check if network settings were changed, show an alert sheet to save, cancel or don't save.
// Returns YES if changes were made to the network settings; returns NO otherwise.
- (BOOL)checkForNetworkSettingsChanges:(id)sender {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  
  NSNumber *newTransportPort
    = [NSNumber numberWithInteger:[[self transportPortField] integerValue]];
  
  NSString *newSTUNServerHost = [[self STUNServerHostField] stringValue];
  
  NSNumber *newSTUNServerPort
    = [NSNumber numberWithInteger:[[self STUNServerPortField] integerValue]];
  
  BOOL newUseICE = ([[self useICECheckBox] state] == NSOnState) ? YES : NO;
  
  NSString *newOutboundProxyHost = [[self outboundProxyHostField] stringValue];
  
  NSNumber *newOutboundProxyPort
    = [NSNumber numberWithInteger:[[self outboundProxyPortField] integerValue]];
  
  if (![[defaults objectForKey:kTransportPort] isEqualToNumber:newTransportPort] ||
      ![[defaults objectForKey:kSTUNServerHost] isEqualToString:newSTUNServerHost] ||
      ![[defaults objectForKey:kSTUNServerPort] isEqualToNumber:newSTUNServerPort] ||
      [defaults boolForKey:kUseICE] != newUseICE ||
      ![[defaults objectForKey:kOutboundProxyHost] isEqualToString:newOutboundProxyHost] ||
      ![[defaults objectForKey:kOutboundProxyPort] isEqualToNumber:newOutboundProxyPort])
  {
    // Explicitly select Network toolbar item.
    [[self toolbar] setSelectedItemIdentifier:[[self networkToolbarItem]
                                               itemIdentifier]];
    // Show alert to the user.
    NSAlert *alert = [[[NSAlert alloc] init] autorelease];
    [alert addButtonWithTitle:NSLocalizedString(@"Save", @"Save button.")];
    [alert addButtonWithTitle:NSLocalizedString(@"Cancel", @"Cancel button.")];
    [alert addButtonWithTitle:
     NSLocalizedString(@"Don't Save", @"Don't save button.")];
    [[[alert buttons] objectAtIndex:1] setKeyEquivalent:@"\033"];
    [alert setMessageText:
     NSLocalizedString(@"Save changes to the network settings?",
                       @"Network settings change confirmation.")];
    [alert setInformativeText:
     NSLocalizedString(@"New network settings will be applied immediately, all "
                       "accounts will be reconnected.",
                       @"Network settings change confirmation informative text.")];
    
    [alert beginSheetModalForWindow:[self window]
                      modalDelegate:self
                     didEndSelector:@selector(networkSettingsChangeAlertDidEnd:returnCode:contextInfo:)
                        contextInfo:sender];
    return YES;
  }
  
  return NO;
}

- (void)networkSettingsChangeAlertDidEnd:(NSAlert *)alert
                              returnCode:(int)returnCode
                             contextInfo:(void *)contextInfo {
  // Close the sheet.
  [[alert window] orderOut:nil];
  
  if (returnCode == NSAlertSecondButtonReturn)
    return;
  
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  id sender = (id)contextInfo;
  
  if (returnCode == NSAlertFirstButtonReturn) {
    [[self transportPortCell] setPlaceholderString:
     [[self transportPortField] stringValue]];
    
    [defaults setObject:[NSNumber numberWithInteger:
                         [[self transportPortField] integerValue]]
                 forKey:kTransportPort];
    
    [defaults setObject:[[self STUNServerHostField] stringValue]
                 forKey:kSTUNServerHost];
    
    [defaults setObject:[NSNumber numberWithInteger:
                         [[self STUNServerPortField] integerValue]]
                 forKey:kSTUNServerPort];
    
    BOOL useICEFlag = ([[self useICECheckBox] state] == NSOnState) ? YES : NO;
    [defaults setBool:useICEFlag forKey:kUseICE];
    
    [defaults setObject:[[self outboundProxyHostField] stringValue]
                 forKey:kOutboundProxyHost];
    
    [defaults setObject:[NSNumber numberWithInteger:
                         [[self outboundProxyPortField] integerValue]]
                 forKey:kOutboundProxyPort];
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:AKPreferenceControllerDidChangeNetworkSettingsNotification
                   object:self];
    
  } else if (returnCode == NSAlertThirdButtonReturn) {
    if ([[defaults objectForKey:kTransportPort] integerValue] == 0) {
      [[self transportPortField] setStringValue:@""];
    } else {
      [[self transportPortField] setIntegerValue:
       [[defaults objectForKey:kTransportPort] integerValue]];
    }
    
    [[self STUNServerHostField] setStringValue:
     [defaults objectForKey:kSTUNServerHost]];
    
    if ([[defaults objectForKey:kSTUNServerPort] integerValue] == 0) {
      [[self STUNServerPortField] setStringValue:@""];
    } else {
      [[self STUNServerPortField] setIntegerValue:
       [[defaults objectForKey:kSTUNServerPort] integerValue]];
    }
    
    [[self useICECheckBox] setState:[[defaults objectForKey:kUseICE]
                                     integerValue]];
    
    [[self outboundProxyHostField] setStringValue:
     [defaults objectForKey:kOutboundProxyHost]];
    
    if ([[defaults objectForKey:kOutboundProxyPort] integerValue] == 0) {
      [[self outboundProxyPortField] setStringValue:@""];
    } else {
      [[self outboundProxyPortField] setIntegerValue:
       [[defaults objectForKey:kOutboundProxyPort] integerValue]];
    }
  }
  
  if ([sender isMemberOfClass:[NSToolbarItem class]]) {
    [[self toolbar] setSelectedItemIdentifier:[sender itemIdentifier]];
    [self changeView:sender];
  } else if ([sender isMemberOfClass:[NSWindow class]])
    [sender close];
}


#pragma mark -
#pragma mark NSTableView data source

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  
  return [[defaults arrayForKey:kAccounts] count];
}

- (id)tableView:(NSTableView *)aTableView
objectValueForTableColumn:(NSTableColumn *)aTableColumn
            row:(NSInteger)rowIndex {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  
  NSDictionary *accountDict
    = [[defaults arrayForKey:kAccounts] objectAtIndex:rowIndex];
  
  return [accountDict objectForKey:[aTableColumn identifier]];
}

- (BOOL)tableView:(NSTableView *)aTableView
writeRowsWithIndexes:(NSIndexSet *)rowIndexes
     toPasteboard:(NSPasteboard *)pboard {
  NSData *data = [NSKeyedArchiver archivedDataWithRootObject:rowIndexes];
  
  [pboard declareTypes:[NSArray arrayWithObject:kAKTelephoneAccountPboardType]
                 owner:self];
  
  [pboard setData:data forType:kAKTelephoneAccountPboardType];
  
  return YES;
}

- (NSDragOperation)tableView:(NSTableView *)aTableView
                validateDrop:(id <NSDraggingInfo>)info
                 proposedRow:(NSInteger)row
       proposedDropOperation:(NSTableViewDropOperation)operation {
  NSData *data
    = [[info draggingPasteboard] dataForType:kAKTelephoneAccountPboardType];
  NSIndexSet *indexes = [NSKeyedUnarchiver unarchiveObjectWithData:data];
  NSInteger draggingRow = [indexes firstIndex];
  
  if (row == draggingRow || row == draggingRow + 1)
    return NSDragOperationNone;
  
  [[self accountsTable] setDropRow:row dropOperation:NSTableViewDropAbove];
  
  return NSDragOperationMove;
}

- (BOOL)tableView:(NSTableView *)aTableView
       acceptDrop:(id <NSDraggingInfo>)info
              row:(NSInteger)row
    dropOperation:(NSTableViewDropOperation)operation {
  NSData *data
    = [[info draggingPasteboard] dataForType:kAKTelephoneAccountPboardType];
  NSIndexSet *indexes = [NSKeyedUnarchiver unarchiveObjectWithData:data];
  NSInteger draggingRow = [indexes firstIndex];
  
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSMutableArray *accounts = [[defaults arrayForKey:kAccounts] mutableCopy];
  id selectedAccount
    = [accounts objectAtIndex:[[self accountsTable] selectedRow]];
  
  // Swap accounts.
  [accounts insertObject:[accounts objectAtIndex:draggingRow] atIndex:row];
  if (draggingRow < row)
    [accounts removeObjectAtIndex:draggingRow];
  else if (draggingRow > row)
    [accounts removeObjectAtIndex:(draggingRow + 1)];
  else  // This should never happen because we don't validate such drop.
    return NO;
  
  [defaults setObject:accounts forKey:kAccounts];
  [defaults synchronize];
  
  [[self accountsTable] reloadData];
  
  // Preserve account selection.
  [[self accountsTable] selectRow:[accounts indexOfObject:selectedAccount]
             byExtendingSelection:NO];
  
  [[NSNotificationCenter defaultCenter]
   postNotificationName:AKPreferenceControllerDidSwapAccountsNotification
                 object:self
               userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                         [NSNumber numberWithInteger:draggingRow], kSourceIndex,
                         [NSNumber numberWithInteger:row], kDestinationIndex,
                         nil]];
  
  return YES;
}


#pragma mark -
#pragma mark NSTableView delegate

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification {
  NSInteger row = [[self accountsTable] selectedRow];
  
  [self populateFieldsForAccountAtIndex:row];
}


#pragma mark -
#pragma mark NSToolbar delegate

// Supply selectable toolbar items
- (NSArray *)toolbarSelectableItemIdentifiers:(NSToolbar *)aToolbar {
  return [NSArray arrayWithObjects:
          [[self generalToolbarItem] itemIdentifier],
          [[self accountsToolbarItem] itemIdentifier],
          [[self soundToolbarItem] itemIdentifier],
          [[self networkToolbarItem] itemIdentifier],
          nil];
}


#pragma mark -
#pragma mark NSWindow delegate

- (BOOL)windowShouldClose:(id)window {
  BOOL networkSettingsChanged = [self checkForNetworkSettingsChanges:window];
  if (networkSettingsChanged)
    return NO;
  
  return YES;
}

- (void)windowWillClose:(NSNotification *)notification {
  // Stop currently playing ringtone that might be selected in Preferences.
  [[[NSApp delegate] ringtone] stop];
}


#pragma mark -
#pragma mark NSPopUpButton notification

- (void)popUpButtonWillPopUp:(NSNotification *)notification {
  [self updateAvailableSounds];
}


#pragma mark -
#pragma mark AKTelephone notifications

- (void)telephoneUserAgentDidFinishStarting:(NSNotification *)notification {
  if (![[[NSApp delegate] telephone] userAgentStarted])
    return;
  
  // Show transport port in the network preferences as a placeholder string.
  [[self transportPortCell] setPlaceholderString:
   [[NSNumber numberWithUnsignedInteger:
     [[[NSApp delegate] telephone] transportPort]] stringValue]];
}

@end
