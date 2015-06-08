/*:

# File IO with Swift

At the moment, there's no Swift specific File API.  You simply use the existing Foundation APIs for File IO.  That means we start by importing it.

*/

import Foundation

/*:

## File API

The traditional file API is built around [NSFileManager](https://developer.apple.com/library/mac/documentation/Cocoa/Reference/Foundation/Classes/NSFileManager_Class/index.html#//apple_ref/occ/cl/NSFileManager), and as you might expect it allows you to examine and interact with the file system.

The first step is to get a file manager and there are two ways to do that.

1. Obtain the default file manager.
2. Create a new and unique file manager.

You should generally use the default file manager, except if you're planning to attach a delegate to it.  [Delegates](https://developer.apple.com/library/mac/documentation/Cocoa/Reference/NSFileManagerDelegate_Protocol/index.html#//apple_ref/occ/intf/NSFileManagerDelegate) are used to receive notifications when operations (copy, move, delete or linking) occur on a file or directory.  The delegate allows you to inject additional logic and control if a particular file is processed or skipped.

Here's how to get the default NSFileManager.

*/

NSFileManager.defaultManager()

//: Note, you can call this as many times as you want.  It will always return the same object.

NSFileManager.defaultManager()

//: To create a unique object, just use the `init` method.  It takes no parameters.

NSFileManager()

/*:

## Handling Paths

Before you can work with files, you need to understand how to construct, handle and manipulate file paths.  There's two ways to do this, either as strings or as URLs.  Both are similar, but each has it's advantages and disadvangages.  

For more on those, see the docs ([NSString](https://developer.apple.com/library/ios/documentation/Cocoa/Reference/Foundation/Classes/NSString_Class/index.html#//apple_ref/doc/uid/20000154-SW38), [NSURL](https://developer.apple.com/library/ios/documentation/Cocoa/Reference/Foundation/Classes/NSURL_Class/index.html#//apple_ref/doc/uid/20000301-SW25).

### Strings

Appending to or deleting path components or extensions.

*/

"/tmp".stringByAppendingPathComponent("junk")
"/tmp/file".stringByAppendingPathExtension("txt")

"/tmp/junk".stringByDeletingPathExtension
"/tmp/file.txt".stringByDeletingPathExtension

//: Obtain the current working directory

NSFileManager.defaultManager().currentDirectoryPath

//: Evaluate things like `~`, `.` and `..` in a path

"~/".stringByExpandingTildeInPath
"~".stringByStandardizingPath
"/tmp/junk/path/../../".stringByStandardizingPath

/*:

### URLs

Appending to or deleting path components or extensions.

*/

NSURL(fileURLWithPath: "/tmp")?.URLByAppendingPathComponent("junk")
NSURL(fileURLWithPath: "/tmp", isDirectory: true)?.URLByAppendingPathComponent("junk", isDirectory: true)
NSURL(fileURLWithPath: "/tmp/file")?.URLByAppendingPathExtension("txt")

NSURL(fileURLWithPath: "/tmp/junk/", isDirectory: true)?.URLByDeletingLastPathComponent
NSURL(fileURLWithPath: "/tmp/junk")?.URLByDeletingLastPathComponent
NSURL(fileURLWithPath: "/tmp/file.txt")?.URLByDeletingPathExtension

//: Obtain the current working directory

NSURL(fileURLWithPath: NSFileManager.defaultManager().currentDirectoryPath)

//: Obtain a URL relative to a path

NSURL(string: "../../", relativeToURL: NSURL(fileURLWithPath: "/tmp/junk/path/"))

/*:

### Special Paths

There are a handful of "special" paths, you might want to access.  These are things like the "Desktop", the user's directory, the application directory, etc.  Here's how you would get the paths for those.

... as a list of strings

*/

NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)

//: ... as a list of urls

NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.ApplicationDirectory, inDomains: NSSearchPathDomainMask.LocalDomainMask)

//: ... as a single url

NSFileManager.defaultManager().URLForDirectory(NSSearchPathDirectory.DesktopDirectory, inDomain: NSSearchPathDomainMask.UserDomainMask, appropriateForURL: nil, create: false, error: nil)

/*:

## Inspecting Files

In many cases you might want to inspect a file or folder, perhaps to confirm if it exists or if it has the proper permissions.  The NSFileManager allows you to do all this.

Note:  The NSFileManager docs suggest that you not use these methods because they are succeptable to race conditions, instead the suggestion is to just try an action and be prepared to gracefully handle an error.

*/

