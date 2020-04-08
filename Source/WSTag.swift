//
//  WSTag.swift
//  Whitesmith
//
//  Created by Ricardo Pereira on 12/05/16.
//  Copyright © 2016 Whitesmith. All rights reserved.
//

import Foundation

public struct WSTag: Hashable {
    public let text: String
    public let imageURL: String?
    public let context: AnyHashable?

    public init(_ text: String, _ imageURL: String? = nil, context: AnyHashable? = nil) {
        self.text = text
        self.imageURL = imageURL
        self.context = context
    }

    public func equals(_ other: WSTag) -> Bool {
        return self.text == other.text && self.imageURL == other.imageURL && self.context == other.context
    }
}

public func == (lhs: WSTag, rhs: WSTag) -> Bool {
    return lhs.equals(rhs)
}
