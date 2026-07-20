import PassKit

struct WalletCapability {
    let isWalletAvailable: Bool

    static var current: WalletCapability {
        WalletCapability(isWalletAvailable: PKPassLibrary.isPassLibraryAvailable())
    }
}
