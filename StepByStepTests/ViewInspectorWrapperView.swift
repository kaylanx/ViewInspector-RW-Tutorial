import XCTest
import Combine
import SwiftUI
import ViewInspector

internal final class Inspection<V> {
   let notice = PassthroughSubject<UInt, Never>()
   var callbacks: [UInt: (V) -> Void] = [:]
   func visit(_ view: V, _ line: UInt) {
      if let callback = callbacks.removeValue(forKey: line) {
         callback(view)
      }
   }
}

struct ViewInspectorWrapperView<InspectableView: View>: View {

  enum Constants: String {
    case viewId = "View-Inspector-Wrapper"
  }

  internal let inspection = Inspection<Self>()
  private var inspectableView: InspectableView

  init(
    @ViewBuilder inspectableView: () -> InspectableView
  ) {
    self.inspectableView = inspectableView()
  }

  var body: some View {
    inspectableView
      .id(Constants.viewId)
      .onReceive(inspection.notice) {
        inspection.visit(self, $0)
      }
  }
}

extension ViewInspectorWrapperView: Inspectable {}
