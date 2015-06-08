/*:

# HTTP Networking

There's a good chance your app will need to interact with the world.  What better way to do that than through HTTP.

There's a couple ways you can do this, we'll explore two.  First we'll look at the built-in support and then we'll look at third party libraries.  We'll cover two examples here, the first is Alamofire and the second is Just, which are both popular open source libraries.

## Setup

Before we get started, we need to import some modules.  The first is the XCPlayground.  This allows us to tell the Playground that it should keep running, by default it will run and terminate.  Since networking requests are generally performed asynchronously, we need the playground to keep running.

*/

import XCPlayground
XCPSetExecutionShouldContinueIndefinitely()

/*:

We also import Foundation, which provides core Mac APIs, Alamofire which is an open source HTTP networking library and SwiftyJSON which is a JSON parsing library (see JSON playground for more details on that).

*/

import Foundation
import Alamofire
import SwiftyJSON
import Just

/*:

## Examples

All of the examples below send requests to [httpbin.org](http://httpbin.org), which simply echo's the request data back as JSON.  We then parse it, using SwiftyJSON and confirm the response.

We'll cover the following common scenarios.

  1. Simple GET request
  2. Basic AUTH request
  3. POST request w/Data

The first section will cover them with the built-in support, the second will use Alamofire and the third will use Just.

The following is some basic data used by all the tests.

*/

let ex1_url = "http://httpbin.org/get"
let ex2_url = "http://httpbin.org/basic-auth/auser/apass"
let ex3_url = "http://httpbin.org/post"

let params:[String: AnyObject] = [
    "foo": [1,2,3],
    "bar": [
        "baz": "qux"
    ]
]

/*:

### Built-in Support

For basic tasks, it's easy enough to use the built-in support.  There's more boiler plate code though, so as you start to do more complicated things the amount of code you need to write will go up quite a bit.  The examples here are pretty simple, but you'll see the difference in volume and complexity of code.

**Ex 1: Simple GET Request**

*/

var task = NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: ex1_url)!) {
    (data, response, err) -> Void in
    if err == nil {
        (response as! NSHTTPURLResponse).statusCode
        let json = JSON(data: data)
        json["origin"].string
        json["url"].string
    } else {
        err
    }
}
task.resume()

/*:

**Ex 2: Basic AUTH request**

*/

let loginData = "auser:apass".dataUsingEncoding(NSUTF8StringEncoding)
let loginEncoded = loginData?.base64EncodedStringWithOptions(nil)
let loginString = "Basic \(loginEncoded!)"

// fails, no auth
task = NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: ex2_url)!) {
    (data, response, err) -> Void in
    if err == nil {
        (response as! NSHTTPURLResponse).statusCode
    } else {
        err
    }
}
task.resume()

// let's send auth, much better!
var request = NSMutableURLRequest(URL: NSURL(string: ex2_url)!)
request.setValue(loginString, forHTTPHeaderField: "Authorization")

task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
    (data, response, err) in
    if err == nil {
        (response as! NSHTTPURLResponse).statusCode
        JSON(data: data!)["user"].stringValue
    } else {
        err
    }
}
task.resume()

/*:

**Ex 3: POST request w/Data**

*/

request = NSMutableURLRequest(URL: NSURL(string: ex3_url)!)
request.HTTPMethod = "POST"
request.HTTPBody = JSON(params).rawString()!.dataUsingEncoding(NSUTF8StringEncoding)
request.setValue("application/json", forHTTPHeaderField: "Content-Type")

task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
    (data, response, err) in
    if err == nil {
        (response as! NSHTTPURLResponse).statusCode
        let json = JSON(data: data!)
        json["json"]["bar"]["baz"].stringValue
    } else {
        err
    }
}
task.resume()


/*:

## Alamofire - Elegant Networking in Swift

Alamofire is a third party library which makes sending HTTP requests in Swift easier.  Here's three examples of using Alamofire.

**Ex 1: Simple GET Request**

*/

Alamofire.request(.GET, "http://httpbin.org/get").responseJSON {
    (req, resp, data, err) in
        if err == nil {
            resp?.statusCode
            let json = JSON(data!)
            json["origin"].stringValue
            json["url"].stringValue
        } else {
            err
        }
    }

/*:

**Ex 2: Basic AUTH request**

*/

// fails, no auth
Alamofire.request(.GET, "http://httpbin.org/basic-auth/auser/apass").responseJSON {
    (req, resp, data, err) in
        if err == nil {
            resp?.statusCode
        } else {
            err
        }
    }

// let's send auth, much better!
Alamofire.request(.GET, "http://httpbin.org/basic-auth/auser/apass")
    .authenticate(user: "auser", password: "apass")
    .responseJSON {
        (req, resp, data, err) in
            if err == nil {
                let status = resp?.statusCode
                JSON(data!)["user"].stringValue
            } else {
                println("Fail: \(err)")
            }
        }

/*:

**Ex 3: POST request w/Data**

*/

Alamofire.request(.POST, "http://httpbin.org/post", parameters: params, encoding: .JSON)
    .responseJSON {
    (req, resp, data, err) in
        if err == nil {
            resp?.statusCode
            let json = JSON(data!)
            json["json"]["bar"]["baz"].stringValue
        }
    }

/*:

## Just: Swift HTTP for Humans

Just is another third party HTTP library.  The syntax is different, but the goal is the same; make HTTP easier in Swift.

**Ex 1: Simple GET Request**

*/

Just.get("http://httpbin.org/get") { (r) in
    if r.ok {
        r.ok
        r.statusCode
        let json = JSON(data: r.content!)
        json["origin"].stringValue
        json["url"].stringValue
    }
}

/*:

**Ex 2: Basic AUTH request**

*/

// fails, no auth
Just.get("http://httpbin.org/basic-auth/auser/apass") { (r) in
    if !r.ok {
        r.ok
        r.statusCode
    }
}

// let's send auth, much better!
Just.get("http://httpbin.org/basic-auth/auser/apass", auth: ("auser", "apass"), asyncCompletionHandler: { (r) in
    if r.ok {
        r.ok
        r.statusCode
        JSON(data: r.content!)["user"].stringValue
    }
})

/*:

**Ex 3: POST request w/Data**

*/

Just.post("http://httpbin.org/post", json: params) { (r) in
    if r.ok {
        r.ok
        r.statusCode
        let json = JSON(data: r.content!)
        json["json"]["bar"]["baz"].stringValue
    }
}
