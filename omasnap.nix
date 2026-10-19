{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ninja,
  pkg-config,
  wayland-scanner,
  wayland-protocols,
  wayland,
  libdeflate,
  kdePackages,
  makeWrapper,
  hyprland,
  wl-clipboard,
  xdg-utils,
  tesseract,
}:

# Native Wayland screenshot + annotation overlay (Hyprland). https://github.com/omacom/omasnap
stdenv.mkDerivation {
  pname = "omasnap";
  version = "1.21.0";

  src = fetchFromGitHub {
    owner = "omacom";
    repo = "omasnap";
    rev = "6771b19de8bcead2b17c16b49f1a8a97445dd8e3";
    hash = "sha256-bK2fOB8P79IBlcAAeKz7l0hOXjKzTqwApidEWWwN7HY=";
  };

  # CMakeLists.txt hardcodes the FHS protocol path.
  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail /usr/share/wayland-protocols ${wayland-protocols}/share/wayland-protocols
  '';

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    wayland-scanner
    kdePackages.wrapQtAppsHook
    makeWrapper
  ];

  buildInputs = [
    kdePackages.qtbase
    kdePackages.layer-shell-qt
    wayland
    wayland-protocols
    libdeflate
  ];

  # Smoke tests need a display (QT_QPA_PLATFORM=offscreen); skip them in the sandbox.
  cmakeFlags = [ (lib.cmakeBool "BUILD_TESTING" false) ];

  # Runtime commands omasnap shells out to.
  qtWrapperArgs = [
    "--prefix PATH : ${
      lib.makeBinPath [
        hyprland
        wl-clipboard
        xdg-utils
        tesseract
      ]
    }"
  ];

  meta = {
    description = "Wayland screenshot and annotation overlay for Hyprland";
    homepage = "https://github.com/omacom/omasnap";
    license = lib.licenses.mit;
    mainProgram = "omasnap";
    platforms = lib.platforms.linux;
  };
}
