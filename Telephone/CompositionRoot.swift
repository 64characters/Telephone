//
//  CompositionRoot.swift
//  Telephone
//
//  Copyright (c) 2008-2016 Alexey Kuznetsov
//  Copyright (c) 2016 64 Characters
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

import Foundation
import StoreKit
import UseCases

final class CompositionRoot: NSObject {
    let userAgent: AKSIPUserAgent
    let preferencesController: PreferencesController
    let ringtonePlayback: RingtonePlaybackUseCase
    let storeWindowController: StoreWindowController
    let purchaseReminder: PurchaseReminderUseCase
    let musicPlayer: MusicPlayer
    let settingsMigration: ProgressiveSettingsMigration
    let applicationDataLocations: ApplicationDataLocations
    private let defaults: UserDefaults
    private let queue: DispatchQueue

    private let storeEventSource: StoreEventSource
    private let userAgentNotificationsToEventTargetAdapter: UserAgentNotificationsToEventTargetAdapter
    private let devicesChangeEventSource: SystemAudioDevicesChangeEventSource!

    init(preferencesControllerDelegate: PreferencesControllerDelegate, conditionalRingtonePlaybackUseCaseDelegate: ConditionalRingtonePlaybackUseCaseDelegate) {
        userAgent = AKSIPUserAgent.shared()
        defaults = UserDefaults.standard
        queue = makeQueue()

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
            target: NullStoreViewEventTarget(), workspace: NSWorkspace.shared()
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

        storeWindowController = StoreWindowController(contentViewController: storeViewController)

        purchaseReminder = PurchaseReminderUseCase(
            accounts: SettingsAccounts(settings: defaults),
            receipt: receipt,
            settings: UserDefaultsPurchaseReminderSettings(defaults: defaults),
            now: Date(),
            version: Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String,
            output: storeWindowController
        )

        storeEventSource = StoreEventSource(
            queue: SKPaymentQueue.default(),
            target: ReceiptValidatingStoreEventTarget(origin: storeViewEventTarget, receipt: receipt)
        )

        let userAgentSoundIOSelection = DelayingUserAgentSoundIOSelectionUseCase(
            useCase: UserAgentSoundIOSelectionUseCase(repository: audioDevices, userAgent: userAgent, settings: defaults),
            userAgent: userAgent
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

        musicPlayer = ConditionalMusicPlayer(
            origin: AvailableMusicPlayers(factory: MusicPlayerFactory()),
            settings: SimpleMusicPlayerSettings(settings: defaults)
        )

        settingsMigration = ProgressiveSettingsMigration(settings: defaults, factory: DefaultSettingsMigrationFactory())

        applicationDataLocations = DirectoryCreatingApplicationDataLocations(
            origin: SimpleApplicationDataLocations(manager: FileManager.default, bundle: Bundle.main),
            manager: FileManager.default
        )

        userAgentNotificationsToEventTargetAdapter = UserAgentNotificationsToEventTargetAdapter(
            target: userAgentSoundIOSelection,
            agent: userAgent
        )
        devicesChangeEventSource = SystemAudioDevicesChangeEventSource(
            target: SystemAudioDevicesChangeEventTargets(
                targets: [
                    UserAgentAudioDeviceUpdateUseCase(userAgent: userAgent),
                    userAgentSoundIOSelection,
                    PreferencesSoundIOUpdater(preferences: preferencesController)
                ]
            ),
            queue: queue
        )

        super.init()

        devicesChangeEventSource.start()
    }

    deinit {
        devicesChangeEventSource.stop()
    }
}

private func makeQueue() -> DispatchQueue {
    let label = Bundle.main.bundleIdentifier! + ".background-queue"
    return DispatchQueue(label: label, attributes: [])
}
