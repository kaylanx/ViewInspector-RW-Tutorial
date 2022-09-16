import Combine
import SwiftUI

//internal final class Inspection<View> {
//  let notice = PassthroughSubject<UInt, Never>()
//  var callbacks: [UInt: (View) -> Void] = [:]
//
//  func visit(_ view: View, _ line: UInt) {
//    if let callback = callbacks.removeValue(forKey: line) {
//      callback(view)
//    }
//  }
//}
