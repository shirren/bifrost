# Major.Minor.Patch version numbering
module Bifrost
  # The major version of Bifrost, updated only for major changes that are
  # likely to require modification to Filmpond apps.
  MAJOR_VERSION = 0

  # The minor version of Bifrost, updated for new feature releases.
  MINOR_VERSION = 1

  # The patch version of Bifrost, updated only for bug fixes from the last
  # feature release.
  PATCH_VERSION = 4

  # The full version as a string.
  VERSION = "#{MAJOR_VERSION}.#{MINOR_VERSION}.#{PATCH_VERSION}".freeze
end
