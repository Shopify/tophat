//
//  MenuItemButtonStyle.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2022-12-09.
//  Copyright © 2022 Shopify. All rights reserved.
//

import SwiftUI

struct MenuItemButtonStyle: PrimitiveButtonStyle {
	private let blinkDuration = 0.18

	@State private var animationTrigger = 0

	var activatesApplication = false
	var blinks = false

	// The .disabled() view modifier is not being used because it causes performance issues
	// in the interface. This workaround manually implements disabled behavior.
	var isEnabled = false

	func makeBody(configuration: Configuration) -> some View {
		Button {
			guard isEnabled else {
				return
			}

			let trigger = configuration.trigger

			Task { @MainActor in
				if blinks {
					animationTrigger += 1
					try? await Task.sleep(for: .seconds(blinkDuration + 0.01), tolerance: .zero)
				}

				if activatesApplication {
					NSRunningApplication.current.activate()
				}

				trigger()
			}
		} label: {
			configuration.label
		}
		.buttonStyle(
			MenuItemButtonStyleInternal(
				animationTrigger: animationTrigger,
				blinkDuration: blinkDuration,
				isEnabled: isEnabled
			)
		)
	}
}

private struct MenuItemButtonStyleInternal: ButtonStyle {
	@State private var hovering = false

	var animationTrigger: Int
	var blinkDuration: TimeInterval
	var isEnabled: Bool

	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.foregroundStyle(isEnabled ? .primary : .tertiary)
			.padding(.vertical, Theme.Size.menuPaddingVertical)
			.padding(.horizontal, Theme.Size.menuPaddingHorizontal)
			.frame(maxWidth: .infinity, alignment: .leading)
			.background {
				RoundedRectangle(cornerRadius: 4)
					.fill(.quaternary)
					.phaseAnimator([isEnabled && hovering ? 1 : 0, 0, 1], trigger: animationTrigger) { view, phase  in
						view.opacity(phase)
					} animation: { _ in
						Animation(BlinkAnimation(duration: blinkDuration / 3))
					}
			}
			.onHover { hovering in
				self.hovering = hovering
			}
			.environment(\.buttonPressed, configuration.isPressed)
			.environment(\.buttonHovered, hovering)
	}
}

extension PrimitiveButtonStyle where Self == MenuItemButtonStyle {
	static var menuItem: Self {
		menuItem(activatesApplication: false, blinks: false)
	}

	static func menuItem(activatesApplication: Bool = false, blinks: Bool = false, disabled: Bool = false) -> Self {
		MenuItemButtonStyle(activatesApplication: activatesApplication, blinks: blinks, isEnabled: !disabled)
	}
}

private struct ButtonPressedKey: EnvironmentKey {
	static let defaultValue = false
}

private struct ButtonHoveredKey: EnvironmentKey {
	static let defaultValue = false
}

extension EnvironmentValues {
	var buttonPressed: Bool {
		get { self[ButtonPressedKey.self] }
		set { self[ButtonPressedKey.self] = newValue }
	}

	var buttonHovered: Bool {
		get { self[ButtonHoveredKey.self] }
		set { self[ButtonHoveredKey.self] = newValue }
	}
}

private struct BlinkAnimation: CustomAnimation {
	var duration: TimeInterval

	func animate<V>(value: V, time: TimeInterval, context: inout AnimationContext<V>) -> V? where V: VectorArithmetic {
		if time > duration {
			return nil
		}

		let progress = time / duration

		return value.scaled(by: progress == 1 ? 1 : 0)
	}
}
