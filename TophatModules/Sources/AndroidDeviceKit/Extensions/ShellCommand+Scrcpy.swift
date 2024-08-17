import Foundation
import ShellKit

extension ShellCommand where Self == ScrcpyCommand {
	static func scrcpy(_ command: Self) -> Self {
		command
	}
}

enum ScrcpyCommand {
	case connect(serial: String)
}

extension ScrcpyCommand: ShellCommand {
	var executable: Executable {
		if let url = PathResolver.scrcpy {
			return .url(url)
		}
		return .name("scrcpy")
	}

	var environment: [String: String] {
		return ["ADB": PathResolver.adb.path(percentEncoded: false)]
	}

	var arguments: [String] {
		switch self {
		case .connect(let serial):
			return ["-s", serial]
		}
	}
}
