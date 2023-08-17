//
//  Array+Extension.swift
//  MafiaMindset
//
//  Created by Aghasif Guliyev on 17.08.23.
//

import Foundation

extension Array {
    func shifted(by positions: Int) -> [Element] {
        let effectiveShift = positions % count
        let shiftedArray = Array(suffix(from: effectiveShift)) + Array(prefix(upTo: effectiveShift))
        return shiftedArray
    }
}
