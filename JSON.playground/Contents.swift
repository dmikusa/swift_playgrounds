import SwiftyJSON

//
// JSON INPUT
//

// load a small JSON object
let small_json_data = "{\"a\": 100, \"b\": 200}".dataUsingEncoding(NSUTF8StringEncoding)!

// load a big JSON object
let path = NSBundle.mainBundle().pathForResource("test", ofType: "json")
let big_json_data = NSData(contentsOfFile: path!)

//
// built-in
//

var error: NSError?
let small_json_obj: AnyObject? = NSJSONSerialization.JSONObjectWithData(small_json_data, options: nil, error: &error)

if error != nil {
    println("Error: \(error)")
}

if let small_json_dict = small_json_obj as? Dictionary<String, Int> {
    let a = small_json_dict["a"]!
    let b = small_json_dict["b"]!
    println("a: \(a)  b: \(b)")
} else {
    println("Couldn't convert to Dictionary<String, Int>")
}

//
// SwiftyJSON
//

let small_json = JSON(data: small_json_data)
let a = small_json["a"].int
let b = small_json["b"].int
println("a: \(a)  b: \(b)")


//
// Complicated JSON parsing
//

//
// built-in
//

// too much effort

//
// SwiftyJSON
//

// parse json
let json_in = JSON(data: big_json_data!)

println("We've read in \(json_in.count) items")

// test.json is a big list, grab the first item
let item1 = json_in[0]

// print some of the keys
for (key,val) in item1 {
    if key == "tags" {
        for (_: String, v: JSON) in val {
            println(v)
        }
    } else if key == "friends" {
        for (i: String, friend: JSON) in val {
            let id = friend["id"]
            let name = friend["name"]
            println("   \(id) -> \(name)")
        }
        
    } else {
        println("\(key): \(val)")
    }
}


//
// Converting to JSON
//

let obj_to_dump = ["name":"Jack", "age": 25, "list":["a","b","c",["what":"this"]]]


//
// built-in
//
let apl_json_out = NSJSONSerialization.dataWithJSONObject(obj_to_dump, options: NSJSONWritingOptions.PrettyPrinted, error: &error)
if error == nil {
    println("Raw Data: \(apl_json_out)")
    let json_str = NSString(data: apl_json_out!, encoding: NSUTF8StringEncoding)
    println("String: \(json_str)")
} else {
    println("Error: \(error)")
}

//
// Swifty JSON
//

let sj_json_out = JSON(obj_to_dump)
println("Raw Data: \(sj_json_out.rawData()!)")
println("String: \(sj_json_out.rawString()!)")
