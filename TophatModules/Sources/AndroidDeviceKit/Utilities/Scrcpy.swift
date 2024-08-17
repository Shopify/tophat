import Foundation
import ShellKit

struct Scrcpy {
	static func connect(serial: String) throws {
		DispatchQueue.global(qos: .background).async {
			do {
				try run(command: .scrcpy(.connect(serial: serial)), log: log)
			} catch {
				// No error handling yet
			}
		}
	}
}
