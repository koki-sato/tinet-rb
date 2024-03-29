lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "tinet/version"

Gem::Specification.new do |spec|
  spec.name          = "tinet"
  spec.version       = Tinet::VERSION
  spec.authors       = ["koki-sato"]
  spec.email         = ["admin@koki-sato.com"]

  spec.summary       = "Ruby implement of slankdev/tinet."
  spec.homepage      = "https://github.com/koki-sato/tinet-rb"
  spec.license       = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/koki-sato/tinet-rb"
  spec.metadata["changelog_uri"] = "https://github.com/koki-sato/tinet-rb/blob/master/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|sample|features)/}) }
  end
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "thor"
  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
