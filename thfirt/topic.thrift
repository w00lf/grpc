# vi: ft=c

include "widget.thrift"

namespace rb TopicThriftExample
	struct Topic {
		1:string alternative_headline, 200 utf8 cyrilic
    2:string announce, 400 utf8 cyrilic
    4:string content_type, 6 asci
    6:i32 dispatched_at, unix, sec
    7:string headline, (50) 200 utf8 cyrilic
    8:i32 id, (1..10_000)
    9:bool is_visible,
    12:bool partner_related,
    13:string preview_token, (12 asci)
    15:i32 published_at, (unix c)
    19:list<widget.Widget> widgets (5)
	}

// Thrift types:

// bool
// byte
// i16
// i32
// i64
// double
// string

// Const
// enums
// Struct (there''s also a special Struct - Union)

// Containers:
// 	list
// 	set
// 	map

/** Structs are the basic complex data structures. They are comprised of fields
	   * which each have an integer identifier, a type, a symbolic name, and an
	   * optional default value. */

// json type - for now i send it in string with deserialization on client side
// It could be done through Struct, but it must be normalized for it

// date-time types - send in milliseconds (i32). Test it whever 32 or 16 is better suitable
// do not forget to convert times on client side

// byte-types - are stubs for complex types later to be substituted with
// actual implementations

// tags are temporarily implemented as an array of strings


