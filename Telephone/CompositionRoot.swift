//
//  CompositionRoot.swift
//  Telephone
//
//  Copyright © 2008-2016 Alexey Kuznetsov
//  Copyright © 2016-2018 64 Characters
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
import UseCases

final class CompositionRoot: NSObject {
    @objc let userAgent: AKSIPUserAgent
    @objc let preferencesController: PreferencesController
    @objc let ringtonePlayback: RingtonePlaybackUseCase
    @objc let storeWindowPresenter: StoreWindowPresenter
    @objc let purchaseReminder: PurchaseReminderUseCase
    @objc let settingsMigration: ProgressiveSettingsMigration
    @objc let orphanLogFileRemoval: OrphanLogFileRemoval
    @objc let workstationSleepStatus: WorkspaceSleepStatus
    @objc let callHistoryViewEventTargetFactory: AsyncCallHistoryViewEventTargetFactory
    @objc let callHistoryPurchaseCheckUseCaseFactory: AsyncCallHistoryPurchaseCheckUseCaseFactory
    @objc let logFileURL: LogFileURL
    @objc let helpMenuActionTarget: HelpMenuActionTarget
    private let defaults: UserDefaults

    private let storeEventSource: StoreEventSource
    private let userAgentEventSource: AKSIPUserAgentUserAgentEventSource
    private let devicesChangeEventSource: SystemAudioDevicesChangeEventSource!
    private let accountsEventSource: PreferencesControllerAccountsEventSource
    private let callEventSource: AKSIPCallCallEventSource
    private let contactsChangeEventSource: Any
    private let dayChangeEventSource: DayChangeEventSource

    @objc init(preferencesControllerDelegate: PreferencesControllerDelegate, conditionalRingtonePlaybackUseCaseDelegate: ConditionalRingtonePlaybackUseCaseDelegate) {
        userAgent = AKSIPUserAgent.shared()
        defaults = UserDefaults.standard

        let audioDevices = SystemAudioDevices()
        let useCaseFactory = DefaultUseCaseFactory(repository: audioDevices, settings: defaults)

        let soundFactory = SimpleSoundFactory(
            load: SettingsRingtoneSoundConfigurationLoadUseCase(settings: defaults, repository: audioDevices),
            factory: NSSoundToSoundAdapterFactory()
        )

        ringtonePlayback = ConditionalRingtonePlaybackUseCase(
            origin: DefaultRingtonePlaybackUseCase(
                factory: RepeatingSoundFactory(
                    soundFactory: soundFactory,
                    timerFactory: FoundationToUseCasesTimerAdapterFactory()
                )
            ),
            delegate: conditionalRingtonePlaybackUseCaseDelegate
        )

        let productsEventTargets = ProductsEventTargets()

        let storeViewController = StoreViewController(
            target: NullStoreViewEventTarget(), workspace: NSWorkspace.shared
        )
        let products = SKProductsRequestToProductsAdapter(expected: ExpectedProducts(), target: productsEventTargets)
        let store = SKPaymentQueueToStoreAdapter(queue: SKPaymentQueue.default(), products: products)
        let receipt = BundleReceipt(bundle: Bundle.main, gateway: ReceiptXPCGateway())
        let storeViewEventTarget = DefaultStoreViewEventTarget(
            factory: DefaultStoreUseCaseFactory(
                products: products,
                store: store,
                receipt: receipt,
                targets: productsEventTargets
            ),
            purchaseRestoration: PurchaseRestorationUseCase(store: store),
            receiptRefresh: ReceiptRefreshUseCase(),
            presenter: DefaultStoreViewPresenter(output: storeViewController)
        )
        storeViewController.updateTarget(storeViewEventTarget)

        storeWindowPresenter = StoreWindowPresenter(controller: StoreWindowController(contentViewController: storeViewController))

        purchaseReminder = PurchaseReminderUseCase(
            accounts: SettingsAccounts(settings: defaults),
            receipt: receipt,
            settings: UserDefaultsPurchaseReminderSettings(defaults: defaults),
            now: Date(),
            version: Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String,
            output: storeWindowPresenter
        )

        let storeEventTargets = StoreEventTargets()
        storeEventTargets.add(storeViewEventTarget)

        storeEventSource = StoreEventSource(
            queue: SKPaymentQueue.default(),
            target: ReceiptValidatingStoreEventTarget(origin: storeEventTargets, receipt: receipt)
        )

        let userAgentSoundIOSelection = DelayingUserAgentSoundIOSelectionUseCase(
            useCase: UserAgentSoundIOSelectionUseCase(repository: audioDevices, userAgent: userAgent, settings: defaults),
            agent: userAgent,
            calls: userAgent
        )

        preferencesController = PreferencesController(
            delegate: preferencesControllerDelegate,
            userAgent: userAgent,
            soundPreferencesViewEventTarget: DefaultSoundPreferencesViewEventTarget(
                useCaseFactory: useCaseFactory,
                presenterFactory: PresenterFactory(),
                userAgentSoundIOSelection: userAgentSoundIOSelection,
                ringtoneOutputUpdate: RingtoneOutputUpdateUseCase(playback: ringtonePlayback),
                ringtoneSoundPlayback: DefaultSoundPlaybackUseCase(factory: soundFactory)
            )
        )

        settingsMigration = ProgressiveSettingsMigration(settings: defaults, factory: DefaultSettingsMigrationFactory())

        let applicationDataLocations = DirectoryCreatingApplicationDataLocations(
            origin: SimpleApplicationDataLocations(manager: FileManager.default, bundle: Bundle.main),
            manager: FileManager.default
        )

        orphanLogFileRemoval = OrphanLogFileRemoval(locations: applicationDataLocations, manager: FileManager.default)

        workstationSleepStatus = WorkspaceSleepStatus(workspace: NSWorkspace.shared)

        userAgentEventSource = AKSIPUserAgentUserAgentEventSource(
            target: UserAgentEventTargets(
                targets: [
                    userAgentSoundIOSelection, BackgroundActivityUserAgentEventTarget(process: ProcessInfo.processInfo)
                ]
            ),
            agent: userAgent
        )

        let background = DispatchQueue(label: Bundle.main.bundleIdentifier! + ".background-queue", qos: .userInitiated)

        devicesChangeEventSource = SystemAudioDevicesChangeEventSource(
            target: SystemAudioDevicesChangeEventTargets(
                targets: [
                    UserAgentAudioDeviceUpdateUseCase(userAgent: userAgent),
                    userAgentSoundIOSelection,
                    PreferencesSoundIOUpdater(preferences: preferencesController)
                ]
            ),
            queue: background
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

        let contacts: Contacts
        let contactsBackground: ExecutionQueue
        if #available(macOS 10.11, *) {
            contacts = CNContactStoreToContactsAdapter()
            contactsBackground = GCDExecutionQueue(queue: background)
        } else {
            contacts = ABAddressBookToContactsAdapter()
            contactsBackground = ThreadExecutionQueue(thread: makeAndStartThread())
        }

        accountsEventSource = PreferencesControllerAccountsEventSource(
            center: NotificationCenter.default,
            target: EnqueuingAccountsEventTarget(
                origin: CallHistoriesHistoryRemoveUseCase(histories: callHistories), queue: contactsBackground
            )
        )

        callEventSource = AKSIPCallCallEventSource(
            center: NotificationCenter.default,
            target: CallEventTargets(
                targets: [
                    EnqueuingCallEventTarget(
                        origin: CallHistoryCallEventTarget(
                            histories: callHistories, factory: DefaultCallHistoryRecordAddUseCaseFactory()
                        ),
                        queue: contactsBackground
                    ),
                    MusicPlayerCallEventTarget(
                        player: SettingsMusicPlayer(
                            origin: CallsMusicPlayer(
                                origin: AvailableMusicPlayers(factory: MusicPlayerFactory()), calls: userAgent
                            ),
                            settings: SimpleMusicPlayerSettings(settings: defaults)
                        )
                    )
                ]
            )
        )

        let contactMatchingSettings = SimpleContactMatchingSettings(settings: defaults)
        let contactMatchingIndex = LazyDiscardingContactMatchingIndex(
            factory: SimpleContactMatchingIndexFactory(contacts: contacts, settings: contactMatchingSettings)
        )
        let contactsChangeEventTarget = EnqueuingContactsChangeEventTarget(origin: contactMatchingIndex, queue: contactsBackground)

        if #available(macOS 10.11, *) {
            contactsChangeEventSource = CNContactStoreContactsChangeEventSource(
                center: NotificationCenter.default, target: contactsChangeEventTarget
            )
        } else {
            contactsChangeEventSource = ABAddressBookContactsChangeEventSource(
                center: NotificationCenter.default, target: contactsChangeEventTarget
            )
        }