let curPath = NSFileManager.defaultManager().currentDirectoryPath

//: Check if a file or directory exists at the path

NSFileManager.defaultManager().fileExistsAtPath(curPath)

//: Check if exists and if a directory

var isDir: ObjCBool = false
NSFileManager.defaultManager().fileExistsAtPath(curPath, isDirectory: &isDir)
if isDir {
    "YES!"
}

//: Check if it's read / write / executable / deletable

NSFileManager.defaultManager().isReadableFileAtPath(curPath)
NSFileManager.defaultManager().isWritableFileAtPath(curPath)
NSFileManager.defaultManager().isExecutableFileAtPath(curPath)
NSFileManager.defaultManager().isDeletableFileAtPath(curPath)

/*:

## Directory Listings & Walking the Directory Tree

It's often useful to be able to list the contents of a directory or even recursively walk a directory tree.  This can be done with the NSFileManager and either a string path or an NSURL.  

In the examples below, we'll use NSURL.  It's slightly more verbose, but offers more functionality.

### List the contents of a Directory

*/

var error:NSError?

//: Get the URL pointing to the `/Applications` directory

let appsUrl:NSURL = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.ApplicationDirectory, inDomains: NSSearchPathDomainMask.LocalDomainMask)[0] as! NSURL

//: List the files (returns an array of NSURLs) in that directory

let filesInDir = NSFileManager.defaultManager().contentsOfDirectoryAtURL(appsUrl, includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions.SkipsHiddenFiles, error: &error)

/*:

### Recursively walk a directory tree

To get started, we get a URL or string path to our target directory.  In this case, it's the user's document's directory.

*/

let docsUrl = NSFileManager.defaultManager().URLForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomain: NSSearchPathDomainMask.UserDomainMask, appropriateForURL: nil, create: false, error: nil)!

/*:

The next step is to configure the NSDirectoryEnumerator.  This takes a few arguments.

  - the URL or path from which to start
  - an array of keys to cache. `nil` gives you the default. `[]` gives you none.  [Common file system keys](https://developer.apple.com/library/mac/documentation/Cocoa/Reference/Foundation/Classes/NSURL_Class/index.html#//apple_ref/doc/constant_group/Common_File_System_Resource_Keys)
  - Options mask to control behavior of enumerator.  [NSDirectoryEnumerationOptions](https://developer.apple.com/library/mac/documentation/Cocoa/Reference/Foundation/Classes/NSFileManager_Class/index.html#//apple_ref/c/tdef/NSDirectoryEnumerationOptions)
  - Optional error handler `(NSURL, NSError) -> Bool` that's called when there's a problem.  The handler can return true / false to control continue or stop.

In this example we don't cache any keys, we skip hidden files and the error handler just logs a message and continues.

*/

let fsEnumerator = NSFileManager.defaultManager().enumeratorAtURL(docsUrl, includingPropertiesForKeys: [], options: NSDirectoryEnumerationOptions.SkipsHiddenFiles)
{ (url:NSURL!, err:NSError!) -> Bool in
        if let e = err {
            "Error \(e)"
        }
        return true
}

//: Last, we run the NSDirectoryEnumerator.

for url in fsEnumerator! {
    "url -> \(url)"
}

/*:

## Basic File Ops

Copy, move and delete operations are straigtforward.  You use the NSFileManager object to perform the operation.

It's also possible to use an NSFileManagerDelegate with the copy, move and delete operations.  This gives you an easy way to add logic and control what is or is not deleted.  An example of this would be deleting all the files with an extension of *pdf*.

*/

let origFile = curPath.stringByAppendingPathComponent("origfile.txt")
let copyFile = curPath.stringByAppendingPathComponent("copyfile.txt")
let moveFile = curPath.stringByAppendingPathComponent("movefile.txt")
let data = "Hello World!".dataUsingEncoding(NSUTF8StringEncoding)

//: ### Create a file

NSFileManager.defaultManager().createFileAtPath(origFile, contents: data, attributes: nil)

//: ### Copy that file

var err:NSError?

if NSFileManager.defaultManager().copyItemAtPath(origFile, toPath: copyFile, error: &err) {
    "File Copied!"
} else {
    "Error \(err)"
}

