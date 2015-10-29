//
//  SelectedSystemAudioDevicesImpl.swift
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

class SelectedSystemAudioDevicesImpl {

    let systemAudioDevices: SystemAudioDevices
    let userDefaults: UserDefaults

    init(systemAudioDevices: SystemAudioDevices, userDefaults: UserDefaults) {
        self.systemAudioDevices = systemAudioDevices
        self.userDefaults = userDefaults
    }
}

extension SelectedSystemAudioDevicesImpl: SelectedSystemAudioDevices {

    var soundInput: SystemAudioDevice? {
        return inputDeviceByNameWithUserDefaultsKey(kSoundInput, fallbackDevice: systemAudioDevices.builtInInput)
    }

    var soundOutput: SystemAudioDevice? {
        return outputDeviceByNameWithUserDefaultsKey(kSoundOutput, fallbackDevice: systemAudioDevices.builtInOutput)
    }

    var ringtoneOutput: SystemAudioDevice? {
        return outputDeviceByNameWithUserDefaultsKey(kRingtoneOutput, fallbackDevice: systemAudioDevices.builtInOutput)
    }

    // MARK: - Private

    private func inputDeviceByNameWithUserDefaultsKey(key: String, fallbackDevice: SystemAudioDevice?) -> SystemAudioDevice? {
        return firstOrSecond(inputDeviceByNameWithUserDefaultsKey(key), second: fallbackDevice)
    }

    private func outputDeviceByNameWithUserDefaultsKey(key: String, fallbackDevice: SystemAudioDevice?) -> SystemAudioDevice? {
        return firstOrSecond(outputDeviceByNameWithUserDefaultsKey(key), second: fallbackDevice)
    }

    private func inputDeviceByNameWithUserDefaultsKey(key: String) -> SystemAudioDevice? {
        let device = deviceByNameWithUserDefaultsKey(key)
        return device?.inputCount > 0 ? device : nil
    }

    private func outputDeviceByNameWithUserDefaultsKey(key: String) -> SystemAudioDevice? {
        let device = deviceByNameWithUserDefaultsKey(key)
        return device?.outputCount > 0 ? device : nil
    }

    private func deviceByNameWithUserDefaultsKey(key: String) -> SystemAudioDevice? {
        let name = userDefaults[key] as? String
        return name.flatMap(deviceWithName)
    }

    private func deviceWithName(name: String) -> SystemAudioDevice? {
        return systemAudioDevices[name]
    }

    private func firstOrSecond<T>(first: T?, second: T?) -> T? {
        return first != nil ? first : second
    }
}

extension SelectedSystemAudioDevicesImpl: SystemAudioDevices {
    var allDevices: [SystemAudioDevice] {
        return systemAudioDevices.allDevices
    }

    var builtInInput: SystemAudioDevice? {
        return systemAudioDevices.builtInInput
    }

    var builtInOutput: SystemAudioDevice? {
        return systemAudioDevices.builtInOutput
    }

    subscript(name: String) -> SystemAudioDevice? {
        return systemAudioDevices[name]
    }
}
