import android.content.Context;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.content.res.AssetManager;
import android.content.res.Resources;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Path;
import android.graphics.drawable.AdaptiveIconDrawable;
import android.graphics.drawable.Drawable;
import android.os.Looper;
import android.util.DisplayMetrics;
import java.io.FileOutputStream;
import java.lang.reflect.Constructor;

/**
 * Extracts an app icon from an APK on the device.
 *
 * Usage: app_process / IconExtractor <apk_path> <package_name> <output_path>
 *
 * Renders the launcher icon to a PNG file at the given output path.
 * Adaptive icons are clipped to a circle to match the most common launcher shape.
 *
 * Rebuild icon_extractor.jar with build_icon_extractor.sh after changing this file.
 */
public class IconExtractor {
    public static void main(String[] args) {
        try {
            renderIcon(args[0], args[1], args[2]);
        } catch (Exception e) {
            System.err.println("Failed to extract the icon of " + args[1] + ": " + e);
            System.exit(1);
        }
    }

    private static void renderIcon(String apkPath, String packageName, String outputPath) throws Exception {
        PackageManager packageManager = createSystemContext().getPackageManager();
        PackageInfo packageInfo = packageManager.getPackageArchiveInfo(apkPath, 0);

        if (packageInfo == null) {
            throw new IllegalArgumentException("Could not open " + apkPath);
        }

        ApplicationInfo applicationInfo = packageInfo.applicationInfo;
        applicationInfo.sourceDir = apkPath;
        applicationInfo.publicSourceDir = apkPath;

        DisplayMetrics dm = new DisplayMetrics();
        dm.setToDefaults();
        dm.densityDpi = DisplayMetrics.DENSITY_XXXHIGH;
        AssetManager assets = packageManager.getResourcesForApplication(applicationInfo).getAssets();
        Resources res = new Resources(assets, dm, null);

        int iconResId = applicationInfo.icon;

        // Fall back to ic_launcher if the manifest doesn't define an icon.
        if (iconResId == 0) {
            iconResId = res.getIdentifier("ic_launcher", "mipmap", packageName);
        }

        if (iconResId == 0) {
            throw new IllegalStateException("Could not find the application's icon");
        }

        Drawable icon = res.getDrawable(iconResId, null);
        int size = Math.max(icon.getIntrinsicWidth(), 192);
        Bitmap bmp = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888);
        Canvas canvas = new Canvas(bmp);

        if (icon instanceof AdaptiveIconDrawable) {
            Path circle = new Path();
            circle.addCircle(size / 2f, size / 2f, size / 2f, Path.Direction.CW);
            canvas.clipPath(circle);
        }

        icon.setBounds(0, 0, size, size);
        icon.draw(canvas);

        try (FileOutputStream out = new FileOutputStream(outputPath)) {
            bmp.compress(Bitmap.CompressFormat.PNG, 100, out);
        }
    }

    /**
     * Creates the system context, since a process started with app_process isn't an app and has none.
     */
    private static Context createSystemContext() throws Exception {
        // ActivityThread creates a Handler, which needs a Looper on the current thread.
        Looper.prepareMainLooper();

        Class<?> activityThreadClass = Class.forName("android.app.ActivityThread");
        Constructor<?> constructor = activityThreadClass.getDeclaredConstructor();
        constructor.setAccessible(true);
        Object activityThread = constructor.newInstance();

        return (Context) activityThreadClass.getMethod("getSystemContext").invoke(activityThread);
    }
}
