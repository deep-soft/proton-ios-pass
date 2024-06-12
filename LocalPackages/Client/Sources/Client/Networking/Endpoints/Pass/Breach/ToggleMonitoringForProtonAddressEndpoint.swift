//
// ToggleMonitoringForProtonAddressEndpoint.swift
// Proton Pass - Created on 24/04/2024.
// Copyright (c) 2024 Proton Technologies AG
//
// This file is part of Proton Pass.
//
// Proton Pass is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Proton Pass is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Proton Pass. If not, see https://www.gnu.org/licenses/.

import ProtonCoreNetworking

struct ToggleMonitoringRequest: Encodable, Sendable {
    let monitor: Bool

    enum CodingKeys: String, CodingKey {
        case monitor = "Monitor"
    }
}

struct ToggleMonitoringForProtonAddressEndpoint: Endpoint {
    typealias Body = ToggleMonitoringRequest
    typealias Response = CodeOnlyResponse

    var debugDescription: String
    var path: String
    var method: HTTPMethod
    var body: ToggleMonitoringRequest?

    init(addressId: String, request: ToggleMonitoringRequest) {
        debugDescription = "Toggle the monitoring for a proton address"
        path = "/pass/v1/breach/address/\(addressId)/monitor"
        method = .put
        body = request
    }
}
