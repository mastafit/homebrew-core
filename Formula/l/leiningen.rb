class Leiningen < Formula
  desc "Build tool for Clojure"
  homepage "https://github.com/technomancy/leiningen"
  url "https://github.com/technomancy/leiningen/archive/refs/tags/2.11.1.tar.gz"
  sha256 "cae3bbb9e5f07ff518b9b35ecfe070066ea074f2cb15ffb0a73ad7fe2a2683cf"
  license "EPL-1.0"
  head "https://github.com/technomancy/leiningen.git", branch: "master"

  bottle do
    sha256 cellar: :any_skip_relocation, all: "31cb72b3bc56b716992ecea80b63189554d533669d837220c179192f10919bc3"
  end

  depends_on "openjdk"

  resource "jar" do
    url "https://github.com/technomancy/leiningen/releases/download/2.11.1/leiningen-2.11.1-standalone.jar"
    sha256 "47d3cd3d436433c59662fb54c5f3c8d87dcf6e8249421b362b38ec3710a3d4f9"
  end

  def install
    libexec.install resource("jar")
    jar = "leiningen-#{version}-standalone.jar"

    # bin/lein autoinstalls and autoupdates, which doesn't work too well for us
    inreplace "bin/lein-pkg" do |s|
      s.change_make_var! "LEIN_JAR", libexec/jar
    end

    (libexec/"bin").install "bin/lein-pkg" => "lein"
    (libexec/"bin/lein").chmod 0755
    (bin/"lein").write_env_script libexec/"bin/lein", Language::Java.overridable_java_home_env
    bash_completion.install "bash_completion.bash" => "lein-completion.bash"
    zsh_completion.install "zsh_completion.zsh" => "_lein"
  end

  def caveats
    <<~EOS
      Dependencies will be installed to:
        $HOME/.m2/repository
      To play around with Clojure run `lein repl` or `lein help`.
    EOS
  end

  test do
    (testpath/"project.clj").write <<~EOS
      (defproject brew-test "1.0"
        :dependencies [[org.clojure/clojure "1.10.3"]])
    EOS
    (testpath/"src/brew_test/core.clj").write <<~EOS
      (ns brew-test.core)
      (defn adds-two
        "I add two to a number"
        [x]
        (+ x 2))
    EOS
    (testpath/"test/brew_test/core_test.clj").write <<~EOS
      (ns brew-test.core-test
        (:require [clojure.test :refer :all]
                  [brew-test.core :as t]))
      (deftest canary-test
        (testing "adds-two yields 4 for input of 2"
          (is (= 4 (t/adds-two 2)))))
    EOS
    system "#{bin}/lein", "test"
  end
end