        let dayChangeEventTargets = DayChangeEventTargets()
        dayChangeEventSource = DayChangeEventSource(center: NotificationCenter.default, target: dayChangeEventTargets)

        let main = GCDExecutionQueue(queue: DispatchQueue.main)

        callHistoryViewEventTargetFactory = AsyncCallHistoryViewEventTargetFactory(
            origin: CallHistoryViewEventTargetFactory(
                histories: callHistories,
                index: contactMatchingIndex,
                settings: contactMatchingSettings,
                receipt: receipt,
                dateFormatter: ShortRelativeDateTimeFormatter(),
                durationFormatter: DurationFormatter(),
                storeEventTargets: storeEventTargets,
                dayChangeEventTargets: dayChangeEventTargets,
                background: contactsBackground,
                main: main
            ),
            background: contactsBackground,
            main: main
        )

        callHistoryPurchaseCheckUseCaseFactory = AsyncCallHistoryPurchaseCheckUseCaseFactory(
            origin: CallHistoryPurchaseCheckUseCaseFactory(
                histories: callHistories, receipt: receipt, background: contactsBackground, main: main
            ),
            background: contactsBackground,
            main: main
        )

        logFileURL = LogFileURL(locations: applicationDataLocations, filename: "Telephone.log")

        helpMenuActionTarget = HelpMenuActionTarget(
            logFileURL: logFileURL,
            homepageURL: URL(string: "https://www.64characters.com/telephone/")!,
            faqURL: URL(string: "https://www.64characters.com/telephone/faq/")!,
            fileBrowser: NSWorkspace.shared,
            webBrowser: NSWorkspace.shared
        )

        super.init()

        devicesChangeEventSource.start()
    }

    deinit {
        devicesChangeEventSource.stop()
    }
}

private func makeAndStartThread() -> Thread {
    let thread = WaitingThread()
    thread.qualityOfService = .userInitiated
    thread.start()
    return thread
}
