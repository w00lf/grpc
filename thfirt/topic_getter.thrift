namespace rb TopicThriftExample

include "query_topic.thrift"
include "topic.thrift"

	service TopicGetter {

		topic.Topic get_topic(1:query_topic.TopicQuery query)
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


