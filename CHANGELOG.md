## 0.5.0

* Support multiple requests #24
* Find the RpcServer actually hosting the reflection service- #23
* Return error_response for not-found and invalid reflection requests #21
* Fix file_containing_extension to look up by extendee type, not extension name #20
* Fix symbol resolution for services/methods defined without a package #19
* Fix symbol lookup cache for non-dataset symbols #18

## 0.4.0

* Support `file_containing_extension` request #14
* Support message name requests #12

## 0.3.0

* Support `file_by_filename` #9
* Update support for `gooogle-protobuf` to only `>= 4.31.0` #9

## 0.2.0

* Support V1 alpha #7 [dorner]
* Don't include services that are not being handled #7 [dorner]
