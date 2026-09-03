//
//  CompositionRoot.swift
//  Telephone
//
//  Copyright © 2008-2016 Alexey Kuznetsov
//  Copyright © 2016-2022 64 Characters
//
//  Telephone is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Telephone is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//

import Contacts
import Foundation
import StoreKit
import SwiftUI
import UseCases

@MainActor
final class CompositionRoot: NSObject {
    @objc let userAgent: AKSIPUserAgent
    @objc let preferencesController: PreferencesController
    @objc let ringtonePlayback: RingtonePlaybackUseCase
    @objc let storeWindowPresenter: StoreWindowPresenter
    @objc let purchaseReminder: PurchaseReminderUseCase
    @objc let userAgentStart: UseCase
    @objc let settingsMigration: ProgressiveSettingsMigration
    @objc let orphanLogFileRemoval: OrphanLogFileRemoval
    @objc let workstationSleepStatus: WorkspaceSleepStatus
    @objc let callHistoryViewEventTargetFactory: AsyncCallHistoryViewEventTargetFactory
    @objc let callHistoryPurchaseCheckUseCaseFactory: AsyncCallHistoryPurchaseCheckUseCaseFactory
    @objc let logFileURL: LogFileURL
    @objc let defaultAppSettings: DefaultAppSettings
    @objc let helpMenuActionTarget: HelpMenuActionTarget
    @objc let accountControllers: AccountControllers
    @objc let nameServers: NameServers
    private let defaults: UserDefaults

    private let storeEventSource: StoreKitTransactionStoreEventSource
    private let userAgentEventSource: AKSIPUserAgentEventSource
    private let devicesChangeEventSource: CoreAudioSystemAudioDevicesChangeEventSource
    private let soundIOChangeEventSource: CoreAudioDefaultSystemSoundIOChangeEventSource
    private let accountsEventSource: PreferencesControllerAccountsEventSource
    private let callEventSource: AKSIPCallEventSource
    private let contactsChangeEventSource: Any
    private let dayChangeEventSource: NSCalendarDayChangeEventSource

