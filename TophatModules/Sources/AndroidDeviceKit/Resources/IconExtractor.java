import android.content.res.AssetManager;
import android.content.res.Resources;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Path;
import android.graphics.drawable.AdaptiveIconDrawable;
import android.graphics.drawable.Drawable;
import android.util.DisplayMetrics;
import java.io.FileOutputStream;
import java.lang.reflect.Method;

/**
 * Extracts an app icon from an APK on the device.
 *
 * Usage: app_process / IconExtractor <apk_path> <package_name> <output_path>
 *
 * Renders the launcher icon to a PNG file at the given output path.
 * Adaptive icons are clipped to a circle to match the most common launcher shape.
 */
public class IconExtractor {
    public static void main(String[] args) throws Exception {
        String apkPath = args[0];
        String packageName = args[1];
        String outputPath = args[2];

        AssetManager assets = AssetManager.class.getConstructor().newInstance();
        Method addPath = AssetManager.class.getMethod("addAssetPath", String.class);
        addPath.invoke(assets, apkPath);

        DisplayMetrics dm = new DisplayMetrics();
        dm.setToDefaults();
        dm.densityDpi = DisplayMetrics.DENSITY_XXXHIGH;
        Resources res = new Resources(assets, dm, null);

        int iconResId = res.getIdentifier("ic_launcher", "mipmap", packageName);
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
}
