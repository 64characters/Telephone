//
//  SelectedSoundIOInteractor.swift
//  Telephone
//
//  Copyright (c) 2008-2015 Alexei Kuznetsov. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//  1. Redistributions of source code must retain the above copyright notice,
//     this list of conditions and the following disclaimer.
//  2. Redistributions in binary form must reproduce the above copyright notice,
//     this list of conditions and the following disclaimer in the documentation
//     and/or other materials provided with the distribution.
//  3. Neither the name of the copyright holder nor the names of contributors
//     may be used to endorse or promote products derived from this software
//     without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
//  THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
//  PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE THE COPYRIGHT HOLDER
//  OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
//  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
//  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
//  OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
//  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
//  OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
//  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

import Domain

public protocol SelectedSoundIOInteractorOutput: class {
    func update(audioDevices: AudioDevices, soundIO: SoundIO)
}

public class SelectedSoundIOInteractor {
    public let systemAudioDeviceRepository: SystemAudioDeviceRepository
    public let userDefaults: UserDefaults
    public let output: SelectedSoundIOInteractorOutput

    public init(systemAudioDeviceRepository: SystemAudioDeviceRepository, userDefaults: UserDefaults, output: SelectedSoundIOInteractorOutput) {
        self.systemAudioDeviceRepository = systemAudioDeviceRepository
        self.userDefaults = userDefaults
        self.output = output
    }
}

extension SelectedSoundIOInteractor: ThrowingInteractor {
    public func execute() throws {
        let systemAudioDevices = SystemAudioDevices(devices: try systemAudioDeviceRepository.allDevices())
        let selectedSystemSoundIO = try SelectedSystemSoundIO(systemAudioDevices: systemAudioDevices, userDefaults: userDefaults)
        output.update(
            AudioDevices(systemAudioDevices: systemAudioDevices),
            soundIO: SoundIO(selectedSystemSoundIO: selectedSystemSoundIO)
        )
    }
}