    @objc init(preferencesControllerDelegate: PreferencesControllerDelegate, nameServersChangeEventTarget: NameServersChangeEventTarget, storeEventTarget: ObjCStoreEventTarget) {
        userAgent = AKSIPUserAgent.shared()
        defaults = UserDefaults.standard

        let systemAudioDevicesFactory = CoreAudioSystemAudioDevicesFactory(objectIDs: CoreAudioDevicesAudioObjectIDs())

        let useCaseFactory = DefaultUseCaseFactory(factory: systemAudioDevicesFactory, settings: defaults)

        let soundIOFactory = PreferredSoundIOFactory(
            devicesFactory: systemAudioDevicesFactory,
            defaultIOFactory: CoreAudioDefaultSystemSoundIOFactory(defaultIO: CoreAudioDefaultIO()),
            settings: defaults
        )

        let soundFactory = SimpleSoundFactory(
            load: SettingsRingtoneSoundConfigurationLoadUseCase(settings: defaults, factory: soundIOFactory),
            factory: NSSoundToSoundAdapterFactory()
        )

        ringtonePlayback = ConditionalRingtonePlaybackUseCase(
            origin: DefaultRingtonePlaybackUseCase(
                factory: RepeatingSoundFactory(
                    soundFactory: soundFactory,
                    timerFactory: FoundationToUseCasesTimerAdapterFactory()
                )
            ),
            delegate: userAgent
        )

        let receipt = StoreKitTransactionReceipt()

        let storeEventTargets = StoreEventTargets(targets: [ObjCStoreEventTargetAdapter(target: storeEventTarget)])

        storeWindowPresenter = StoreWindowPresenter(controller: StoreWindowController(contentViewController: NSHostingController(rootView: StoreKitStoreView(target: storeEventTargets))))

        purchaseReminder = PurchaseReminderUseCase(
            accounts: SettingsAccounts(settings: defaults),
            receipt: receipt,
            settings: UserDefaultsPurchaseReminderSettings(defaults: defaults),
            now: Date(),
            version: Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String,
            output: storeWindowPresenter
        )

        userAgentStart = UserAgentStartUseCase(agent: userAgent, factory: PurchaseCheckUseCaseFactory(receipt: receipt))

        storeEventSource = StoreKitTransactionStoreEventSource(target: storeEventTargets)

        let userAgentEventsUserAgentSoundIOSelection = UserAgentEventsUserAgentSoundIOSelectionUseCase(
            useCase: UserAgentSoundIOSelectionUseCase(
                devicesFactory: systemAudioDevicesFactory, soundIOFactory: soundIOFactory, agent: userAgent
            ),
            agent: userAgent,
            calls: userAgent
        )

        let userAgentSoundIOSelection = AudioDevicesEventsUserAgentSoundIOSelectionUseCase(
            origin: userAgentEventsUserAgentSoundIOSelection
        )

        preferencesController = PreferencesController(
            delegate: preferencesControllerDelegate,
            userAgent: userAgent,
            soundPreferencesViewEventTarget: SoundPreferencesViewEventTarget(
                useCaseFactory: useCaseFactory,
                presenterFactory: PresenterFactory(),
                userAgentSoundIOSelection: userAgentSoundIOSelection,
                ringtoneOutputUpdate: RingtoneOutputUpdateUseCase(playback: ringtonePlayback),
                ringtoneSoundPlayback: DefaultSoundPlaybackUseCase(factory: soundFactory)
            )
        )

        settingsMigration = ProgressiveSettingsMigration(
            settings: defaults, factory: DefaultSettingsMigrationFactory(settings: defaults)
        )

        let applicationDataLocations = DirectoryCreatingApplicationDataLocations(
            origin: SimpleApplicationDataLocations(manager: FileManager.default, bundle: Bundle.main),
            manager: FileManager.default
        )

        orphanLogFileRemoval = OrphanLogFileRemoval(locations: applicationDataLocations, manager: FileManager.default)

        workstationSleepStatus = WorkspaceSleepStatus(workspace: NSWorkspace.shared)

        userAgentEventSource = AKSIPUserAgentEventSource(
            target: UserAgentEventTargets(
                targets: [
                    userAgentEventsUserAgentSoundIOSelection,
                    BackgroundActivityUserAgentEventTarget(process: ProcessInfo.processInfo)
                ]
            ),
            agent: userAgent
        )

        let background = DispatchQueue(label: Bundle.main.bundleIdentifier! + ".background-queue", qos: .userInitiated)

        devicesChangeEventSource = CoreAudioSystemAudioDevicesChangeEventSource(
            target: SystemAudioDevicesChangeEventTargets(
                targets: [
                    UserAgentAudioDeviceUpdateUseCase(agent: userAgent),
                    userAgentSoundIOSelection,
                    PreferencesSoundIOUpdater(preferences: preferencesController)
                ]
            ),
            queue: background
        )

        soundIOChangeEventSource = CoreAudioDefaultSystemSoundIOChangeEventSource(
            target: userAgentSoundIOSelection, queue: background
        )

        let callHistories = DefaultCallHistories(
            factory: NotifyingCallHistoryFactory(
                origin: ReversedCallHistoryFactory(
                    origin: PersistentCallHistoryFactory(
                        history: TruncatingCallHistoryFactory(limit: 1000),
                        storage: SimplePropertyListStorageFactory(manager: FileManager.default),
                        locations: applicationDataLocations
                    )
                )
            )
        )

        accountsEventSource = PreferencesControllerAccountsEventSource(
            center: NotificationCenter.default, target: CallHistoriesHistoryRemoveUseCase(histories: callHistories)
        )

        callEventSource = AKSIPCallEventSource(
            center: NotificationCenter.default,
            target: CallEventTargets(
                targets: [
                    CallHistoryCallEventTarget(
                        histories: callHistories, factory: DefaultCallHistoryRecordAddUseCaseFactory()
                    ),
                    MusicPlayerCallEventTarget(
                        player: SettingsMusicPlayer(
                            origin: CallsMusicPlayer(
                                origin: AvailableMusicPlayers(factory: MusicPlayerFactory()), calls: userAgent
                            ),
                            settings: SimpleMusicPlayerSettings(settings: defaults)
                        )
                    ),
                    RingtonePlaybackCallEventTarget(playback: ringtonePlayback),
                    UserAttentionRequestCallEventTarget(
                        request: CallsUserAttentionRequest(
                            origin: ApplicationUserAttentionRequest(
                                application: NSApp, center: NotificationCenter.default
                            ),
                            calls: userAgent
                        )
                    )
                ]
            )
        )

        let contactMatchingSettings = SimpleContactMatchingSettings(settings: defaults)
        let contactMatchingIndex = LazyDiscardingContactMatchingIndex(
            factory: SimpleContactMatchingIndexFactory(
                contacts: CNContactStoreToContactsAdapter(store: CNContactStore()), settings: contactMatchingSettings
            )
        )

        contactsChangeEventSource = CNContactStoreContactsChangeEventSource(
            center: NotificationCenter.default, target: contactMatchingIndex
        )

        let dayChangeEventTargets = DayChangeEventTargets()
        dayChangeEventSource = NSCalendarDayChangeEventSource(center: NotificationCenter.default, target: dayChangeEventTargets)

        callHistoryViewEventTargetFactory = AsyncCallHistoryViewEventTargetFactory(
            origin: CallHistoryViewEventTargetFactory(
                histories: callHistories,
                index: contactMatchingIndex,
                settings: contactMatchingSettings,
                receipt: receipt,
                dateFormatter: ShortRelativeDateTimeFormatter(),
                durationFormatter: DurationFormatter(),
                storeEventTargets: storeEventTargets,
                dayChangeEventTargets: dayChangeEventTargets
            )
        )

        callHistoryPurchaseCheckUseCaseFactory = AsyncCallHistoryPurchaseCheckUseCaseFactory(
            origin: CallHistoryPurchaseCheckUseCaseFactory(histories: callHistories, receipt: receipt)
        )

        logFileURL = LogFileURL(locations: applicationDataLocations, filename: "Telephone.log")

        defaultAppSettings = DefaultAppSettings(
            settings: defaults, localization: Bundle.main.preferredLocalizations.first ?? ""
        )

        helpMenuActionTarget = HelpMenuActionTarget(
            logFileURL: logFileURL,
            homepageURL: URL(string: "https://www.64characters.com/telephone/")!,
            faqURL: URL(string: "https://www.64characters.com/telephone/faq/")!,
            fileBrowser: NSWorkspace.shared,
            webBrowser: NSWorkspace.shared,
            clipboard: NSPasteboard.general,
            settings: AppSettings(
                settings: defaults,
                defaults: defaultAppSettings.defaults,
                accountDefaults: DefaultAppSettings.accountDefaults
            )
        )

        accountControllers = AccountControllers()

        nameServers = NameServers(bundle: Bundle.main, target: nameServersChangeEventTarget)
    }
}
