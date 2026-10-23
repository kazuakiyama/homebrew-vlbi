class Sched < Formula
  desc "A program for planning and scheduling Very Long Baseline Interferometry (VLBI) observations"
  homepage "https://www.aoc.nrao.edu/software/sched/index.html"
  url "ftp://ftp.aoc.nrao.edu/pub/sched/sched_11.8/sched_11.8.tar.gz"
  version "11.8"
  sha256 "d512af114da189accfb25a626737ae5efd065fd9cf7e21bfff838efc91feeea1"
  revision 2

  # GCC 16 no longer has Intel macOS bottles; GCC 15 still does.
  on_intel do
    depends_on "gcc@15"
  end

  on_arm do
    depends_on "gcc"
  end
  depends_on "libx11"
  depends_on "kazuakiyama/vlbi/pgplot"

  fails_with :clang do
    cause "Miscompilation resulting in segfault on queries"
  end

  def install
    fc = if Hardware::CPU.intel?
      Formula["gcc@15"].opt_bin/"gfortran-15"
    else
      Formula["gcc"].opt_bin/"gfortran"
    end
    ENV["FC"] = fc.to_s
    ENV.fortran

    # GCC 16 adds a Fortran SPLIT intrinsic. Use SCHED's JPL routine instead.
    inreplace "src/Jpl/state.f", "      SAVE\n", "      SAVE\n      EXTERNAL SPLIT\n"
    ENV.deparallelize

    pgplotdir = "#{HOMEBREW_PREFIX}/lib"
    pgplotlib = "-L#{pgplotdir} -lpgplot -lX11 -lpng"
    xld = "-L#{HOMEBREW_PREFIX}/lib -lX11"
    cflags = "-Wall -Wno-int-conversion"
    fflags = "-Wall -fimplicit-none -fno-backslash -fallow-argument-mismatch"
    
    on_intel do
      system "cd src; make CC='#{ENV.cc}' FC='#{fc}' CFLAGS='-Dintel_osx #{cflags}' FFLAGS='-Dintel_osx #{fflags}' LPGPLOT='#{pgplotdir}' LDPGPLOT='#{pgplotlib}' XLD='#{xld}'"
    end

    on_arm do
      system "cd src; make CC='#{ENV.cc}' FC='#{fc}' CFLAGS='-Darm_osx #{cflags}' FFLAGS='-Darm_osx #{fflags}' LPGPLOT='#{pgplotdir}' LDPGPLOT='#{pgplotlib}' XLD='#{xld}'"
    end
    
    system "cd bin/linux64gf; ln -s ./sched nsched"

    bin.install ["bin/linux64gf/sched", "bin/linux64gf/nsched", "bin/schclean", "bin/crd_noneg"]
    prefix.install Dir["README*", "*notes.txt", "catalogs", "doc", "examples", "setups"]
  end

  def caveats
    <<~EOF
      As zsh has `sched` as a default command, users may not run SCHED just by typing `sched` in their shells. 
      For an ad-hoc mitigation, this homebrew formula will add an alias `nsched` (for "N"RAO SCHED) to the sched command so that users don't have to type the full path in zsh.
      
      The additional files (doc, notes, examples, setting files, etc) will be installed into the directory given by `brew --prefix sched`.
      
      Don't forget to add paths for PGPLOT and SCHED before using SCHED.
      For instance, you can add the following lines to your ~/.bash_profile or ~/.zshrc file
      (and remember to source the file to update your current session):
      
      PGPLOT_DIR=`brew --prefix pgplot`/lib
      if [ -e $PGPLOT_DIR ]; then
        export PGPLOT_DIR=$PGPLOT_DIR
        export PGPLOT_DEV=/xwin       # This is up to your preference. /xserve might be your choise.
        export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$PGPLOT_DIR
      fi

      SCHED_DIR=`brew --prefix sched`
      if [ -e $SCHED_DIR ]; then
        export SCHED=$SCHED_DIR
      fi
    EOF
  end

  test do
    ENV["SCHED"] = prefix.to_s
    ENV["PGPLOT_DIR"] = Formula["kazuakiyama/vlbi/pgplot"].opt_share.to_s
    ENV["PGPLOT_DEV"] = "/null"

    # Fortran STOP may return success on error, so verify the generated schedule.
    output = pipe_output("#{bin}/sched", (prefix/"examples/manual_1.key").read, 0)
    assert_match "Finished", output
    assert_match "SUMMARY FILE FOR PROJECT: BE001", (testpath/"be001.sum").read
    vex = (testpath/"be001.vex").read
    assert_match "VEX_rev = 1.5;", vex
    assert_match "exper_name = BE001;", vex
    assert_match "$SCHED;", vex
    assert_match(/^scan \S+;/, vex)
    assert_predicate bin/"nsched", :executable?
  end
end
