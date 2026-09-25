public extension String {
	var isValidQuickLaunchEntryID: Bool {
		!isEmpty && allSatisfy { $0.isASCII && ($0.isLetter || $0.isNumber || $0 == "-") }
	}
}
