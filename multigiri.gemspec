#!/usr/bin/env gem build
# encoding: utf-8

# Run ./multigiri.gemspec or gem build multigiri.gemspec
# NOTE: we can't use require_relative because when we run gem build, it use eval for executing this file
require File.expand_path("../lib/multigiri/version", __FILE__)
require "base64"

Gem::Specification.new do |s|
  s.name = "multigiri"
  s.version = Multigiri::VERSION
  s.authors = ["Jakub Stastny aka Botanicus"]
  s.homepage = "http://github.com/botanicus/multigiri"
  s.summary = "" # TODO: summary
  s.description = "" # TODO: long description
  s.cert_chain = nil
  s.email = Base64.decode64("c3Rhc3RueUAxMDFpZGVhcy5jeg==\n")
  s.has_rdoc = true

  # files
  s.files = `git ls-files`.split("\n")

  s.executables = Dir["bin/*"].map(&File.method(:basename))
  s.default_executable = "multigiri"
  s.require_paths = ["lib"]

  # Ruby version
  s.required_ruby_version = ::Gem::Requirement.new(">= 1.9")

  # runtime dependencies
  s.add_dependency "nokogiri"

  begin
    require "changelog"
  rescue LoadError
    warn "You have to have changelog gem installed for post install message"
  else
    s.post_install_message = CHANGELOG.new.version_changes
  end

  # RubyForge
  s.rubyforge_project = "multigiri"
end
