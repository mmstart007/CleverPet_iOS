# cleverpet-ios-app
CleverPet Hub mobile app for iOS 

## Deploying App to TestFlight
1. In the Info.plist file:
  * if needed, update the variable “Bundle version string, short” (`<key>CFBundleShortVersionString</key>` if not viewed in      xcode) to a value that looks like 0.0.10; the new value must be ‘greater’ than the old value. Consult with team if        incrementing up into higher ‘decimal places’.
  
  * Change the Bundle Version (`<key>CFBundleVersion</key>` if not viewed in xcode) from `${BITRISE_BUILD_NUMBER}` to an integer,   defining the version of the version string that you are building, e.g. 0.0.10 (1). The templating variable is there for    bitrise to populate when we build with bitrise. When we build and send to itunes, we build it locally, and so the          variable is never populated and xcode throws an error.

2. Under the ‘Product’ header in the menu bar, scroll down and click ‘Archive’. If all goes well, you should see the build     process running in the status bar at the top of the xcode window, followed by a pop up window with entries that read         ‘CleverPet’ and list Creation Date and Version as properties. 

3. On this window, click the blue ‘Upload to App Store’ button on the right. If all goes well, a new window should pop up       with a green check mark.

