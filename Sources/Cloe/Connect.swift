// Created by Gil Birman on 1/11/20.

import SwiftUI
import Combine

/// Inject a Cloe Store into a SwiftUI view
///
/// Example usage:
///
///     struct MyView: View {
///       var index: Int
///
///       // Define your derived state
///       struct MyDerivedState: Equatable {
///         var age: Int
///         var name: String
///       }
///
///       // Inject your store
///       @EnvironmentObject var store: AppStore
///
///       // Connect to the store
///       var body: some View {
///         Connect(store: store, selector: selector, content: body)
///       }
///
///       // Setup a state selector
///       private func selector(_ state: AppState) -> MyDerivedState {
///         .init(age: state.age, name: state.names[index])
///       }
///
///       // Render something using the selected state
///       private func body(_ state: MyDerivedState) -> some View {
///         Text("Hello \(state.name)!")
///       }
///     }
@available(iOS 13, macOS 10.15, tvOS 13, watchOS 6, *)
public struct Connect<State, SubState: Equatable, Content: View>: View {

  // MARK: Public

  public var content: (SubState) -> Content

  public init(
    store: Store<State>,
    selector: @escaping StateSelector<State, SubState>,
    content: @escaping (SubState) -> Content)
  {
    self.content = content
    publisher = store.uniqueSubStatePublisher(selector)
    _state = SwiftUI.State(initialValue: selector(store.state))
  }

  public var body: some View {
    content(state).onReceive(publisher) { state in
      self.state = state
    }
  }

  // MARK: Private

  @SwiftUI.State private var state: SubState
  private var publisher: AnyPublisher<SubState, Never>
}
