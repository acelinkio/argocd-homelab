# phantomtest
Project used for testing ForwardAuth based upon Zoriya's blog.  https://github.com/zoriya/blog/tree/master/content/blogs/phantom-token


## Build notes
```sh
git clone https://github.com/zoriya/blog.git
cd blog/content/blogs/phantom-token
cd api
# zot.bitey.life/phantomtest-api:1.0.0
docker buildx build . --platform linux/amd64,linux/arm64 --tag zot.bitey.life/phantomtest-api:1.0.0 --push
# zot.bitey.life/phantomtest-auth:1.0.0
cd ../auth
docker buildx build . --platform linux/amd64,linux/arm64 --tag zot.bitey.life/phantomtest-auth:1.0.0 --push
```