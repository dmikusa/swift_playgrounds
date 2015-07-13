import SwiftyJSON

/*:

## JSON

This playground shows a couple approaches for using JSON from Swift.  The first is the built-in support and the second is a friendlier library called SwiftyJSON.

*/

//: Load a small bit of data to use below
let small_json_data = "{\"a\": 100, \"b\": 200}".dataUsingEncoding(NSUTF8StringEncoding)!

//: Load a larger amount of data to use below
let path = NSBundle.mainBundle().pathForResource("test", ofType: "json")
let big_json_data = NSData(contentsOfFile: path!)

/*:

### Reading w/Built-in Support

Here we use Swift's build-in JSON support to parse the small JSON blob.  As you can see it's pretty simple, you just have to handle the optionals correctly.

*/

var error: NSError?
let small_json_obj: AnyObject? = NSJSONSerialization.JSONObjectWithData(small_json_data, options: nil, error: &error)

if error != nil {
    "Error: \(error)"
}

if let small_json_dict = small_json_obj as? Dictionary<String, Int> {
    let a = small_json_dict["a"]!
    let b = small_json_dict["b"]!
    "a: \(a)  b: \(b)"
} else {
    "Couldn't convert to Dictionary<String, Int>"
}

/*:

### Reading w/SwiftyJSON

Here's the same example, but using SwiftyJSON.  The code is easier to read and less verbose.

*/

let small_json = JSON(data: small_json_data)
let a = small_json["a"].intValue
let b = small_json["b"].int
"a: \(a)  b: \(b)"

/*:

### More Complicated Example of Reading

This example parses a more complicated JSON object.  The `test.json` file is in the `Resources` directory of this playground, if you'd like to see the raw JSON.

#### Built-in Support

I'm not showing how you'd do this with the built-in support as it's a lot of code and messy.  There's nothing wrong with the built-in support, using it just requires more verbose code.

#### SwiftyJSON

Here's how you'd parse it with SwiftyJSON.  As you can see, it's not much more compliated than the short example above.

*/

// parse json
let json_in = JSON(data: big_json_data!)

"We've read in \(json_in.count) items"

// test.json is a big list, grab the first item
let item1 = json_in[0]

// print some of the keys
for (key,val) in item1 {
    if key == "tags" {
        for (_: String, v: JSON) in val {
            v
        }
    } else if key == "friends" {
        for (i: String, friend: JSON) in val {
            let id = friend["id"]
            let name = friend["name"]
            "   \(id) -> \(name)"
        }
        
    } else {
        "\(key): \(val)"
    }
}


/*:

### Converting to JSON

The other side of the coin is writing data into the JSON format.  Below are two examples on doing this.

Regardless of the way you do it note the limitations that are documented on the NSJSONSerialization object.  Essentially it works with simple types that easily correspond to JSON.

*/

let obj_to_dump = ["name":"Jack", "age": 25, "list":["a","b","c",["what":"this"]]]


//: #### Built-in Support

let apl_json_out = NSJSONSerialization.dataWithJSONObject(obj_to_dump, options: NSJSONWritingOptions.PrettyPrinted, error: &error)
if error == nil {
    "Raw Data: \(apl_json_out)"
    let json_str = NSString(data: apl_json_out!, encoding: NSUTF8StringEncoding)
    "String: \(json_str)"
} else {
    "Error: \(error)"
}

/*:

#### SwiftyJSON

Note how again, SwiftyJSON API is more concise.

*/

let sj_json_out = JSON(obj_to_dump)
"Raw Data: \(sj_json_out.rawData()!)"
"String: \(sj_json_out.rawString()!)"
