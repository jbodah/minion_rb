
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "minion/version"

Gem::Specification.new do |spec|
  spec.name          = "minion_rb"
  spec.version       = Minion::VERSION
  spec.authors       = ["Josh Bodah"]
  spec.email         = ["joshuabodah@gmail.com"]

  spec.summary       = %q{a dsl for proxying http traffic}
  spec.homepage      = "https://github.com/jbodah/minion_rb"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"

  spec.add_dependency "evil-proxy", "~> 0.2"
end