//: ### Move the original file

if NSFileManager.defaultManager().moveItemAtPath(origFile, toPath: moveFile, error: &err) {
    "File Moved!"
} else {
    "Error \(err)"
}

//: ### Delete the copied file

if NSFileManager.defaultManager().removeItemAtPath(copyFile, error: &err) {
    "File \(copyFile) removed!"
} else {
    "Error \(err)"
}

//: ### Delete the moved file

if NSFileManager.defaultManager().removeItemAtPath(moveFile, error: &err) {
    "File \(moveFile) removed!"
} else {
    "Error \(err)"
}

/*:

## Temp Files and Directories

Creating temporary files and directories can helpful in your apps. For example, if you need a short term place to stash something on disk.

On your Mac, there's two places you can use for temporary files.  The first is the traditional "/tmp" directory.  The second is the user's cache directory.  The main difference between the two is that the "/tmp" directory is periodically cleared out.

### Locate the "/tmp" directory

*/

NSTemporaryDirectory()

//: ### Locate the cache directory

NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0]

/*: 

### Create a temporary file

There's no Swift or Cocoa API call to make a temporary file.  Instead you just use the C function `mkstemp`.  Doing that from Swift is easy enough, but requires a few steps.

First, you need to create the path.  We're going to do this by combining the temp directory and a template string.  In the template string, all `X` characters are replaced by a unique alphanumeric combination.  See `mkstemp` [man page](https://developer.apple.com/library/mac/documentation/Darwin/Reference/ManPages/man3/mkstemp.3.html) for more on how it works.

Also, note how we call `fileSystemRepresentation()` to get an array of encoded characters from the string.  We need this to interact properly with the C `mkstemp` function.

*/

var tmpFilePathTemplate = NSTemporaryDirectory().stringByAppendingPathComponent("prefix.XXXXXX.suffix").fileSystemRepresentation()

//: Second, call `mkstemp` with our file name.  It returns a file descriptor number, we'll need that in the next step.

var fileDesc = mkstemp(&tmpFilePathTemplate)

/*:

The third step is to check for errors with `mkstemp`.  If it fails, it'll return `-1`.  More details on the error can be found by inspecting the global `errno`.

*/

if fileDesc == -1 {
    "Fail :( [\(errno)] -> \(strerror(errno))"
    // normally, you'd handle this better
}

//: The fourth step is to take the file descriptor, which is a number and use it to get a handle to the file.  That can then be used to interact with the file.

var tmpFile = NSFileHandle(fileDescriptor: fileDesc, closeOnDealloc: false)

// do some stuff

tmpFile.closeFile()

//: When we're done with the temp file, we need to delete it.  The easiest way to do that is with NSFileManager's `removeitemAtPath` method.

let tmpFilePath = NSFileManager.defaultManager().stringWithFileSystemRepresentation(tmpFilePathTemplate, length: tmpFilePathTemplate.count)

NSFileManager.defaultManager().removeItemAtPath(tmpFilePath, error: &err)


/*:

### Create a temporary directory

This works much like creating a temporary file.  You just use the C `mkdtemp` method instead.  here's an example.

*/

var tempDirPathTemplate = NSTemporaryDirectory().stringByAppendingPathComponent("dir-prefix.XXXXXX.suffix").fileSystemRepresentation()

mkdtemp(&tempDirPathTemplate)

let tmpDirPath = NSFileManager.defaultManager().stringWithFileSystemRepresentation(tempDirPathTemplate, length: tempDirPathTemplate.count)

NSFileManager.defaultManager().removeItemAtPath(tmpDirPath, error: &err)

/*:

## Accessing Resources from an App Bundle

To access resources that you bundle with your app, things like images, config, etc..; you simply need to use the `NSBundle.mainBundle().pathForResource(..)` method.  This returns the full path to the bundled resource.

In this example, we grabs the "BundledFile.txt" file that is packaged with the playground, read the entire thing and convert it to a string.

More docs on this [here](https://developer.apple.com/library/mac/documentation/Cocoa/Reference/Foundation/Classes/NSBundle_Class/index.html#//apple_ref/doc/uid/20000214-SW13).

*/

if let resourcePath = NSBundle.mainBundle().pathForResource("BundledFile", ofType: "txt") {
    NSString(data: NSData(contentsOfFile: resourcePath)!, encoding: NSUTF8StringEncoding)
}

