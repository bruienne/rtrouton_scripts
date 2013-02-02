#!/bin/sh

# Checks for backup directory for Java 7 plug-in
# and creates it if needed.

if [ -d "/Library/Internet Plug-Ins (Disabled)" ]; then
     echo "Backup Directory Found"
  else
     mkdir "/Library/Internet Plug-Ins (Disabled)"
     chown -R root:wheel "/Library/Internet Plug-Ins (Disabled)"
fi

# If a previous version of the Java 7 plug-in is already 
# in the backup directory, the previously backed up Java 7 
# plug-in is removed.

if [ -d "/Library/Internet Plug-Ins (Disabled)/JavaAppletPlugin.plugin" ]; then
      rm -rf "/Library/Internet Plug-Ins (Disabled)/JavaAppletPlugin.plugin"
fi

# Moves current Java 7 plug-in to the backup directory

if [ -d "/Library/Internet Plug-Ins/JavaAppletPlugin.plugin" ]; then
     mv "/Library/Internet Plug-Ins/JavaAppletPlugin.plugin" "/Library/Internet Plug-Ins (Disabled)/JavaAppletPlugin.plugin"
fi

# Create symlink to the Apple Java 6 plug-in in
# /Library/Internet Plug-Ins 

ln -sf /System/Library/Java/Support/Deploy.bundle/Contents/Resources/JavaPlugin2_NPAPI.plugin "/Library/Internet Plug-Ins/JavaAppletPlugin.plugin"

# Re-enable Java SE 6 Web Start, which allows Java 
# applets to run in web browsers

ln -sf /System/Library/Frameworks/JavaVM.framework/Commands/javaws /usr/bin/javaws

# Check to see if Xprotect is blocking our current JVM build and reenable if it is

CURRENT_JAVA_BUILD=`/usr/libexec/PlistBuddy -c "print :JavaVM:JVMVersion" /Library/Java/Home/bundle/Info.plist`
XPROTECT_JAVA_BUILD=`/usr/libexec/PlistBuddy -c "print :JavaWebComponentVersionMinimum" /System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/XProtect.meta.plist`

if [ ${CURRENT_JAVA_BUILD: -3} -lt ${XPROTECT_JAVA_BUILD: -3} ]; then

     logger "Current JavaVM build (${CURRENT_JAVA_BUILD: -3}) is less than the minimum build required by Xprotect (${XPROTECT_JAVA_BUILD: -3}), reenabling."
	defaults write /System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/XProtect.meta JavaWebComponentVersionMinimum -string "$CURRENT_JAVA_BUILD"
else
	logger "Current JVM build is ${CURRENT_JAVA_BUILD: -3} and Xprotect minimum build is ${XPROTECT_JAVA_BUILD: -3}, nothing to do here."
fi

exit 0
