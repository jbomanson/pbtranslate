# Copyright 2016 Jori Bomanson.
#
#   This file is a modified version of src/compiler/crystal/config.cr
#   from the Crystal language.

# Copyright 2012-2016 Manas Technology Solutions.
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

module PBTranslate::Config
  def self.description
    version, sha = version_and_sha
    String.build do |io|
      io << "PBTranslate"
      io << " " << version if version
      io << " [" << sha << "]" if sha
      io << " (" << date << ")"
    end
  end

  @@version_and_sha : {String?, String?}?

  def self.version_and_sha
    @@version_and_sha ||= compute_version_and_sha
  end

  private def self.compute_version_and_sha
    # Set explicitly: 0.0.0, ci, HEAD, whatever
    config_version = {{env("PBTRANSLATE_CONFIG_VERSION")}}
    return {config_version, nil} if config_version

    git_version = {{`(git describe --tags --long --always 2>/dev/null) || true`.stringify.chomp}}

    # Either:
    # Failed git and no explicit version set: ""
    # Shallow clone with no tag in reach: abcd123
    return {nil, git_version} unless git_version.includes? '-'

    # On release: 0.0.0-0-gabcd123
    # Ahead of last release: 0.0.0-42-gabcd123
    tag, commits, sha = git_version.split("-")
    sha = sha[1..-1]                                # Strip g
    tag = "#{tag}+#{commits}" unless commits == "0" # Reappend commits since release unless we hit it exactly

    {tag, sha}
  end

  def self.date
    {{ `date "+%Y-%m-%d"`.stringify.chomp }}
  end
end
