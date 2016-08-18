# vi: ft=c

namespace rb TopicThriftExample

struct Widget {
  1:i32 id, (1..10_000)
  2:string type, (6 ascii)
  3:string data, (1000 utf8)
  4:i32 created_at, (unix, c)
  5:i32 updated_at, (unix, c)
  6:i32 position (1..100)
}
