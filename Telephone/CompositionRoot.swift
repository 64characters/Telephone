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
    private let userDefaults: NSUserDefaults
    private let queue: dispatch_queue_t

    private let productPurchaseEventSource: ProductPurchaseEventSource
    private let userAgentNotificationsToEventTargetAdapter: UserAgentNotificationsToEventTargetAdapter
    private let devicesChangeEventSource: SystemAudioDevicesChangeEventSource!

    init(preferencesControllerDelegate: PreferencesControllerDelegate, conditionalRingtonePlaybackUseCaseDelegate: ConditionalRingtonePlaybackUseCaseDelegate) {
        userAgent = AKSIPUserAgent.sharedUserAgent()
        userDefaults = NSUserDefaults.standardUserDefaults()
        queue = createQueue()

        let audioDevices = SystemAudioDevices()
        let useCaseFactory = DefaultUseCaseFactory(repository: audioDevices, userDefaults: userDefaults)

        let userDefaultsSoundFactory = UserDefaultsSoundFactory(
            load: UserDefaultsRingtoneSoundConfigurationLoadUseCase(
                userDefaults: userDefaults,
                repository: audioDevices
            ),
            factory: NSSoundToSoundAdapterFactory()
        )

        ringtonePlayback = ConditionalRingtonePlaybackUseCase(
            origin: DefaultRingtonePlaybackUseCase(
                factory: RepeatingSoundFactory(
                    soundFactory: userDefaultsSoundFactory,
                    timerFactory: NSTimerToTimerAdapterFactory()
                )
            ),
            delegate: conditionalRingtonePlaybackUseCaseDelegate
        )

        let productsEventTargets = ProductsEventTargets()

        let storeViewController = StoreViewController(target: NullStoreViewEventTarget())
        let products = SKProductsRequestToProductsAdapter(
            identifiers: ["com.tlphn.Telephone.iap.month", "com.tlphn.Telephone.iap.year"],
            target: productsEventTargets
        )
        let store = SKPaymentQueueToStoreAdapter(queue: SKPaymentQueue.defaultQueue(), products: products)
        let receipt = LoggingReceipt(origin: BundleReceipt(bundle: NSBundle.mainBundle(), gateway: ReceiptXPCGateway()))
        let storeViewEventTarget = DefaultStoreViewEventTarget(
            factory: DefaultStoreUseCaseFactory(
                products: LoggingProducts(origin: products),
                store: LoggingStore(origin: store),
                targets: productsEventTargets,
                factory: SKReceiptRefreshRequestAdapterFactory(receipt: receipt)
            ),
            presenter: DefaultStoreViewPresenter(output: storeViewController)
        )
        storeViewController.updateTarget(storeViewEventTarget)

        storeWindowController = StoreWindowController(contentViewController: storeViewController)

        productPurchaseEventSource = ProductPurchaseEventSource(
            queue: SKPaymentQueue.defaultQueue(),
            products: LoggingProducts(origin: products),
            target: ReceiptValidatingProductPurchaseEventTarget(origin: storeViewEventTarget, receipt: receipt)
        )

        let userAgentSoundIOSelection = DelayingUserAgentSoundIOSelectionUseCase(
            useCase: UserAgentSoundIOSelectionUseCase(
                repository: audioDevices,
                userAgent: userAgent,
                userDefaults: userDefaults
            ),
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
                ringtoneSoundPlayback: DefaultSoundPlaybackUseCase(factory: userDefaultsSoundFactory)
            )
        )

        userAgentNotificationsToEventTargetAdapter = UserAgentNotificationsToEventTargetAdapter(
            target: userAgentSoundIOSelection,
            userAgent: userAgent
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

private func createQueue() -> dispatch_queue_t {
    let label = NSBundle.mainBundle().bundleIdentifier! + ".background-queue"
    return dispatch_queue_create(label, DISPATCH_QUEUE_SERIAL)
}
