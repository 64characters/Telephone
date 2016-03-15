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

    private let userAgentNotificationsToObserverAdapter: UserAgentNotificationsToObserverAdapter
    private let devicesChangeMonitor: SystemAudioDevicesChangeMonitor!

    init(preferencesControllerDelegate: PreferencesControllerDelegate, conditionalRingtonePlaybackInteractorDelegate: ConditionalRingtonePlaybackInteractorDelegate) {
        userAgent = AKSIPUserAgent.sharedUserAgent()
        userDefaults = NSUserDefaults.standardUserDefaults()
        queue = createQueue()

        let audioDevices = SystemAudioDevices()
        let interactorFactory = DefaultInteractorFactory(systemAudioDeviceRepository: audioDevices, userDefaults: userDefaults)

        let userDefaultsSoundFactory = UserDefaultsSoundFactory(
            interactor: UserDefaultsRingtoneSoundConfigurationLoadInteractor(
                userDefaults: userDefaults,
                systemAudioDeviceRepository: audioDevices
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
            soundPreferencesViewObserver: SoundPreferencesViewEventHandler(
                interactorFactory: interactorFactory,
                presenterFactory: PresenterFactory(),
                ringtoneOutputUpdateInteractor: RingtoneOutputUpdateInteractor(playback: ringtonePlayback),
                ringtoneSoundPlaybackInteractor: SoundPlaybackInteractor(soundFactory: userDefaultsSoundFactory),
                userAgent: userAgent
            )
        )

        userAgentNotificationsToObserverAdapter = UserAgentNotificationsToObserverAdapter(
            observer: UserAgentSoundIOSelector(interactorFactory: interactorFactory),
            userAgent: userAgent
        )
        devicesChangeMonitor = SystemAudioDevicesChangeMonitor(
            observer: UserAgentAudioDeviceUpdater(
                interactor: UserAgentAudioDeviceUpdateAndSoundIOSelectionInteractor(
                    updateInteractor: UserAgentAudioDeviceUpdateInteractor(
                        userAgent: userAgent
                    ),
                    selectionInteractor: UserAgentSoundIOSelectionInteractor(
                        systemAudioDeviceRepository: audioDevices,
                        userAgent: userAgent,
                        userDefaults: userDefaults
                    )
                )
            ),
            queue: queue
        )

        super.init()

        devicesChangeMonitor.start()
    }

    deinit {
        devicesChangeMonitor.stop()
    }
}

private func createQueue() -> dispatch_queue_t {
    let label = NSBundle.mainBundle().bundleIdentifier! + ".background-queue"
    return dispatch_queue_create(label, DISPATCH_QUEUE_SERIAL)
}
