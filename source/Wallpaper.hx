package;


#if sys
import sys.FileSystem;
import sys.io.Process;
#end

#if windows
@:headerCode('
    #include <windows.h>
    #include <iostream>
    #include <string>
    #include <hxcpp.h>
')
#end
class Wallpaper
{
	@:noCompletion
	public static var oldWallpaper(default, null):String;

	@:noCompletion
	public static function setOld():Void
	{
		oldWallpaper = _setOld();
	}

	#if windows
	@:functionCode('
        wchar_t* wallpath = const_cast<wchar_t*>(path.wchar_str());
        SystemParametersInfoW(SPI_SETDESKWALLPAPER, 0, reinterpret_cast<void*>(wallpath), SPIF_UPDATEINIFILE | SPIF_SENDCHANGE);
    ')
	#end
	@:noCompletion
	public static function setWallpaper(path:String):Void
	{
		#if fmacf
		var imagePath:String = path;
        var command:String = "osascript -e 'tell application \"Finder\" to set desktop picture to POSIX file \"" + imagePath + "\"'";
        var process = Process.runCommand(command);
		#end
		return;
	}

	#if windows
	@:functionCode('
        WCHAR buffer[1024] = {0};
        SystemParametersInfoW(SPI_GETDESKWALLPAPER, 256, &buffer, NULL);
        return String(buffer);
    ')
	#end
	@:noCompletion
	private static function _setOld():String
	{
		#if fmacf
        var getWallpaperCommand:String = "osascript -e 'tell application \"Finder\" to get desktop picture as POSIX file'";
        var getWallpaperProcess = Process.runCommand(getWallpaperCommand);
        // Check for errors
        if (getWallpaperProcess.exitCode != 0) {
            trace("Error getting desktop wallpaper");
        } else {
            var wallpaperPath:String = getWallpaperProcess.stdout.toString().trim();
            var destinationFolder:String = "assets/";
            var wallpaperFileName:String = FileSystem.fileName(wallpaperPath);
            var destinationPath:String = destinationFolder + wallpaperFileName;
            var copyWallpaperCommand:String = "cp " + wallpaperPath + " " + destinationPath;

            // Execute the command to copy the wallpaper file
            var copyWallpaperProcess = Process.runCommand(copyWallpaperCommand);

            // Check for errors
            if (copyWallpaperProcess.exitCode != 0) {
                trace("Error saving desktop wallpaper");
            } else {
                trace("Desktop wallpaper saved successfully to: " + destinationPath);
            }
        }
		#end
		return "";
	}
}
