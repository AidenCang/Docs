

public class FlutterJNI {
    @UiThread
    public static native boolean nativeGetIsSoftwareRenderingEnabled();
    @UiThread
    public static native String nativeGetObservatoryUri();
    private native void nativeSurfaceCreated(long var1, Surface var3);
    private native void nativeSurfaceChanged(long var1, int var3, int var4);
    private native void nativeSurfaceDestroyed(long var1);
    private native void nativeSetViewportMetrics(long var1, float var3, int var4, int var5, int var6, int var7, int var8, int var9, int var10, int var11, int var12, int var13);
    private native Bitmap nativeGetBitmap(long var1);
    private native void nativeDispatchPointerDataPacket(long var1, ByteBuffer var3, int var4);
    private native void nativeDispatchSemanticsAction(long var1, int var3, int var4, ByteBuffer var5, int var6);
    private native void nativeSetSemanticsEnabled(long var1, boolean var3);
    private native void nativeSetAccessibilityFeatures(long var1, int var3);
    private native void nativeRegisterTexture(long var1, long var3, SurfaceTexture var5);
    private native void nativeMarkTextureFrameAvailable(long var1, long var3);
    private native void nativeUnregisterTexture(long var1, long var3);
    private native long nativeAttach(FlutterJNI var1, boolean var2);
    private native void nativeDetach(long var1);
    private native void nativeDestroy(long var1);
    private native void nativeRunBundleAndSnapshotFromLibrary(long var1, @NonNull String[] var3, @Nullable String var4, @Nullable String var5, @NonNull AssetManager var6);
    private native void nativeDispatchEmptyPlatformMessage(long var1, String var3, int var4);
    private native void nativeDispatchPlatformMessage(long var1, String var3, ByteBuffer var4, int var5, int var6);
    private native void nativeInvokePlatformMessageEmptyResponseCallback(long var1, int var3);
    private native void nativeInvokePlatformMessageResponseCallback(long var1, int var3, ByteBuffer var4, int var5);
}
