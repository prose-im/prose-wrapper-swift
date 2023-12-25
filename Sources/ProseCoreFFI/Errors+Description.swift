//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import Foundation

extension ClientError: LocalizedError {
  /// - Important: ``ClientError`` is not localized.
  public var errorDescription: String? {
    switch self {
    case .Generic(let msg):
      return msg
    }
  }
}
