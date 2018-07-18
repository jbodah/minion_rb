# minion_rb

a dsl for proxying http traffic

## Installation

```rb
gem install minion_rb
```

## Usage

`minion_rb` is built on top of [evil-proxy](https://github.com/bbtfr/evil-proxy) so you
must install the CA cert in your browser [as described here](https://github.com/bbtfr/evil-proxy#usage)
to function properly with HTTPS.

Once you've done that you'll need to write a driver script for the proxy.
Below is an example where I replace `fast.wistia.com/assets/app/stats-<SHA>.js` with
a local file by querying webpack-dev-server:

```rb
# proxy.rb
require 'minion'

Minion.proxy do
  host "fast.wistia.com" do
    get /stats-[a-z0-9]*\.js$/ do |req, res|
      require 'json'
      manifest = JSON.parse(`curl 0.0.0.0:3001/assets/manifest.json`)
      asset = manifest["assetsByChunkName"]["app/stats"]
      res.body = `curl https://example2.wistia.dev/assets/#{asset}`
    end
  end
end.start
```

Then run it with Ruby and hit your endpoint:

```
ruby proxy.rb
```
