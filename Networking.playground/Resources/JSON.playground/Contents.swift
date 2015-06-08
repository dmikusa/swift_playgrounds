
import SwiftyJSON

//
// JSON INPUT
//

// load test.json
let path = NSBundle.mainBundle().pathForResource("test", ofType: "json")

// parse json
let json_in = JSON(data: NSData(contentsOfFile: path!)!)

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
// JSON OUTPUT
//

let obj = ["name":"Jack", "age": 25, "list":["a","b","c",["what":"this"]]]
let json_out = JSON(obj)
println("Out: \(json_out.rawString())")