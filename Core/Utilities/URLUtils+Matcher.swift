//
// URLUtils+Matcher.swift
// Proton Pass - Created on 10/10/2022.
// Copyright (c) 2022 Proton Technologies AG
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

import Foundation

private let kHttpHttpsSet: Set<String> = ["http", "https"]

public extension URLUtils {
    /// Compare 2 URLs given a set of allowed schemes (protocols)
    enum MatcherV2 {
        /// `matched` case associates an `Int` as match score
        public enum MatchResult {
            case matched(Int)
            case notMatched

            public var score: Int {
                if case .matched(let score) = self {
                    return score
                }
                return 0
            }
        }
        /// Compare if 2 URLs are matched and if they are matched, also indicate match score.
        /// match score starts from `1000` and decreases gradually.
        public static func compare(_ leftUrl: URL, _ rightUrl: URL) -> MatchResult {
            guard let leftScheme = leftUrl.scheme,
                  let rightScheme = rightUrl.scheme,
                  let leftHost = leftUrl.host,
                  let rightHost = rightUrl.host else { return .notMatched }

            let httpHttps = ["http", "https"]
            if httpHttps.contains(leftScheme), httpHttps.contains(rightScheme) {
                if leftScheme == "https", rightScheme == "http" {
                    return .notMatched
                } else {
                    guard let domainParser = try? DomainParser(),
                          let parsedLeftHost = domainParser.parse(host: leftHost),
                          let parsedRightHost = domainParser.parse(host: rightHost),
                          parsedLeftHost.publicSuffix == parsedRightHost.publicSuffix else {
                        return .notMatched
                    }

                    guard let leftDomain = parsedLeftHost.domain,
                          let rightDomain = parsedRightHost.domain,
                          leftDomain == rightDomain else {
                        return .notMatched
                    }

                    var leftSubdomains = leftHost.components(separatedBy: ".")
                    var rightSubdomains = rightHost.components(separatedBy: ".")

                    var matchScore = 1_000
                    while let lastLeftSubdomain = leftSubdomains.popLast() {
                        let lastRightSubdomain = rightSubdomains.popLast()
                        if lastLeftSubdomain != lastRightSubdomain {
                            matchScore -= 1
                        }
                    }
                    matchScore -= rightSubdomains.count

                    return .matched(matchScore)
                }
            } else {
                // Other schemes like `ssh` or `ftp`...
                if leftScheme == rightScheme, leftHost == rightHost {
                    return .matched(1_000)
                } else {
                    return .notMatched
                }
            }
        }
    }

    /// Compare 2 URLs given a set of allowed schemes (protocols)
    struct Matcher {
        /// A set of allowed schemes (protocols) e.g `https`, `ftp`, `ssh`.
        /// Use this to ignore schemes that we do not want to support.
        let allowedSchemes: Set<String>

        /// Default `URLMatcher` that supports only `https` & `https` schemes
        public static var `default` = Self(allowedSchemes: kHttpHttpsSet)

        public init(allowedSchemes: Set<String>) {
            self.allowedSchemes = allowedSchemes
        }

        /// Compare if 2 URLs are matched.
        ///
        /// If URLs have `http` or `https` as protocol,
        /// will use `DomainParser` to define if they share the same top level domain (TLD)
        /// and then only the compare the top most subdomain after the TLD.
        /// `http` & `https` are interchangeable.
        /// E.g:
        /// https://example.com matches https://subdomain.example.com
        /// http://example.com matches https://subdomain.example.com
        /// https://example.net does not match https://example.com
        ///
        ///
        /// If URLs do not have `http` or `https` as protocol, will compare the whole host
        /// E.g:
        /// ssh://example.com does not match ssh://subdomain.example.com
        ///
        /// - Parameters:
        ///   - leftUrl: Left hand `URL`
        ///   - rightUrl: Right hand `URL`
        ///  - Returns: `true` if matched, `false` if not matched
        public func isMatched(_ leftUrl: URL, _ rightUrl: URL) -> Bool {
            guard let leftScheme = leftUrl.scheme,
                  let rightScheme = rightUrl.scheme,
                  let leftHost = leftUrl.host,
                  let rightHost = rightUrl.host else { return false }

            if allowedSchemes == kHttpHttpsSet {
                // `https` & `https`
                guard allowedSchemes.contains(leftScheme),
                      allowedSchemes.contains(rightScheme) else { return false }

                guard let domainParser = try? DomainParser(),
                      let parsedLeftHost = domainParser.parse(host: leftHost),
                      let parsedRightHost = domainParser.parse(host: rightHost),
                      parsedLeftHost.publicSuffix == parsedRightHost.publicSuffix else {
                    return leftUrl.absoluteString == rightUrl.absoluteString
                }

                guard let leftDomain = parsedLeftHost.domain,
                      let rightDomain = parsedRightHost.domain else {
                    return false
                }

                let leftDomainWithoutTld = leftDomain
                    .replacingOccurrences(of: ".\(parsedLeftHost.publicSuffix)", with: "")

                let rightDomainWithoutTld = rightDomain
                    .replacingOccurrences(of: ".\(parsedRightHost.publicSuffix)", with: "")

                guard let leftTopSubdomain = leftDomainWithoutTld.components(separatedBy: ".").last,
                      let rightTopSubdomain = rightDomainWithoutTld.components(separatedBy: ".").last else {
                    return false
                }

                return leftTopSubdomain == rightTopSubdomain
            } else {
                // Other schemes e.g `ssh`, `ftp`..
                guard leftScheme == rightScheme else { return false }

                guard let leftHost = leftUrl.host,
                      let rightHost = rightUrl.host else { return false }
                return leftHost == rightHost
            }
        }
    }
}

extension URLUtils.MatcherV2.MatchResult: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case let (.matched(lScore), .matched(rScore)):
            return lScore == rScore
        case (.notMatched, .notMatched):
            return true
        default:
            return false
        }
    }
}
