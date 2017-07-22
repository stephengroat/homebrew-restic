require 'securerandom'

class Restic < Formula
  desc "restic backup program"
  homepage "https://restic.github.io/"

  url "https://github.com/restic/restic/releases/download/v0.7.1/restic-0.7.1.tar.gz"
  sha256 "81efde662c34225b5705f3d72daa1f6278455c2b8f786224d7a1ecca0b14efca"
  version "0.7.1"

  head "https://github.com/restic/restic.git"

  depends_on 'go'

  def install
    system "make"
    system "mkdir #{prefix}/bin"
    system "cp restic #{prefix}/bin"
  end

  test do
    test_repo_name = SecureRandom.hex
    test_repo_path = "/tmp/restic-#{test_repo_name}"

    system "RESTIC_PASSWORD=foo restic -r #{test_repo_path} init"
    system "RESTIC_PASSWORD=foo restic -r #{test_repo_path} backup #{$0}"

    snapshot = `RESTIC_PASSWORD=foo restic -r #{test_repo_path} snapshots | tail -n+3 | head -n1 | awk '{print $1}'`
    snapshot.chomp!

    system "RESTIC_PASSWORD=foo restic -r #{test_repo_path} restore #{snapshot} -t #{test_repo_path}-restore"
    system "diff -q #{$0} #{test_repo_path}-restore/#{File.basename($0)}"

    system "rm -rf #{test_repo_path}"
  end
end
