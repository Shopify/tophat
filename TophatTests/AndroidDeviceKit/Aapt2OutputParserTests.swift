//
//  Aapt2OutputParserTests.swift
//  TophatTests
//
//  Created by Jared Hendry on 2026-11-15.
//  Copyright © 2026 Shopify. All rights reserved.
//

import Testing
@testable import AndroidDeviceKit

struct Aapt2OutputParserTests {
	@Test
	func readsApplicationIconResourceID() {
		let manifest = """
		N: android=http://schemas.android.com/apk/res/android (line=2)
		  E: manifest (line=2)
		    A: http://schemas.android.com/apk/res/android:versionCode(0x0101021b)=31
		      E: application (line=27)
		        A: http://schemas.android.com/apk/res/android:theme(0x01010000)=@0x7f110009
		        A: http://schemas.android.com/apk/res/android:label(0x01010001)=@0x7f10001d
		        A: http://schemas.android.com/apk/res/android:icon(0x01010002)=@0x7f0d0001
		        A: http://schemas.android.com/apk/res/android:allowBackup(0x01010280)=false
		          E: activity (line=34)
		            A: http://schemas.android.com/apk/res/android:label(0x01010001)=@0x7f10001d
		"""

		#expect(Aapt2OutputParser.iconResourceID(inManifestTree: manifest) == "0x7f0d0001")
	}

	@Test
	func ignoresIconsDeclaredOnActivities() {
		let manifest = """
		  E: manifest (line=2)
		      E: application (line=11)
		        A: http://schemas.android.com/apk/res/android:label(0x01010001)=@0x7f010000
		          E: activity (line=14)
		            A: http://schemas.android.com/apk/res/android:icon(0x01010002)=@0x7f020005
		"""

		#expect(Aapt2OutputParser.iconResourceID(inManifestTree: manifest) == nil)
	}

	@Test
	func returnsNoResourceIDForIconReferencedByName() {
		let manifest = """
		  E: manifest (line=2)
		      E: application (line=11)
		        A: http://schemas.android.com/apk/res/android:icon(0x01010002)=@com.example:mipmap/ic_launcher
		"""

		#expect(Aapt2OutputParser.iconResourceID(inManifestTree: manifest) == nil)
	}

