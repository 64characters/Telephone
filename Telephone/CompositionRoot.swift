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
import UseCases

class CompositionRoot: NSObject {
    let userAgent: AKSIPUserAgent
    let preferencesController: PreferencesController
    let ringtonePlayback: RingtonePlaybackInteractor
    let storeWindowController: StoreWindowController
    private let userDefaults: NSUserDefaults
    private let queue: dispatch_queue_t

    private let userAgentNotificationsToEventTargetAdapter: UserAgentNotificationsToEventTargetAdapter
    private let devicesChangeEventSource: SystemAudioDevicesChangeEventSource!

    init(preferencesControllerDelegate: PreferencesControllerDelegate, conditionalRingtonePlaybackInteractorDelegate: ConditionalRingtonePlaybackInteractorDelegate) {
        userAgent = AKSIPUserAgent.sharedUserAgent()
        userDefaults = NSUserDefaults.standardUserDefaults()
        queue = createQueue()

        let audioDevices = SystemAudioDevices()
        let interactorFactory = DefaultInteractorFactory(repository: audioDevices, userDefaults: userDefaults)

        let userDefaultsSoundFactory = UserDefaultsSoundFactory(
            configurationLoader: UserDefaultsRingtoneSoundConfigurationLoadInteractor(
                userDefaults: userDefaults,
                repository: audioDevices
            ),
            factory: NSSoundToSoundAdapterFactory()
        )

        ringtonePlayback = ConditionalRingtonePlaybackInteractor(
            origin: DefaultRingtonePlaybackInteractor(
                factory: RepeatingSoundFactory(
                    soundFactory: userDefaultsSoundFactory,
                    timerFactory: NSTimerToTimerAdapterFactory()
                )
            ),
            delegate: conditionalRingtonePlaybackInteractorDelegate
        )

        let storeClientEventTargetComposite = StoreClientEventTargetComposite()

        let storeViewController = StoreViewController()
        let storeViewEventTarget = DefaultStoreViewEventTarget(
            interactorFactory: DefaultStoreInteractorFactory(
                identifiers: ["one", "two"],
                client: FakeStoreClient(eventTarget: storeClientEventTargetComposite),
                composite: storeClientEventTargetComposite
            ),
            presenterFactory: StorePresenterFactory(output: storeViewController)
        )
        storeViewController.updateEventTarget(storeViewEventTarget)

        storeWindowController = StoreWindowController(contentViewController: storeViewController)

        let userAgentSoundIOSelection = DelayingUserAgentSoundIOSelectionInteractor(
            interactor: UserAgentSoundIOSelectionInteractor(
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
                interactorFactory: interactorFactory,
                presenterFactory: PresenterFactory(),
                userAgentSoundIOSelection: userAgentSoundIOSelection,
                ringtoneOutputUpdate: RingtoneOutputUpdateInteractor(playback: ringtonePlayback),
                ringtoneSoundPlayback: DefaultSoundPlaybackInteractor(factory: userDefaultsSoundFactory)
            )
        )

        userAgentNotificationsToEventTargetAdapter = UserAgentNotificationsToEventTargetAdapter(
            target: userAgentSoundIOSelection,
            userAgent: userAgent
        )
        devicesChangeEventSource = SystemAudioDevicesChangeEventSource(
            target: SystemAudioDevicesChangeEventTargetComposite(
                targets: [
                    UserAgentAudioDeviceUpdateInteractor(userAgent: userAgent),
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
