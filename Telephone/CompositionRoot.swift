//
//  CompositionRoot.swift
//  Telephone
//
//  Copyright (c) 2008-2015 Alexey Kuznetsov
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
    private let userDefaults: NSUserDefaults
    private let queue: dispatch_queue_t

    private let userAgentNotificationsToEventTargetAdapter: UserAgentNotificationsToEventTargetAdapter
    private let devicesChangeEventSource: SystemAudioDevicesChangeEventSource!

    init(preferencesControllerDelegate: PreferencesControllerDelegate, conditionalRingtonePlaybackInteractorDelegate: ConditionalRingtonePlaybackInteractorDelegate) {
        userAgent = AKSIPUserAgent.sharedUserAgent()
        userDefaults = NSUserDefaults.standardUserDefaults()
        queue = createQueue()

        let audioDevices = SystemAudioDevices()
        let interactorFactory = DefaultInteractorFactory(systemAudioDeviceRepository: audioDevices, userDefaults: userDefaults)

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

        preferencesController = PreferencesController(
            delegate: preferencesControllerDelegate,
            soundPreferencesViewEventTarget: DefaultSoundPreferencesViewEventTarget(
                interactorFactory: interactorFactory,
                presenterFactory: PresenterFactory(),
                ringtoneOutputUpdate: RingtoneOutputUpdateInteractor(playback: ringtonePlayback),
                ringtoneSoundPlayback: DefaultSoundPlaybackInteractor(factory: userDefaultsSoundFactory),
                userAgent: userAgent
            )
        )

        userAgentNotificationsToEventTargetAdapter = UserAgentNotificationsToEventTargetAdapter(
            target: UserAgentSoundIOSelector(factory: interactorFactory),
            userAgent: userAgent
        )
        devicesChangeEventSource = SystemAudioDevicesChangeEventSource(
            target: SystemAudioDevicesChangeEventTargetComposite(
                targets: [
                    UserAgentAudioDeviceUpdater(
                        interactor: UserAgentAudioDeviceUpdateAndSoundIOSelectionInteractor(
                            update: UserAgentAudioDeviceUpdateInteractor(
                                userAgent: userAgent
                            ),
                            selection: UserAgentSoundIOSelectionInteractor(
                                repository: audioDevices,
                                userAgent: userAgent,
                                userDefaults: userDefaults
                            )
                        )
                    ),
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