	@Test
	func prefersRasterIconOverAdaptiveIcon() {
		let resources = """
		  type mipmap id=0d entryCount=2
		    resource 0x7f0d0000 mipmap/ic_foreground
		      (xxhdpi) (file) res/mipmap-xxhdpi-v4/ic_foreground.png type=PNG
		    resource 0x7f0d0001 mipmap/ic_launcher
		      (mdpi) (file) res/mipmap-mdpi-v4/ic_launcher.png type=PNG
		      (mdpi-v26) (file) res/mipmap-mdpi-v26/ic_launcher.xml type=XML
		      (xxhdpi) (file) res/mipmap-xxhdpi-v4/ic_launcher.png type=PNG
		      (xxhdpi-v26) (file) res/mipmap-xxhdpi-v26/ic_launcher.xml type=XML
		      (xxxhdpi) (file) res/mipmap-xxxhdpi-v4/ic_launcher.png type=PNG
		    resource 0x7f0d0002 mipmap/ic_launcher_round
		      (xxhdpi) (file) res/mipmap-xxhdpi-v4/ic_launcher_round.png type=PNG
		"""

		#expect(
			Aapt2OutputParser.iconPath(inResourceTable: resources, resourceID: "0x7f0d0001")
				== "res/mipmap-xxhdpi-v4/ic_launcher.png"
		)
	}

	@Test
	func findsDrawableIconWithVersionedConfigurations() {
		let resources = """
		Binary APK
		Package name=com.shopify.AnimationDisabler id=7f
		  type drawable id=02 entryCount=1
		    resource 0x7f020000 drawable/ic_launcher
		      (mdpi-v4) (file) res/drawable-mdpi-v4/ic_launcher.png type=PNG
		      (hdpi-v4) (file) res/drawable-hdpi-v4/ic_launcher.png type=PNG
		      (xhdpi-v4) (file) res/drawable-xhdpi-v4/ic_launcher.png type=PNG
		      (xxhdpi-v4) (file) res/drawable-xxhdpi-v4/ic_launcher.png type=PNG
		  type layout id=03 entryCount=1
		    resource 0x7f030000 layout/activity_disable_animation
		      () (file) res/layout/activity_disable_animation.xml type=XML
		"""

		#expect(
			Aapt2OutputParser.iconPath(inResourceTable: resources, resourceID: "0x7f020000")
				== "res/drawable-xxhdpi-v4/ic_launcher.png"
		)
	}

	@Test(arguments: ["png", "webp", "jpg", "jpeg", "gif"])
	func findsRasterIcon(fileExtension: String) {
		let resources = """
		    resource 0x7f080000 mipmap/ic_launcher
		      (xxhdpi) (file) res/mipmap-xxhdpi-v4/ic_launcher.\(fileExtension)
		"""

		#expect(
			Aapt2OutputParser.iconPath(inResourceTable: resources, resourceID: "0x7f080000")
				== "res/mipmap-xxhdpi-v4/ic_launcher.\(fileExtension)"
		)
	}

	@Test
	func prefersHigherDensityOverCloserLowerDensity() {
		let resources = """
		    resource 0x7f080000 mipmap/ic_launcher
		      (400dpi) (file) res/mipmap-400dpi-v4/ic_launcher.png type=PNG
		      (xxxhdpi) (file) res/mipmap-xxxhdpi-v4/ic_launcher.png type=PNG
		"""

		#expect(
			Aapt2OutputParser.iconPath(inResourceTable: resources, resourceID: "0x7f080000")
				== "res/mipmap-xxxhdpi-v4/ic_launcher.png"
		)
	}

	@Test
	func choosesLowestDensityAbovePreferred() {
		let resources = """
		    resource 0x7f080000 mipmap/ic_launcher
		      (xhdpi) (file) res/mipmap-xhdpi-v4/ic_launcher.png type=PNG
		      (560dpi) (file) res/mipmap-560dpi-v4/ic_launcher.png type=PNG
		      (xxxhdpi) (file) res/mipmap-xxxhdpi-v4/ic_launcher.png type=PNG
		"""

		#expect(
			Aapt2OutputParser.iconPath(inResourceTable: resources, resourceID: "0x7f080000")
				== "res/mipmap-560dpi-v4/ic_launcher.png"
		)
	}

	@Test
	func choosesHighestDensityBelowPreferred() {
		let resources = """
		    resource 0x7f080000 mipmap/ic_launcher
		      (xhdpi) (file) res/mipmap-xhdpi-v4/ic_launcher.png type=PNG
		      (420dpi) (file) res/mipmap-420dpi-v4/ic_launcher.png type=PNG
		"""

		#expect(
			Aapt2OutputParser.iconPath(inResourceTable: resources, resourceID: "0x7f080000")
				== "res/mipmap-420dpi-v4/ic_launcher.png"
		)
	}

	@Test
	func prefersDensityIndependentIconOverLowerDensities() {
		let resources = """
		    resource 0x7f080000 drawable/ic_launcher
		      (mdpi) (file) res/drawable-mdpi-v4/ic_launcher.png type=PNG
		      (hdpi) (file) res/drawable-hdpi-v4/ic_launcher.png type=PNG
		      (nodpi) (file) res/drawable-nodpi-v4/ic_launcher.png type=PNG
		"""

		#expect(
			Aapt2OutputParser.iconPath(inResourceTable: resources, resourceID: "0x7f080000")
				== "res/drawable-nodpi-v4/ic_launcher.png"
		)
	}

	@Test
	func prefersHigherDensityOverDensityIndependentIcon() {
		let resources = """
		    resource 0x7f080000 drawable/ic_launcher
		      (xxxhdpi) (file) res/drawable-xxxhdpi-v4/ic_launcher.png type=PNG
		      (nodpi) (file) res/drawable-nodpi-v4/ic_launcher.png type=PNG
		"""

		#expect(
			Aapt2OutputParser.iconPath(inResourceTable: resources, resourceID: "0x7f080000")
				== "res/drawable-xxxhdpi-v4/ic_launcher.png"
		)
	}

	@Test
	func prefersAnyDensityIconOverPreferredDensity() {
		let resources = """
		    resource 0x7f080000 drawable/ic_launcher
		      (xxhdpi) (file) res/drawable-xxhdpi-v4/ic_launcher.png type=PNG
		      (anydpi) (file) res/drawable-anydpi-v4/ic_launcher.png type=PNG
		"""

		#expect(
			Aapt2OutputParser.iconPath(inResourceTable: resources, resourceID: "0x7f080000")
				== "res/drawable-anydpi-v4/ic_launcher.png"
		)
	}

	@Test
	func ignoresIconsForOtherConfigurations() {
		let resources = """
		    resource 0x7f080000 mipmap/ic_launcher
		      (xhdpi) (file) res/mipmap-xhdpi-v4/ic_launcher.png type=PNG
		      (fr-xxhdpi) (file) res/mipmap-fr-xxhdpi-v4/ic_launcher.png type=PNG
		      (night-xxhdpi-v8) (file) res/mipmap-night-xxhdpi-v8/ic_launcher.png type=PNG
		"""

		#expect(
			Aapt2OutputParser.iconPath(inResourceTable: resources, resourceID: "0x7f080000")
				== "res/mipmap-xhdpi-v4/ic_launcher.png"
		)
	}

	@Test
	func ignoresFlagDisabledValues() {
		let resources = """
		    resource 0x7f080000 mipmap/ic_launcher
		      (xhdpi) (file) res/mipmap-xhdpi-v4/ic_launcher.png type=PNG
		      Flag disabled values:
		      (xxhdpi) (file) res/mipmap-xxhdpi-v4/ic_launcher_disabled.png type=PNG
		"""

		#expect(
			Aapt2OutputParser.iconPath(inResourceTable: resources, resourceID: "0x7f080000")
				== "res/mipmap-xhdpi-v4/ic_launcher.png"
		)
	}

	@Test
	func returnsNoPathForVectorOnlyIcon() {
		let resources = """
		    resource 0x7f080000 mipmap/ic_launcher
		      (anydpi-v26) (file) res/mipmap-anydpi-v26/ic_launcher.xml type=XML
		    resource 0x7f080001 mipmap/other
		      (xxhdpi) (file) res/mipmap-xxhdpi-v4/other.png type=PNG
		"""

		#expect(Aapt2OutputParser.iconPath(inResourceTable: resources, resourceID: "0x7f080000") == nil)
	}

	@Test
	func returnsNoPathForUnknownResource() {
		let resources = """
		    resource 0x7f080000 mipmap/ic_launcher
		      (xxhdpi) (file) res/mipmap-xxhdpi-v4/ic_launcher.png type=PNG
		"""

		#expect(Aapt2OutputParser.iconPath(inResourceTable: resources, resourceID: "0x7f080009") == nil)
	}

	@Test
	func followsReferenceByName() {
		let resources = """
		    resource 0x7f080000 mipmap/ic_launcher
		      () @mipmap/ic_launcher_by_name
		      (anydpi-v26) (file) res/mipmap-anydpi-v26/ic_launcher.xml type=XML
		    resource 0x7f080001 mipmap/other
		      (xxhdpi) (file) res/mipmap-xxhdpi-v4/other.png type=PNG
		    resource 0x7f080002 mipmap/ic_launcher_by_name
		      (mdpi) (file) res/mipmap-mdpi-v4/ic_launcher_by_name.webp
		      (xxhdpi) (file) res/mipmap-xxhdpi-v4/ic_launcher_by_name.webp
		      (xxxhdpi) (file) res/mipmap-xxxhdpi-v4/ic_launcher_by_name.webp
		"""

		#expect(
			Aapt2OutputParser.iconPath(inResourceTable: resources, resourceID: "0x7f080000")
				== "res/mipmap-xxhdpi-v4/ic_launcher_by_name.webp"
		)
	}

	@Test
	func followsReferenceByID() {
		let resources = """
		    resource 0x7f080000 mipmap/ic_launcher
		      () @0x7f080002
		    resource 0x7f080001 mipmap/other
		      (xxhdpi) (file) res/mipmap-xxhdpi-v4/other.png type=PNG
		    resource 0x7f080002 mipmap/ic_launcher_by_id PUBLIC
		      (xxhdpi) (file) res/mipmap-xxhdpi-v4/ic_launcher_by_id.png type=PNG
		"""

		#expect(
			Aapt2OutputParser.iconPath(inResourceTable: resources, resourceID: "0x7f080000")
				== "res/mipmap-xxhdpi-v4/ic_launcher_by_id.png"
		)
	}

	@Test
	func followsReferenceForPreferredDensity() {
		let resources = """
		    resource 0x7f080000 mipmap/ic_launcher
		      (mdpi) @mipmap/ic_launcher_small
		      (xxhdpi) @mipmap/ic_launcher_large
		    resource 0x7f080001 mipmap/ic_launcher_large
		      (xxhdpi) (file) res/mipmap-xxhdpi-v4/ic_launcher_large.png type=PNG
		    resource 0x7f080002 mipmap/ic_launcher_small
		      (mdpi) (file) res/mipmap-mdpi-v4/ic_launcher_small.png type=PNG
		"""

		#expect(
			Aapt2OutputParser.iconPath(inResourceTable: resources, resourceID: "0x7f080000")
				== "res/mipmap-xxhdpi-v4/ic_launcher_large.png"
		)
	}

	@Test
	func followsReferenceOverLowerDensityFile() {
		let resources = """
		    resource 0x7f080000 mipmap/ic_launcher
		      (mdpi) (file) res/mipmap-mdpi-v4/ic_launcher.png type=PNG
		      (xxhdpi) @mipmap/ic_launcher_large
		    resource 0x7f080001 mipmap/ic_launcher_large
		      (xxhdpi) (file) res/mipmap-xxhdpi-v4/ic_launcher_large.png type=PNG
		"""

		#expect(
			Aapt2OutputParser.iconPath(inResourceTable: resources, resourceID: "0x7f080000")
				== "res/mipmap-xxhdpi-v4/ic_launcher_large.png"
		)
	}

	@Test
	func followsNextReferenceWhenOneHasNoRasterFile() {
		let resources = """
		    resource 0x7f080000 mipmap/ic_launcher
		      () @null
		      (v21) @android:mipmap/sym_def_app_icon
		      (v23) @0x01080093
		      (v24) @mipmap/ic_launcher_vector
		      (v26) @mipmap/ic_launcher_raster
		    resource 0x7f080001 mipmap/ic_launcher_raster
		      (xxhdpi) (file) res/mipmap-xxhdpi-v4/ic_launcher_raster.png type=PNG
		    resource 0x7f080002 mipmap/ic_launcher_vector
		      (anydpi-v24) (file) res/mipmap-anydpi-v24/ic_launcher_vector.xml type=XML
		"""

		#expect(
			Aapt2OutputParser.iconPath(inResourceTable: resources, resourceID: "0x7f080000")
				== "res/mipmap-xxhdpi-v4/ic_launcher_raster.png"
		)
	}

	@Test
	func ignoresReferencesForOtherConfigurations() {
		let resources = """
		    resource 0x7f080000 mipmap/ic_launcher
		      (night) @mipmap/ic_launcher_night
		      (anydpi-v26) (file) res/mipmap-anydpi-v26/ic_launcher.xml type=XML
		    resource 0x7f080001 mipmap/ic_launcher_night
		      (xxhdpi) (file) res/mipmap-xxhdpi-v4/ic_launcher_night.png type=PNG
		"""

		#expect(Aapt2OutputParser.iconPath(inResourceTable: resources, resourceID: "0x7f080000") == nil)
	}

	@Test
	func stopsFollowingReferenceCycle() {
		let resources = """
		    resource 0x7f080000 mipmap/ic_launcher
		      () @mipmap/ic_launcher_cycle
		    resource 0x7f080001 mipmap/ic_launcher_cycle
		      () @0x7f080000
		"""

		#expect(Aapt2OutputParser.iconPath(inResourceTable: resources, resourceID: "0x7f080000") == nil)
	}
}
