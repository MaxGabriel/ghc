module GHC (
    array, base, binary, bytestring, cabal, compiler, containers, compareSizes,
    deepseq, deriveConstants, directory, dllSplit, filepath, genapply,
    genprimopcode, ghc, ghcBoot, ghcCabal, ghci, ghcPkg, ghcPrim, ghcPwd, ghcTags,
    haddock, haskeline, hsc2hs, hoopl, hp2ps, hpc, hpcBin, integerGmp,
    integerSimple, iservBin, mkUserGuidePart, parallel, pretty, primitive, process,
    runghc, stm, templateHaskell, terminfo, time, transformers, unix, win32, xhtml,

    defaultKnownPackages, defaultTargetDirectory, defaultProgramPath
    ) where

import Base
import Package
import Stage

-- These are all GHC packages we know about. Build rules will be generated for
-- all of them. However, not all of these packages will be built. For example,
-- package 'win32' is built only on Windows.
-- Settings/Packages.hs defines default conditions for building each package,
-- which can be overridden in Settings/User.hs.
defaultKnownPackages :: [Package]
defaultKnownPackages =
    [ array, base, binary, bytestring, cabal, compiler, containers, compareSizes
    , deepseq, deriveConstants, directory, dllSplit, filepath, genapply
    , genprimopcode, ghc, ghcBoot, ghcCabal, ghci, ghcPkg, ghcPrim
    , ghcPwd, ghcTags, haddock, haskeline, hsc2hs, hoopl, hp2ps, hpc, hpcBin
    , integerGmp, integerSimple, iservBin, mkUserGuidePart, parallel, pretty
    , primitive , process, runghc, stm, templateHaskell, terminfo, time
    , transformers, unix, win32, xhtml ]

-- Package definitions (see Package.hs)
array, base, binary, bytestring, cabal, compiler, containers, compareSizes,
    deepseq, deriveConstants, directory, dllSplit, filepath, genapply,
    genprimopcode, ghc, ghcBoot, ghcCabal, ghci, ghcPkg, ghcPrim, ghcPwd,
    ghcTags, haddock, haskeline, hsc2hs, hoopl, hp2ps, hpc, hpcBin, integerGmp,
    integerSimple, iservBin, mkUserGuidePart, parallel, pretty, primitive, process,
    runghc, stm, templateHaskell, terminfo, time, transformers, unix, win32, xhtml :: Package

array           = library  "array"
base            = library  "base"
binary          = library  "binary"
bytestring      = library  "bytestring"
cabal           = library  "Cabal"          `setPath` "libraries/Cabal/Cabal"
compiler        = topLevel "ghc"            `setPath` "compiler"
containers      = library  "containers"
compareSizes    = utility  "compareSizes"   `setPath` "utils/compare_sizes"
deepseq         = library  "deepseq"
deriveConstants = utility  "deriveConstants"
directory       = library  "directory"
dllSplit        = utility  "dll-split"
filepath        = library  "filepath"
genapply        = utility  "genapply"
genprimopcode   = utility  "genprimopcode"
ghc             = topLevel "ghc-bin"        `setPath` "ghc"
ghcBoot         = library  "ghc-boot"
ghcCabal        = utility  "ghc-cabal"
ghci            = library  "ghci"
ghcPkg          = utility  "ghc-pkg"
ghcPrim         = library  "ghc-prim"
ghcPwd          = utility  "ghc-pwd"
ghcTags         = utility  "ghctags"
haddock         = utility  "haddock"
haskeline       = library  "haskeline"
hsc2hs          = utility  "hsc2hs"
hoopl           = library  "hoopl"
hp2ps           = utility  "hp2ps"
hpc             = library  "hpc"
hpcBin          = utility  "hpc-bin"        `setPath` "utils/hpc"
integerGmp      = library  "integer-gmp"
integerSimple   = library  "integer-simple"
iservBin        = topLevel "iserv-bin"      `setPath` "iserv"
mkUserGuidePart = utility  "mkUserGuidePart"
parallel        = library  "parallel"
pretty          = library  "pretty"
primitive       = library  "primitive"
process         = library  "process"
runghc          = utility  "runghc"
stm             = library  "stm"
templateHaskell = library  "template-haskell"
terminfo        = library  "terminfo"
time            = library  "time"
transformers    = library  "transformers"
unix            = library  "unix"
win32           = library  "Win32"
xhtml           = library  "xhtml"

-- TODO: The following utils are not included into the build system because
-- they seem to be unused or unrelated to the build process: chechUniques,
-- completion, count_lines, coverity, debugNGC, describe-unexpected, genargs,
-- lndir, mkdirhier, testremove, touchy, unlit, vagrant

-- GHC build results will be placed into target directories with the following
-- typical structure:
-- * build/          : contains compiled object code
-- * doc/            : produced by haddock
-- * package-data.mk : contains output of ghc-cabal applied to pkgCabal
-- TODO: simplify to just 'show stage'?
-- TODO: we divert from the previous convention for ghc-cabal and ghc-pkg,
-- which used to store stage 0 build results in 'dist' folder
-- On top of that, mkUserGuidePart used dist for stage 1 for some reason.
defaultTargetDirectory :: Stage -> Package -> FilePath
defaultTargetDirectory stage pkg
    | pkg   == compiler = "stage" ++ show (fromEnum stage + 1)
    | pkg   == ghc      = "stage" ++ show (fromEnum stage + 1)
    | stage == Stage0   = "dist-boot"
    | otherwise         = "dist-install"

defaultProgramPath :: Stage -> Package -> Maybe FilePath
defaultProgramPath stage pkg
    | pkg == compareSizes    = program $ pkgName pkg
    | pkg == deriveConstants = program $ pkgName pkg
    | pkg == dllSplit        = program $ pkgName pkg
    | pkg == genapply        = program $ pkgName pkg
    | pkg == genprimopcode   = program $ pkgName pkg
    | pkg == ghc             = program $ "ghc-stage" ++ show (fromEnum stage + 1)
    | pkg == ghcCabal        = program $ pkgName pkg
    | pkg == ghcPkg          = program $ pkgName pkg
    | pkg == ghcPwd          = program $ pkgName pkg
    | pkg == ghcTags         = program $ pkgName pkg
    | pkg == haddock         = program $ pkgName pkg
    | pkg == hsc2hs          = program $ pkgName pkg
    | pkg == hp2ps           = program $ pkgName pkg
    | pkg == hpcBin          = program $ pkgName pkg
    | pkg == mkUserGuidePart = program $ pkgName pkg
    | pkg == runghc          = program $ pkgName pkg
    | otherwise              = Nothing
  where
    program name = Just $ pkgPath pkg -/- defaultTargetDirectory stage pkg
                                      -/- "build/tmp" -/- name <.> exe
