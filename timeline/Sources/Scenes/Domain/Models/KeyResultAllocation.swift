import Foundation

struct KeyResultAllocation: Hashable {
    let keyResultID: UUID
    var seconds: TimeInterval

    init(keyResultID: UUID, seconds: TimeInterval) {
        self.keyResultID = keyResultID
        self.seconds = seconds
    }
}
